package com.example.wallpaper_theme_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.io.File

class IconWidgetProvider : AppWidgetProvider() {
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val tempWidgetId = intent.getIntExtra("temp_widget_id", -1)
            android.util.Log.d("IconWidgetProvider", "📥 onReceive - temp_widget_id: $tempWidgetId")
            
            if (tempWidgetId != -1) {
                // Gerçek widget ID'lerini al
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, IconWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                
                android.util.Log.d("IconWidgetProvider", "🔍 Found ${appWidgetIds.size} widget IDs: ${appWidgetIds.contentToString()}")
                
                // Son eklenen widget'ı güncelle (en yüksek ID)
                val latestWidgetId = appWidgetIds.maxOrNull()
                if (latestWidgetId != null) {
                    android.util.Log.d("IconWidgetProvider", "🎯 Updating latest widget: $latestWidgetId")
                    updateAppWidget(context, appWidgetManager, latestWidgetId, tempWidgetId)
                    
                    // Flutter'a başarı bildirimini gönder
                    notifyFlutterWidgetAdded(context)
                }
            }
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
            android.util.Log.d("IconWidgetProvider", "✅ Notified Flutter about widget success")
        } catch (e: Exception) {
            android.util.Log.e("IconWidgetProvider", "❌ Failed to notify Flutter: ${e.message}")
        }
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        android.util.Log.d("IconWidgetProvider", "🔄 onUpdate called with ${appWidgetIds.size} widgets: ${appWidgetIds.contentToString()}")
        
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, null)
        }
    }

    override fun onEnabled(context: Context) {
        android.util.Log.d("IconWidgetProvider", "✅ Widget enabled")
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            tempWidgetId: Int?
        ) {
            android.util.Log.d("IconWidgetProvider", "📝 Updating widget $appWidgetId (temp: $tempWidgetId)")
            
            val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
            
            // temp ID'den verileri oku
            var iconPath: String? = null
            var packageName: String? = null
            
            var appName: String? = null
            
            if (tempWidgetId != null) {
                iconPath = prefs.getString("WIDGET_ICON_PATH_$tempWidgetId", null)
                packageName = prefs.getString("WIDGET_PACKAGE_NAME_$tempWidgetId", null)
                appName = prefs.getString("WIDGET_APP_NAME_$tempWidgetId", null)
                android.util.Log.d("IconWidgetProvider", "📥 From temp ID $tempWidgetId: icon=$iconPath, pkg=$packageName, name=$appName")
                
                // Gerçek widget ID ile kaydet
                if (iconPath != null && packageName != null) {
                    prefs.edit().apply {
                        putString("WIDGET_ICON_PATH_$appWidgetId", iconPath)
                        putString("WIDGET_PACKAGE_NAME_$appWidgetId", packageName)
                        putString("WIDGET_APP_NAME_$appWidgetId", appName)
                        commit()
                    }
                    android.util.Log.d("IconWidgetProvider", "💾 Saved with real widget ID: $appWidgetId")
                }
            } else {
                // Gerçek ID'den oku
                iconPath = prefs.getString("WIDGET_ICON_PATH_$appWidgetId", null)
                packageName = prefs.getString("WIDGET_PACKAGE_NAME_$appWidgetId", null)
                appName = prefs.getString("WIDGET_APP_NAME_$appWidgetId", null)
                android.util.Log.d("IconWidgetProvider", "📥 From real ID $appWidgetId: icon=$iconPath, pkg=$packageName, name=$appName")
            }

            // RemoteViews oluştur
            val views = RemoteViews(context.packageName, R.layout.widget_icon)

            // İkon yükle - SADECE dosyadan BitmapFactory ile
            var bitmap: Bitmap? = null
            
            if (iconPath != null) {
                val iconFile = File(iconPath)
                android.util.Log.d("IconWidgetProvider", "📂 Checking icon file: $iconPath")
                android.util.Log.d("IconWidgetProvider", "📂 File exists: ${iconFile.exists()}")
                android.util.Log.d("IconWidgetProvider", "📂 File readable: ${iconFile.canRead()}")
                android.util.Log.d("IconWidgetProvider", "📂 File size: ${iconFile.length()} bytes")
                
                if (iconFile.exists() && iconFile.canRead()) {
                    try {
                        bitmap = BitmapFactory.decodeFile(iconPath)
                        if (bitmap != null) {
                            android.util.Log.d("IconWidgetProvider", "✅ Bitmap decoded: ${bitmap.width}x${bitmap.height}, config=${bitmap.config}")
                        } else {
                            android.util.Log.e("IconWidgetProvider", "❌ BitmapFactory returned null!")
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("IconWidgetProvider", "❌ Exception decoding bitmap: ${e.message}")
                        e.printStackTrace()
                    }
                } else {
                    android.util.Log.e("IconWidgetProvider", "❌ File doesn't exist or not readable!")
                }
            } else {
                android.util.Log.e("IconWidgetProvider", "❌ iconPath is null!")
            }
            
            // Bitmap'i widget'a set et
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_icon, bitmap)
                android.util.Log.d("IconWidgetProvider", "✅ Custom icon set successfully!")
            } else {
                android.util.Log.e("IconWidgetProvider", "❌ NO BITMAP - Widget will show default layout image")
            }
            
            // Uygulama ismini set et
            if (appName != null) {
                views.setTextViewText(R.id.widget_app_name, appName)
                android.util.Log.d("IconWidgetProvider", "✅ App name set: $appName")
            } else {
                views.setTextViewText(R.id.widget_app_name, "")
                android.util.Log.w("IconWidgetProvider", "⚠️ No app name available")
            }

            // Tıklama eventi
            if (packageName != null) {
                val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
                if (launchIntent != null) {
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.widget_icon, pendingIntent)
                    android.util.Log.d("IconWidgetProvider", "🎯 Click handler set for: $packageName")
                }
            }

            // Widget'ı güncelle
            appWidgetManager.updateAppWidget(appWidgetId, views)
            android.util.Log.d("IconWidgetProvider", "✅ Widget updated successfully")
        }
    }
}
