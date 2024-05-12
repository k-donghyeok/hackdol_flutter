package com.example;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.provider.BlockedNumberContract;
import android.telecom.Call;
import android.telecom.CallScreeningService;
import android.util.Log;

public class hackdolBlockingService extends CallScreeningService {
    @Override


    public void addBlockPhoneNumber(String phoneNumber) {
        // ContentResolver를 사용하여 휴대전화의 차단 목록에 번호를 추가합니다.
        ContentResolver contentResolver = getContentResolver();

        // 차단 목록에 추가할 번호를 설정합니다.
        ContentValues values = new ContentValues();
        values.put(BlockedNumberContract.BlockedNumbers.COLUMN_ORIGINAL_NUMBER, phoneNumber);

        // BlockedNumberContract에 정의된 URI를 사용하여 번호를 차단합니다.
        Uri uri = BlockedNumberContract.BlockedNumbers.CONTENT_URI;
        Uri blockedUri = contentResolver.insert(uri, values);

        // 차단에 성공했는지 확인합니다.
        if (blockedUri != null) {
            Log.d("MyCallBlockingService", "Phone number blocked: " + phoneNumber);
        } else {
            Log.e("MyCallBlockingService", "Failed to block phone number: " + phoneNumber);
        }
    }
}
