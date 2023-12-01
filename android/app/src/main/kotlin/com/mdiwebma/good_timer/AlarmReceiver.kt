package com.mdiwebma.good_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        MyNativePlugin.onReceiveAlarm(context, intent)
    }
}
