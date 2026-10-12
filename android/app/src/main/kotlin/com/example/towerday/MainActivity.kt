package com.example.towerday

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "my_little_tower/screen_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "hasUsageAccess" -> {
                    result.success(hasUsageAccess())
                }

                "openUsageAccessSettings" -> {
                    openUsageAccessSettings()
                    result.success(null)
                }

                "getTodayScreenTime" -> {
                    if (!hasUsageAccess()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access has not been granted.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val minutes = getTodayScreenTime()
                        result.success(minutes)
                    } catch (e: Exception) {
                        result.error(
                            "USAGE_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )

        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }

        
    
    
    
    
    private fun getTodayScreenTime(): Int {
        val manager =
            getSystemService(Context.USAGE_STATS_SERVICE)
                as UsageStatsManager

        val calendar = java.util.Calendar.getInstance()
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)

        val startOfDay = calendar.timeInMillis
        val now = System.currentTimeMillis()

        val events = manager.queryEvents(startOfDay, now)
        val event = android.app.usage.UsageEvents.Event()

        var screenIsOn = false
        var screenOnStart = 0L
        var totalScreenOnMs = 0L
        var sawScreenEvent = false

        while (events.hasNextEvent()) {
            events.getNextEvent(event)

            when (event.eventType) {
                android.app.usage.UsageEvents.Event.SCREEN_INTERACTIVE -> {
                    if (!screenIsOn) {
                        screenIsOn = true
                        screenOnStart = event.timeStamp
                    }
                    sawScreenEvent = true
                }

                android.app.usage.UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    if (screenIsOn) {
                        totalScreenOnMs +=
                            event.timeStamp - screenOnStart
                    } else if (!sawScreenEvent) {
                        // The first recorded event is screen-off.
                        // The state at midnight is unknown, so use
                        // an estimate for this initial interval.
                        totalScreenOnMs +=
                            event.timeStamp - startOfDay
                    }

                    screenIsOn = false
                    screenOnStart = 0L
                    sawScreenEvent = true
                }
            }
        }

        // If the screen is still interactive, count up to now.
        if (screenIsOn && now > screenOnStart) {
            totalScreenOnMs += now - screenOnStart
        }

        val minutes = (totalScreenOnMs / 60_000L).toInt()

        android.util.Log.d(
            "TowerScreenTime",
            "SCREEN-ON TOTAL: $minutes minutes"
        )

        return minutes
    }


    
    private fun debugInstagramUsage() {
        val manager =
            getSystemService(Context.USAGE_STATS_SERVICE)
                as UsageStatsManager

        val calendar = java.util.Calendar.getInstance()
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)

        val stats = manager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            calendar.timeInMillis,
            System.currentTimeMillis()
        )

        for (stat in stats) {
            if (stat.packageName == "com.instagram.android") {
                android.util.Log.d(
                    "TowerScreenTime",
                    "INSTAGRAM RECORD: " +
                        "first=${stat.firstTimeStamp}, " +
                        "last=${stat.lastTimeStamp}, " +
                        "used=${stat.totalTimeInForeground / 60000L} min"
                )
            }
        }
    }




}
