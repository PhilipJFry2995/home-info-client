package com.filiahin.home_info_client

import android.os.Bundle
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.home_info_client.channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle NFC intent data
        val intent = intent
        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            val nfcData = handleNfcIntent(intent)
            sendNfcDataToFlutter(nfcData)
        }
    }

    private fun handleNfcIntent(intent: Intent): String {
        // Extract NFC data from the intent
        // For example, to retrieve a plain text payload from an NDEF record:
        val ndefMessage = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)!![0] as NdefMessage
        val ndefRecord = ndefMessage.records[0]
        val payload = ndefRecord.payload
        val languageCodeLength = payload[0]
        val languageCodeBytes = payload.copyOfRange(1, 1 + languageCodeLength)
        val textBytes = payload.copyOfRange(1 + languageCodeLength, payload.size)

        val nfcData = textBytes.toString(Charsets.UTF_8)
        return nfcData
    }

    private fun sendNfcDataToFlutter(nfcData: String) {
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                .invokeMethod("onNfcDataReceived", nfcData)
    }
}
