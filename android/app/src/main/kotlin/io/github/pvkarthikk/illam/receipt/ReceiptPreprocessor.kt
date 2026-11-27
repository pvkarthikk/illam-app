package io.github.pvkarthikk.illam.receipt

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * Decodes, auto-orients, downscales, and contrast-enhances receipt photos
 * prior to on-device Tesseract OCR.
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

        val enhanced = stretchReceiptContrast(scaled)
        if (enhanced !== scaled) {
            scaled.recycle()
        }
        return enhanced
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

    private fun stretchReceiptContrast(source: Bitmap): Bitmap {
        val w = source.width
        val h = source.height
        val total = w * h
        if (total <= 0) return source

        val pixels = IntArray(total)
        source.getPixels(pixels, 0, w, 0, 0, w, h)

        val hist = IntArray(256)
        for (i in 0 until total) {
            val p = pixels[i]
            val r = (p ushr 16) and 0xFF
            val g = (p ushr 8) and 0xFF
            val b = p and 0xFF
            val lum = (77 * r + 150 * g + 29 * b) ushr 8
            pixels[i] = lum
            hist[lum]++
        }

        val lowTarget = (total * 0.01).toInt()
        val highTarget = (total * 0.98).toInt()
        var acc = 0
        var lo = 0
        var hi = 255
        var foundLo = false
        for (bin in 0..255) {
            acc += hist[bin]
            if (!foundLo && acc >= lowTarget) {
                lo = bin
                foundLo = true
            }
            if (acc >= highTarget) {
                hi = bin
                break
            }
        }

        val span = hi - lo
        if (span < 24) {
            for (i in 0 until total) {
                val lum = pixels[i]
                pixels[i] = (0xFF shl 24) or (lum shl 16) or (lum shl 8) or lum
            }
        } else {
            val lut = IntArray(256)
            for (v in 0..255) {
                val norm = ((v - lo).toFloat() / span.toFloat()).coerceIn(0f, 1f)
                // Gentle contrast S-stretch around 0.5 while keeping grayscale detail
                // so Tesseract's local Otsu binarizer handles uneven shadows.
                val boosted = (0.5f + (norm - 0.5f) * 1.25f).coerceIn(0f, 1f)
                val out = (boosted * 255f).roundToInt().coerceIn(0, 255)
                lut[v] = (0xFF shl 24) or (out shl 16) or (out shl 8) or out
            }
            for (i in 0 until total) {
                pixels[i] = lut[pixels[i]]
            }
        }

        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        out.setPixels(pixels, 0, w, 0, 0, w, h)
        return out
    }
}
