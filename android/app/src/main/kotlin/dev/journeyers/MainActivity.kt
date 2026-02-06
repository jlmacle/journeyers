package dev.journeyers

import android.content.ContentUris
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.journeyers/file_access"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "readFileContent") {
                val fileId = call.argument<String>("id")?.toLong() ?: 0L
                val content = readDownloadsFile(fileId)
                if (content != null) result.success(content) else result.error("404", "File not found", null)
            }
        }
    }

    private fun readDownloadsFile(id: Long): String? {
        // Construct the Uri for the specific document ID in the Downloads collection
        val contentUri = ContentUris.withAppendedId(MediaStore.Downloads.EXTERNAL_CONTENT_URI, id)
        
        return try {
            contentResolver.openInputStream(contentUri)?.use { inputStream ->
                BufferedReader(InputStreamReader(inputStream)).use { it.readText() }
            }
        } catch (e: Exception) {
            null
        }
    }
}