package com.app.coin_analyzer

import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.SystemClock
import android.util.Log
import com.app.coin_analyzer.CoinAnalyzerApplication.Companion.session
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.walletconnect.Session
import org.walletconnect.nullOnThrow

class MainActivity : FlutterActivity(), Session.Callback {

    private var txRequest: Long? = null
    private var txtStatus: String? = null
    private lateinit var walletResult: MethodChannel.Result

    companion object {
        const val CHANNEL = "com.app.coin_analyzer/walletconnect"
        const val CONNECT_METHOD = "onConnectWallet"
        const val DISCONNECT_METHOD = "onDisconnectWallet"
        const val TRANSACTIONS_METHOD = "onWalletTransactions"
    }

    override fun onMethodCall(call: Session.MethodCall) {

    }

    override fun onStatus(status: Session.Status) {
        when (status) {
            Session.Status.Approved -> sessionApproved()
            Session.Status.Closed -> sessionClosed()
            Session.Status.Connected,
            Session.Status.Disconnected,
            is Session.Status.Error -> {
                // Do Stuff
            }
        }
    }

    private fun sessionApproved() {
        txtStatus = "Connected: ${session!!.approvedAccounts()}"
        Log.d("MainActivity", "Session : $txtStatus");
    }

    private fun sessionClosed() {
        txtStatus = "Disconnected"
        Log.d("MainActivity", "Session : $txtStatus");
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                    walletResult = result!!
                    when {
                        call?.method.equals(CONNECT_METHOD) -> {
                            onConnectWallet()
                        }
                        call?.method.equals(DISCONNECT_METHOD) -> {
                            onDisConnectWallet()
                        }
                        call?.method.equals(TRANSACTIONS_METHOD) -> {
                            Log.d("MainActivity", "Transaction Initiate")
                            onWalletTransactions()
                        }
                    }
                }
    }

    private var mLastClickTime: Long = 0

    override fun onStart() {
        super.onStart()
        Log.e("MainActivity", "On Start Called")
        initialSetup()
    }

    private fun initialSetup() {
        val session = nullOnThrow { session } ?: return
        session.addCallback(this)
        sessionApproved()
    }

    private fun handleResponse(resp: Session.MethodCall.Response) {
        if (resp.id == txRequest) {
            txRequest = null
            txtStatus = "Last response: " + ((resp.result as? String) ?: "Unknown response")
            Log.e("MainActivity", txtStatus.toString())
        }
    }

    override fun onDestroy() {
        session!!.removeCallback(this)
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (session != null) {
            val from = session!!.approvedAccounts()?.first()
            Log.e("MainActivity: ", " From " + from.toString())
            walletResult.success(from.toString())
        }
    }

    private fun onConnectWallet() {
        CoinAnalyzerApplication.resetSession()
        session!!.addCallback(this)
        val i = Intent(Intent.ACTION_VIEW)
        i.data = Uri.parse(CoinAnalyzerApplication.config.toWCUri())
        startActivityForResult(i, 100)
//        startActivity(i)
    }

    private fun onDisConnectWallet() {
        session?.kill()
    }

    private fun onWalletTransactions() {
        if (SystemClock.elapsedRealtime() - mLastClickTime < 5000) {
            return
        }
        Log.d("MainActivity", "Transaction Start")
        mLastClickTime = SystemClock.elapsedRealtime();
//        CoinAnalyzerApplication.resetSession();
        val from = session!!.approvedAccounts()?.first()
                ?: return
        val txRequest = System.currentTimeMillis()
        var list = listOf<String>(from, "0xf605fC4FC37DeD5aa5DeC06Ec3764567B7245352", "0x9184E72A000")

        Log.d("MainActivity", "Transaction method called")
        session!!.performMethodCall(
                Session.MethodCall.SendTransaction(
                        txRequest,
                        from,
                        "0x76d53710Fc6028e845aF092B818A9eC72f718465",
                        null,
                        null,
                        null,
                        "0x9184E72A000",
                        ""
                ),
                ::handleResponse
//        CoinAnalyzerApplication.session.performMethodCall(
//                Session.MethodCall.Custom(
//                        txRequest,
//                        "Transfer",
//                        list
//                ),
//                ::handleResponse
        )
        this.txRequest = txRequest
        Handler().postDelayed(Runnable {
            val i = Intent(Intent.ACTION_VIEW)
            i.data = Uri.parse("wc:")
            startActivityForResult(i, 101)
        }, 3000)

//        val from = CoinAnalyzerApplication.session.approvedAccounts()?.first()
//                ?: return
//        val txRequest = System.currentTimeMillis()
//        CoinAnalyzerApplication.session.performMethodCall(
//                Session.MethodCall.SendTransaction(
//                        txRequest,
//                        from,
//                        "0xf605fC4FC37DeD5aa5DeC06Ec3764567B7245352",
//                        null,
//                        null,
//                        null,
//                        "0x9184E72A000",
//                        ""
//                ),
//                ::handleResponse
//        )
//        this.txRequest = txRequest
    }
}
