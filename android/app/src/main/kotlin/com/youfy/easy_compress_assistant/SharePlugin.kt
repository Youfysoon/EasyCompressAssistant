package com.youfy.easy_compress_assistant

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

/**
 * Share functionality plugin
 * Provides file sharing, save as, copy path and other functions
 */
class SharePlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.youfy.easy_compress_assistant/share"
        const val REQUEST_CODE_SAVE_AS = 2001
    }

    private var pendingSaveResult: MethodChannel.Result? = null
    private var pendingSourcePath: String? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shareFile" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    shareFile(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path is null", null)
                }
            }
            "saveAs" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    saveAs(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path is null", null)
                }
            }
            "copyToClipboard" -> {
                val text = call.argument<String>("text")
                if (text != null) {
                    copyToClipboard(text, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Text is null", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun shareFile(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
                return
            }

            val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(
                    activity,
                    "${activity.packageName}.fileprovider",
                    file
                )
            } else {
                Uri.fromFile(file)
            }

            val intent = Intent(Intent.ACTION_SEND).apply {
                type = getMimeType(file.name)
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val chooser = Intent.createChooser(intent, "Share file")
            activity.startActivity(chooser)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("SHARE_ERROR", e.message, null)
        }
    }

    private fun saveAs(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
                return
            }

            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                type = getMimeType(file.name)
                putExtra(Intent.EXTRA_TITLE, file.name)
                addCategory(Intent.CATEGORY_OPENABLE)
            }

            pendingSaveResult = result
            pendingSourcePath = path
            activity.startActivityForResult(intent, REQUEST_CODE_SAVE_AS)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("SAVE_AS_ERROR", e.message, null)
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_SAVE_AS) return false

        if (resultCode == Activity.RESULT_OK && data?.data != null) {
            val destinationUri = data.data!!
            val sourcePath = pendingSourcePath

            if (sourcePath != null) {
                try {
                    activity.contentResolver.openOutputStream(destinationUri)?.use { output ->
                        FileInputStream(File(sourcePath)).use { input ->
                            input.copyTo(output)
                        }
                    }
                    pendingSaveResult?.success(mapOf(
                        "success" to true,
                        "destination" to destinationUri.toString()
                    ))
                } catch (e: Exception) {
                    e.printStackTrace()
                    pendingSaveResult?.error("COPY_ERROR", e.message, null)
                }
            } else {
                pendingSaveResult?.error("NO_SOURCE", "Source path is null", null)
            }
        } else {
            pendingSaveResult?.success(mapOf("success" to false, "cancelled" to true))
        }

        pendingSaveResult = null
        pendingSourcePath = null
        return true
    }

    private fun copyToClipboard(text: String, result: MethodChannel.Result) {
        try {
            val clipboard = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("File Path", text)
            clipboard.setPrimaryClip(clip)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("CLIPBOARD_ERROR", e.message, null)
        }
    }

    private fun getMimeType(fileName: String): String {
        return when {
            fileName.endsWith(".zip", ignoreCase = true) -> "application/zip"
            fileName.endsWith(".rar", ignoreCase = true) -> "application/x-rar-compressed"
            fileName.endsWith(".7z", ignoreCase = true) -> "application/x-7z-compressed"
            fileName.endsWith(".tar", ignoreCase = true) -> "application/x-tar"
            fileName.endsWith(".gz", ignoreCase = true) -> "application/gzip"
            fileName.endsWith(".pdf", ignoreCase = true) -> "application/pdf"
            fileName.endsWith(".jpg", ignoreCase = true) || 
            fileName.endsWith(".jpeg", ignoreCase = true) -> "image/jpeg"
            fileName.endsWith(".png", ignoreCase = true) -> "image/png"
            fileName.endsWith(".txt", ignoreCase = true) -> "text/plain"
            else -> "*/*"
        }
    }
}
