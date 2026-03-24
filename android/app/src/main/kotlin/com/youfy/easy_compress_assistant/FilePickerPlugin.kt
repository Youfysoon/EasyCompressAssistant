package com.youfy.easy_compress_assistant

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Native file picker plugin
 * Provides interface for Flutter to call Android native file picker
 */
class FilePickerPlugin : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.youfy.easy_compress_assistant/file_picker"
        private const val REQUEST_CODE_PICK_FILE = 1001
        private const val REQUEST_CODE_PICK_MULTIPLE_FILES = 1002
        private const val REQUEST_CODE_PICK_DIRECTORY = 1003

        @JvmStatic
        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            val plugin = FilePickerPlugin()
            plugin.setContext(activity)
            channel.setMethodCallHandler(plugin)
        }
    }

    private lateinit var context: Activity
    private var pendingResult: MethodChannel.Result? = null
    private var pendingMimeTypes: List<String>? = null

    fun setContext(ctx: Activity) {
        this.context = ctx
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (resultCode != Activity.RESULT_OK) {
            pendingResult?.success(null)
            pendingResult = null
            return true
        }

        when (requestCode) {
            REQUEST_CODE_PICK_FILE -> {
                val uri = data?.data
                if (uri != null) {
                    val fileInfo = getFileInfoFromUri(uri)
                    pendingResult?.success(fileInfo)
                } else {
                    pendingResult?.success(null)
                }
                pendingResult = null
                return true
            }
            REQUEST_CODE_PICK_MULTIPLE_FILES -> {
                val clipData = data?.clipData
                val uriList = mutableListOf<Map<String, Any?>>()
                
                if (clipData != null) {
                    for (i in 0 until clipData.itemCount) {
                        val uri = clipData.getItemAt(i).uri
                        uriList.add(getFileInfoFromUri(uri))
                    }
                } else if (data?.data != null) {
                    uriList.add(getFileInfoFromUri(data.data!!))
                }
                
                pendingResult?.success(uriList)
                pendingResult = null
                return true
            }
            REQUEST_CODE_PICK_DIRECTORY -> {
                val uri = data?.data
                if (uri != null) {
                    val dirInfo = getDirectoryInfoFromUri(uri)
                    pendingResult?.success(dirInfo)
                } else {
                    pendingResult?.success(null)
                }
                pendingResult = null
                return true
            }
        }
        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickFile" -> {
                val mimeTypes = call.argument<List<String>>("mimeTypes") ?: listOf("*/*")
                pickFile(mimeTypes, result)
            }
            "pickMultipleFiles" -> {
                val mimeTypes = call.argument<List<String>>("mimeTypes") ?: listOf("*/*")
                pickMultipleFiles(mimeTypes, result)
            }
            "pickDirectory" -> {
                pickDirectory(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun pickFile(mimeTypes: List<String>, result: MethodChannel.Result) {
        pendingResult = result
        pendingMimeTypes = mimeTypes

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeTypes.firstOrNull() ?: "*/*"
            if (mimeTypes.size > 1) {
                putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
            }
        }

        context.startActivityForResult(intent, REQUEST_CODE_PICK_FILE)
    }

    private fun pickMultipleFiles(mimeTypes: List<String>, result: MethodChannel.Result) {
        pendingResult = result
        pendingMimeTypes = mimeTypes

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeTypes.firstOrNull() ?: "*/*"
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            if (mimeTypes.size > 1) {
                putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
            }
        }

        context.startActivityForResult(intent, REQUEST_CODE_PICK_MULTIPLE_FILES)
    }

    private fun pickDirectory(result: MethodChannel.Result) {
        pendingResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)

        context.startActivityForResult(intent, REQUEST_CODE_PICK_DIRECTORY)
    }

    /**
     * Get file info from URI and copy to app cache directory
     */
    private fun getFileInfoFromUri(uri: Uri): Map<String, Any?> {
        val contentResolver = context.contentResolver
        val fileName = getFileNameFromUri(contentResolver, uri)
        val fileSize = getFileSizeFromUri(contentResolver, uri)
        val mimeType = contentResolver.getType(uri) ?: "*/*"
        
        val cachedPath = copyUriToCache(contentResolver, uri, fileName)

        return mapOf(
            "name" to fileName,
            "size" to fileSize,
            "uri" to uri.toString(),
            "path" to cachedPath,
            "mimeType" to mimeType
        )
    }

    /**
     * Get directory info from URI
     * Copies directory contents to app cache and returns cache path
     */
    private fun getDirectoryInfoFromUri(uri: Uri): Map<String, Any?> {
        val documentFile = androidx.documentfile.provider.DocumentFile.fromTreeUri(context, uri)
        val dirName = documentFile?.name ?: "Unknown"
        
        // Create cache directory for this picked directory
        val cacheDir = File(context.cacheDir, "picked_directories/$dirName")
        cacheDir.mkdirs()
        
        // Copy all files from the picked directory to cache
        copyDocumentTreeToCache(documentFile, cacheDir)
        
        return mapOf(
            "name" to dirName,
            "uri" to uri.toString(),
            "path" to cacheDir.absolutePath
        )
    }
    
    /**
     * Recursively copy DocumentFile tree to cache directory
     */
    private fun copyDocumentTreeToCache(source: androidx.documentfile.provider.DocumentFile?, destDir: File) {
        if (source == null) return
        
        if (source.isDirectory) {
            // Create subdirectory
            val subDir = File(destDir, source.name ?: "subdir")
            subDir.mkdirs()
            
            // Recursively copy children
            for (child in source.listFiles()) {
                copyDocumentTreeToCache(child, subDir)
            }
        } else if (source.isFile) {
            // Copy file
            val destFile = File(destDir, source.name ?: "file")
            try {
                context.contentResolver.openInputStream(source.uri)?.use { input ->
                    java.io.FileOutputStream(destFile).use { output ->
                        input.copyTo(output)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun getFileNameFromUri(contentResolver: ContentResolver, uri: Uri): String {
        var name = "Unknown"
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0) {
                    name = it.getString(nameIndex) ?: "Unknown"
                }
            }
        }
        return name
    }

    private fun getFileSizeFromUri(contentResolver: ContentResolver, uri: Uri): Long {
        var size: Long = 0
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val sizeIndex = it.getColumnIndex(OpenableColumns.SIZE)
                if (sizeIndex >= 0) {
                    size = it.getLong(sizeIndex)
                }
            }
        }
        return size
    }

    private fun copyUriToCache(contentResolver: ContentResolver, uri: Uri, fileName: String): String? {
        return try {
            val cacheDir = File(context.cacheDir, "picked_files")
            cacheDir.mkdirs()
            
            val outputFile = File(cacheDir, fileName)
            
            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(outputFile).use { output ->
                    input.copyTo(output)
                }
            }
            
            outputFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
