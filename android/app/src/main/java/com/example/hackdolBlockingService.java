package com.example;

import android.telecom.Call;
import android.telecom.CallScreeningService;
import android.telecom.CallScreeningService.CallResponse;
import android.telecom.CallScreeningService.CallResponse.Builder;
import android.telecom.Call.Details;
import android.util.Log;

public class hackdolBlockingService extends CallScreeningService {
    @Override
    public void onScreenCall(Details callDetails) {
        // 전화번호 차단 로직을 여기에 작성합니다.
        // 플러터 앱에서 전달한 전화번호를 처리할 수 있습니다.
        String phoneNumber = callDetails.getHandle().toString();
        Log.d("MyCallBlockingService", "Call screened: " + phoneNumber);
        // 여기에 전화 차단 로직을 추가합니다.
        blockPhoneNumber(callDetails);
    }

    private void blockPhoneNumber(Details callDetails) {
        // 여기에 전화번호를 차단하는 코드를 추가합니다.
        // 이 예시에서는 단순히 전화번호를 로그에 출력하는 것으로 대체합니다.
        Log.d("MyCallBlockingService", "Blocking phone number: " + callDetails.getHandle().toString());

        // 실제로는 다음과 같이 휴대전화의 차단 목록에 전화번호를 추가할 수 있습니다.
        CallResponse.Builder responseBuilder = new CallResponse.Builder();
        responseBuilder.setDisallowCall(true); // 차단
        responseBuilder.setRejectCall(true); // 거부
        responseBuilder.setSkipNotification(true); // 알림 생략
        respondToCall(callDetails, responseBuilder.build());
    }
}
