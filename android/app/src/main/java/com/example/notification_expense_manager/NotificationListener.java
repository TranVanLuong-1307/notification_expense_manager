package com.example.notification_expense_manager;

import android.app.Notification;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

public class NotificationListener extends NotificationListenerService {

    private static final String TAG = "NotificationReader";

    // Callback dùng để gửi notification sang MainActivity
    public interface NotificationCallback {
        void onNotificationReceived(
                String packageName,
                String title,
                String text,
                long timestamp
        );
    }

    private static NotificationCallback callback;

    // MainActivity sẽ đăng ký callback tại đây
    public static void setNotificationCallback(NotificationCallback newCallback) {
        callback = newCallback;
    }

    @Override
    public void onListenerConnected() {
        super.onListenerConnected();

        Log.d(TAG, "Notification Listener connected");
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        super.onNotificationPosted(sbn);

        if (sbn == null) {
            return;
        }

        Notification notification = sbn.getNotification();

        if (notification == null) {
            return;
        }

        // 1. Lấy package của ứng dụng gửi notification
        String packageName = sbn.getPackageName();

        // 2. Lấy title
        CharSequence titleCharSequence =
                notification.extras.getCharSequence(Notification.EXTRA_TITLE);

        // 3. Lấy text
        CharSequence textCharSequence =
                notification.extras.getCharSequence(Notification.EXTRA_TEXT);

        String title =
                titleCharSequence != null
                        ? titleCharSequence.toString()
                        : "";

        String text =
                textCharSequence != null
                        ? textCharSequence.toString()
                        : "";

        // 4. Lấy thời gian notification
        long timestamp = sbn.getPostTime();

        // ==============================
        // DEBUG LOGCAT
        // ==============================

        Log.d(TAG, "==============================");
        Log.d(TAG, "Package: " + packageName);
        Log.d(TAG, "Title: " + title);
        Log.d(TAG, "Text: " + text);
        Log.d(TAG, "Time: " + timestamp);
        Log.d(TAG, "==============================");

        // ==============================
        // GỬI DỮ LIỆU CHO MAINACTIVITY
        // ==============================

        if (callback != null) {

            callback.onNotificationReceived(
                    packageName,
                    title,
                    text,
                    timestamp
            );

        } else {

            Log.d(
                    TAG,
                    "Callback chưa được đăng ký - Flutter chưa sẵn sàng"
            );
        }
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        super.onNotificationRemoved(sbn);

        if (sbn != null) {

            Log.d(
                    TAG,
                    "Notification removed: "
                            + sbn.getPackageName()
            );
        }
    }
}