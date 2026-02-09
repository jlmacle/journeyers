import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // Class-level constants to resolve "Cannot find in scope" errors
    private let CHANNEL = "dev.journeyers/iossaf"
    private let KEY_URI = "flutter.applicationFolderPath"
    
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
            
            switch call.method {
            case "openDirectory":
                self.pendingResult = result
                self.showFolderPicker()
                
            case "getStoredDirectory":
                if let bookmarkData = UserDefaults.standard.data(forKey: self.KEY_URI) {
                    var isStale = false
                    let url = try? URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                    result(url?.path)
                } else {
                    result(nil)
                }
                
            case "saveFile":
                let args = call.arguments as? [String: Any]
                let fileName = args?["fileName"] as? String ?? "file.csv"
                let content = (args?["content"] as? FlutterStandardTypedData)?.data ?? Data()
                result(self.saveToStoredFolder(fileName: fileName, content: content))
                
            case "readFileContent":
                let args = call.arguments as? [String: Any]
                let fileName = args?["fileName"] as? String ?? ""
                // Explicitly handling the optional String? returned by the helper
                if let content = self.readFileFromStoredFolder(fileName: fileName) {
                    result(content)
                } else {
                    result(FlutterError(code: "READ_FAIL", message: "File not found", details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Folder Operations

    private func showFolderPicker() {
        // UI for folder selection
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        window?.rootViewController?.present(documentPicker, animated: true)
    }

    private func saveToStoredFolder(fileName: String, content: Data) -> Bool {
        return accessFolder { folderUrl in
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            do {
                try content.write(to: fileUrl)
                return true
            } catch {
                return false
            }
        } ?? false
    }

    private func readFileFromStoredFolder(fileName: String) -> String? {
        // Correctly typed closure to resolve 'nil' compatibility error
        return accessFolder { (folderUrl: URL) -> String? in
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            return try? String(contentsOf: fileUrl, encoding: .utf8)
        }
    }

    /// Helper to resolve the bookmark and manage security-scoped access.
    /// Uses generics (T) to work for both saving (Bool) and reading (String).
    private func accessFolder<T>(action: (URL) -> T?) -> T? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: KEY_URI) else { return nil }
        var isStale = false
        do {
            // Options is empty set [] for iOS security-scoped bookmarks
            let url = try URL(resolvingBookmarkData: bookmarkData, 
                               options: [], 
                               relativeTo: nil, 
                               bookmarkDataIsStale: &isStale)
            
            // Wraps file access in start/stop calls required by iOS sandbox
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                return action(url)
            }
        } catch {
            print("Error resolving bookmark: \(error)")
        }
        return nil
    }
}

// MARK: - UIDocumentPickerDelegate
extension AppDelegate: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else {
            pendingResult?(nil)
            return
        }

        do {
            // Persistence: bookmark allows folder access after app restarts
            let bookmarkData = try selectedUrl.bookmarkData(options: .minimalBookmark, 
                                                           includingResourceValuesForKeys: nil, 
                                                           relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: KEY_URI)
            pendingResult?(selectedUrl.path)
        } catch {
            pendingResult?(FlutterError(code: "BOOKMARK_ERR", message: error.localizedDescription, details: nil))
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pendingResult?(nil)
    }
}