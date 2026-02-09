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

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.journeyers/saf"
    private val PREFS_NAME = "FlutterSharedPreferences"
    private val KEY_URI = "flutter.applicationFolderPath"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDirectory" -> {
                // Result callback stored for later use
                pendingResult = result 
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                startActivityForResult(intent, 100)
             }
                "getStoredDirectory" -> {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    result.success(prefs.getString(KEY_URI, null))
                }
                "saveFile" -> {
                    val name = call.argument<String>("fileName") ?: "file.csv"
                    val bytes = call.argument<ByteArray>("content") ?: byteArrayOf()
                    val success = saveToStoredFolder(name, bytes)
                    result.success(success)
                }
                "readFileContent" -> {
                    val fileName = call.argument<String>("fileName") ?: ""
                    val content = readFileFromStoredFolder(fileName)
                    if (content != null) result.success(content) else result.error("READ_FAIL", "File not found", null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToStoredFolder(fileName: String, content: ByteArray): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val uriString = prefs.getString(KEY_URI, null) ?: return false
        val treeUri = Uri.parse(uriString)

        return try {
            val rootDoc = DocumentFile.fromTreeUri(this, treeUri)
            val newFile = rootDoc?.createFile("text/csv", fileName)

            newFile?.uri?.let { fileUri ->
                contentResolver.openOutputStream(fileUri)?.use { it.write(content) }
                true
            } ?: false
        } catch (e: Exception) { false }
    }

    private fun readFileFromStoredFolder(fileName: String): String? {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val uriString = prefs.getString(KEY_URI, null) ?: return null
        val treeUri = Uri.parse(uriString)

        return try 
        {
            // 1. Ensure the treeUri is not null and context is valid
            treeUri?.let { uri ->
                val rootDoc = DocumentFile.fromTreeUri(this, uri)
                
                // 2. Use safe calls or null checks for rootDoc
                val uriString: String? = rootDoc?.uri?.toString()
                
                // 3. Finding a file is an expensive operation; ensure rootDoc exists first
                val file = rootDoc?.findFile(fileName)

                println("rootDoc: $rootDoc")
                println("uriString: $uriString")
                println("fileName: $fileName")
                
                // 4. Check if the file actually exists after findFile
                if (file != null && file.exists()) {println("File found: ${file.name}")} 
                else {println("File not found or fileName is incorrect")}
            
                file?.uri?.let { fileUri ->
                    contentResolver.openInputStream(fileUri)?.use { inputStream ->
                        BufferedReader(InputStreamReader(inputStream)).readText()
                    }
                }
            }
        
        } catch (e: Exception) { null }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100) {
            if (resultCode == RESULT_OK) {
                data?.data?.let { uri ->
                    contentResolver.takePersistableUriPermission(uri, 
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    
                    getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putString(KEY_URI, uri.toString()).apply()

                    // 3. Signal success to Flutter now that data is saved
                    pendingResult?.success(uri.toString())
                }
            } else {
                // Signal failure or cancellation
                pendingResult?.success(null)
            }
            pendingResult = null // Clear the reference
        }
    }
}