import 'dart:async';

import 'package:flutter/material.dart';

import 'services/notification_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý chi tiêu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Lưu thông báo mới nhất nhận được từ Android
  Map<String, dynamic>? _latestNotification;

  StreamSubscription<Map<String, dynamic>>?
  _notificationSubscription;

  @override
  void initState() {
    super.initState();

    // Lắng nghe thông báo từ Android
    _notificationSubscription =
        NotificationService.notifications.listen(
              (notification) {
            debugPrint(
              '========== FLUTTER NOTIFICATION ==========',
            );
            debugPrint(
              'Package: ${notification['packageName']}',
            );
            debugPrint(
              'Title: ${notification['title']}',
            );
            debugPrint(
              'Text: ${notification['text']}',
            );
            debugPrint(
              'Time: ${notification['timestamp']}',
            );
            debugPrint(
              '==========================================',
            );

            if (!mounted) return;

            // Cập nhật notification lên giao diện
            setState(() {
              _latestNotification = notification;
            });
          },
          onError: (error) {
            debugPrint(
              'Notification error: $error',
            );
          },
        );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // =========================
  // HOME
  // =========================

  Widget _buildHomeScreen() {
    final notification = _latestNotification;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông báo mới nhất',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (notification == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chưa nhận được thông báo nào.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active),
                        SizedBox(width: 8),
                        Text(
                          'Đã nhận thông báo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    const Text(
                      'Package:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification['packageName']
                          ?.toString() ??
                          '',
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Tiêu đề:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification['title']
                          ?.toString() ??
                          '',
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Nội dung:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification['text']
                          ?.toString() ??
                          '',
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Timestamp:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification['timestamp']
                          ?.toString() ??
                          '',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // CHỌN MÀN HÌNH
  // =========================

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();

      case 1:
        return const Center(
          child: Text(
            'Transactions\n(Lịch sử giao dịch)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        );

      case 2:
        return const Center(
          child: Text(
            'Statistics\n(Tổng chi theo tháng và danh mục)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        );

      case 3:
        return const Center(
          child: Text(
            'Settings\n(Quyền Notification, Xóa dữ liệu)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        );

      default:
        return _buildHomeScreen();
    }
  }

  // =========================
  // UI CHÍNH
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý chi tiêu',
        ),
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
      ),

      body: _getCurrentScreen(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService.sendTestBankNotification();
        },
        child: const Icon(Icons.notifications_active),
      ),
    );
  }
}