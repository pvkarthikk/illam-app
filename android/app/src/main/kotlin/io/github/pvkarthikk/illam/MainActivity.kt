package io.github.pvkarthikk.illam

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.github.pvkarthikk.illam.receipt.ReceiptOcrChannel
import io.github.pvkarthikk.illam.sms.SmsBridge
import io.github.pvkarthikk.illam.widget.WidgetBridge

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WidgetBridge.onLaunchOrNewIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        WidgetBridge.onLaunchOrNewIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        WidgetBridge.attachForeground(this, flutterEngine)
        PdfTextChannel.attach(this, flutterEngine)
        SmsBridge.attach(this, flutterEngine)
        ReceiptOcrChannel.attach(this, flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        ReceiptOcrChannel.detach()
        SmsBridge.detach()
        PdfTextChannel.detach()
        WidgetBridge.detachForeground()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (ReceiptOcrChannel.onRequestPermissionsResult(requestCode, permissions, grantResults)) {
            return
        }
        if (SmsBridge.onRequestPermissionsResult(requestCode, permissions, grantResults)) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (ReceiptOcrChannel.onActivityResult(requestCode, resultCode, data)) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
