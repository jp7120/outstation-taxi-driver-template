package com.fire.finalupicheck

import android.os.Bundle
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import com.wangsun.upi.payment.UpiPayment
import com.wangsun.upi.payment.model.PaymentDetail
import com.wangsun.upi.payment.model.TransactionDetails
import com.fire.finalupicheck.databinding.ActivityMainBinding
import org.jetbrains.anko.AnkoLogger
import org.jetbrains.anko.info


class MainActivity : AppCompatActivity(), AnkoLogger {

    private lateinit var appBarConfiguration: AppBarConfiguration
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.toolbar)

        val navController = findNavController(R.id.nav_host_fragment_content_main)
        appBarConfiguration = AppBarConfiguration(navController.graph)
        setupActionBarWithNavController(navController, appBarConfiguration)

        binding.fab.setOnClickListener { view ->

            var amount: Double = 1.0
           startUpiPayment("Kavin",amount.toString())
        }
    }


    private fun startUpiPayment(name: String, amount:String){
        val payment = PaymentDetail(
            vpa="sundararajalamelu-1@oksbi",
            name = "SILVER TAXI",
            payeeMerchantCode = "4121",
            //txnId = "",
            txnRefId = "BCR2DN6T36K6XTS3",

            description = "WALLET RECHARGE BY DRIVER ",
            amount = amount)


        UpiPayment(this)
            .setApp("phonepe")
            .setPaymentDetail(payment)

            .setUpiApps(UpiPayment.UPI_APPS)

            .setCallBackListener(object : UpiPayment.OnUpiPaymentListener{
                override fun onSubmitted(data: TransactionDetails) {
                    info { "transaction pending: $data" }
                    Toast.makeText(this@MainActivity,"transaction pending: $data", Toast.LENGTH_LONG).show()
                }
                override fun onSuccess(data: TransactionDetails) {
                    info { "transaction success: $data" }
                    Toast.makeText(this@MainActivity,"transaction success: $data", Toast.LENGTH_LONG).show()
                }
                override fun onError(message: String) {
                    info { "transaction failed: $message" }
                    Toast.makeText(this@MainActivity,"transaction failed: $message", Toast.LENGTH_LONG).show()
                }
            }).pay()


        val existingApps = UpiPayment.getExistingUpiApps(this)
        info { "existing app: $existingApps" }
    }



}