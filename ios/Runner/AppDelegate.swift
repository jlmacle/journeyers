import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate 
{
    
    // Class-level constants
    private let CHANNEL = "dev.journeyers/iossaf"
    private let KEY_BOOKMARK = "dev.journeyers.folderBookmarkiOS"
    private let KEY_PATH = "flutter.applicationFolderPath" // Unique for binary data
    private let KEY_URI = "flutter.applicationFolderPath"
    private let DEBUG: Bool = true
    
    // Stores the result callback for Flutter communication
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let safChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        safChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch call.method 
            {
                case "openDirectory":
                    if DEBUG {print("openDirectory")}
                    self.pendingResult = result
                    self.showFolderPicker()
                    
                case "getStoredDirectory":
                if DEBUG {print("getStoredDirectory")}
                    if let bookmarkData = UserDefaults.standard.data(forKey: self.KEY_URI) {
                        var isStale = false
                        let url = try? URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                        result(url?.path)
                    } else {
                        result(nil)
                    }

                case "listFiles":
                    if DEBUG {print("listFiles")}
                    // Returns a list of file names, or an empty list if none found
                    if let files = self.listFilesFromStoredFolder() {
                        result(files)
                    } else {
                        result([String]()) 
                    }
                    
                case "saveFile":
                    if DEBUG {print("saveFile")}
                    let args = call.arguments as? [String: Any]
                    let fileName = args?["fileName"] as? String ?? "file.csv"
                    let content = (args?["content"] as? FlutterStandardTypedData)?.data ?? Data()
                    if DEBUG {print("fileName: \(fileName)")}
                    if DEBUG {print("content: \(content)")}
                    result(self.saveToStoredFolder(fileName: fileName, content: content))
                    
                case "readFileContent":
                    if DEBUG {print("readFileContent")}
                    let args = call.arguments as? [String: Any]
                    let fileName = args?["fileName"] as? String ?? ""
                    // Explicitly handling the optional String? returned by the helper
                    if let content = self.readFileFromStoredFolder(fileName: fileName) {
                        result(content)
                    } else {
                        result(FlutterError(code: "READ_FAIL", message: "File not found", details: nil))
                    }

                case "deleteFile":
                    if DEBUG {print("deleteFile")}
                    let args = call.arguments as? [String: Any]
                    let fileName = args?["fileName"] as? String ?? ""
                    result(self.deleteFromStoredFolder(fileName: fileName))
                    
                default:
                    if DEBUG {print("FlutterMethodNotImplemented")}
                    result(FlutterMethodNotImplemented)
                }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Folder Operations

    private func showFolderPicker() {
        if DEBUG {print("showFolderPicker")}
        // UI for folder selection
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        window?.rootViewController?.present(documentPicker, animated: true)
    }

    private func listFilesFromStoredFolder() -> [String]? 
    {
        if DEBUG {print("listFilesFromStoredFolder")}
        // Once accessFolder successfully gains permission, 
        // it passes the directory's location (folderUrl) into the block.
        return accessFolder 
        { (folderUrl: URL) -> [String] in
            let fileManager = FileManager.default
            do 
            {
                // Gets all items in the directory
                let items = try fileManager.contentsOfDirectory(at: folderUrl, 
                                                                includingPropertiesForKeys: [.isDirectoryKey], 
                                                                options: .skipsHiddenFiles)
                
                // Filters out items that are directories
                let fileNames = items.filter { url in
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    return !(resourceValues?.isDirectory ?? false)
                }.map { $0.lastPathComponent }
                
                return fileNames
            } 
            catch 
            {
                print("iOS Listing Error: \(error)")
                return []
            }
        }
    }

    private func saveToStoredFolder(fileName: String, content: Data) -> Bool 
    {
        if DEBUG {print("saveToStoredFolder")}
        return accessFolder { folderUrl in
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            do 
            {
                try content.write(to: fileUrl)
                if DEBUG {print("saveToStoredFolder: success: content: \(content)")}
                return true
            } 
            catch 
            {
                print("iOS saveToStoredFolder Error: \(error)")
                return false
            }
        } ?? false
    }

    private func readFileFromStoredFolder(fileName: String) -> String? {
        if DEBUG {print("readFileFromStoredFolder")}
        // Correctly typed closure to resolve 'nil' compatibility error
        return accessFolder { (folderUrl: URL) -> String? in
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            return try? String(contentsOf: fileUrl, encoding: .utf8)
        }
    }

    private func deleteFromStoredFolder(fileName: String) -> Bool {
        if DEBUG {print("deleteFromStoredFolder")}
        return accessFolder { (folderUrl: URL) -> Bool in
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            let fileManager = FileManager.default
            
            // Check if file exists before attempting deletion
            if fileManager.fileExists(atPath: fileUrl.path) {
                do {
                    try fileManager.removeItem(at: fileUrl)
                    return true
                } catch {
                    print("iOS Deletion Error: \(error)")
                    return false
                }
            }
            return false
        } ?? false
    }

    /// Helper to resolve the bookmark and manage security-scoped access.
    /// Uses generics (T) to work for both saving (Bool) and reading (String).
    private func accessFolder<T>(action: (URL) -> T?) -> T? {
        if DEBUG {print("accessFolder")}
        guard let bookmarkData = UserDefaults.standard.data(forKey: KEY_BOOKMARK) else 
        { 
        print("Issue: No binary bookmark found for key \(KEY_BOOKMARK)")
        return nil 
    }
        var isStale = false
        do {
            // Options is empty set [] for iOS security-scoped bookmarks
            let url = try URL(resolvingBookmarkData: bookmarkData, 
                               options: [], 
                               relativeTo: nil, 
                               bookmarkDataIsStale: &isStale)
            
            // Wraps file access in start/stop calls required by iOS sandbox
            if url.startAccessingSecurityScopedResource() {
                print("Access Granted to: \(url.path)")
                defer { url.stopAccessingSecurityScopedResource() }
                return action(url)
            }
            else 
            {
                print("Access denied to: \(url.path)") // This is likely what is happening
            }
        } catch {
            print("Error resolving bookmark: \(error)")
        }
        return nil
    }
}

// MARK: - UIDocumentPickerDelegate
extension AppDelegate: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) 
    {
        if DEBUG {print("documentPicker")}
        guard let selectedUrl = urls.first else {
            pendingResult?(nil)
            return
        }

        do {
            // 1. Creates the security bookmark for persistent access (Internal Use)
            let bookmarkData = try selectedUrl.bookmarkData(options: .suitableForBookmarkFile, 
                                                           includingResourceValuesForKeys: nil, 
                                                           relativeTo: nil)
            // Saving the binary data to the bookmark key
            UserDefaults.standard.set(bookmarkData, forKey: KEY_BOOKMARK)
        
            // Save the STRING path for Flutter
            UserDefaults.standard.set(selectedUrl.path, forKey: KEY_PATH)
        
            pendingResult?(selectedUrl.path)
        } catch {
            pendingResult?(FlutterError(code: "BOOKMARK_ERR", message: error.localizedDescription, details: nil))
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if DEBUG {print("documentPickerWasCancelled")}
        pendingResult?(nil)
    }
}