import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaishodoPayrollApp());
}

class TaishodoPayrollApp extends StatelessWidget {
  const TaishodoPayrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Chấm Công & Bảng Lương Taishodo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D47A1),
            primary: const Color(0xFF0D47A1),
            secondary: const Color(0xFF00897B),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F6F9),
          cardTheme: const CardTheme(
            elevation: 0.5,
            color: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return auth.isAuthenticated
        ? const DashboardScreen()
        : const LoginScreen();
  }
}
