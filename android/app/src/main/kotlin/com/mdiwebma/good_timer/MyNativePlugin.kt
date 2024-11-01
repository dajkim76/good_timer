package com.mdiwebma.good_timer

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.startActivity
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class MyNativePlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel : MethodChannel
    private var focusPlayer: MediaPlayer? = null
    private var restPlayer: MediaPlayer? = null
    private var activity: Activity? = null

    fun setActivity(activity: Activity) {
        this.activity = activity
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.mdiwebma.good_timer")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getAppVersionName") {
            try {
                val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
                val versionName = packageInfo.versionName
                result.success(versionName)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "setAlarm") {
            try {
                val id = call.argument<Int>("extra_id")!!
                val rtcTimeMillis = call.argument<Long>("extra_rtcTimeMillis")!!
                val wakeUp = call.argument<Boolean>("extra_wakeUp")!!
                val succeeded = setAlarm(id, rtcTimeMillis, wakeUp)
                if (succeeded) result.success(true) else result.error("setAlarm failed", null, null)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "cancelAlarm") {
            try {
                val id = call.argument<Int>("extra_id")!!
                val succeeded = cancelAlarm(id);
                if (succeeded) result.success(true) else result.error("cancelAlarm failed", null, null)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "playSound") {
            try {
                val id = call.argument<Int>("extra_id")!!
                val succeeded = playSound(id);
                if (succeeded) result.success(true) else result.error("playSound failed", null, null)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "ignoreBatteryOptimization") {
            try {
                val retValue = ignoreBatteryOptimization()
                result.success(retValue)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "isIgnoreBatteryOptimization") {
            result.success(isIgnoreBatteryOptimization())
        } else if (call.method == "openAppMarketPage") {
            try {
                openAppMarketPage()
                result.success(true)
            } catch (ex: Exception) {
                result.error(ex.toString(), null, null)
            }
        } else if (call.method == "querySettingAlarms") {
            if (Build.VERSION.SDK_INT >= 31 /*Android 12*/) {
                val powerManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                return if (powerManager.canScheduleExactAlarms()) {
                    result.success(1)
                } else {
                    result.success(0)
                }
            } else {
                result.success(-1)
            }
        } else if (call.method == "openSettingAlarms") {
            if (Build.VERSION.SDK_INT >= 31 /*Android 12*/) {
                try {
                    val intent = Intent(
                        android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                        Uri.parse("package:" + context.getPackageName())
                    )
                    activity?.startActivity(intent)
                    result.success(true)
                } catch (ex: Exception) {
                    result.error(ex.toString(), null, null)
                }
            } else {
                result.success(false)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        activity = null
        try {
            focusPlayer?.release()
            restPlayer?.release()
            cancelAlarm(1)
        }catch (ex: Exception) {
            Log.e(TAG, ex.toString(), ex)
            showErrorToast(context, ex)
        }
    }

    private fun setAlarm(id: Int, rtcTimeMillis: Long, wakeUp: Boolean) : Boolean {
        if (rtcTimeMillis < System.currentTimeMillis()) {
            Log.e(TAG, "setAlarm time is past")
            return false
        }
        val alarmManager: AlarmManager = context.getSystemService(Activity.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= 31 /*Android 12*/) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, rtcTimeMillis, getPendingIntent(id, wakeUp))
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, rtcTimeMillis, getPendingIntent(id, wakeUp))
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, rtcTimeMillis, getPendingIntent(id, wakeUp))
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, rtcTimeMillis, getPendingIntent(id, wakeUp))
        }
        Log.d(TAG, "setAlarm done")
        return true
    }

    private fun getPendingIntent(id: Int, wakeUp: Boolean): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java)
            .putExtra("extra_id", id)
            .putExtra("extra_wakeUp", wakeUp)

        return PendingIntent.getBroadcast(context, id, intent, if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0 )
    }

    private fun cancelAlarm(id: Int): Boolean {
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_NO_CREATE  or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0)
        )
        if (pendingIntent != null) {
            val alarmManager: AlarmManager = context.getSystemService(Activity.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "cancelAlarm >> cancel")
            return true
        }
        Log.e(TAG, "cancelAlarm >> not found")
        return false
    }

    private fun playSound(id: Int): Boolean {
        wakeUpScreen2(context, true)
        if (id == 0) {
            val player: MediaPlayer = focusPlayer ?: MediaPlayer.create(context, R.raw.focus).also {
                focusPlayer = it
            }
            player.start()
        } else if (id == 1) {
            val player: MediaPlayer = restPlayer ?: MediaPlayer.create(context, R.raw.rest).also {
                restPlayer = it
            }
            player.start()
        } else {
            Log.e(TAG, "playSound failed: no id")
            return false
        }
        return true
    }

    private fun ignoreBatteryOptimization(): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // not supported
            return -1
        }
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        if (powerManager.isIgnoringBatteryOptimizations(context.packageName)
        ) {
            // already ignored
            return 1
        }
        try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.data = Uri.parse("package:" + context.packageName)
            if (activity != null) {
                activity?.startActivity(intent)
            } else {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent)
            }
            return 0
        } catch (ex: ActivityNotFoundException) {
            throw ex
        }
    }

    private fun isIgnoreBatteryOptimization(): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return -1;
        }
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (powerManager.isIgnoringBatteryOptimizations(context.packageName)
        ) {
            1
        } else {
            0
        }
    }

    fun openAppMarketPage() {
        try {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse("market://details?id=com.mdiwebma.good_timer")
            activity?.startActivity(intent)
        } catch (ex: ActivityNotFoundException) {
            Log.e(TAG, ex.toString(), ex)
            throw  ex
        }
    }

    companion object {
        const val TAG = "GoodTimerNativePlugin"

        fun onReceiveAlarm(context: Context, intent: Intent) {
            val wakeUp = intent.getBooleanExtra("extra_wakeUp", false)
            Log.d(TAG, "onReceiveAlarm: wakeUp=$wakeUp")
            //Toast.makeText(context, "onReceiverAlarm wakeUp=$wakeUp", Toast.LENGTH_SHORT).show()
            if (wakeUp) {
                wakeUpScreen2(context, true)
            } else {
                bringAppToForeground(context)
            }
        }

        fun wakeUpScreen(context: Context) {
            val powerManager: PowerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!powerManager.isScreenOn()) {
                val wakeLock: PowerManager.WakeLock = powerManager.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                    context.packageName
                )
                wakeLock.acquire(10*60*1000L /*10 minutes*/)
                wakeLock.release()
            }
        }

        fun wakeUpScreen2(context: Context, bringAppToForeground: Boolean) {
            val powerManager: PowerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock: PowerManager.WakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE, "AlarmBroadcastReceiver:MyWakeLock"
            )
            wakeLock.acquire(3 * 60 * 1000L /*3 minutes*/)
            if (bringAppToForeground) bringAppToForeground(context)
            wakeLock.release();
        }

        // FIXME NOT WORKING
        fun bringAppToForeground(context: Context) : Boolean {
            try {
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                intent!!.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                context.startActivity(intent)
                return true
            }catch (ex: Exception) {
                Log.e(TAG, ex.toString(), ex)
                return false
            }
        }

        fun showErrorToast(context: Context, ex: Exception) {
            Toast.makeText(context, ex.toString(), Toast.LENGTH_LONG).show()
        }
    }
}
