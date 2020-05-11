package cn.jiguang.plugins.jmlink;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import cn.jiguang.jmlinksdk.api.JMLinkAPI;
import cn.jiguang.plugins.jmlink.common.JLogger;

public class SplashActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Uri uri = getIntent().getData();
        JMLinkModule.setUri(uri);
        JMLinkAPI.getInstance().init(getApplicationContext());
        Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (intent != null) {
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        } else {
            JLogger.e("launchIntent not found");
        }
    }
}
