package com.thereciprocalsolutions.taxigodriver



import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.io.ByteArrayOutputStream
import java.util.*

class UpiIndiaPlugin(activityFromPrev: Activity) :
    MethodChannel.MethodCallHandler, ActivityResultListener {


    private val CHANNEL = "com.thereciprocalsolutions.silvertaxidriver"

    private val uniqueRequestCode = 5120
    private  var acti: Activity = activityFromPrev
    private var finalResult: MethodChannel.Result? = null
    private var exception = false
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        finalResult = result
        if (call.method == "startTransaction") {
            startTransaction(call, result)
        } else {
            result.notImplemented()
        }
    }

    private fun startTransaction(call: MethodCall, result: MethodChannel.Result) {
        val app: String?

        Log.d("UpiIndia NOTE: ", "Entered in start")

        // Extract the arguments.
        app = if (call.argument<Any?>("app") == null) {
            "in.org.npci.upiapp"
        } else {
            call.argument<String>("app")
        }
        val receiverUpiId = call.argument<String>("receiverUpiId")
        val receiverName = call.argument<String>("receiverName")
        val transactionRefId = call.argument<String>("transactionRefId")
        val transactionNote = call.argument<String>("transactionNote")
        val amount = call.argument<String>("amount")
        val currency = call.argument<String>("currency")
        val url = call.argument<String>("url")
        val merchantId = call.argument<String>("merchantId")

        // Build the query and initiate the transaction.
        try {
            exception = false
            val uriBuilder = Uri.Builder()
            uriBuilder.scheme("upi").authority("pay")
            uriBuilder.appendQueryParameter("pa", receiverUpiId)
            uriBuilder.appendQueryParameter("pn", receiverName)
            uriBuilder.appendQueryParameter("tn", transactionNote)
            uriBuilder.appendQueryParameter("am", amount)
            if (transactionRefId != null) {
                uriBuilder.appendQueryParameter("tr", transactionRefId)
            }
            if (currency == null) {
                uriBuilder.appendQueryParameter("cr", "INR")
            } else uriBuilder.appendQueryParameter("cu", currency)
            if (url != null) {
                uriBuilder.appendQueryParameter("url", url)
            }
            if (merchantId != null) {
                uriBuilder.appendQueryParameter("mc", merchantId)
            }
            val uri = uriBuilder.build()

            // Built Query. Ready to call intent.
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = uri
//            intent.setPackage(app)
            acti.startActivityForResult(intent, uniqueRequestCode)
//            finalResult = result
//            if (isAppInstalled(app)) {
//                activity.startActivityForResult(intent, uniqueRequestCode)
//                finalResult = result
//            } else {
//                Log.d("UpiIndia NOTE: ", "$app not installed on the device.")
//                result.success("app_not_installed")
//            }
        } catch (ex: Exception) {
            exception = true
            Log.d("UpiIndia NOTE: ", "" + ex)
            result.error("FAILED", "invalid_parameters", null)
        }
    }

    // On receiving the response.
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?):Boolean {
        if (uniqueRequestCode == requestCode && finalResult != null) {
            Log.d("UpiIndia NOTE: ", "Entered activity result")

            if (data != null) {
                try {
                    val response = data.getStringExtra("response")
                    if (!exception) finalResult!!.success(response)
                } catch (ex: Exception) {
                    if (!exception) finalResult!!.success("null_response")
                }
            } else {
                Log.d("UpiIndia NOTE: ", "Received NULL, User cancelled the transaction.")
                if (!exception) finalResult!!.success("user_canceled")
            }
        }
        else
        {
            Log.d("UpiIndia NOTE: ", "Failed in activity result")

        }
        return true
    }

    // Method to check if app is already installed or not.
//    private fun isAppInstalled(uri: String?): Boolean {
//        val pm = acti.packageManager
//        try {
//            pm.getPackageInfo(uri!!, PackageManager.GET_ACTIVITIES)
//            return true
//        } catch (pme: PackageManager.NameNotFoundException) {
//            pme.printStackTrace()
//            Log.e("UpiIndia ERROR: ", "" + pme)
//        }
//        return false
//    }// Get Package name of the app.

    // Get Actual name of the app to display.

    // Get app icon as Drawable

    // Convert the Drawable Icon as Bitmap.

    // Convert the Bitmap icon to byte[] received as Uint8List by dart.

    // Put everything in a map

    // Add this app info to the list.
    // Method to get all Apps on device who can handle UPI Intent.


//    companion object {
//        fun registerWith(registrar: PluginRegistry.Registrar) {
//            val channel = MethodChannel(registrar.messenger(), "com.thereciprocalsolutions.silvertaxidriver")
//            val _plugin = UpiIndiaPlugin(registrar)
//            registrar.addActivityResultListener(_plugin)
//            channel.setMethodCallHandler(_plugin)
//        }
//    }


}
