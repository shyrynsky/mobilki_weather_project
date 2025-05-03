package com.example.proj_weather // Замените на ваш реальный пакет

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "widget_channel"
    private lateinit var appWidgetManager: AppWidgetManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appWidgetManager = AppWidgetManager.getInstance(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                // Получаем ID всех экземпляров виджета
                val componentName = ComponentName(this, WeatherWidget::class.java)
                val ids = appWidgetManager.getAppWidgetIds(componentName)

                // Создаем Intent для обновления
                val updateIntent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                    component = componentName
                }

                // Отправляем broadcast
                sendBroadcast(updateIntent)
                result.success(ids.size)
            } else {
                result.notImplemented()
            }
        }
    }
}