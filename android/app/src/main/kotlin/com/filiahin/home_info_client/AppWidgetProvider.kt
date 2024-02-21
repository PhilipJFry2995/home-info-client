package com.filiahin.home_info_client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // Pending intent to update counter on button click
                val acUnitBackgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://acunit"))
                setOnClickPendingIntent(R.id.ac_unit_button, acUnitBackgroundIntent)

                val bedBackgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://bed"))
                setOnClickPendingIntent(R.id.bed_button, bedBackgroundIntent)

                val movieBackgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://movie"))
                setOnClickPendingIntent(R.id.movie_button, movieBackgroundIntent)

                val workBackgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://work"))
                setOnClickPendingIntent(R.id.work_button, workBackgroundIntent)

                val powerOffBackgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://poweroff"))
                setOnClickPendingIntent(R.id.power_off_button, powerOffBackgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}