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
import android.app.usage.UsageEvents

class MainActivity : FlutterActivity() {

    private val CHANNEL = "my_little_tower/screen_time"

    private val excludedPackages = setOf(
        "com.android.systemui",
        "com.sec.android.app.launcher",
        "com.android.incallui",
    )

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
                    android.util.Log.d(
                        "TowerScreenTime",
                        "DEBUG: getTodayScreenTime handler reached"
                    )

                
                    if (!hasUsageAccess()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access has not been granted.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        android.util.Log.e(
                            "TowerDebug",
                            "TEST BUILD 12345 - getTodayScreenTime reached"
                        )

                        printAppScreenTimes()
                        debugInstagramEvents()

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

                "getScreenTimeForDate" -> {
                    if(!hasUsageAccess()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access has not been granted.",
                            null
                        )
                        return@setMethodCallHandler
                    }
                    val startMillis = call.argument<Long>("startMillis")
                    val endMillis = call.argument<Long>("endMillis")

                    if (startMillis == null || endMillis == null || endMillis <= startMillis) {
                        result.error(
                            "INVALID_DATE_RANGE",
                            "A valid start and end time are required.",
                            null
                        )
                    } else {
                        try {
                            printAppScreenTimes()
                            val minutes = getScreenTimeBetween(
                                startMillis, 
                                endMillis
                            )
                            result.success(minutes)
                        } catch (e: Exception) {
                            result.error(
                                "SCREEN_TIME_ERROR",
                                e.message,
                                null
                            )
                        }
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

        
    
    
    
    
    
        
        
        
        private fun getScreenTimeBetween(
            startMillis: Long,
            endMillis: Long
        ): Int {
        return getScreenOnTimeBetween(startMillis, endMillis)
        }

        private fun getTodayScreenTime(): Int {
            return getScreenOnTimeBetween(
                getStartOfScreenTimeDay(),
                System.currentTimeMillis()
            )
        }

        private fun getScreenOnTimeBetween(
            startMillis: Long,
            endMillis: Long
        ): Int {
            if (android.os.Build.VERSION.SDK_INT < 28) {
                throw IllegalStateException(
                    "Screen-on event tracking requires Android 9 or later."
                )
            }

    val manager =
        getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    // Look back to determine whether the screen was already on at start.
    val queryStart = (startMillis - 24 * 60 * 60 * 1000L).coerceAtLeast(0L)
    val events = manager.queryEvents(queryStart, endMillis)
        ?: throw IllegalStateException("Android returned no usage events.")

    val event = UsageEvents.Event()
    var screenOn = false
    var segmentStart = startMillis
    var totalMillis = 0L

    while (events.hasNextEvent()) {
        events.getNextEvent(event)
        val time = event.timeStamp

        when (event.eventType) {
            UsageEvents.Event.SCREEN_INTERACTIVE -> {
                if (time < startMillis) {
                    screenOn = true
                    segmentStart = startMillis
                } else if (!screenOn) {
                    screenOn = true
                    segmentStart = time
                }
            }

            UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                if (screenOn) {
                    totalMillis +=
                        (time - segmentStart).coerceAtLeast(0L)
                    screenOn = false
                }
            }
        }
    }

    if (screenOn) {
        totalMillis += (endMillis - segmentStart).coerceAtLeast(0L)
    }

    return (totalMillis / 60_000L).toInt()
    }

        private fun debugInstagramEvents() {
            val manager = getSystemService(
                Context.USAGE_STATS_SERVICE
            ) as UsageStatsManager

            val calendar = java.util.Calendar.getInstance().apply {
                set(java.util.Calendar.HOUR_OF_DAY, 0)
                set(java.util.Calendar.MINUTE, 0)
                set(java.util.Calendar.SECOND, 0)
                set(java.util.Calendar.MILLISECOND, 0)
            }

            val start = calendar.timeInMillis
            val end = System.currentTimeMillis()

            val events = manager.queryEvents(start, end)
            val event = android.app.usage.UsageEvents.Event()

            android.util.Log.d(
                "TowerScreenTime",
                "===== INSTAGRAM FOREGROUND EVENTS ====="
            )

            while (events.hasNextEvent()) {
                events.getNextEvent(event)

                if (event.packageName == "com.instagram.android") {
                    android.util.Log.d(
                        "TowerScreenTime",
                        "time=${java.util.Date(event.timeStamp)}, " +
                            "type=${event.eventType}"
                    )
                }
            }

            android.util.Log.d(
                "TowerScreenTime",
                "===== END INSTAGRAM EVENTS ====="
            )
        }

        private fun getStartOfScreenTimeDay(): Long {
            val calendar = java.util.Calendar.getInstance()

            // Before 6:00 a.m., use 6:00 a.m. yesterday.
            if (calendar.get(java.util.Calendar.HOUR_OF_DAY) < 6) {
                calendar.add(java.util.Calendar.DAY_OF_YEAR, -1)
            }

            calendar.set(java.util.Calendar.HOUR_OF_DAY, 6)
            calendar.set(java.util.Calendar.MINUTE, 0)
            calendar.set(java.util.Calendar.SECOND, 0)
            calendar.set(java.util.Calendar.MILLISECOND, 0)

            return calendar.timeInMillis
        }

        private fun printAppScreenTimes() {
        val usageStatsManager = getSystemService(
            android.content.Context.USAGE_STATS_SERVICE
        ) as android.app.usage.UsageStatsManager

        val calendar = java.util.Calendar.getInstance()
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)

        android.util.Log.d(
            "TowerScreenTime",
            "QUERY RANGE: start=${java.util.Date(calendar.timeInMillis)}, " +
                "end=${java.util.Date(System.currentTimeMillis())}"
        )

        val usageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            calendar.timeInMillis,
            System.currentTimeMillis()
        )

        val pm = packageManager

        android.util.Log.d("TowerScreenTime", "===== APP USAGE TODAY =====")

        usageStats
            .filter { it.totalTimeInForeground > 0 }
            .sortedByDescending { it.totalTimeInForeground }
            .forEach { stats ->
                val packageName = stats.packageName

                val appName = try {
                    pm.getApplicationLabel(
                        pm.getApplicationInfo(packageName, 0)
                    ).toString()
                } catch (_: Exception) {
                    packageName
                }

                val minutes = stats.totalTimeInForeground / 60000.0

                android.util.Log.d(
                    "TowerScreenTime",
                    "$appName | $packageName | %.1f minutes".format(minutes)
                )
            }

        android.util.Log.d("TowerScreenTime", "===== END APP USAGE =====")
    }  

    
}



