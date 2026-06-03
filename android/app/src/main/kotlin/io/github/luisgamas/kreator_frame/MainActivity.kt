package io.github.luisgamas.kreator_frame

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val wallpaperChannel = "kreator_frame/wallpaper"
    private val kustomChannel = "kreator_frame/kustom"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wallpaperChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val url = call.argument<String>("url") ?: run {
                            result.error("INVALID_ARGS", "url is required", null)
                            return@setMethodCallHandler
                        }
                        val location = call.argument<Int>("location") ?: 1

                        Thread {
                            try {
                                val service = WallpapersNativeServices(applicationContext)
                                val success = service.applyWallpaper(url, location)
                                Handler(Looper.getMainLooper()).post {
                                    result.success(success)
                                }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("WALLPAPER_ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }

                    "openNativeWallpaperPicker" -> {
                        val url = call.argument<String>("url") ?: run {
                            result.error("INVALID_ARGS", "url is required", null)
                            return@setMethodCallHandler
                        }

                        Thread {
                            try {
                                val service = WallpapersNativeServices(applicationContext)
                                val intent = service.prepareNativeWallpaperIntent(url)
                                Handler(Looper.getMainLooper()).post {
                                    try {
                                        startActivity(intent)
                                        result.success(true)
                                    } catch (e: Exception) {
                                        result.error("WALLPAPER_ERROR", "Failed to launch native picker: ${e.message}", null)
                                    }
                                }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("WALLPAPER_ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }

                    "openWallpaperChooser" -> {
                        val url = call.argument<String>("url") ?: run {
                            result.error("INVALID_ARGS", "url is required", null)
                            return@setMethodCallHandler
                        }

                        Thread {
                            try {
                                val service = WallpapersNativeServices(applicationContext)
                                val intent = service.prepareWallpaperChooserIntent(url)
                                Handler(Looper.getMainLooper()).post {
                                    try {
                                        startActivity(intent)
                                        result.success(true)
                                    } catch (e: Exception) {
                                        result.error("WALLPAPER_ERROR", "Failed to launch wallpaper chooser: ${e.message}", null)
                                    }
                                }
                            } catch (e: Exception) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error("WALLPAPER_ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, kustomChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isKustomAppInstalled" -> {
                        val pkg = call.argument<String>("packageName") ?: run {
                            result.error("INVALID_ARGS", "packageName is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val pm = packageManager
                            pm.getPackageInfo(pkg, 0)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "sendWidgetToKustomApp" -> {
                        val pkg = call.argument<String>("packageName") ?: run {
                            result.error("INVALID_ARGS", "packageName is required", null)
                            return@setMethodCallHandler
                        }
                        val activity = call.argument<String>("editorActivity") ?: run {
                            result.error("INVALID_ARGS", "editorActivity is required", null)
                            return@setMethodCallHandler
                        }
                        val assetPath = call.argument<String>("assetPath") ?: run {
                            result.error("INVALID_ARGS", "assetPath is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val intent = Intent().apply {
                                setComponent(ComponentName(pkg, activity))
                                data = Uri.Builder()
                                    .scheme("kfile")
                                    .authority("${packageName}.kustom.provider")
                                    .appendPath(assetPath)
                                    .build()
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("KUSTOM_ERROR", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
