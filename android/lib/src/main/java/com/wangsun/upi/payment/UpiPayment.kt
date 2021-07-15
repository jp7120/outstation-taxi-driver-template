package com.wangsun.upi.payment

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.wangsun.upi.payment.model.PaymentDetail
import com.wangsun.upi.payment.model.TransactionDetails
import org.jetbrains.anko.AnkoLogger
import org.jetbrains.anko.info
import java.io.IOException
import java.lang.ref.WeakReference
import java.util.*


/**
 * Created by WANGSUN on 26-Sep-19.
 */
class UpiPayment(activity: FragmentActivity) : AnkoLogger{
    private var mPaymentDetail: PaymentDetail? = null
    private var mActivity: WeakReference<FragmentActivity> = WeakReference(activity)
    private var mUpiApps: ArrayList<String> = arrayListOf()

    var tr :TransactionDetails = TransactionDetails("","","","","")



    private var mOnUpiPaymentListener: OnUpiPaymentListener? = null


    companion object{
        const val UPI_PAYMENT_REQUEST_CODE = 201
        const val ARG_UPI_APPS_LIST = "upi.apps.list"
        var selectedAppName: String = ""
        /**
         * default selected upi apps
         */
        @JvmStatic
        val UPI_APPS: ArrayList<String> = arrayListOf("google pay","phonepe","paytm","bhim","mobikwik")

        /**
         * if developer want to check existing upi apps
         * to control visibility of "Pay using Upi App" button.
         *
         * eg. if developer want to show "Pay using Upi App" button only if upi app present
         */
        @JvmStatic
        fun getExistingUpiApps(context: Context): ArrayList<String>{

            // Set Parameters for UPI
            val payUri = Uri.Builder()

            payUri.scheme("upi").authority("pay")
            payUri.appendQueryParameter("pa", "")
            payUri.appendQueryParameter("pn", "")
            payUri.appendQueryParameter("tid", "")
            payUri.appendQueryParameter("mc", "")
            payUri.appendQueryParameter("tr", "")
            payUri.appendQueryParameter("tn", "")
            payUri.appendQueryParameter("am", "")
            payUri.appendQueryParameter("cu", "")

            val paymentIntent = Intent(Intent.ACTION_VIEW)
            paymentIntent.data = payUri.build()

            val appNames = arrayListOf<String>()

            val appList = context.packageManager.queryIntentActivities(paymentIntent, 0)
            for (i in appList){
                appNames.add(i.loadLabel(context.packageManager).toString().toLowerCase())
            }
            return appNames
        }
    }



    /**
     * set payment details i.e vpa, amount, etc
     */
    fun setPaymentDetail(paymentDetail: PaymentDetail): UpiPayment{
        mPaymentDetail = paymentDetail
        return this
    }

    /**
     * set list of upi-apps (add only name of apps)
     * if you don't call setPaymentDetail() then all available apps will be shown
     * setPaymentDetail() act like a filter
     * it means: from all available apps in device only show these selected apps if available
     */
    fun setUpiApps(data: ArrayList<String>): UpiPayment{
        mUpiApps.clear()
        if(data.isNotEmpty()){
            for(i in data){
                mUpiApps.add(i.toLowerCase())
            }
        }
        return this
    }


    fun setApp(data: String): UpiPayment {
//        Toast.makeText(mActivity.get(), "You have choosen $data", Toast.LENGTH_SHORT).show()

        if (data == "paytm") {
            selectedAppName = "net.one97.paytm"
//            Toast.makeText(mActivity.get(), "Opening PayTM....", Toast.LENGTH_SHORT).show()

        }
        else if (data == "phonepe")
        {
            selectedAppName = "com.phonepe.app"
//            Toast.makeText(mActivity.get(), "Opening PhonePe...", Toast.LENGTH_SHORT).show()


        }
        else
        {            selectedAppName = ""

//            Toast.makeText(mActivity.get(), "App not available...", Toast.LENGTH_SHORT).show()

            info{ "No app with the name specified please check while calling this method $selectedAppName" }

        }
        return this

    }

    /**
     * callback listener
     */
    fun setCallBackListener(listener: OnUpiPaymentListener): UpiPayment{
        mOnUpiPaymentListener = listener
        return this
    }

    /**
     * start upiPayment
     */
    fun pay(){
        if(mOnUpiPaymentListener!=null)
            startFragment()
        else
            Toast.makeText(mActivity.get(),"set callback listener first.",Toast.LENGTH_SHORT).show()
    }


    /**
     * start fragment
     */
    private fun startFragment() {
        if(!hasError()){
            val bundle = Bundle()
            bundle.putSerializable(PaymentDetail.ARG_BUNDLE,mPaymentDetail)
            bundle.putStringArrayList(ARG_UPI_APPS_LIST,mUpiApps)

            val fragment = UpiPaymentFragment()
            fragment.arguments = bundle
            fragment.setListener(object : UpiPaymentFragment.OnUpiFragmentListener{
                override fun onSubmitted(data: TransactionDetails) {
                    mOnUpiPaymentListener?.onSubmitted(data)
                }

                override fun onSuccess(data: TransactionDetails) {
                    mOnUpiPaymentListener?.onSuccess(data)
                }

                override fun onError(message: String) {
                    mOnUpiPaymentListener?.onError(message)
                }
            })
            mActivity.get()?.supportFragmentManager?.beginTransaction()?.add(fragment, UpiPaymentFragment::class.java.name)?.commitAllowingStateLoss()
        }
    }

//    var tr :TransactionDetails = TransactionDetails("","","","","")


    /**
     * checking internal error before process
     */
    private fun hasError():Boolean{ //send back error message
        if(mPaymentDetail==null){
            mOnUpiPaymentListener?.onError("Payment shouldn't be null.")
            return true
        }
        if(!mPaymentDetail!!.vpa.contains("@")){
            mOnUpiPaymentListener?.onError("Invalid vpa/upi id.")
            return true
        }
        if(!mPaymentDetail!!.amount.contains(".")){
            mOnUpiPaymentListener?.onError("Invalid amount (should be 0.00 decimal format).")
            return true
        }
//        if(mPaymentDetail!!.txnId==""){
//            mPaymentDetail!!.txnId = generateString()
//        }
        if(mPaymentDetail!!.txnRefId==""){
            mPaymentDetail!!.txnRefId = generateString()
        }
        return false
    }


    private fun generateString(): String {
        val uuid = UUID.randomUUID().toString()
        return uuid.replace("-".toRegex(), "")
    }

    /**
     * callback listener
     */
//    var tr :TransactionDetails = TransactionDetails("","","","","")

    interface OnUpiPaymentListener {

        fun onSuccess(data: TransactionDetails) //success
        fun onSubmitted(data: TransactionDetails) //pending
        fun onError(message: String="Payment canceled.") //transaction failed or error
    }


    /*************************
     *      Fragment
     ************************/
    class UpiPaymentFragment : Fragment(), AnkoLogger {

        var selectedApp: String = ""

        override fun onActivityCreated(savedInstanceState: Bundle?) {
            super.onActivityCreated(savedInstanceState)

            val paymentDetail = arguments?.getSerializable(PaymentDetail.ARG_BUNDLE) as PaymentDetail
            val uri = getPaymentUri(paymentDetail)
            // Check if app is installed or not
            // Set Data Intent
            val paymentIntent = Intent(Intent.ACTION_VIEW)
            paymentIntent.data = uri

//            if (paymentIntent.resolveActivity(context!!.packageManager) == null)
                startUpiBottomSheet(uri)
//            else
//                mListener?.onError("No UPI app found! Please Install to Proceed!")
        }

        private fun isPackageInstalled(
            packageName: String,
            packageManager: PackageManager
        ): Boolean {
            return try {
                packageManager.getPackageInfo(packageName, 0)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
        }
        var isResultSent = false


        private fun getPaymentUri(paymentDetail: PaymentDetail): Uri {

            // Set Parameters for UPI
            val payUri = Uri.Builder()

            payUri.scheme("upi").authority("pay")
            payUri.appendQueryParameter("pa", paymentDetail.vpa)
            payUri.appendQueryParameter("pn", paymentDetail.name)
            payUri.appendQueryParameter("tid", paymentDetail.txnId)
            payUri.appendQueryParameter("mc", paymentDetail.payeeMerchantCode)
            payUri.appendQueryParameter("tr", paymentDetail.txnRefId)
            payUri.appendQueryParameter("tn", paymentDetail.description)
            payUri.appendQueryParameter("am", paymentDetail.amount)
            payUri.appendQueryParameter("cu", paymentDetail.currency)

            //Build URI
            return payUri.build()
        }
        var tr :TransactionDetails = TransactionDetails("","","","","")


        private  fun startUpiBottomSheet(uri: Uri) {

            try {


                    selectedApp = selectedAppName
                    val paymentIntent = Intent(Intent.ACTION_VIEW)
                    paymentIntent.data = uri
                    paymentIntent.setPackage(selectedAppName)
                    val pm = context!!.packageManager
                    val isInstalled = isPackageInstalled(selectedAppName, pm)
                    if(isInstalled) {
                        startActivityForResult(paymentIntent, UPI_PAYMENT_REQUEST_CODE)
                        info {" starting activity ${isInstalled}"}
                    }
                    else
                    {
                        info{"NOt availble in else condn"}
//                        mListener?.onError("App not available")
                        throw IOException("App is Not Aavilable")

                    }

            }
            catch (e: IOException)
            {
                info { "not avail $e" }
                isResultSent = true
                mListener?.onError("App not available")

            }
            catch (e: ActivityNotFoundException)
            {
                info { "(not avail) cannot perform action $e" }
                isResultSent = true
                mListener?.onError("Problem with Payment App")

            }

            val bundle = Bundle()
            bundle.putString("uri", uri.toString())
            bundle.putStringArrayList(ARG_UPI_APPS_LIST,arguments?.getStringArrayList(ARG_UPI_APPS_LIST))

//            val upiBottomSheet = UpiBottomSheet()
//            upiBottomSheet.arguments = bundle
//            upiBottomSheet.setListener(object : UpiBottomSheet.OnUpiTypeSelectedListener{
//                override fun onUpiAppClosed() { mListener?.onError() }
//
//                override fun onUpiAppSelected(data: ResolveInfo) {
////                    selectedApp = data.loadLabel(context!!.packageManager).toString().toLowerCase()
//                    selectedApp = "net.one97.paytm"
//                    val paymentIntent = Intent(Intent.ACTION_VIEW)
//                    paymentIntent.data = uri
//                    paymentIntent.setPackage("net.one97.paytm")
//                    startActivityForResult(paymentIntent,UPI_PAYMENT_REQUEST_CODE)
//                }
//            })
//            upiBottomSheet.isCancelable = false
//            upiBottomSheet.show(fragmentManager!!, UpiBottomSheet::class.java.simpleName)
        }

        override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
            super.onActivityResult(requestCode, resultCode, data)
            if (requestCode == UPI_PAYMENT_REQUEST_CODE && !isResultSent) {
                info { "onActivityResult: under requestCode" }
                if (resultCode == Activity.RESULT_OK && !isResultSent) {
                    info { "transaction detail: under resultCode" }
                    if (data != null&& !isResultSent) {
                        info { "onActivityResult: under data" }
                        val response = data.getStringExtra("response")
                        if (response != null&& !isResultSent) {
                            info { "onActivityResult: under response" }
                            val transactionDetails = getTransactionDetails(response)
                            info { "onActivityResult-> transactionDetails: $transactionDetails" }
                            if(transactionDetails.status!=null&& !isResultSent){
                                transactionDetails.appName = selectedApp
                                try {

                                        if ( !isResultSent) {
                                            when (transactionDetails.status.toLowerCase()) {
                                                "success" -> mListener?.onSuccess(transactionDetails)
                                                "submitted" -> mListener?.onSubmitted(transactionDetails)
                                                else -> mListener?.onError("Payment failed.")
                                        //                                        else -> mListener?.onError(tr)
                                            }
                                        }else
                                        {
                                            info { "Result already sent" }
                                        }
                                } catch (e:Exception)
                                {
                                    info { "Exception happening"+e.toString() }
//                                    Toast.makeText(this,"Error in the send success part",0).show()
                                }
                            }
                            else
                                mListener?.onError("Status is null.")
                        } else
                            mListener?.onError()
                    } else
                        mListener?.onError()
                }
                else
                    mListener?.onError()
            }

        }

        //Make TransactionDetails object from response string
        private fun getTransactionDetails(response: String): TransactionDetails {
            val map = getQueryString(response)

            val transactionId = map["txnId"]
            val responseCode = map["responseCode"]
            val approvalRefNo = map["ApprovalRefNo"]
            val status = map["Status"]
            val transactionRefId = map["txnRef"]
            return TransactionDetails(transactionId, responseCode, approvalRefNo, status, transactionRefId)
        }


        private fun getQueryString(url: String): Map<String, String> {
            info { "transaction detail: $url" }
            val params = url.split("&".toRegex())
            val map = HashMap<String, String>()
            for (param in params) {

                val name: String
                val value: String
                val array = param.split("=".toRegex())

                if(array.size>1){
                    name = array[0]
                    value = array[1]
                }
                else{
                    name = array[0]
                    value = ""
                }
                map[name] = value
            }
            return map
        }

        /**
         * callback listener
         */
        private var mListener: OnUpiFragmentListener? = null

        fun setListener(listener: OnUpiFragmentListener) {
            this.mListener = listener
        }

        interface OnUpiFragmentListener {
            fun onSuccess(data: TransactionDetails) //success
            fun onSubmitted(data: TransactionDetails) //pending
            fun onError(message: String="Payment canceled.")//transaction failed or error
        }
    }
}