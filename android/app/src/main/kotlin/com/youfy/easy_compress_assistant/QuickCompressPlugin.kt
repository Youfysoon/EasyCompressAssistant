package com.youfy.easy_compress_assistant

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/**
 * Quick compress Flutter Plugin
 * Provides interface for Flutter to call quick compress functionality
 */
class QuickCompressPlugin : MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.youfy.easy_compress_assistant/quick_compress"
        private const val PROGRESS_INTERVAL = 2000L // Report progress every 2 seconds

        @JvmStatic
        fun registerWith(flutterEngine: FlutterEngine, context: Context, activity: Activity?) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            channel.setMethodCallHandler(QuickCompressPlugin())
        }
    }

    private lateinit var context: Context
    private var currentActivity: Activity? = null
    private val handler = Handler(Looper.getMainLooper())
    private var progressCallback: ((String) -> Unit)? = null

    fun setContext(ctx: Context, activity: Activity? = null) {
        this.context = ctx
        this.currentActivity = activity
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> {
                result.success(true)
            }
            "quickCompressAndSend" -> {
                val filePaths = call.argument<List<String>>("filePaths")
                val archiveName = call.argument<String>("archiveName")

                if (filePaths.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "No files to compress", null)
                    return
                }

                Thread {
                    val success = performQuickCompress(filePaths, archiveName) { progressMsg ->
                        handler.post {
                            progressCallback?.invoke(progressMsg)
                        }
                    }

                    handler.post {
                        result.success(success)
                    }
                }.start()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun performQuickCompress(
        filePaths: List<String>,
        archiveName: String?,
        onProgress: (String) -> Unit
    ): Boolean {
        return try {
            val cacheDir = context.cacheDir
            val outputFileName = archiveName ?: "compressed_${System.currentTimeMillis()}.zip"
            val finalFileName = if (outputFileName.endsWith(".zip")) outputFileName else "$outputFileName.zip"
            val outputFile = File(cacheDir, finalFileName)

            var processedCount = 0
            val totalCount = filePaths.size

            val progressRunnable = object : Runnable {
                override fun run() {
                    val progress = if (totalCount > 0) {
                        (processedCount * 100 / totalCount).coerceIn(0, 100)
                    } else 0
                    onProgress("Compressing... $progress% ($processedCount/$totalCount)")
                    handler.postDelayed(this, PROGRESS_INTERVAL)
                }
            }
            handler.postDelayed(progressRunnable, PROGRESS_INTERVAL)

            try {
                ZipOutputStream(BufferedOutputStream(FileOutputStream(outputFile))).use { zos ->
                    val buffer = ByteArray(8192)

                    for (filePath in filePaths) {
                        val file = File(filePath)
                        if (file.exists()) {
                            addFileToZip(file, file.name, zos, buffer)
                            processedCount++
                        }
                    }
                }
            } finally {
                handler.removeCallbacks(progressRunnable)
            }

            handler.post {
                shareCompressedFile(outputFile)
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            handler.post {
                Toast.makeText(context, "Compression failed: ${e.message}", Toast.LENGTH_SHORT).show()
            }
            false
        }
    }

    private fun addFileToZip(file: File, entryName: String, zos: ZipOutputStream, buffer: ByteArray) {
        if (file.isDirectory) {
            file.listFiles()?.forEach { child ->
                val childEntryName = "$entryName/${child.name}"
                addFileToZip(child, childEntryName, zos, buffer)
            }
        } else {
            file.inputStream().use { input ->
                val entry = ZipEntry(entryName)
                zos.putNextEntry(entry)

                var len: Int
                while (input.read(buffer).also { len = it } > 0) {
                    zos.write(buffer, 0, len)
                }

                zos.closeEntry()
            }
        }
    }

    private fun shareCompressedFile(file: File) {
        try {
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )

            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "application/zip"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val chooser = Intent.createChooser(shareIntent, "Send compressed file")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(chooser)

            Toast.makeText(context, "Compression complete, preparing to send...", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(context, "Send failed: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
