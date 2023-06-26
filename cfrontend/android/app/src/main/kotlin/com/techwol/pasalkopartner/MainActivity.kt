package com.techwol.faastopartner
import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import kotlin.random.Random
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter.native/helper").setMethodCallHandler { call, result ->
            if (call.method == "intentActivity") {
                if (Build.MANUFACTURER.equals("Xiaomi", true)) {
                    val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
                    intent.setClassName(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.permissions.PermissionsEditorActivity"
                    )
                    intent.putExtra("extra_pkgname", "com.techwol.faastopartner")
                    startActivity(intent)
                }
            }

            if (call.method == "sendToBackground") {
                val startMain = Intent(Intent.ACTION_MAIN)
                startMain.addCategory(Intent.CATEGORY_HOME)
                startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(startMain)
            }
        }
    }
}

