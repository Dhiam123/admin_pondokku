import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'pages/login_page.dart';
import 'widgets/admin.dart';

void main() {
  runApp(const AdminPondokApp());
}

class AdminPondokApp extends StatelessWidget {
  const AdminPondokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Pondok Pesantren',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/admin': (_) => const Admin(),
      },
    );
  }
}
