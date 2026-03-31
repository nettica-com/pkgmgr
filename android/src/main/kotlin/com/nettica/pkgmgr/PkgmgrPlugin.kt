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

  private val iconSize = 96

  private fun loadIconBase64(pm: android.content.pm.PackageManager, app: android.content.pm.ApplicationInfo): String? {
    return try {
      val iconDrawable = pm.getApplicationIcon(app)
      val iconClass = iconDrawable::class.java.name
      val iconBitmap: android.graphics.Bitmap? = if (iconDrawable is android.graphics.drawable.BitmapDrawable) {
        android.graphics.Bitmap.createScaledBitmap(iconDrawable.bitmap, iconSize, iconSize, true)
      } else {
        try {
          val bitmap = android.graphics.Bitmap.createBitmap(iconSize, iconSize, android.graphics.Bitmap.Config.ARGB_8888)
          val canvas = android.graphics.Canvas(bitmap)
          iconDrawable.setBounds(0, 0, iconSize, iconSize)
          iconDrawable.draw(canvas)
          bitmap
        } catch (ex: Exception) {
          android.util.Log.e("PkgmgrPlugin", "Could not convert $iconClass to bitmap for ${app.packageName}", ex)
          null
        }
      }
      if (iconBitmap == null) return null
      val stream = java.io.ByteArrayOutputStream()
      iconBitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
      android.util.Base64.encodeToString(stream.toByteArray(), android.util.Base64.NO_WRAP)
    } catch (e: Exception) {
      android.util.Log.e("PkgmgrPlugin", "Failed to load icon for ${app.packageName}", e)
      null
    }
  }

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
        if (name.isEmpty() || name == packageName) continue
        val iconBase64 = loadIconBase64(pm, app) ?: continue
        appList.add(mapOf("name" to name, "package" to packageName, "icon" to iconBase64))
      } catch (e: Exception) {
        android.util.Log.e("PkgmgrPlugin", "Failed to process app: ${app.packageName}", e)
      }
    }
    return appList
  }

  private fun getInstalledAppsInfo(context: android.content.Context, showSystem: Boolean): List<Map<String, String?>> {
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
        if (name.isEmpty() || name == packageName) continue
        appList.add(mapOf("name" to name, "package" to packageName, "icon" to null))
      } catch (e: Exception) {
        android.util.Log.e("PkgmgrPlugin", "Failed to process app: ${app.packageName}", e)
      }
    }
    return appList
  }

  private fun getAppIcon(context: android.content.Context, packageId: String): String? {
    return try {
      val pm = context.packageManager
      val app = pm.getApplicationInfo(packageId, android.content.pm.PackageManager.GET_META_DATA)
      loadIconBase64(pm, app)
    } catch (e: Exception) {
      android.util.Log.e("PkgmgrPlugin", "Failed to get icon for $packageId", e)
      null
    }
  }
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getInstalledApps" -> {
        val context = applicationContext
        if (context == null) { result.error("NO_CONTEXT", "Application context is null", null); return }
        val showSystem = call.getBooleanArg("showSystem", false)
        mainScope.launch {
          val appList = withContext(Dispatchers.Default) { getInstalledApps(context, showSystem) }
          result.success(appList)
        }
      }
      "getInstalledAppsInfo" -> {
        val context = applicationContext
        if (context == null) { result.error("NO_CONTEXT", "Application context is null", null); return }
        val showSystem = call.getBooleanArg("showSystem", false)
        mainScope.launch {
          val appList = withContext(Dispatchers.Default) { getInstalledAppsInfo(context, showSystem) }
          result.success(appList)
        }
      }
      "getAppIcon" -> {
        val context = applicationContext
        if (context == null) { result.error("NO_CONTEXT", "Application context is null", null); return }
        val packageId = call.argument<String>("packageId")
        if (packageId == null) { result.error("INVALID_ARG", "packageId is required", null); return }
        mainScope.launch {
          val icon = withContext(Dispatchers.Default) { getAppIcon(context, packageId) }
          result.success(icon)
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
