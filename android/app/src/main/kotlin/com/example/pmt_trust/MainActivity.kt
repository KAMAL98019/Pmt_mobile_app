package com.example.pmt_trust

import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Use new WindowInsetsController for Android 11+ (API 30+)
            WindowCompat.setDecorFitsSystemWindows(window, false)
            
            val controller = window.insetsController
            controller?.let {
                it.hide(android.view.WindowInsets.Type.systemBars())
                it.systemBarsBehavior = 
                    android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        }
    }
}
