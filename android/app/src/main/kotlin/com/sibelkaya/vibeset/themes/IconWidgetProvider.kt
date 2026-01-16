package com.sibelkaya.vibeset.themes

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.RemoteViews
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.io.File
import com.sibelkaya.vibeset.themes.BuildConfig

class IconWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        Companion.logDebug("IconWidgetProvider", "📥 onReceive - action: ${intent.action}")
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val tempWidgetId = intent.getIntExtra("temp_widget_id", -1)
            Companion.logDebug("IconWidgetProvider", "📥 temp_widget_id from intent: $tempWidgetId")
            
            if (tempWidgetId != -1) {
                // Gerçek widget ID'lerini al
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, IconWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                
                Companion.logDebug("IconWidgetProvider", "🔍 Found ${appWidgetIds.size} widget IDs: ${appWidgetIds.contentToString()}")
                
                // Son eklenen widget'ı güncelle (en yüksek ID)
                val latestWidgetId = appWidgetIds.maxOrNull()
                if (latestWidgetId != null) {
                    Companion.logDebug("IconWidgetProvider", "🎯 Updating latest widget: $latestWidgetId")
                    updateAppWidget(context, appWidgetManager, latestWidgetId, tempWidgetId)
                    
                    // Flutter'a başarı bildirimini gönder
                    notifyFlutterWidgetAdded(context)
                } else {
                    Companion.logError("IconWidgetProvider", "❌ No widgets found!")
                }
            } else {
                Companion.logWarning("IconWidgetProvider", "⚠️ temp_widget_id not found in intent")
            }
        } else if (intent.action == AppWidgetManager.ACTION_APPWIDGET_ENABLED) {
            Companion.logDebug("IconWidgetProvider", "✅ ACTION_APPWIDGET_ENABLED")
        }
    }
    
    private fun notifyFlutterWidgetAdded(context: Context) {
        try {
            // Intent ile MainActivity'yi bilgilendir
            val intent = Intent(context, MainActivity::class.java).apply {
                action = "WIDGET_ADDED_SUCCESS"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            context.startActivity(intent)
            Companion.logDebug("IconWidgetProvider", "✅ Notified Flutter about widget success")
        } catch (e: Exception) {
            Companion.logError("IconWidgetProvider", "❌ Failed to notify Flutter: ${e.message}")
        }
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        logDebug("IconWidgetProvider", "🔄 onUpdate called with ${appWidgetIds.size} widgets: ${appWidgetIds.contentToString()}")
        
        // SharedPreferences'tan en son temp widget ID'yi al
        val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        val latestTempWidgetId = prefs.getInt("LATEST_TEMP_WIDGET_ID", -1)
        val latestTimestamp = prefs.getLong("LATEST_TEMP_WIDGET_TIMESTAMP", 0)
        
        logDebug("IconWidgetProvider", "🔍 Latest temp widget ID: $latestTempWidgetId, timestamp: $latestTimestamp")
        
        // Eğer son 10 saniye içinde kaydedilmiş bir temp ID varsa
        val now = System.currentTimeMillis()
        if (latestTempWidgetId != -1 && (now - latestTimestamp) < 10000) {
            logDebug("IconWidgetProvider", "✅ Found recent temp ID - mapping to widgets")
            
            // En yeni widget ID'yi bul (en büyük ID)
            val latestWidgetId = appWidgetIds.maxOrNull()
            
            if (latestWidgetId != null) {
                logDebug("IconWidgetProvider", "🎯 Mapping temp ID $latestTempWidgetId to widget ID $latestWidgetId")
                
                // Temp ID'den verileri gerçek widget ID'ye kopyala
                val iconPath = prefs.getString("WIDGET_ICON_PATH_$latestTempWidgetId", null)
                val packageName = prefs.getString("WIDGET_PACKAGE_NAME_$latestTempWidgetId", null)
                val appName = prefs.getString("WIDGET_APP_NAME_$latestTempWidgetId", null)
                
                if (iconPath != null && packageName != null) {
                    prefs.edit().apply {
                        putString("WIDGET_ICON_PATH_$latestWidgetId", iconPath)
                        putString("WIDGET_PACKAGE_NAME_$latestWidgetId", packageName)
                        putString("WIDGET_APP_NAME_$latestWidgetId", appName)
                        // Temp ID temizle
                        remove("LATEST_TEMP_WIDGET_ID")
                        remove("LATEST_TEMP_WIDGET_TIMESTAMP")
                        commit()
                    }
                    logDebug("IconWidgetProvider", "💾 Mapped data to widget $latestWidgetId")
                    
                    // Widget'ı güncelle
                    updateAppWidget(context, appWidgetManager, latestWidgetId, null)
                    
                    // Flutter'a başarı bildir
                    notifyFlutterWidgetAdded(context)
                    return
                }
            }
        }
        
        // Normal güncelleme - tüm widget'ları güncelle
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, null)
        }
    }

    override fun onEnabled(context: Context) {
        logDebug("IconWidgetProvider", "✅ Widget enabled")
    }

    companion object {
        // Debug logging helper - Release modunda logları kapatır
        private fun logDebug(tag: String, message: String) {
            if (BuildConfig.DEBUG) {
                android.util.Log.d(tag, message)
            }
        }
        
        private fun logError(tag: String, message: String, throwable: Throwable? = null) {
            if (BuildConfig.DEBUG) {
                if (throwable != null) {
                    android.util.Log.e(tag, message, throwable)
                } else {
                    android.util.Log.e(tag, message)
                }
            }
        }
        
        private fun logWarning(tag: String, message: String) {
            if (BuildConfig.DEBUG) {
                android.util.Log.w(tag, message)
            }
        }
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            tempWidgetId: Int?
        ) {
            logDebug("IconWidgetProvider", "📝 Updating widget $appWidgetId (temp: $tempWidgetId)")
            
            val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
            
            // temp ID'den verileri oku
            var iconPath: String? = null
            var packageName: String? = null
            
            var appName: String? = null
            
            if (tempWidgetId != null) {
                iconPath = prefs.getString("WIDGET_ICON_PATH_$tempWidgetId", null)
                packageName = prefs.getString("WIDGET_PACKAGE_NAME_$tempWidgetId", null)
                appName = prefs.getString("WIDGET_APP_NAME_$tempWidgetId", null)
                logDebug("IconWidgetProvider", "📥 From temp ID $tempWidgetId: icon=$iconPath, pkg=$packageName, name=$appName")
                
                // Gerçek widget ID ile kaydet
                if (iconPath != null && packageName != null) {
                    prefs.edit().apply {
                        putString("WIDGET_ICON_PATH_$appWidgetId", iconPath)
                        putString("WIDGET_PACKAGE_NAME_$appWidgetId", packageName)
                        putString("WIDGET_APP_NAME_$appWidgetId", appName)
                        commit()
                    }
                    logDebug("IconWidgetProvider", "💾 Saved with real widget ID: $appWidgetId")
                }
            } else {
                // Gerçek ID'den oku
                iconPath = prefs.getString("WIDGET_ICON_PATH_$appWidgetId", null)
                packageName = prefs.getString("WIDGET_PACKAGE_NAME_$appWidgetId", null)
                appName = prefs.getString("WIDGET_APP_NAME_$appWidgetId", null)
                logDebug("IconWidgetProvider", "📥 From real ID $appWidgetId: icon=$iconPath, pkg=$packageName, name=$appName")
            }

            // RemoteViews oluştur
            val views = RemoteViews(context.packageName, R.layout.widget_icon)

            // İkon yükle - SADECE dosyadan BitmapFactory ile
            var bitmap: Bitmap? = null
            
            if (iconPath != null) {
                val iconFile = File(iconPath)
                logDebug("IconWidgetProvider", "📂 Checking icon file: $iconPath")
                logDebug("IconWidgetProvider", "📂 File exists: ${iconFile.exists()}")
                logDebug("IconWidgetProvider", "📂 File readable: ${iconFile.canRead()}")
                logDebug("IconWidgetProvider", "📂 File size: ${iconFile.length()} bytes")
                
                if (iconFile.exists() && iconFile.canRead()) {
                    try {
                        bitmap = BitmapFactory.decodeFile(iconPath)
                        if (bitmap != null) {
                            logDebug("IconWidgetProvider", "✅ Bitmap decoded: ${bitmap.width}x${bitmap.height}, config=${bitmap.config}")
                        } else {
                            logError("IconWidgetProvider", "❌ BitmapFactory returned null!")
                        }
                    } catch (e: Exception) {
                        logError("IconWidgetProvider", "❌ Exception decoding bitmap: ${e.message}")
                        e.printStackTrace()
                    }
                } else {
                    logError("IconWidgetProvider", "❌ File doesn't exist or not readable!")
                }
            } else {
                logError("IconWidgetProvider", "❌ iconPath is null!")
            }
            
            // Bitmap'i widget'a set et
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_icon, bitmap)
                logDebug("IconWidgetProvider", "✅ Custom icon set successfully!")
            } else {
                logError("IconWidgetProvider", "❌ NO BITMAP - Widget will show default layout image")
            }
            
            // Uygulama ismini set et
            if (appName != null) {
                views.setTextViewText(R.id.widget_app_name, appName)
                logDebug("IconWidgetProvider", "✅ App name set: $appName")
            } else {
                views.setTextViewText(R.id.widget_app_name, "")
                logWarning("IconWidgetProvider", "⚠️ No app name available")
            }

            // Tıklama eventi
            if (packageName != null) {
                val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
                if (launchIntent != null) {
                    // PendingIntent flags - Android sürümüne göre
                    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        // Android 12+ (API 31+) - FLAG_IMMUTABLE gerekli
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        // Android 6-11 (API 23-30) - FLAG_IMMUTABLE yok
                        PendingIntent.FLAG_UPDATE_CURRENT
                    } else {
                        // Android 5.x ve altı
                        PendingIntent.FLAG_UPDATE_CURRENT
                    }
                    
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        launchIntent,
                        flags
                    )
                    views.setOnClickPendingIntent(R.id.widget_icon, pendingIntent)
                    logDebug("IconWidgetProvider", "🎯 Click handler set for: $packageName (flags: $flags)")
                }
            }

            // Widget'ı güncelle
            appWidgetManager.updateAppWidget(appWidgetId, views)
            logDebug("IconWidgetProvider", "✅ Widget updated successfully")
        }
    }
}
