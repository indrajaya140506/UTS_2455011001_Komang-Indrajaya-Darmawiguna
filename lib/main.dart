import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/country_provider.dart';
import 'providers/match_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const VClubApp());
}

class VClubApp extends StatelessWidget {
  const VClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: MaterialApp(
        title: 'VCLUB',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
