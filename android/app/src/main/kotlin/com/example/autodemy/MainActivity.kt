package com.example.autodemy

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import android.view.WindowManager

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block screenshots and screen recordings — QR codes will show as black screen
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
