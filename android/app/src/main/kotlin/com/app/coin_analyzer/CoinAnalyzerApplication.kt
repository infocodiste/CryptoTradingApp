package com.app.coin_analyzer

import android.util.Log
import androidx.multidex.MultiDexApplication
import com.squareup.moshi.Moshi
import okhttp3.OkHttpClient
import org.komputing.khex.extensions.toNoPrefixHexString
import org.walletconnect.Session
import org.walletconnect.impls.*
import org.walletconnect.nullOnThrow
import java.io.File
import java.util.*

class CoinAnalyzerApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        initMoshi()
        initClient()
        initBridge()
        initSessionStorage()
    }

    private fun initClient() {
        client = OkHttpClient.Builder().build()
    }

    private fun initMoshi() {
        moshi = Moshi.Builder().build()
    }


    private fun initBridge() {
        bridge = WCBridgeServer(moshi)
        bridge.start()
    }

    private fun initSessionStorage() {
        storage = FileWCSessionStore(File(cacheDir, "session_store.json").apply { createNewFile() }, moshi)
    }

    companion object {
        private lateinit var client: OkHttpClient
        private lateinit var moshi: Moshi
        private lateinit var bridge: WCBridgeServer
        private lateinit var storage: WCSessionStore
        lateinit var config: Session.Config
        var session: Session? = null

        fun resetSession() {
            nullOnThrow { session }?.clearCallbacks()
            val key = ByteArray(32).also { Random().nextBytes(it) }.toNoPrefixHexString()

            val uuid = UUID.randomUUID().toString();
            val bridge = "http://localhost:${WCBridgeServer.PORT}"

            Log.d("SESSION UUID", uuid)
            Log.d("SESSION Bridge", bridge)
            Log.d("SESSION Key", key)

            config = Session.Config(uuid, bridge, key)
            Log.d("SESSION Config Url", config.toWCUri());
            val iconList = listOf<String>("https://firebasestorage.googleapis.com/v0/b/crypto-fce6b.appspot.com/o/icons%2Flauncher_icon.png?alt=media&token=e0756b4b-72e1-4cad-b080-b87d6e52c9cf");
            session = WCSession(
                    config.toFullyQualifiedConfig(),
                    MoshiPayloadAdapter(moshi),
                    storage,
                    OkHttpTransport.Builder(client, moshi),
                    Session.PeerMeta(name = "Coin Analyzer", url = "Coin Analyzer", description = "Coin Analyzer app", icons = iconList)
            )
            session!!.offer()
        }
    }

//    companion object {
//        private lateinit var client: OkHttpClient
//        private lateinit var moshi: Moshi
//        private lateinit var bridge: WCBridgeServer
//        private lateinit var storage: WCSessionStore
//        lateinit var config: Session.Config
//        lateinit var session: Session
//
//        fun resetSession() {
//            nullOnThrow { session }?.clearCallbacks()
//            val key = ByteArray(32).also { Random().nextBytes(it) }.toNoPrefixHexString()
//            config = Session.Config(UUID.randomUUID().toString(), "http://localhost:${WCBridgeServer.PORT}", key)
//            session = WCSession(config,
//                    MoshiPayloadAdapter(moshi),
//                    storage,
//                    OkHttpTransport.Builder(client, moshi),
//                    Session.PeerMeta(name = "Coin Analyzer")
//            )
//            session.offer()
//        }
//    }
}
