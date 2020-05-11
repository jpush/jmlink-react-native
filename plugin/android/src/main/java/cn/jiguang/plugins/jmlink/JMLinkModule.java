package cn.jiguang.plugins.jmlink;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Map;

import cn.jiguang.jmlinksdk.api.JMLinkAPI;
import cn.jiguang.jmlinksdk.api.JMLinkCallback;
import cn.jiguang.jmlinksdk.api.ReplayCallback;
import cn.jiguang.plugins.jmlink.common.JConstants;
import cn.jiguang.plugins.jmlink.common.JLogger;

public class JMLinkModule extends ReactContextBaseJavaModule {
    private ReactApplicationContext context;
    private static Uri uri;
    @NonNull
    @Override
    public String getName() {
        return "JMLinkModule";
    }

    @SuppressWarnings("WeakerAccess")
    public JMLinkModule(@NonNull ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        reactContext.addActivityEventListener(new ActivityEventListener() {
            @Override
            public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
            }

            @Override
            public void onNewIntent(Intent intent) {
                router();
            }
        });
    }

    @ReactMethod
    public void logE(String tag, String msg) {
        Log.e(tag, msg);
    }

    @ReactMethod
    public void init(ReadableMap params) {
        try {
            if (params.hasKey("debug")) {
                JMLinkAPI.getInstance().setDebugMode(params.getBoolean("debug"));
            }
            if (params.hasKey("clipEnabled")) {
                JMLinkAPI.getInstance().setDebugMode(params.getBoolean("clipEnabled"));
            }
        } catch (Throwable t) {
            t.printStackTrace();
        }
        JMLinkAPI.getInstance().init(context.getApplicationContext());
    }

    @ReactMethod
    public void getParams() {
        JMLinkAPI.getInstance().registerDefault(new JMLinkCallback() {
            @Override
            public void execute(Map<String, String> map, Uri uri) {
                sendEvent(JConstants.PARAM_EVENT, convertToResult(map, JMLinkAPI.getInstance().getParams()));
            }
        });
        router();
    }

    @SuppressWarnings("SameParameterValue")
    private void sendEvent(String eventName, WritableMap params) {
        try {
            context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
        }catch (Throwable throwable){
            JLogger.e("sendEvent error:"+throwable.getMessage());
        }
    }

    private void router() {
        Uri uri = JMLinkModule.uri;
        JMLinkModule.clearUri();
        JLogger.d("get uri:" + uri);
        if (uri != null) {
            JMLinkAPI.getInstance().router(uri);
        } else {
            JMLinkAPI.getInstance().replay(new ReplayCallback() {
                @Override
                public void onFailed() {
                    JLogger.d( "replay onfailed");
                }

                @Override
                public void onSuccess() {
                    JLogger.e("replay onSuccess");
                }
            });
        }
    }

    private WritableMap convertToResult(Map<String, String> params, Map<String, String> dynpParams) {
        WritableMap writableMap = Arguments.createMap();
        WritableMap paramsMap = Arguments.createMap();
        if (params != null && params.size() > 0) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                paramsMap.putString(entry.getKey(), entry.getValue());
            }
        }
        WritableMap dynpParamsMap = Arguments.createMap();
        if (dynpParams != null && dynpParams.size() > 0) {
            for (Map.Entry<String, String> entry : dynpParams.entrySet()) {
                dynpParamsMap.putString(entry.getKey(), entry.getValue());
            }
        }
        writableMap.putMap(JConstants.PARAMS, paramsMap);
        writableMap.putMap(JConstants.DYNP_PARAMS, dynpParamsMap);
        return writableMap;
    }

    @SuppressWarnings("WeakerAccess")
    public static void setUri(Uri uri) {
        JMLinkModule.uri = uri;
    }

    private static void clearUri() {
        JMLinkModule.uri = null;
    }
}
