package com.example.wallpaper_theme_app

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/shortcuts"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "createAppShortcut") {
                val appName = call.argument<String>("appName")
                val iconPath = call.argument<String>("iconPath")
                val packageName = call.argument<String>("packageName")

                if (appName == null || packageName == null) {
                    result.error("INVALID_ARGUMENTS", "appName ve packageName gereklidir", null)
                    return@setMethodCallHandler
                }

                try {
                    // Android 8.0 (API 26) ve üzeri için ShortcutManager kullan
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        // Kısayolu destekliyor mu kontrol et
                        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(this)) {
                            result.error("NOT_SUPPORTED", "Bu cihaz kısayol eklemeyi desteklemiyor", null)
                            return@setMethodCallHandler
                        }

                        // Kısayol ikonunu hazırla
                        var iconBitmap: Bitmap? = null
                        
                        if (iconPath != null && iconPath.isNotEmpty()) {
                            try {
                                val iconFile = File(iconPath)
                                if (iconFile.exists()) {
                                    iconBitmap = BitmapFactory.decodeFile(iconFile.absolutePath)
                                    android.util.Log.d("MainActivity", "İkon başarıyla yüklendi: $iconPath")
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("MainActivity", "İkon yükleme hatası: ${e.message}")
                            }
                        }
                        
                        // Eğer iconBitmap oluşturulamadıysa, uygulamanın kendi ikonunu kullan
                        if (iconBitmap == null) {
                            try {
                                val appInfo = applicationContext.packageManager.getApplicationInfo(
                                    applicationContext.packageName, 
                                    0
                                )
                                val drawable = applicationContext.packageManager.getApplicationIcon(appInfo)
                                iconBitmap = drawableToBitmap(drawable)
                            } catch (e: Exception) {
                                android.util.Log.e("MainActivity", "Varsayılan ikon alınamadı: ${e.message}")
                            }
                        }

                        // Kısayolun açacağı Intent (kendi uygulamamızı açar)
                        val shortcutIntent = Intent(this, MainActivity::class.java).apply {
                            action = Intent.ACTION_MAIN
                            addCategory(Intent.CATEGORY_LAUNCHER)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                        }

                        // ShortcutInfo oluştur
                        val shortcutInfoBuilder = ShortcutInfoCompat.Builder(this, "shortcut_${System.currentTimeMillis()}")
                            .setShortLabel(appName)
                            .setLongLabel(appName)
                            .setIntent(shortcutIntent)

                        // İkon varsa ekle
                        if (iconBitmap != null) {
                            shortcutInfoBuilder.setIcon(IconCompat.createWithBitmap(iconBitmap))
                        }

                        val shortcutInfo = shortcutInfoBuilder.build()

                        // Kısayol ekleme isteği gönder (kullanıcıya dialog gösterir)
                        val success = ShortcutManagerCompat.requestPinShortcut(this, shortcutInfo, null)
                        
                        if (success) {
                            android.util.Log.d("MainActivity", "Kısayol başarıyla istendi")
                            result.success(true)
                        } else {
                            android.util.Log.w("MainActivity", "Kısayol isteği başarısız")
                            result.error("SHORTCUT_FAILED", "Kısayol isteği başarısız oldu", null)
                        }
                        
                    } else {
                        // Android 7.1 ve altı için eski yöntem (INSTALL_SHORTCUT)
                        android.util.Log.d("MainActivity", "Eski API seviyesi, INSTALL_SHORTCUT kullanılıyor")
                        
                        // Hedef uygulamayı başlatacak Intent oluştur
                        val launchIntent = Intent(this, MainActivity::class.java).apply {
                            action = Intent.ACTION_MAIN
                            addCategory(Intent.CATEGORY_LAUNCHER)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                        }

                        // Kısayol oluşturma Intent'i
                        val shortcutIntent = Intent("com.android.launcher.action.INSTALL_SHORTCUT")
                        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, launchIntent)
                        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, appName)
                        shortcutIntent.putExtra("duplicate", false)
                        
                        // İkon yolunu kullanarak Bitmap oluştur
                        var iconBitmap: Bitmap? = null
                        
                        if (iconPath != null && iconPath.isNotEmpty()) {
                            try {
                                val iconFile = File(iconPath)
                                if (iconFile.exists()) {
                                    iconBitmap = BitmapFactory.decodeFile(iconFile.absolutePath)
                                    android.util.Log.d("MainActivity", "İkon başarıyla yüklendi: $iconPath")
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("MainActivity", "İkon yükleme hatası: ${e.message}")
                            }
                        }
                        
                        // Eğer iconBitmap oluşturulamadıysa, uygulamanın kendi ikonunu kullan
                        if (iconBitmap == null) {
                            try {
                                val appInfo = applicationContext.packageManager.getApplicationInfo(
                                    applicationContext.packageName, 
                                    0
                                )
                                val drawable = applicationContext.packageManager.getApplicationIcon(appInfo)
                                iconBitmap = drawableToBitmap(drawable)
                            } catch (e: Exception) {
                                android.util.Log.e("MainActivity", "Varsayılan ikon alınamadı: ${e.message}")
                            }
                        }
                        
                        // Bitmap'i Intent'e ekle
                        if (iconBitmap != null) {
                            shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON, iconBitmap)
                        }

                        // Kısayol oluşturma broadcast'i gönder
                        sendBroadcast(shortcutIntent)
                        
                        result.success(true)
                    }
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Kısayol oluşturma hatası: ${e.message}", e)
                    result.error("SHORTCUT_ERROR", "Kısayol oluşturulamadı: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
    
    // Drawable'ı Bitmap'e dönüştür
    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }
        
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        
        return bitmap
    }
}
