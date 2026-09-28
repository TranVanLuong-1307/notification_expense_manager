package com.example.notification_expense_manager;

import android.content.ComponentName;
import android.content.Intent;
import android.provider.Settings;
import android.text.TextUtils;

import androidx.annotation.NonNull;

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

    private EventChannel.EventSink eventSink;

    @Override
    public void configureFlutterEngine(
            @NonNull FlutterEngine flutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine);

        // =========================
        // EVENT CHANNEL
        // Android -> Flutter
        // =========================

        new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                EVENT_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {

            @Override
            public void onListen(
                    Object arguments,
                    EventChannel.EventSink events
            ) {
                eventSink = events;

                NotificationListener.setNotificationCallback(
                        (packageName, title, text, timestamp) -> {

                            runOnUiThread(() -> {

                                if (eventSink == null) {
                                    return;
                                }

                                Map<String, Object> data =
                                        new HashMap<>();

                                data.put("packageName", packageName);
                                data.put("title", title);
                                data.put("text", text);
                                data.put("timestamp", timestamp);

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
        });

        // =========================
        // METHOD CHANNEL
        // Flutter -> Android
        // =========================

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                METHOD_CHANNEL
        ).setMethodCallHandler((call, result) -> {

            if (call.method.equals("openNotificationSettings")) {

                Intent intent = new Intent(
                        Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
                );

                startActivity(intent);

                result.success(null);

            } else if (call.method.equals("isNotificationAccessGranted")) {

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
                                componentName.flattenToString()
                        );

                result.success(granted);

            } else {

                result.notImplemented();
            }
        });
    }

    @Override
    protected void onDestroy() {
        NotificationListener.setNotificationCallback(null);
        eventSink = null;

        super.onDestroy();
    }
}