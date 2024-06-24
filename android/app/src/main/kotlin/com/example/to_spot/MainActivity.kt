package com.example.to_spot

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory
class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        MapKitFactory.setApiKey("yandex-map-kit-api-key") // Your generated API key
        super.configureFlutterEngine(flutterEngine)
    }
}
