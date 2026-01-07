package com.example.wallpaper_theme_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class ProxyShortcutActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Intent'ten hedef paket adını al
        val targetPackage = intent.getStringExtra("target_package")

        if (targetPackage != null && targetPackage.isNotEmpty()) {
            // Hedef uygulamayı başlat
            val launchIntent = packageManager.getLaunchIntentForPackage(targetPackage)
            
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                startActivity(launchIntent)
            }
        }

        // Proxy Activity'yi hemen sonlandır
        finish()
    }
}
