package com.example.wallpaper_theme_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.pm.ShortcutManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.widget.RemoteViews
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/shortcuts"
    private val WALLPAPER_CHANNEL = "com.example.app/wallpaper"
    
    // MethodChannel referansını sakla (widget başarı bildirimi için)
    private var shortcutsChannel: MethodChannel? = null
    
    // Son kaydedilen MediaStore URI'sini sakla (temizlik için)
    private var lastWallpaperUri: Uri? = null
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Widget ekleme başarılı bildirimini kontrol et
        if (intent.action == "WIDGET_ADDED_SUCCESS") {
            android.util.Log.d("MainActivity", "✅ Widget added successfully - notifying Flutter")
            shortcutsChannel?.invokeMethod("widgetAddedSuccess", null)
        }
    }

    // Material You renk değişimi için aktivite yeniden başlatılmasını engelle
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        
        // Android 12+ Material You renk değişimi kontrolü
        // CONFIG_ASSETS_PATHS (0x80000000) değişimi duvar kağıdı değişimini işaret eder
        try {
            val diff = resources.configuration.diff(newConfig)
            
            // diff maskesi 0x80000000 ise (veya negatif değer) duvar kağıdı değişmiş demektir
            if (diff < 0 || (diff and 0x80000000.toInt()) != 0) {
                android.util.Log.d("MainActivity", "⚠️ Duvar kağıdı değişimi algılandı - CONFIG_ASSETS_PATHS değişti")
                android.util.Log.d("MainActivity", "Diff mask: ${diff.toString(16)}")
                
                // Flutter'a sinyal gönderilebilir (opsiyonel)
                // MethodChannel ile "wallpaperChanged" event'i yayınlanabilir
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Configuration change kontrolü hatası: ${e.message}")
        }
        
        // Restart sinyalini yut - aktivite yeniden başlamasın
    }
    
    // AppResume - MediaStore'daki geçici duvar kağıdını temizle
    override fun onResume() {
        super.onResume()
        cleanupTempWallpaper()
    }
    
    private fun cleanupTempWallpaper() {
        try {
            // Son kaydedilen wallpaper URI'sini sil
            if (lastWallpaperUri != null) {
                contentResolver.delete(lastWallpaperUri!!, null, null)
                android.util.Log.d("MainActivity", "✅ MediaStore'daki geçici wallpaper silindi: $lastWallpaperUri")
                lastWallpaperUri = null
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "MediaStore temizleme hatası: ${e.message}", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Widget kanalını sakla (callback için)
        shortcutsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Wallpaper Intent kanalı
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WALLPAPER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openWallpaperIntent" -> {
                    val imagePath = call.argument<String>("imagePath")
                    
                    if (imagePath == null) {
                        result.error("INVALID_ARGUMENTS", "imagePath gereklidir", null)
                        return@setMethodCallHandler
                    }
                    
                    try {
                        val file = File(imagePath)
                        
                        // Dosya kontrolü
                        if (!file.exists() || file.length() == 0L) {
                            result.error("FILE_ERROR", "Dosya bulunamadı veya boş", null)
                            return@setMethodCallHandler
                        }
                        
                        android.util.Log.d("MainActivity", "📂 Dosya yolu: $imagePath")
                        android.util.Log.d("MainActivity", "📊 Dosya boyutu: ${file.length()} bytes")
                        
                        // MediaStore'a kaydet (Public - Honor/Huawei için kritik)
                        val contentUri = saveToMediaStore(file)
                        
                        if (contentUri == null) {
                            result.error("MEDIASTORE_ERROR", "MediaStore'a kayıt başarısız", null)
                            return@setMethodCallHandler
                        }
                        
                        // Son URI'yi sakla (temizlik için)
                        lastWallpaperUri = contentUri
                        
                        android.util.Log.d("MainActivity", "✅ MediaStore URI: $contentUri")
                        
                        // Intent Chooser ile sistem seçicisini aç
                        val intent = Intent(Intent.ACTION_ATTACH_DATA)
                        intent.setDataAndType(contentUri, "image/jpeg")
                        intent.putExtra("mimeType", "image/jpeg")
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        
                        val chooser = Intent.createChooser(intent, "Duvar Kağıdı Olarak Ayarla")
                        chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        
                        startActivity(chooser)
                        android.util.Log.d("MainActivity", "🚀 Intent Chooser açıldı")
                        
                        result.success(true)
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "❌ Hata: ${e.message}", e)
                        result.error("INTENT_ERROR", "Duvar kağıdı ekranı açılamadı: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        // Widget kanalı
        shortcutsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "createAppWidget" -> {
                    val appName = call.argument<String>("appName")
                    val iconPath = call.argument<String>("iconPath")
                    val packageName = call.argument<String>("packageName")

                    if (packageName == null || appName == null) {
                        result.error("INVALID_ARGUMENTS", "packageName ve appName gereklidir", null)
                        return@setMethodCallHandler
                    }

                    try {
                        createAppWidget(iconPath, packageName, appName, result)
                    } catch (e: Exception) {
                        result.error("WIDGET_ERROR", "Widget oluşturulamadı: ${e.message}", null)
                    }
                }
                "createAppShortcut" -> {
                    val appName = call.argument<String>("appName")
                    val iconPath = call.argument<String>("iconPath")
                    val packageName = call.argument<String>("packageName")

                    if (appName == null || packageName == null) {
                    result.error("INVALID_ARGUMENTS", "appName ve packageName gereklidir", null)
                    return@setMethodCallHandler
                }

                try {
                    // Hedef uygulamanın launch intent'ini al
                    val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                    if (launchIntent == null) {
                        result.error("PACKAGE_NOT_FOUND", "Hedef uygulama bulunamadı", null)
                        return@setMethodCallHandler
                    }
                    
                    // Android 8.0+ için ShortcutManager, altı için broadcast
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        android.util.Log.d("MainActivity", "ShortcutManager ile kısayol oluşturuluyor")
                        
                        // Kısayol desteklenmiyor mu kontrol et
                        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(this)) {
                            result.error("NOT_SUPPORTED", "Bu cihaz kısayol eklemeyi desteklemiyor", null)
                            return@setMethodCallHandler
                        }
                    } else {
                        android.util.Log.d("MainActivity", "Legacy Broadcast yöntemi ile kısayol oluşturuluyor")
                        
                        // Kısayol oluşturma Intent'i
                        val shortcutIntent = Intent("com.android.launcher.action.INSTALL_SHORTCUT")
                        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, launchIntent)
                        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, appName)
                        shortcutIntent.putExtra("duplicate", false)
                        
                        // İkon yükleme (Android 7.1 ve altı için)
                        var iconBitmap: Bitmap? = null
                        
                        if (iconPath != null && iconPath.isNotEmpty()) {
                            try {
                                val iconFile = File(iconPath)
                                if (iconFile.exists()) {
                                    iconBitmap = BitmapFactory.decodeFile(iconFile.absolutePath)
                                    android.util.Log.d("MainActivity", "✅ İkon yüklendi (Legacy): $iconPath")
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("MainActivity", "❌ İkon yükleme hatası: ${e.message}")
                            }
                        }
                        
                        // Eğer iconBitmap oluşturulamadıysa hata fırlat (fallback yok!)
                        if (iconBitmap == null) {
                            android.util.Log.e("MainActivity", "⚠️ İKON YÜKLENEMEDİ (Legacy) - Shortcut oluşturulamıyor")
                            result.error("ICON_LOAD_FAILED", "İkon dosyası yüklenemedi (Legacy)", null)
                            return@setMethodCallHandler
                        }
                        
                        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON, iconBitmap)
                        
                        sendBroadcast(shortcutIntent)
                        android.util.Log.d("MainActivity", "Kısayol broadcast gönderildi")
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    
                    // Android 8.0+ için ShortcutManager devam ediyor
                    var iconBitmap: Bitmap? = null
                    
                    if (iconPath != null && iconPath.isNotEmpty()) {
                        try {
                            val iconFile = File(iconPath)
                            if (iconFile.exists()) {
                                iconBitmap = BitmapFactory.decodeFile(iconFile.absolutePath)
                                android.util.Log.d("MainActivity", "✅ İkon yüklendi: $iconPath")
                            }
                        } catch (e: Exception) {
                            android.util.Log.e("MainActivity", "❌ İkon yükleme hatası: ${e.message}")
                        }
                    }
                    
                    if (iconBitmap == null) {
                        android.util.Log.e("MainActivity", "⚠️ İKON YÜKLENEMEDİ - Shortcut oluşturulamıyor")
                        result.error("ICON_LOAD_FAILED", "İkon dosyası yüklenemedi", null)
                        return@setMethodCallHandler
                    }
                    
                    // ShortcutInfo oluştur
                    val shortcutId = "shortcut_${packageName}_${System.currentTimeMillis()}"
                    val shortcutLabel = appName
                    
                    val shortcutInfoBuilder = ShortcutInfoCompat.Builder(this, shortcutId)
                        .setShortLabel(shortcutLabel)
                        .setLongLabel(shortcutLabel)
                        .setIntent(launchIntent)
                    
                    // İkon ekle
                    shortcutInfoBuilder.setIcon(IconCompat.createWithBitmap(iconBitmap))
                    android.util.Log.d("MainActivity", "✅ Shortcut oluşturuldu: $shortcutLabel")
                    
                    val shortcutInfo = shortcutInfoBuilder.build()
                    
                    // Kısayol ekleme isteği gönder
                    val success = ShortcutManagerCompat.requestPinShortcut(this, shortcutInfo, null)
                    
                    if (success) {
                        android.util.Log.d("MainActivity", "Kısayol başarıyla istendi")
                        result.success(true)
                    } else {
                        android.util.Log.w("MainActivity", "Kısayol isteği başarısız")
                        result.error("SHORTCUT_FAILED", "Kısayol isteği başarısız oldu", null)
                    }
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Kısayol oluşturma hatası: ${e.message}", e)
                    result.error("SHORTCUT_ERROR", "Kısayol oluşturulamadı: ${e.message}", null)
                }
            }
            else -> result.notImplemented()
            }
        }
    }

    private fun createAppWidget(iconPath: String?, packageName: String, appName: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.error("NOT_SUPPORTED", "Widget pinleme Android 8.0+ gerektirir", null)
            return
        }

        val appWidgetManager = AppWidgetManager.getInstance(this)
        val myProvider = ComponentName(this, IconWidgetProvider::class.java)

        // Widget pinleme desteklenmiyor mu kontrol et
        if (!appWidgetManager.isRequestPinAppWidgetSupported) {
            result.error("NOT_SUPPORTED", "Bu cihaz widget pinlemeyi desteklemiyor", null)
            return
        }

        android.util.Log.d("MainActivity", "🎯 Icon path: $iconPath")
        android.util.Log.d("MainActivity", "🎯 Package: $packageName")
        
        // Icon dosyasının var olduğunu doğrula
        if (iconPath == null || !File(iconPath).exists()) {
            android.util.Log.e("MainActivity", "❌ Icon file doesn't exist!")
            result.error("INVALID_ICON", "Icon dosyası bulunamadı", null)
            return
        }

        // Widget için geçici bir ID oluştur (sistemin gerçek ID'si farklı olacak)
        val tempWidgetId = (System.currentTimeMillis() % 100000000).toInt()

        android.util.Log.d("MainActivity", "🆔 Temp Widget ID: $tempWidgetId")

        // Widget bilgilerini KEY_PREFIX ile SharedPreferences'a kaydet
        val prefs = getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putString("WIDGET_ICON_PATH_$tempWidgetId", iconPath)
        editor.putString("WIDGET_PACKAGE_NAME_$tempWidgetId", packageName)
        editor.putString("WIDGET_APP_NAME_$tempWidgetId", appName)
        val saved = editor.commit() // Senkron kaydet
        
        android.util.Log.d("MainActivity", if (saved) "✅ Saved to SharedPreferences" else "❌ Failed to save")
        
        // Doğrulama
        val verify = prefs.getString("WIDGET_ICON_PATH_$tempWidgetId", null)
        android.util.Log.d("MainActivity", "🔍 Verification - Saved icon path: $verify")

        // Widget Bundle'ı oluştur - tempWidgetId'yi geçir
        val configBundle = android.os.Bundle()
        configBundle.putInt("temp_widget_id", tempWidgetId)
        
        // Callback intent - widget eklenince ID mapping yapacağız
        val callbackIntent = Intent(this, IconWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra("temp_widget_id", tempWidgetId)
        }
        
        val successCallback = PendingIntent.getBroadcast(
            this,
            tempWidgetId,
            callbackIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        android.util.Log.d("MainActivity", "🚀 Requesting pin widget...")
        
        // Widget'ı pin et
        // NOT: requestPinAppWidget sadece dialog açılıp açılmadığını döndürür
        // Kullanıcının "Add" veya "Cancel" seçimini callback'ten öğreniriz
        val dialogShown = appWidgetManager.requestPinAppWidget(myProvider, configBundle, successCallback)
        
        if (dialogShown) {
            android.util.Log.d("MainActivity", "📋 Widget pinning dialog shown to user")
            // Kullanıcı henüz seçim yapmadı, başarı mesajını gösterme
            result.success(false)
        } else {
            android.util.Log.w("MainActivity", "⚠️ Widget pinning NOT supported")
            result.error("PIN_FAILED", "Widget pinleme desteklenmiyor", null)
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

    private fun saveToMediaStore(file: File): Uri? {
        return try {
            val bitmap = BitmapFactory.decodeFile(file.absolutePath) ?: run {
                android.util.Log.e("MainActivity", "❌ Bitmap decode failed")
                return null
            }

            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, "wallpaper_temp_${System.currentTimeMillis()}.jpg")
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/WallpaperTemp")
            }

            val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            uri?.let {
                contentResolver.openOutputStream(it)?.use { outputStream ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
                    android.util.Log.d("MainActivity", "✅ MediaStore'a kaydedildi: $uri")
                }
            }
            bitmap.recycle()
            uri
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ MediaStore kaydetme hatası: ${e.message}")
            null
        }
    }
}
