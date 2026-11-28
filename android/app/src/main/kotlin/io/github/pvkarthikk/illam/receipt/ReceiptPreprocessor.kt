package io.github.pvkarthikk.illam.receipt

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * Decodes, auto-orients, and downscales receipt photos prior to on-device ML Kit OCR.
 */
object ReceiptPreprocessor {
    private const val MAX_DIMENSION = 2000

    fun prepare(path: String, extraRotationDegrees: Int): Bitmap? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

        val decodeOpts = BitmapFactory.Options().apply {
            inSampleSize = computeSampleSize(bounds.outWidth, bounds.outHeight, MAX_DIMENSION)
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val decoded = BitmapFactory.decodeFile(path, decodeOpts) ?: return null

        val exifRotation = readExifTransform(path)
        val normalized = applyTransform(decoded, exifRotation, extraRotationDegrees)
        if (normalized !== decoded) {
            decoded.recycle()
        }

        val scaled = downscaleIfNeeded(normalized, MAX_DIMENSION)
        if (scaled !== normalized) {
            normalized.recycle()
        }
        return scaled
    }

    private fun computeSampleSize(width: Int, height: Int, maxDim: Int): Int {
        var sample = 1
        val largest = max(width, height)
        while ((largest / sample) > maxDim * 2) {
            sample *= 2
        }
        return sample
    }

    private fun readExifTransform(path: String): Matrix {
        val matrix = Matrix()
        val orientation = try {
            ExifInterface(path).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL,
            )
        } catch (_: Throwable) {
            ExifInterface.ORIENTATION_NORMAL
        }
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                matrix.postRotate(180f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
        }
        return matrix
    }

    private fun applyTransform(
        source: Bitmap,
        exifMatrix: Matrix,
        extraRotationDegrees: Int,
    ): Bitmap {
        val extra = ((extraRotationDegrees % 360) + 360) % 360
        if (exifMatrix.isIdentity && extra == 0) {
            return source
        }
        val combined = Matrix(exifMatrix)
        if (extra != 0) {
            combined.postRotate(extra.toFloat())
        }
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, combined, true)
    }

    private fun downscaleIfNeeded(source: Bitmap, maxDim: Int): Bitmap {
        val w = source.width
        val h = source.height
        val largest = max(w, h)
        if (largest <= maxDim) return source
        val scale = maxDim.toFloat() / largest.toFloat()
        val targetW = max(1, (w * scale).roundToInt())
        val targetH = max(1, (h * scale).roundToInt())
        return Bitmap.createScaledBitmap(source, targetW, targetH, true)
    }
}
