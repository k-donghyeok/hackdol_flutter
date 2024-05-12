package com.example.myplugin;

import android.telecom.Call;
import android.telecom.CallScreeningService;
import android.util.Log;


import com.example.hackdolBlockingService;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class my_channel extends CallScreeningService {

    // MethodChannel을 통해 Flutter로부터 호출된 메서드를 처리합니다.
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("blockPhoneNumber")) {
            // blockPhoneNumber 메서드를 호출하여 전화번호를 차단합니다.
            blockPhoneNumber(call.argument("phoneNumber"));
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void blockPhoneNumber(String phoneNumber) {
        hackdolBlockingService blockingService = new hackdolBlockingService();
        blockingService.addBlockPhoneNumber(phoneNumber);
        Log.d("MyCallBlockingService", "Blocking phone number: " + phoneNumber);
        // 여기서는 간단히 콘솔에 전화번호를 출력하는 것으로 대체합니다.
    }
}
