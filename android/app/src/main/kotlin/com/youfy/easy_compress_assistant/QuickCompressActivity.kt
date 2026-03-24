package com.youfy.easy_compress_assistant

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.core.content.FileProvider
import java.io.*
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/**
 * Quick compress and send activity
 * Receives multiple selected files from file manager, compresses and shares them
 */
class QuickCompressActivity : Activity() {

    companion object {
        private const val TAG = "QuickCompressActivity"
        private const val PROGRESS_INTERVAL = 2000L // Report progress every 2 seconds
    }

    private val handler = Handler(Looper.getMainLooper())
    private var progressRunnable: Runnable? = null
    private var isCompressing = false
    private var processedFiles = 0
    private var totalFiles = 0
    private var outputZipFile: File? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingIntent()
    }

    private fun handleIncomingIntent() {
        when (intent.action) {
            Intent.ACTION_SEND -> {
                val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                if (uri != null) {
                    val uris = listOf(uri)
                    if (checkTotalFileSize(uris)) {
                        startQuickCompress(uris)
                    } else {
                        showToast("Total file size exceeds 1GB, please reduce file size")
                        finish()
                    }
                } else {
                    showToast("No files received")
                    finish()
                }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                if (!uris.isNullOrEmpty()) {
                    if (checkTotalFileSize(uris)) {
                        startQuickCompress(uris)
                    } else {
                        showToast("Total file size exceeds 1GB, please reduce file size")
                        finish()
                    }
                } else {
                    showToast("No files received")
                    finish()
                }
            }
            else -> {
                showToast("Unsupported action")
                finish()
            }
        }
    }

    private fun checkTotalFileSize(uris: List<Uri>): Boolean {
        val maxFileSize = 1L * 1024 * 1024 * 1024 // 1GB in bytes
        var totalSize = 0L
        
        for (uri in uris) {
            val size = getFileSize(uri)
            totalSize += size
            
            if (totalSize > maxFileSize) {
                return false
            }
        }
        
        return true
    }

    private fun getFileSize(uri: Uri): Long {
        return try {
            contentResolver.openAssetFileDescriptor(uri, "r")?.use { descriptor ->
                descriptor.length
            } ?: 0L
        } catch (e: Exception) {
            try {
                val documentFile = androidx.documentfile.provider.DocumentFile.fromSingleUri(this, uri)
                documentFile?.length() ?: 0L
            } catch (e: Exception) {
                0L
            }
        }
    }

    private fun startQuickCompress(uris: List<Uri>) {
        isCompressing = true
        processedFiles = 0
        totalFiles = uris.size

        showToast("Starting compression...")
        startProgressReporting()

        Thread {
            val success = compressAndSend(uris)
            
            handler.post {
                stopProgressReporting()
                isCompressing = false
                
                if (success && outputZipFile != null) {
                    showToast("Compression complete, preparing to send...")
                    shareCompressedFile(outputZipFile!!)
                } else {
                    showToast("Compression failed")
                }
                finish()
            }
        }.start()
    }

    private fun compressAndSend(uris: List<Uri>): Boolean {
        return try {
            val cacheDir = cacheDir
            val timestamp = System.currentTimeMillis()
            outputZipFile = File(cacheDir, "compressed_$timestamp.zip")

            ZipOutputStream(BufferedOutputStream(FileOutputStream(outputZipFile))).use { zos ->
                val buffer = ByteArray(8192)

                for (uri in uris) {
                    addUriToZip(uri, zos, buffer, "")
                    processedFiles++
                }
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun addUriToZip(uri: Uri, zos: ZipOutputStream, buffer: ByteArray, parentPath: String) {
        val documentFile = androidx.documentfile.provider.DocumentFile.fromSingleUri(this, uri)
            ?: return

        val fileName = if (parentPath.isEmpty()) {
            documentFile.name ?: "file_${System.currentTimeMillis()}"
        } else {
            "$parentPath/${documentFile.name ?: "file_${System.currentTimeMillis()}"}"
        }

        if (documentFile.isDirectory) {
            val dirUri = androidx.documentfile.provider.DocumentFile.fromTreeUri(this, uri)
            if (dirUri != null && dirUri.isDirectory) {
                val children = dirUri.listFiles()
                for (child in children) {
                    addDocumentFileToZip(child, zos, buffer, fileName)
                }
            } else {
                val treeUri = androidx.documentfile.provider.DocumentFile.fromTreeUri(this, uri)
                treeUri?.let { tree ->
                    if (tree.isDirectory) {
                        for (child in tree.listFiles()) {
                            addDocumentFileToZip(child, zos, buffer, fileName)
                        }
                    }
                }
            }
        } else {
            addFileToZip(uri, fileName, zos, buffer)
        }
    }

    private fun addDocumentFileToZip(
        documentFile: androidx.documentfile.provider.DocumentFile,
        zos: ZipOutputStream,
        buffer: ByteArray,
        parentPath: String
    ) {
        val fileName = if (parentPath.isEmpty()) {
            documentFile.name ?: return
        } else {
            "$parentPath/${documentFile.name ?: return}"
        }

        if (documentFile.isDirectory) {
            val children = documentFile.listFiles()
            for (child in children) {
                addDocumentFileToZip(child, zos, buffer, fileName)
            }
        } else if (documentFile.isFile) {
            documentFile.uri?.let { uri ->
                addFileToZip(uri, fileName, zos, buffer)
            }
        }
    }

    private fun addFileToZip(uri: Uri, entryName: String, zos: ZipOutputStream, buffer: ByteArray) {
        try {
            contentResolver.openInputStream(uri)?.use { input ->
                val entry = ZipEntry(entryName)
                zos.putNextEntry(entry)

                var len: Int
                while (input.read(buffer).also { len = it } > 0) {
                    zos.write(buffer, 0, len)
                }

                zos.closeEntry()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startProgressReporting() {
        progressRunnable = object : Runnable {
            override fun run() {
                if (isCompressing) {
                    val progress = if (totalFiles > 0) {
                        (processedFiles * 100 / totalFiles).coerceIn(0, 100)
                    } else 0
                    showToast("Compressing... $progress% (${processedFiles}/$totalFiles)")
                    handler.postDelayed(this, PROGRESS_INTERVAL)
                }
            }
        }
        handler.postDelayed(progressRunnable!!, PROGRESS_INTERVAL)
    }

    private fun stopProgressReporting() {
        progressRunnable?.let { handler.removeCallbacks(it) }
    }

    private fun shareCompressedFile(file: File) {
        try {
            val uri = FileProvider.getUriForFile(
                this,
                "${packageName}.fileprovider",
                file
            )

            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "application/zip"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val chooser = Intent.createChooser(shareIntent, "Send compressed file")
            startActivity(chooser)
        } catch (e: Exception) {
            e.printStackTrace()
            showToast("Send failed: ${e.message}")
        }
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopProgressReporting()
    }
}
