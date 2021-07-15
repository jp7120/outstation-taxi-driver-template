

package com.thereciprocalsolutions.taxigodriver

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Base64.*
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.wangsun.upi.payment.UpiPayment
import com.wangsun.upi.payment.model.PaymentDetail
import com.wangsun.upi.payment.model.TransactionDetails
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.jetbrains.anko.AnkoLogger
import org.jetbrains.anko.info
import java.util.*


class MainActivity: FlutterFragmentActivity(), AnkoLogger {
    private val CHANNEL = "com.thereciprocalsolutions.silvertaxidriver"

//    private val CHANNEL = "com.thereciprocalsolutions.silvertaxidriver"

    private val uniqueRequestCode = 5120
    private  var acti: Activity = this
    private var finalResult: MethodChannel.Result? = null
    private var exception = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);






        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler{
                    call,result->
                if (call.method == "startTransaction") {

//                    startTransaction(call, result)
    finalResult =result

                    var appName = call.argument<Any?>("app").toString();
                    var upiId = call.argument<Any?>("receiverUpiId").toString();
                    var merchName = call.argument<Any?>("receiverName").toString();
                    var merchCode = call.argument<Any?>("merchantId").toString();
                    var transRefer = call.argument<Any?>("transactionRefId").toString();
                    var cust = call.argument<Any?>("driver").toString();
                    var amounts = call.argument<Any?>("amount").toString();
                    var description = call.argument<Any?>("transactionNote").toString();

                    startUpiPayment(cust,amounts,appName,upiId,description,merchName,merchCode, transRefer)
                } else {
                    result.notImplemented()
                }
            }
    }

//    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        finalResult = result
//        if (call.method == "startTransaction") {
//            startTransaction(call, result)
//        } else {
//            result.notImplemented()
//        }
//    }

    var i =0;
    private fun startUpiPayment(name: String, amount:String, app:String,upiId:String,note: String,merchName: String,merchCode:String,transRef:String){
        val payment = PaymentDetail(
            vpa=upiId,
            name = merchName,
            payeeMerchantCode = merchCode,
            //txnId = "",
            txnRefId = transRef,
            description = note,
            amount = amount)


        try {

            UpiPayment(this)
                .setApp(app)
                .setPaymentDetail(payment)
                .setUpiApps(UpiPayment.UPI_APPS)
                .setCallBackListener(object : UpiPayment.OnUpiPaymentListener {
                    override fun onSubmitted(data: TransactionDetails) {
                        info { "transaction pending: $data" }
//                        Toast.makeText(
//                            this@MainActivity,
//                            "transaction pending: $data",
//                            Toast.LENGTH_LONG
//                        ).show()
                        var approvNum : String
                        var gson = Gson()
                        var jsonfile = gson.toJson(data)
                        info { "JSON "+jsonfile }
                        if(data.approvalRefNo==null)
                            approvNum= "not available"
                        else
                            approvNum = data.approvalRefNo.toString()
                        var responseJSON="""{"appName":"${data.appName}","responseCode":"00","status":"${data.status}","transactionId":"${data.transactionId}","transactionRefId":"${data.transactionRefId}","approvalRefNo":"${approvNum}"}"""
                        info { "JSON "+responseJSON }
                        finalResult?.success(responseJSON)
                    }

                    override fun onSuccess(data: TransactionDetails) {
                        info { "transaction success: $data" }
//                        Toast.makeText(
//                            this@MainActivity,
//                            "Transaction success: $data",
//                            Toast.LENGTH_LONG
//                        ).show()
                        var approvNum : String
                        var gson = Gson()
                        var jsonfile = gson.toJson(data)
                        info { "JSON "+jsonfile }
                        if(data.approvalRefNo==null)
                            approvNum= "not available"
                        else
                            approvNum = data.approvalRefNo.toString()
                        var responseJSON="""{"appName":"${data.appName}","responseCode":"00","status":"${data.status}","transactionId":"${data.transactionId}","transactionRefId":"${data.transactionRefId}","approvalRefNo":"${approvNum}","amount": ${amount}}"""
                        info { "JSON "+responseJSON }
                        finalResult?.success(responseJSON)
                    }

                    override fun onError(message: String) {
                        info { "transaction failed: $message" }

                        if(message=="Problem with Payment App")

                        {
                            Toast.makeText(
                                this@MainActivity,
                                "There is a Problem with Payment App. Kindly restart the phone check!",
                                Toast.LENGTH_LONG
                            ).show()

                        }
                        else {


                            Toast.makeText(
                                this@MainActivity,
                                "Transaction failed: $message",
                                Toast.LENGTH_LONG
                            ).show()
                        }

                        // FOR TESTING THE SUCCESS RESPONSE
                     /*   var data = TransactionDetails(transactionId="YBLb55b5b2d48374146a9c9b829c1c15056", responseCode="0", approvalRefNo=null, status="Success", transactionRefId="BCR2DN6T36K6XTS3")
                        var approvNum : String
                        var gson = Gson()
                        var jsonfile = gson.toJson(data)
                        if(data.approvalRefNo==null)
                            approvNum= "not available"
                        else
                            approvNum = data.approvalRefNo.toString()
                        var responseJSON="""{"appName":"${data.appName}","responseCode":"00","status":"${data.status}","transactionId":"${data.transactionId}","transactionRefId":"${data.transactionRefId}","approvalRefNo":"${approvNum}"}"""
                        finalResult?.success(responseJSON)*/

                        // FOR SENDING ERROR RESPONSE
                        i++;
//                        if(i%2!=0)
                            finalResult?.error(400.toString(), message.toString(), "FAILED")

//                        else
//                            info { "Result already sent" }

//
                    }
                }).pay()

        }catch (e: Exception)
        {
            info { "Exception in sending result $e" }
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
            intent.setPackage(app)
            finalResult = result
            acti.startActivityForResult(intent, uniqueRequestCode)

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
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        if (uniqueRequestCode == requestCode && finalResult != null) {
//            Log.d("UpiIndia NOTE: ", "Entered activity result")
//
//            if (data != null) {
//                try {
//                    val response = data.getStringExtra("response")
//                    if (!exception) {
//                        finalResult!!.success(response)
//                        Toast.makeText(this,"Payment success with $response",Toast.LENGTH_LONG).show()
//                    }
//                } catch (ex: Exception) {
//                    Toast.makeText(this,"Payment Failed ",Toast.LENGTH_LONG).show()
//
//                    if (!exception) finalResult!!.success("null_response")
//                }
//            } else {
//                Log.d("UpiIndia NOTE: ", "Received NULL, User cancelled the transaction.")
//                if (!exception) finalResult!!.success("user_canceled")
//            }
//        }
//        else
//        {
//            Log.d("UpiIndia NOTE: ", "Result not defined Failed in activity result")
//
//        }
//
//    }

    //    private fun startUpiPayment(name: String, amount:String){
//        val payment = PaymentDetail(
//            vpa="8885777222@okbizaxis",
//            name = "SILVER TAXI",
//            payeeMerchantCode = "4121",
//            //txnId = "",
//            txnRefId = "BCR2DN6T36K6XTS3",
//            description = "WALLET RECHARGE BY DRIVER $name ",
//            amount = "$amount")
//
//
//        UpiPayment(this)
//            .setPaymentDetail(payment)
//            .setUpiApps(UpiPayment.UPI_APPS)
//            .setCallBackListener(object : UpiPayment.OnUpiPaymentListener{
//                override fun onSubmitted(data: TransactionDetails) {
//
//                    info { "transaction pending: $data" }
//                    Toast.makeText(this@MainActivity,"transaction pending: $data", Toast.LENGTH_LONG).show()
//                }
//                override fun onSuccess(data: TransactionDetails) {
//                    info { "transaction success: $data" }
//                    Toast.makeText(this@MainActivity,"transaction success: $data", Toast.LENGTH_LONG).show()
//                }
//                override fun onError(message: String) {
//                    info { "transaction failed: $message" }
//                    Toast.makeText(this@MainActivity,"transaction failed: $message", Toast.LENGTH_LONG).show()
//                }
//            }).pay()
//
//
//        val existingApps = UpiPayment.getExistingUpiApps(this)
//        info { "existing app: $existingApps" }
//    }
        fun openGpayOld() {
            //Add you login here
            //channel.invokeMethod("callBack", "data1")
            val GOOGLE_PAY_PACKAGE_NAME = "com.google.android.apps.nbu.paisa.user"
            val GOOGLE_PAY_REQUEST_CODE = 123

            val uri = Uri.Builder()
                .scheme("upi")
                .authority("pay")
                .appendQueryParameter("pa", "rakshnahildas@oksbi")
                .appendQueryParameter("pn", "Rakshna Sivakumar")
                //.appendQueryParameter("mc", "your-merchant-code")
                //.appendQueryParameter("tr", "your-transaction-ref-id")
                .appendQueryParameter("tn", "Haalo Customer Payment Gateway #orderNo 105")
                .appendQueryParameter("am", "")
                .appendQueryParameter("cu", "INR")
                //.appendQueryParameter("url", "your-transaction-url")
                .build()

            val intent = Intent(Intent.ACTION_VIEW, uri)
            // if (intent.resolveActivity(getPackageManager()) != null) {
            startActivity(intent)
            // } else {
            //     result.success("Failed")
            // }
        }
    }


