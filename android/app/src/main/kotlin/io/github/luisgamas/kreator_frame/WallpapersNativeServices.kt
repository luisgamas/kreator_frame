package io.github.luisgamas.kreator_frame

import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.content.FileProvider
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class WallpapersNativeServices(private val context: Context) {

    // ============================================================
    // Custom wallpaper application
    // ============================================================

    fun applyWallpaper(url: String, location: Int): Boolean {
        val scaledBitmap = downloadAndProcessBitmap(url)
        applyBitmapAsWallpaper(scaledBitmap, location)
        scaledBitmap.recycle()
        return true
    }

    private fun downloadAndProcessBitmap(url: String): Bitmap {
        // 1. Get screen dimensions (physical pixels)
        val displayMetrics = Resources.getSystem().displayMetrics
        val screenWidth = displayMetrics.widthPixels
        val screenHeight = displayMetrics.heightPixels

        // 2. Download image
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.doInput = true
        connection.connect()
        val originalBitmap = BitmapFactory.decodeStream(connection.inputStream)
        connection.inputStream.close()

        // 3. Center-crop to screen aspect ratio
        val origWidth = originalBitmap.width.toFloat()
        val origHeight = originalBitmap.height.toFloat()
        val screenAspect = screenWidth.toFloat() / screenHeight.toFloat()
        val imageAspect = origWidth / origHeight

        val cropWidth: Float
        val cropHeight: Float

        if (imageAspect > screenAspect) {
            // Image wider than screen → crop width
            cropHeight = origHeight
            cropWidth = cropHeight * screenAspect
        } else {
            // Image taller than screen → crop height
            cropWidth = origWidth
            cropHeight = cropWidth / screenAspect
        }

        val left = ((origWidth - cropWidth) / 2).toInt()
        val top = ((origHeight - cropHeight) / 2).toInt()

        // 4. Crop and scale to screen size
        val croppedBitmap = Bitmap.createBitmap(
            originalBitmap, left, top, cropWidth.toInt(), cropHeight.toInt()
        )
        originalBitmap.recycle()

        val scaledBitmap = Bitmap.createScaledBitmap(croppedBitmap, screenWidth, screenHeight, true)
        croppedBitmap.recycle()

        return scaledBitmap
    }

    private fun applyBitmapAsWallpaper(bitmap: Bitmap, location: Int) {
        val wallpaperManager = android.app.WallpaperManager.getInstance(context)

        val which = when (location) {
            1 -> android.app.WallpaperManager.FLAG_SYSTEM  // Home screen
            2 -> android.app.WallpaperManager.FLAG_LOCK    // Lock screen
            else -> android.app.WallpaperManager.FLAG_SYSTEM or android.app.WallpaperManager.FLAG_LOCK // Both
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            // API 24+: can target FLAG_SYSTEM and/or FLAG_LOCK separately
            wallpaperManager.setBitmap(bitmap, null, true, which)
        } else {
            // API < 24: only home screen supported
            wallpaperManager.setBitmap(bitmap)
        }
    }

    // ============================================================
    // Native Android wallpaper picker
    // ============================================================

    fun prepareNativeWallpaperIntent(url: String): Intent {
        // 1. Download original image to a cache file (no cropping, the system handles it)
        val file = downloadImageToFile(url)

        // 2. Expose the file via FileProvider to get a shareable content URI
        val contentUri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )

        // 3. Build the native crop-and-set intent (shows home/lock/both dialog on Android 7+)
        val intent = android.app.WallpaperManager.getInstance(context)
            .getCropAndSetWallpaperIntent(contentUri)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        // Explicitly grant URI read permissions to all packages that can handle this intent
        // (fixes SecurityException on customized ROMs like Xiaomi's MIUI/HyperOS)
        try {
            val resInfoList = context.packageManager.queryIntentActivities(
                intent,
                android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
            )
            for (resolveInfo in resInfoList) {
                val packageName = resolveInfo.activityInfo.packageName
                context.grantUriPermission(packageName, contentUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return intent
    }

    // ============================================================
    // Wallpaper app chooser (ACTION_ATTACH_DATA)
    // ============================================================

    fun prepareWallpaperChooserIntent(url: String): Intent {
        // 1. Download original image to a separate cache file
        val file = downloadImageToChooserFile(url)

        // 2. Expose the file via FileProvider to get a shareable content URI
        val contentUri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )

        // 3. Build ACTION_ATTACH_DATA intent: Android shows "Apply with..." system bottom sheet
        val attachIntent = Intent(Intent.ACTION_ATTACH_DATA).apply {
            addCategory(Intent.CATEGORY_DEFAULT)
            setDataAndType(contentUri, "image/jpeg")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            putExtra("mimeType", "image/jpeg")
        }

        // Explicitly grant URI read permissions to all packages that can handle the attach intent
        // (fixes SecurityException on customized ROMs like Xiaomi's MIUI/HyperOS)
        try {
            val resInfoList = context.packageManager.queryIntentActivities(
                attachIntent,
                android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
            )
            for (resolveInfo in resInfoList) {
                val packageName = resolveInfo.activityInfo.packageName
                context.grantUriPermission(packageName, contentUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val chooserIntent = Intent.createChooser(attachIntent, null)
        chooserIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        return chooserIntent
    }

    private fun downloadImageToFile(url: String): File {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.doInput = true
        connection.connect()
        val bytes = connection.inputStream.readBytes()
        connection.inputStream.close()

        val file = File(context.cacheDir, "wallpaper_native_picker.jpg")
        file.writeBytes(bytes)
        return file
    }

    private fun downloadImageToChooserFile(url: String): File {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.doInput = true
        connection.connect()
        val bytes = connection.inputStream.readBytes()
        connection.inputStream.close()

        val file = File(context.cacheDir, "wallpaper_chooser.jpg")
        file.writeBytes(bytes)
        return file
    }
}
