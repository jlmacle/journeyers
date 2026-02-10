/**
 * MainActivity - Flutter Activity with native platform channel for file operations
 * 
 * This class extends FlutterActivity and implements a method channel bridge between Flutter
 * and native Android code for performing Storage Access Framework (SAF) operations.
 * It provides functionality to:
 * - Open and store document tree permissions
 * - Save files to designated storage folders
 * - Read files from designated storage folders
 */
package dev.journeyers

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * MainActivity - Main entry point for the Journeyers app
 * Implements Flutter method channel "dev.journeyers/saf" to handle file I/O operations
 */
class MainActivity: FlutterActivity() {
    // Method channel identifier used for communication between Flutter and native code
    private val CHANNEL = "dev.journeyers/saf"
    
    // SharedPreferences key for storing user preferences
    private val PREFS_NAME = "FlutterSharedPreferences"
    
    // SharedPreferences key for storing the application folder URI path
    private val KEY_URI = "flutter.applicationFolderPath"
    
    // Stores the result callback from a method call to be invoked after user interaction
    private var pendingResult: MethodChannel.Result? = null

    /**
     * Configures the Flutter engine and sets up the method channel handler
     * This method is called when the Flutter engine is ready for configuration
     * 
     * @param flutterEngine The FlutterEngine instance to configure
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Creates a method channel and sets up handler for incoming method calls from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Opens the system file picker for the user to select a directory
                "openDirectory" -> {
                // Stores the result callback for later use when activity result is received
                pendingResult = result 
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                startActivityForResult(intent, 100)
             }
                // Retrieves the previously stored directory URI from SharedPreferences
                "getStoredDirectory" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    result.success(prefs.getString(KEY_URI, null))
                }
                // Saves a file with the given name and content to the stored directory
                "saveFile" -> {
                    val name = call.argument<String>("fileName") ?: "file.csv"
                    val bytes = call.argument<ByteArray>("content") ?: byteArrayOf()
                    val success = saveToStoredFolder(name, bytes)
                    result.success(success)
                }
                // Reads and returns the content of a file from the stored directory
                "readFileContent" -> {
                    val fileName = call.argument<String>("fileName") ?: ""
                    val content = readFileFromStoredFolder(fileName)
                    if (content != null) result.success(content) else result.error("READ_FAIL", "File not found", null)
                }
                // deletes a file with the given name
                "deleteFile" -> {
                    val fileName = call.argument<String>("fileName") ?: ""
                    val success = deleteFromStoredFolder(fileName)
                    result.success(success)
                }
                // Handles unknown method calls
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Saves a file with the given name and content to the stored directory
     * Retrieves the directory URI from SharedPreferences and creates/writes the file
     * 
     * @param fileName The name of the file to save
     * @param content The byte array content to write to the file
     * @return true if the save operation was successful, false otherwise
     */
    private fun saveToStoredFolder(fileName: String, content: ByteArray): Boolean {
        // Retrieves stored directory URI from SharedPreferences
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val uriString = prefs.getString(KEY_URI, null) ?: return false
        val treeUri = Uri.parse(uriString)

        return try {
            // Gets the root document from the stored tree URI
            val rootDoc = DocumentFile.fromTreeUri(this, treeUri)
            // Creates a new CSV file in the directory
            val newFile = rootDoc?.createFile("text/csv", fileName)

            // Writes content to the file and returns success status
            newFile?.uri?.let { fileUri ->
                contentResolver.openOutputStream(fileUri)?.use { it.write(content) }
                true
            } ?: false
        } catch (e: Exception) { 
            // Returns false if any exception occurs during file save
            false 
        }
    }

    /**
     * Reads and returns the content of a file from the stored directory
     * Retrieves the directory URI from SharedPreferences and reads the specified file
     * 
     * @param fileName The name of the file to read
     * @return The file content as a String, or null if the file doesn't exist or an error occurs
     */
    private fun readFileFromStoredFolder(fileName: String): String? {
        // Retrieves stored directory URI from SharedPreferences
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val uriString = prefs.getString(KEY_URI, null) ?: return null
        val treeUri = Uri.parse(uriString)

        return try 
        {
            // 1. Ensures the treeUri is not null and context is valid
            treeUri?.let { uri ->
                // Gets the root DocumentFile from the tree URI
                val rootDoc = DocumentFile.fromTreeUri(this, uri)
                
                // 2. Uses safe calls or null checks for rootDoc
                val uriString: String? = rootDoc?.uri?.toString()
                
                // 3. Finding a file is an expensive operation; ensures rootDoc exists first
                // Searches for the file with the specified name in the directory
                val file = rootDoc?.findFile(fileName)

                // Debug logging to assist with troubleshooting
                println("uriString: $uriString")
                println("fileName: $fileName")
                
                // 4. Checks if the file actually exists after findFile operation
                if (file != null && file.exists()) {
                    println("File found: ${file.name}")
                } else {
                    println("File not found or fileName is incorrect")
                }
            
                // Opens input stream and reads the file content as text
                file?.uri?.let { fileUri ->
                    contentResolver.openInputStream(fileUri)?.use { inputStream ->
                        BufferedReader(InputStreamReader(inputStream)).readText()
                    }
                }
            }
        
        } catch (e: Exception) { 
            // Returns null if any exception occurs during file read
            null 
        }
    }

    private fun deleteFromStoredFolder(fileName: String): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val uriString = prefs.getString(KEY_URI, null) ?: return false
        val treeUri = Uri.parse(uriString)

        return try {
            val rootDoc = DocumentFile.fromTreeUri(this, treeUri)
            val file = rootDoc?.findFile(fileName)
            
            if (file != null && file.exists()) {
                // 1. Capture the URI before deletion
                val fileUri = file.uri 
                
                // 2. Perform the deletion
                val deleted = file.delete() 

                if (deleted) {
                    // 3. Notify the ContentResolver that this specific URI has changed
                    // This is more effective for SAF than MediaScanner
                    contentResolver.notifyChange(fileUri, null)
                    
                    // 4. Optional: If you still want to trigger a MediaScan for the path
                    // Note: This only works if the URI can be resolved to a physical path
                    val path = fileUri.path 
                    if (path != null) {
                        android.media.MediaScannerConnection.scanFile(
                            this, arrayOf(path), null
                        ) { _, _ -> println("Refresh scan complete") }
                    }
                    true
                } else {
                    false
                }
            } else {
                false
            }
        } catch (e: Exception) {
            println("Error deleting file: ${e.message}")
            false
        }
    }

    /**
     * Handles the result of the activity (directory picker)
     * Called when the user selects a directory or cancels the operation
     * 
     * @param requestCode The request code used when starting the activity
     * @param resultCode The result code indicating success or cancellation
     * @param data The intent data containing the selected URI
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        // Checks if this is the response from the directory picker (request code 100)
        if (requestCode == 100) {
            if (resultCode == RESULT_OK) {
                // User successfully selected a directory
                data?.data?.let { uri ->
                    // Requests persistent permission to access the selected directory
                    contentResolver.takePersistableUriPermission(uri, 
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    
                    // Saves the directory URI to SharedPreferences for later use
                    getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putString(KEY_URI, uri.toString()).apply()

                    // Signals success to Flutter with the selected URI
                    pendingResult?.success(uri.toString())
                }
            } else {
                // User cancelled the directory picker or an error occurred
                // Signals failure/cancellation to Flutter
                pendingResult?.success(null)
            }
            // Clears the pending result reference
            pendingResult = null
        }
    }
}