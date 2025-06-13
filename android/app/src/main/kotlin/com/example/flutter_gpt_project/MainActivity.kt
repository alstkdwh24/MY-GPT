package com.example.flutter_gpt_project
import android.os.Bundle
import android.util.Log
import com.kakao.sdk.common.util.Utility
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val keyHash = Utility.getKeyHash(this)
        Log.d("KeyHash", "KeyHash: $keyHash")
    }
}