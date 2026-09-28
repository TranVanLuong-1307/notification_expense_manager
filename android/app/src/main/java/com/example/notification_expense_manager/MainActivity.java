package com.example.notification_expense_manager;

import android.Manifest;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String EVENT_CHANNEL =
            "notification_expense_manager/notifications";

    private static final String METHOD_CHANNEL =
            "notification_expense_manager/settings";

    // Channel dùng để tạo notification test
    private static final String TEST_CHANNEL_ID =
            "bank_test_channel";

    private EventChannel.EventSink eventSink;

    @Override
    public void configureFlutterEngine(
            @NonNull FlutterEngine flutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine);

        // Tạo Notification Channel dùng cho notification test
        createTestNotificationChannel();

        // =========================
        // EVENT CHANNEL
        // Android -> Flutter
        // =========================

        new EventChannel(
                flutterEngine
                        .getDartExecutor()
                        .getBinaryMessenger(),
                EVENT_CHANNEL
        ).setStreamHandler(
                new EventChannel.StreamHandler() {

                    @Override
                    public void onListen(
                            Object arguments,
                            EventChannel.EventSink events
                    ) {
                        eventSink = events;

                        NotificationListener
                                .setNotificationCallback(
                                        (
                                                packageName,
                                                title,
                                                text,
                                                timestamp
                                        ) -> {

                                            runOnUiThread(() -> {

                                                if (eventSink == null) {
                                                    return;
                                                }

                                                Map<String, Object> data =
                                                        new HashMap<>();

                                                data.put(
                                                        "packageName",
                                                        packageName
                                                );

                                                data.put(
                                                        "title",
                                                        title
                                                );

                                                data.put(
                                                        "text",
                                                        text
                                                );

                                                data.put(
                                                        "timestamp",
                                                        timestamp
                                                );

                                                eventSink.success(data);
                                            });
                                        }
                                );
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;

                        NotificationListener
                                .setNotificationCallback(null);
                    }
                }
        );

        // =========================
        // METHOD CHANNEL
        // Flutter -> Android
        // =========================

        new MethodChannel(
                flutterEngine
                        .getDartExecutor()
                        .getBinaryMessenger(),
                METHOD_CHANNEL
        ).setMethodCallHandler(
                (call, result) -> {

                    // -------------------------
                    // Mở Notification Access
                    // -------------------------

                    if (call.method.equals(
                            "openNotificationSettings"
                    )) {

                        Intent intent =
                                new Intent(
                                        Settings
                                                .ACTION_NOTIFICATION_LISTENER_SETTINGS
                                );

                        startActivity(intent);

                        result.success(null);
                    }

                    // -------------------------
                    // Kiểm tra Notification Access
                    // -------------------------

                    else if (call.method.equals(
                            "isNotificationAccessGranted"
                    )) {

                        String enabledListeners =
                                Settings.Secure.getString(
                                        getContentResolver(),
                                        "enabled_notification_listeners"
                                );

                        ComponentName componentName =
                                new ComponentName(
                                        this,
                                        NotificationListener.class
                                );

                        boolean granted =
                                enabledListeners != null
                                        && enabledListeners.contains(
                                        componentName
                                                .flattenToString()
                                );

                        result.success(granted);
                    }

                    // -------------------------
                    // Gửi notification ngân hàng giả
                    // -------------------------

                    else if (call.method.equals(
                            "sendTestBankNotification"
                    )) {

                        sendTestBankNotification();

                        result.success(null);
                    }

                    else {
                        result.notImplemented();
                    }
                }
        );
    }

    // =========================
    // TẠO NOTIFICATION CHANNEL
    // =========================

    private void createTestNotificationChannel() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationChannel channel =
                    new NotificationChannel(
                            TEST_CHANNEL_ID,
                            "Thông báo giao dịch thử nghiệm",
                            NotificationManager.IMPORTANCE_HIGH
                    );

            channel.setDescription(
                    "Dùng để kiểm tra chức năng đọc thông báo giao dịch"
            );

            NotificationManager notificationManager =
                    getSystemService(
                            NotificationManager.class
                    );

            notificationManager
                    .createNotificationChannel(channel);
        }
    }

    // =========================
    // TẠO NOTIFICATION NGÂN HÀNG GIẢ
    // =========================

    private void sendTestBankNotification() {

        String title = "MB Bank";

        String text =
                "TK 123456789 -250,000 VND. "
                        + "SD 3,250,000 VND. "
                        + "GD: GRAB";

        NotificationCompat.Builder builder =
                new NotificationCompat.Builder(
                        this,
                        TEST_CHANNEL_ID
                )
                        .setSmallIcon(
                                android.R.drawable
                                        .ic_dialog_info
                        )
                        .setContentTitle(title)
                        .setContentText(text)
                        .setStyle(
                                new NotificationCompat
                                        .BigTextStyle()
                                        .bigText(text)
                        )
                        .setPriority(
                                NotificationCompat
                                        .PRIORITY_HIGH
                        )
                        .setAutoCancel(true);

        // Android 13+ cần POST_NOTIFICATIONS
        if (
                Build.VERSION.SDK_INT
                        >= Build.VERSION_CODES.TIRAMISU
                        &&
                        ActivityCompat.checkSelfPermission(
                                this,
                                Manifest.permission.POST_NOTIFICATIONS
                        )
                                != PackageManager.PERMISSION_GRANTED
        ) {

            ActivityCompat.requestPermissions(
                    this,
                    new String[]{
                            Manifest.permission.POST_NOTIFICATIONS
                    },
                    1001
            );

            return;
        }

        NotificationManagerCompat
                .from(this)
                .notify(
                        1001,
                        builder.build()
                );
    }

    @Override
    protected void onDestroy() {

        NotificationListener
                .setNotificationCallback(null);

        eventSink = null;

        super.onDestroy();
    }
}