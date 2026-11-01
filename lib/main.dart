import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const VClubApp());
}

class VClubApp extends StatelessWidget {
  const VClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VCLUB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}
