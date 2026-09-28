import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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

  final List<Widget> _screens = [
    const Center(child: Text('Home\n(Tổng chi hôm nay, Giao dịch gần đây)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
    const Center(child: Text('Transactions\n(Lịch sử giao dịch)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
    const Center(child: Text('Statistics\n(Tổng chi theo tháng và danh mục)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
    const Center(child: Text('Settings\n(Quyền Notification, Xóa dữ liệu)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nút thêm giao dịch được bấm!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}