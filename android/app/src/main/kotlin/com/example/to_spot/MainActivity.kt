package com.example.to_spot

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory
class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        MapKitFactory.setApiKey("e470b168-8d7c-440f-a909-3d29f1bd9433") // Your generated API key
        super.configureFlutterEngine(flutterEngine)
    }
}
