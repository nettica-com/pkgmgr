package com.nettica.pkgmgr

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/** PkgmgrPlugin */

class PkgmgrPlugin: FlutterPlugin, MethodCallHandler {
  private val mainScope = CoroutineScope(Dispatchers.Main)
  private lateinit var channel : MethodChannel
  private var applicationContext: android.content.Context? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pkgmgr")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  // Helper to extract optional boolean argument from MethodCall
  private fun MethodCall.getBooleanArg(key: String, default: Boolean): Boolean {
    val arg = this.argument<Boolean>(key)
    return arg ?: default
  }

  // Overload getInstalledApps to accept showSystem
  private fun getInstalledApps(context: android.content.Context, showSystem: Boolean): List<Map<String, String?>> {
    val pm = context.packageManager
    val apps = pm.getInstalledApplications(android.content.pm.PackageManager.GET_META_DATA)
      .filter { appInfo ->
        showSystem || (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) == 0 || appInfo.packageName == "com.android.chrome"
      }
    val appList = mutableListOf<Map<String, String?>>()
    for (app in apps) {
      try {
        val name = pm.getApplicationLabel(app).toString()
        val packageName = app.packageName
        if (name.isEmpty() || name == packageName) {
          android.util.Log.e("PkgmgrPlugin", "Skipping app with empty name or name equals package: $name ($packageName)")
          continue
        }
        android.util.Log.e("PkgmgrPlugin", "Processing app: $name ($packageName)")
        val iconDrawable = pm.getApplicationIcon(app)
        val iconClass = iconDrawable::class.java.name
        var iconBitmap: android.graphics.Bitmap? = null
        if (iconDrawable is android.graphics.drawable.BitmapDrawable) {
          iconBitmap = iconDrawable.bitmap
        } else {
          try {
            val width = iconDrawable.intrinsicWidth.takeIf { it > 0 } ?: 96
            val height = iconDrawable.intrinsicHeight.takeIf { it > 0 } ?: 96
            val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bitmap)
            iconDrawable.setBounds(0, 0, width, height)
            iconDrawable.draw(canvas)
            iconBitmap = bitmap
            android.util.Log.e("PkgmgrPlugin", "Converted $iconClass to bitmap for $name ($packageName)")
          } catch (ex: Exception) {
            android.util.Log.e("PkgmgrPlugin", "Could not convert $iconClass to bitmap for $name ($packageName)", ex)
          }
        }
        if (iconBitmap == null) {
          android.util.Log.e("PkgmgrPlugin", "No valid icon bitmap for $name ($packageName), type: $iconClass")
          continue
        }
        val stream = java.io.ByteArrayOutputStream()
        iconBitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
        val iconBase64 = android.util.Base64.encodeToString(stream.toByteArray(), android.util.Base64.NO_WRAP)
        appList.add(mapOf(
          "name" to name,
          "package" to packageName,
          "icon" to iconBase64
        ))
      } catch (e: Exception) {
        android.util.Log.e("PkgmgrPlugin", "Failed to process app: ${app.packageName}", e)
        continue
      }
    }
    return appList
  }
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getInstalledApps" -> {
        val context = applicationContext
        if (context == null) {
          result.error("NO_CONTEXT", "Application context is null", null)
          return
        }
        val showSystem = call.getBooleanArg("showSystem", false)
        mainScope.launch {
          val appList = withContext(Dispatchers.Default) {
            getInstalledApps(context, showSystem)
          }
          result.success(appList)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    applicationContext = null
    mainScope.cancel()
  }
}
