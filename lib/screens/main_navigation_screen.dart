import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/layout/responsive_layout.dart';

import 'dashboard/dashboard_screen.dart';
import 'players/players_screen.dart';
import 'attendance/attendance_screen.dart';
import 'profile/team_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Halaman navigasi

  // Halaman navigasi
  List<Widget> get _pages => [
    const DashboardScreen(),
    const PlayersScreen(),
    AttendanceScreen(
      onBackToPlayers: () {
        _onDestinationSelected(1);
      },
    ),
    TeamProfileScreen(
      onBackToAttendance: () {
        _onDestinationSelected(2);
      },
    ),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    NavigationItem(
      label: 'Pemain',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    NavigationItem(
      label: 'Absensi',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    NavigationItem(
      label: 'Profil Tim',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      return _buildDesktopLayout();
    }

    if (ResponsiveLayout.isTablet(context)) {
      return _buildTabletLayout();
    }

    return _buildMobileLayout();
  }

  // MOBILE
  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppTheme.navy,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _navigationItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon, color: Colors.white),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  // TABLET
  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Colors.white,
            indicatorColor: AppTheme.navy,
            labelType: NavigationRailLabelType.all,
            destinations: _navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon, color: Colors.white),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, color: AppTheme.border),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  // DESKTOP
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 230,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildBrand(),
                const SizedBox(height: 36),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final selected = _selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          selected: selected,
                          selectedTileColor: AppTheme.navy.withValues(
                            alpha: 0.08,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected
                                ? AppTheme.navy
                                : AppTheme.textSecondary,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selected
                                  ? AppTheme.navy
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          onTap: () {
                            _onDestinationSelected(index);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'VCLUB © 2026',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: AppTheme.border),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.sports_volleyball_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'VCLUB',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.navy,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage Your Team',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
