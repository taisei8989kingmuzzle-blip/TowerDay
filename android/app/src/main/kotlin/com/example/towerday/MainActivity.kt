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

        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = java.util.Calendar.getInstance()

        calendar.set(
            java.util.Calendar.HOUR_OF_DAY,
            0
        )
        calendar.set(
            java.util.Calendar.MINUTE,
            0
        )
        calendar.set(
            java.util.Calendar.SECOND,
            0
        )
        calendar.set(
            java.util.Calendar.MILLISECOND,
            0
        )

        val startOfDay = calendar.timeInMillis
        val now = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startOfDay,
            now
        )

        var totalTime = 0L

        for (usageStat in stats) {
            totalTime += usageStat.totalTimeInForeground
        }

        return (totalTime / 60000L).toInt()
    }
}
