package com.example.rassi_assist;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

public class GlobalApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        //알림 채널 생성
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "라씨";
            String description = "라씨 알림";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(
                    "com.thinkpool.mobile.sinq.push", name, importance);
            mChannel.setDescription(description);

            NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(mChannel);
        }
    }
}
