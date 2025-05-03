package com.example.proj_weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.net.URL
import android.graphics.Bitmap
import android.graphics.BitmapFactory

class WeatherWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        appWidgetIds.forEach { appWidgetId ->
            // Intent для открытия приложения
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE
            )

            // Обновление данных
            val views = RemoteViews(context.packageName, R.layout.weather_widget_layout).apply {
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            // Получение данных из SharedPreferences
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            views.setTextViewText(R.id.widget_city, prefs.getString("flutter.city", "Город"))
            views.setTextViewText(R.id.widget_temp, prefs.getString("flutter.temp", "20°C"))
            views.setTextViewText(R.id.widget_condition, prefs.getString("flutter.condition", ""))
            views.setTextViewText(R.id.widget_humidity, prefs.getString("flutter.humidity", ""))
            views.setTextViewText(R.id.widget_wind, prefs.getString("flutter.wind", ""))

            val iconUrl = prefs.getString("flutter.icon_url", "//cdn.weatherapi.com/weather/64x64/day/113.png")

            // Загружаем иконку асинхронно
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val bitmap = loadBitmapFromUrl(iconUrl)
                    views.setImageViewBitmap(R.id.widget_icon, bitmap)
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                } catch (e: Exception) {
                    Log.e("Widget", "Error loading icon: ${e.message}")
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
    private fun loadBitmapFromUrl(url: String?): Bitmap? {
        if (url.isNullOrEmpty()) return null
        return try {
            val inputStream = URL(url).openStream()
            BitmapFactory.decodeStream(inputStream)
        } catch (e: Exception) {
            null
        }
    }
}
