package com.youfy.easy_compress_assistant

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var filePickerPlugin: FilePickerPlugin? = null
    private var quickCompressPlugin: QuickCompressPlugin? = null
    private var sharePlugin: SharePlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register file picker plugin
        filePickerPlugin = FilePickerPlugin()
        filePickerPlugin?.setContext(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.youfy.easy_compress_assistant/file_picker"
        ).setMethodCallHandler(filePickerPlugin!!)

        // Register quick compress plugin
        quickCompressPlugin = QuickCompressPlugin()
        quickCompressPlugin?.setContext(this, this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.youfy.easy_compress_assistant/quick_compress"
        ).setMethodCallHandler(quickCompressPlugin!!)

        // Register share plugin
        sharePlugin = SharePlugin(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SharePlugin.CHANNEL_NAME
        ).setMethodCallHandler(sharePlugin!!)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Unit {
        // Try to handle with plugins first
        if (filePickerPlugin?.onActivityResult(requestCode, resultCode, data) == true) {
            return
        }
        if (sharePlugin?.onActivityResult(requestCode, resultCode, data) == true) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
