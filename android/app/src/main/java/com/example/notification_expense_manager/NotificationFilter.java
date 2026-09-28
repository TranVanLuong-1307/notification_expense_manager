package com.example.notification_expense_manager;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class NotificationFilter {

    /*
     * Package của chính ứng dụng.
     * Chỉ dùng để kiểm tra notification giả trong quá trình phát triển.
     */
    private static final String TEST_PACKAGE =
            "com.example.notification_expense_manager";

    /*
     * Danh sách package của các ứng dụng ngân hàng
     * được hệ thống hỗ trợ.
     */
    private static final Set<String> SUPPORTED_BANK_PACKAGES =
            new HashSet<>(Arrays.asList(

                    // App hiện tại - dùng để test
                    TEST_PACKAGE,

                    // MB Bank
                    "com.mbmobile",

                    // BIDV SmartBanking
                    "com.vnpay.bidv",

                    // Techcombank Mobile
                    "vn.com.techcombank.bb.app",

                    // TPBank Mobile
                    "com.tpb.mb.gprsandroid",

                    // ACB ONE
                    "mobile.acb.com.vn"
            ));

    private NotificationFilter() {
        // Không cho tạo object từ class này.
    }

    /**
     * Kiểm tra notification có đến từ
     * ứng dụng ngân hàng được hỗ trợ hay không.
     */
    public static boolean shouldProcess(String packageName) {

        if (packageName == null || packageName.isEmpty()) {
            return false;
        }

        return SUPPORTED_BANK_PACKAGES.contains(packageName);
    }
}