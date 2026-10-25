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
                    if (!hasUsageAccess()) {
                        result.error(
                            "NO_PERMISSION",
                            "Usage access has not been granted.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        printAppScreenTimes()
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

        
    
    
    
    
    
        
        
        
    private fun getTodayScreenTime(): Int {
        val manager = getSystemService(
            Context.USAGE_STATS_SERVICE
        ) as UsageStatsManager

        val calendar = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }

        val startOfDay = calendar.timeInMillis
        val now = System.currentTimeMillis()

        // Android merges records for each package.
        val stats = manager.queryAndAggregateUsageStats(
            startOfDay,
            now
        )

        // Sum each package's aggregated foreground time.
        val totalMs = stats.values
            .filterNot { it.packageName in excludedPackages }
            .sumOf { it.totalTimeInForeground }

        return (totalMs / 60_000L).toInt()
    }


            private fun getScreenTimeBetween(
            startMillis: Long,
            endMillis: Long
        ): Int {
            val usageStatsManager = getSystemService(
                USAGE_STATS_SERVICE
            ) as android.app.usage.UsageStatsManager

            val usageStats =
                usageStatsManager.queryAndAggregateUsageStats(
                    startMillis,
                    endMillis
                )

            val totalForegroundMillis = usageStats.values
                .filterNot { it.packageName in excludedPackages }
                .sumOf { it.totalTimeInForeground }
            return (totalForegroundMillis / 60_000L).toInt()
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

        val usageStats = usageStatsManager.queryAndAggregateUsageStats(
            calendar.timeInMillis,
            System.currentTimeMillis()
        )

        val pm = packageManager

        android.util.Log.d("TowerScreenTime", "===== APP USAGE TODAY =====")

        usageStats.values
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



