package com.example;
import android.content.ContentResolver;
import android.provider.BlockedNumberContract;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BlockPhoneNumberHandler implements MethodChannel.MethodCallHandler {
    private final ContentResolver contentResolver;

    public BlockPhoneNumberHandler(ContentResolver contentResolver) {
        this.contentResolver = contentResolver;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("blockPhoneNumber")) {
            String phoneNumber = call.argument("phoneNumber");
            blockNumber(phoneNumber);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void blockNumber(String phoneNumber) {
        BlockedNumberContract.BlockedNumbers.add(contentResolver, phoneNumber);
        Log.d("BlockedNumberProvider", "Blocked number: " + phoneNumber);
    }
}
