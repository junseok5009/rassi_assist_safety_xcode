package com.example.rassi_assist;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.Settings;
import android.service.notification.StatusBarNotification;
import android.text.TextUtils;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.mobile.thinkpool.trade.MainActivity;
import com.mobile.thinkpool.trade.R;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Map;


/**
 * Created on 2023-07
 * Push message
 */
public class FirebaseMessageService extends FirebaseMessagingService {
    private static final String TAG = "[FirebaseMessagingService] ";
    public static SharedPreferences mPrefs = null;

    public static final int NOTIFICATION_ID = 1;
    public static int count = 0;

    private Uri ringtoneUri = null;
    private PendingIntent pendingIntent = null;
    String pTitle = "";
    String pushContent = "";

    private int requestCode = 0;

    /**
     * onNewToken이 호출되는 두 가지 시나리오가 있습니다.
     * 1) 최초 앱 시작 시 새로운 토큰이 생성되는 경우
     * 2) 기존 토큰이 변경될 때마다
     * #2 아래에서 기존 토큰이 변경되는 세 가지 시나리오가 있습니다.
     * A) 앱이 새 기기로 복원됩니다.
     * 나) 사용자가 앱을 제거/재설치하는 경우
     * 다) 사용자가 앱 데이터 삭제
     */
    @Override
    public void onNewToken(@NotNull String s) {
        super.onNewToken(s);
        Log.e(TAG, "##### [RASSI] onNewToken TOKEN : "+s);
        // NOTE 토큰 재생성되면 업데이트
        mPrefs = getSharedPreferences(IConstants.PREFS_NAME, MODE_PRIVATE);
        mPrefs.edit().putString(IConstants.PREFS_FCM_TOKEN, s).apply();
        String userId = mPrefs.getString(IConstants.PREFS_USER_ID, "");
        if(!userId.equals("")){
            if(TextUtils.isEmpty(mPrefs.getString(IConstants.PREFS_TEST_CHANGE_ID, ""))) {
//                JsonObject param = new JsonObject();
//                param.addProperty("userId", userId);
//                param.addProperty("appEnv", "EN10");
//                param.addProperty("deviceId", AppUtils.getDeviceID(this));
//                param.addProperty("pushToken", s);
//                Call<ApiBaseSimple> call = LocalUtil.INSTANCE.getDefaultRetrofit().create(Services.class).getPUSH01(param);
//                call.enqueue(new Callback<ApiBaseSimple>() {
//                    @Override
//                    public void onResponse(Call<ApiBaseSimple> call, Response<ApiBaseSimple> response) {
//                        // NOTE 실패해도 딱히 할 수 있는게 없다.
//                    }
//
//                    @Override
//                    public void onFailure(Call<ApiBaseSimple> call, Throwable t) { }
//                });
            }

        }
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        mPrefs = getSharedPreferences(IConstants.PREFS_NAME, MODE_PRIVATE);
        Log.w(TAG, "onMessageReceived()");
        if (remoteMessage.getData().size() > 0) {
            Log.w(TAG, "remoteMessage : " + remoteMessage.getData().toString());
            sendNotification(remoteMessage);
        }

        if (remoteMessage.getNotification() != null) {
            Log.w(TAG, "remoteMessage.getNotification() != null " + remoteMessage.getNotification().getBody());
        }
        super.onMessageReceived(remoteMessage);
    }

    private void sendNotification(RemoteMessage remoteMessage) {
        Log.w(TAG, "### sendNotification () ");
        try {
            Map<String, String> receiveData = remoteMessage.getData();
            String pushSN = receiveData.get("pushSn");
            String landingType = receiveData.get("linkType");
            String pushDate = receiveData.get("pushDate");
            String landingUrl = receiveData.get("landingUrl");
            String pocketSn = receiveData.get("pocketSn");
            String discountType = receiveData.get("discountType");
            if(TextUtils.isEmpty(pushSN)) pushSN = "";
            if(TextUtils.isEmpty(landingType)) landingType = "";
            if(TextUtils.isEmpty(pushDate)) pushDate = "";
            if(TextUtils.isEmpty(landingUrl)) landingUrl = "";
            if(TextUtils.isEmpty(pocketSn)) pocketSn = "";
            if(TextUtils.isEmpty(discountType)) discountType = "";

            String pushDiv1 = receiveData.get("pushDiv1");
            String pushDiv2 = receiveData.get("pushDiv2");
            String pushDiv3 = receiveData.get("pushDiv3");
            pTitle = receiveData.get("pushTitle");
            pushContent = receiveData.get("pushContent");
            String stockCode = receiveData.get("stockCode");
            String stockName = receiveData.get("stockName");
            String linkPage = receiveData.get("linkPage");
            String sImgUrl = receiveData.get("imageUrl");
            if(TextUtils.isEmpty(pushDiv1)) pushDiv1 = "";
            if(TextUtils.isEmpty(pushDiv2)) pushDiv2 = "";
            if(TextUtils.isEmpty(pTitle)) pTitle = "";
            if(TextUtils.isEmpty(pushContent)) pushContent = "";
            if(TextUtils.isEmpty(stockCode)) stockCode = "";
            if(TextUtils.isEmpty(stockName)) stockName = "";
            if(TextUtils.isEmpty(linkPage)) linkPage = "";
            if(TextUtils.isEmpty(sImgUrl)) sImgUrl = "";

            if(pushDiv1.equals("TS") || pushDiv1.equals("RN")
                    || pushDiv1.equals("SN") || pushDiv1.equals("SB") || pushDiv1.equals("BS")
                    || pushDiv1.equals("CB") || pushDiv1.equals("IS") || pushDiv1.equals("HK")
                    || pushDiv1.equals("CS") || pushDiv1.equals("NT") || pushDiv1.equals("IF")) {
                String userId = mPrefs.getString(IConstants.PREFS_USER_ID, "");
                if(userId.equals("")) {
                    Log.w(TAG, "### sendNotification 유저 아이디 없음 ");
//                    return;
                }
            }

            try {
                requestCode = Integer.parseInt(pushSN);
            } catch (NumberFormatException ex){
                ex.printStackTrace();
                requestCode = (int) (System.currentTimeMillis() / 1000);
            }

            Log.w(TAG, "linkPage : " + linkPage);
            Log.w(TAG, "### push id : " + requestCode);

            getActiveNotificationCount();
            Intent intent = null;

            if(intent == null) {
                if(landingType.equals("APP")) {
                    intent = createIntent(
                            pushSN, landingType, linkPage, landingUrl, pushDiv1,
                            stockCode, stockName, pocketSn, discountType, pushDiv2);
                } else {
                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse(linkPage));
                }
            }

            PendingIntent pendingIntent;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                pendingIntent = PendingIntent.getActivity(this, requestCode , intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
            } else {
                pendingIntent = PendingIntent.getActivity(this, requestCode , intent, PendingIntent.FLAG_ONE_SHOT);
            }

            if(sImgUrl.length() > 0) {
                ImageGetEvent mImgGetTask = new ImageGetEvent();
                mImgGetTask.execute(sImgUrl);
            } else {
                if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false) && mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                    NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID);

                    if(pushDiv1.equals("TS")) {
                        if(pushDiv3.equals("BUY")) {
                            MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                            if(player != null) {
                                player.start();
                            }
                            mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_buy_icon))
                                    .setSmallIcon(R.mipmap.logo_icon)
                                    .setContentTitle(pTitle)
                                    .setContentText(pushContent)
                                    .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                    .setAutoCancel(true)
                                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                                    .setWhen(System.currentTimeMillis())
                                    .setVibrate(new long[]{600, 600})
                                    .setContentIntent(pendingIntent);
                        } else if(pushDiv3.equals("SELL")) {
                            if(pushDiv2.equals("USER")) {
                                MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                if(player != null) {
                                    player.start();
                                }
                                mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.custom_icon))
                                        .setSmallIcon(R.mipmap.logo_icon)
                                        .setContentTitle(pTitle)
                                        .setContentText(pushContent)
                                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                        .setAutoCancel(true)
                                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                                        .setWhen(System.currentTimeMillis())
                                        .setVibrate(new long[]{600, 600})
                                        .setContentIntent(pendingIntent);
                            } else {
                                MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                if(player != null) {
                                    player.start();
                                }
                                mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_sell_icon))
                                        .setSmallIcon(R.mipmap.logo_icon)
                                        .setContentTitle(pTitle)
                                        .setContentText(pushContent)
                                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                        .setAutoCancel(true)
                                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                                        .setWhen(System.currentTimeMillis())
                                        .setVibrate(new long[]{600, 600})
                                        .setContentIntent(pendingIntent);
                            }
                        }
                    } else {
                        MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                        if(player != null) {
                            player.start();
                        }
                        mBuilder.setSmallIcon(R.mipmap.logo_icon)
                                .setContentTitle(pTitle)
                                .setContentText(pushContent)
                                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                .setAutoCancel(true)
                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                .setWhen(System.currentTimeMillis())
                                .setVibrate(new long[]{600, 600})
                                .setContentIntent(pendingIntent);
                    }

                    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                    notificationManager.notify(requestCode, mBuilder.build());
                } else {
                    NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID);
                    if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false)) {
                        if(pushDiv1.equals("TS")) {
                            if(pushDiv3.equals("BUY")) {
                                mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_buy_icon))
                                        .setSmallIcon(R.mipmap.logo_icon)
                                        .setContentTitle(pTitle)
                                        .setContentText(pushContent)
                                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                        .setAutoCancel(true)
                                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                                        .setWhen(System.currentTimeMillis())
                                        .setSound(null)
                                        .setVibrate(new long[]{600, 600})
                                        .setContentIntent(pendingIntent);
                            } else if(pushDiv3.equals("SELL")) {
                                if(pushDiv2.equals("USER")) {
                                    mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.custom_icon))
                                            .setSmallIcon(R.mipmap.logo_icon)
                                            .setContentTitle(pTitle)
                                            .setContentText(pushContent)
                                            .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                            .setAutoCancel(true)
                                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                                            .setWhen(System.currentTimeMillis())
                                            .setSound(null)
                                            .setVibrate(new long[]{600, 600})
                                            .setContentIntent(pendingIntent);
                                } else {
                                    mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_sell_icon))
                                            .setSmallIcon(R.mipmap.logo_icon)
                                            .setContentTitle(pTitle)
                                            .setContentText(pushContent)
                                            .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                            .setAutoCancel(true)
                                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                                            .setWhen(System.currentTimeMillis())
                                            .setSound(null)
                                            .setVibrate(new long[]{600, 600})
                                            .setContentIntent(pendingIntent);
                                }
                            }
                        } else {
                            mBuilder.setSmallIcon(R.mipmap.logo_icon)
                                    .setContentTitle(pTitle)
                                    .setContentText(pushContent)
                                    .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                    .setAutoCancel(true)
                                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                                    .setWhen(System.currentTimeMillis())
                                    .setSound(null)
                                    .setVibrate(new long[]{600, 600})
                                    .setContentIntent(pendingIntent);
                        }

                        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                        notificationManager.notify(requestCode, mBuilder.build());
                    } else {
                        if(mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                            if(pushDiv1.equals("TS")) {
                                if(pushDiv3.equals("BUY")) {
                                    MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                    if(player != null) {
                                        player.start();
                                    }
                                    mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_buy_icon))
                                            .setSmallIcon(R.mipmap.logo_icon)
                                            .setContentTitle(pTitle)
                                            .setContentText(pushContent)
                                            .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                            .setAutoCancel(true)
                                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                                            .setWhen(System.currentTimeMillis())
                                            .setContentIntent(pendingIntent);
                                } else if(pushDiv3.equals("SELL")) {
                                    if(pushDiv2.equals("USER")) {
                                        MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                        if(player != null) {
                                            player.start();
                                        }
                                        mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.custom_icon))
                                                .setSmallIcon(R.mipmap.logo_icon)
                                                .setContentTitle(pTitle)
                                                .setContentText(pushContent)
                                                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                                .setAutoCancel(true)
                                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                                .setWhen(System.currentTimeMillis())
                                                .setContentIntent(pendingIntent);
                                    } else {
                                        MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                        if(player != null) {
                                            player.start();
                                        }
                                        mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_sell_icon))
                                                .setSmallIcon(R.mipmap.logo_icon)
                                                .setContentTitle(pTitle)
                                                .setContentText(pushContent)
                                                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                                .setAutoCancel(true)
                                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                                .setWhen(System.currentTimeMillis())
                                                .setContentIntent(pendingIntent);
                                    }
                                }
                            } else {
                                MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                                if(player != null) {
                                    player.start();
                                }
                                mBuilder.setSmallIcon(R.mipmap.logo_icon)
                                        .setContentTitle(pTitle)
                                        .setContentText(pushContent)
                                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                        .setAutoCancel(true)
                                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                                        .setWhen(System.currentTimeMillis())
                                        .setContentIntent(pendingIntent);
                            }

                            NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                            notificationManager.notify(requestCode, mBuilder.build());
                        } else {
                            if(pushDiv1.equals("TS")) {
                                if(pushDiv3.equals("BUY")) {
                                    ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                                    mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_buy_icon))
                                            .setSmallIcon(R.mipmap.logo_icon)
                                            .setContentTitle(pTitle)
                                            .setContentText(pushContent)
                                            .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                            .setAutoCancel(true)
                                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                                            .setSound(ringtoneUri)
                                            .setWhen(System.currentTimeMillis())
                                            .setContentIntent(pendingIntent);
                                } else if(pushDiv3.equals("SELL")) {
                                    if(pushDiv2.equals("USER")) {
                                        ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                                        mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.custom_icon))
                                                .setSmallIcon(R.mipmap.logo_icon)
                                                .setContentTitle(pTitle)
                                                .setContentText(pushContent)
                                                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                                .setAutoCancel(true)
                                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                                .setSound(ringtoneUri)
                                                .setWhen(System.currentTimeMillis())
                                                .setContentIntent(pendingIntent);
                                    } else {
                                        ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                                        mBuilder.setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.push_sell_icon))
                                                .setSmallIcon(R.mipmap.logo_icon)
                                                .setContentTitle(pTitle)
                                                .setContentText(pushContent)
                                                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                                .setAutoCancel(true)
                                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                                .setSound(ringtoneUri)
                                                .setWhen(System.currentTimeMillis())
                                                .setContentIntent(pendingIntent);
                                    }
                                }
                            } else {
                                ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                                mBuilder.setSmallIcon(R.mipmap.logo_icon)
                                        .setContentTitle(pTitle)
                                        .setContentText(pushContent)
                                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                                        .setAutoCancel(true)
                                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                                        .setSound(ringtoneUri)
                                        .setWhen(System.currentTimeMillis())
                                        .setContentIntent(pendingIntent);
                            }

                            NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                            notificationManager.notify(requestCode, mBuilder.build());
                        }
                    }
                }
                Log.w(TAG, "Notify : End End");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    //TODO 소리, 진동 설정에 따른 Notification 확인 필요

    //일반적인 페이지 이동 Intent
    private Intent createIntent(
            String pushSN, String landingType, String landingPage, String landingUrl, String landingDiv1,
            String stockCode, String stockName, String pocketSn, String discountType, String landingDiv2) {
        Intent mIntent = new Intent(this, MainActivity.class);
        mIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        //랜딩 페이지 추가
        mIntent.putExtra("push_click" , true);
        mIntent.putExtra("pushSn", pushSN);
        mIntent.putExtra("landingType", landingType);
        mIntent.putExtra("landingPage", landingPage);
        mIntent.putExtra("landingUrl", landingUrl);
        mIntent.putExtra("pushDiv1", landingDiv1);
        mIntent.putExtra("pushDiv2", landingDiv2);
        mIntent.putExtra("stockCode", stockCode);
        mIntent.putExtra("stockName", stockName);
        mIntent.putExtra("pocketSn", pocketSn);
        mIntent.putExtra("discountType", discountType);

        return mIntent;
    }

    private class ImageGetEvent extends AsyncTask<String, Void, Bitmap> {
        @Override
        protected Bitmap doInBackground(String... urls) {
            Bitmap map = null;
            for (String url : urls) {
                map = downloadImage(url);
            }
            return map;
        }

        @Override
        protected void onPostExecute(Bitmap result) {
            if (result != null) {
                notifyMessage(result);
            } else {
                notifyMessage(null);
            }
        }

        private Bitmap downloadImage(String url) {
            Bitmap bitmap = null;
            InputStream stream = null;
            BitmapFactory.Options bmOption = new BitmapFactory.Options();
            bmOption.inSampleSize = 1;
            bmOption.inDither = true;

            try {
                stream = getHttpConnection(url);
                if(stream != null) {
                    bitmap = BitmapFactory.decodeStream(stream, null, bmOption);
                    stream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
                notifyMessage(null);
            }
            return bitmap;
        }

        private InputStream getHttpConnection(String urlString) throws IOException {
            InputStream stream = null;
            URL url = new URL(urlString);
            URLConnection connection = url.openConnection();

            try {
                HttpURLConnection httpConn = (HttpURLConnection) connection;
                httpConn.setRequestMethod("GET");
                httpConn.connect();

                if (httpConn.getResponseCode() == HttpURLConnection.HTTP_OK) {
                    stream = httpConn.getInputStream();
                }
            } catch (Exception e) {
                e.printStackTrace();
                notifyMessage(null);
            }

            return stream;
        }
    }

    private void notifyMessage(Bitmap result) {
        if(result != null) {
            if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false) && mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                player.start();
                NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID)
                        .setSmallIcon(R.mipmap.logo_icon)
                        .setContentTitle(pTitle)
                        .setContentText(pushContent)
                        .setLargeIcon(result)
                        .setStyle(new NotificationCompat.BigPictureStyle().bigPicture(result).bigLargeIcon((Bitmap) null).setBigContentTitle(pTitle).setSummaryText(pushContent))
                        .setAutoCancel(true)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setWhen(System.currentTimeMillis())
                        .setVibrate(new long[]{600, 600})
                        .setContentIntent(pendingIntent);

                NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.notify(requestCode, mBuilder.build());
            } else {
                if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false)) {
                    NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID)
                            .setSmallIcon(R.mipmap.logo_icon)
                            .setContentTitle(pTitle)
                            .setContentText(pushContent)
                            .setLargeIcon(result)
                            .setStyle(new NotificationCompat.BigPictureStyle().bigPicture(result).bigLargeIcon((Bitmap) null).setBigContentTitle(pTitle).setSummaryText(pushContent))
                            .setAutoCancel(true)
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setWhen(System.currentTimeMillis())
                            .setSound(null)
                            .setVibrate(new long[]{600, 600})
                            .setContentIntent(pendingIntent);

                    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                    notificationManager.notify(requestCode, mBuilder.build());
                } else {
                    if(mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                        MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                        player.start();
                        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID)
                                .setSmallIcon(R.mipmap.logo_icon)
                                .setContentTitle(pTitle)
                                .setContentText(pushContent)
                                .setLargeIcon(result)
                                .setStyle(new NotificationCompat.BigPictureStyle().bigPicture(result).bigLargeIcon((Bitmap) null).setBigContentTitle(pTitle).setSummaryText(pushContent))
                                .setAutoCancel(true)
                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                .setWhen(System.currentTimeMillis())
                                .setContentIntent(pendingIntent);

                        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                        notificationManager.notify(requestCode, mBuilder.build());
                    } else {
                        ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);

                        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID)
                                .setSmallIcon(R.mipmap.logo_icon)
                                .setContentTitle(pTitle)
                                .setContentText(pushContent)
                                .setLargeIcon(result)
                                .setStyle(new NotificationCompat.BigPictureStyle().bigPicture(result).bigLargeIcon((Bitmap) null).setBigContentTitle(pTitle).setSummaryText(pushContent))
                                .setAutoCancel(true)
                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                .setWhen(System.currentTimeMillis())
                                .setSound(ringtoneUri)
                                .setContentIntent(pendingIntent);

                        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                        notificationManager.notify(requestCode, mBuilder.build());
                    }
                }
            }
        } else {
            if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false) && mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                player.start();

                NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID)
                        .setSmallIcon(R.mipmap.logo_icon)
                        .setContentTitle(pTitle)
                        .setContentText(pushContent)
                        .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                        .setAutoCancel(true)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setWhen(System.currentTimeMillis())
                        .setVibrate(new long[]{600, 600})
                        .setContentIntent(pendingIntent);

                NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.notify(requestCode, mBuilder.build());
            } else {
                if(mPrefs.getBoolean(IConstants.PREFS_NOTI_VIBE, false)) {
                    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                    notificationManager.notify(requestCode, getNotiBuilderVibe().build());
                } else {
                    if(mPrefs.getBoolean(IConstants.PREFS_NOTI_SOUND, false)) {
                        MediaPlayer player = MediaPlayer.create(getApplicationContext(), Settings.System.DEFAULT_NOTIFICATION_URI);
                        player.start(); //소리 재생

                        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                        notificationManager.notify(requestCode, getNotiBuilderNoSound().build());
                    } else {
                        ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                        notificationManager.notify(requestCode, getNotiBuilderSound().build());
                    }
                }
            }
        }
    }

    private NotificationCompat.Builder getNotiBuilderVibe() {
        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID);
        mBuilder.setSmallIcon(R.mipmap.logo_icon)
                .setContentTitle(pTitle)
                .setContentText(pushContent)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setWhen(System.currentTimeMillis())
                .setSound(null)
                .setVibrate(new long[]{600, 600})
                .setContentIntent(pendingIntent);
        return mBuilder;
    }

    private NotificationCompat.Builder getNotiBuilderSound() {
        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID);
        mBuilder.setSmallIcon(R.mipmap.logo_icon)
                .setContentTitle(pTitle)
                .setContentText(pushContent)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setWhen(System.currentTimeMillis())
                .setSound(ringtoneUri)
                .setContentIntent(pendingIntent);
        return mBuilder;
    }

    private NotificationCompat.Builder getNotiBuilderNoSound() {

        final NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, IConstants.NOTIFICATION_CH_ID);
        mBuilder.setSmallIcon(R.mipmap.logo_icon)
                .setContentTitle(pTitle)
                .setContentText(pushContent)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(pushContent))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setWhen(System.currentTimeMillis())
                .setContentIntent(pendingIntent);
        return mBuilder;
    }

    private int getActiveNotificationCount() throws NoSuchFieldException {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        StatusBarNotification[] activeNotifications = notificationManager.getActiveNotifications();

        int MAX_NOTIFICATION_COUNT = 23;
        if(activeNotifications.length > MAX_NOTIFICATION_COUNT) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                StatusBarNotification notification = Arrays.stream(activeNotifications)
                        .min(Comparator.comparing(StatusBarNotification::getId))
                        .orElseThrow(NoSuchFieldException::new);
                notificationManager.cancel(notification.getId());
            }
        }
        return activeNotifications.length;
    }

    interface IConstants {
        //[난독해제파일 등록]  App > build > outputs > mapping > release > mapping.txt
        boolean isDebuggable = false;        // false - 출시용 버전  /  true - 개발용 버전

        String PREFS_NAME = "rassi_trade_prefs";    // 프리퍼런스 이름
        String PREFS_FCM_TOKEN = "fcm_token";       // fcm token
        String NOTIFICATION_CH_ID = "com.thinkpool.mobile.sinq.push";       // Push 채널
        String PREFS_TODAY_TOKEN_CHECK_FTS = "fts_today_token_check";       // FragTradeSecretary에서 매일 한번만 fcm token 체크, 오늘 날짜 저장
        String PREFS_TODAY_TOKEN_CHECK_FMM = "fmm_today_token_check";       // FragTradeSecretary에서 매일 한번만 fcm token 체크, 오늘 날짜 저장

        String PREFS_USER_ID = "rassi_id";          // 씽크풀 ID
        String PREFS_TEMP_ID = "temp_id";
        String PREFS_USER_NAME = "user_name";                   //회원이름 [String]
        String PREFS_CUR_VER_CODE = "app_version_code";         //설치된 앱에서 가져오는 버전코드 [int]
        String PREFS_PRE_VER_CODE = "pre_version_code";         //이전에 앱 실행시 저장된 앱버전
        String PREFS_TEST_CHANGE_ID = "test_change_id";         //테스트앱에서 아이디 변경시 푸시 등록 방지
        String PREFS_TEST_ID = "test_id";                       //테스트 아이디로 변경시 결제 불가 [String]
        String PREFS_CHK_LOGIN_DATE = "check_login_date";       //씽크풀 로그인 체크 날짜 [String]

        String PREFS_NOTI_VIBE = "noti_vibe";
        String PREFS_NOTI_SOUND = "noti_sound";

    }

}

