package com.nekofeed

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
