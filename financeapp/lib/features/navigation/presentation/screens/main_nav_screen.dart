import 'package:flutter/material.dart';
import 'package:financeapp/core/constants/app_constants.dart';
import 'package:financeapp/core/theme/app_colors.dart';
import 'package:financeapp/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:financeapp/features/transactions/presentation/screens/history_screen.dart';
import 'package:financeapp/features/reports/presentation/screens/reports_screen.dart';
import 'package:financeapp/features/profile/presentation/screens/more_screen.dart';
import 'package:financeapp/features/transactions/presentation/screens/add_transaction_screen.dart';
import '../widgets/bottom_nav.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNavigateToHistory: () => setState(() => _index = 1)),
      const HistoryScreen(),
      const ReportsScreen(),
      const MoreScreen(),
    ];
  }

  void _openAdd() {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AddTransactionScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLimits.contentMaxWidth),
          child: IndexedStack(index: _index, children: _screens),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black87,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
