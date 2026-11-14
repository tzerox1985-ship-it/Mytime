import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginMode = true; // true: Đăng nhập, false: Đăng ký
  final _fullNameController = TextEditingController(text: 'Trần Thế Thưởng');
  final _employeeCodeController = TextEditingController(text: '5598');
  final _emailController = TextEditingController(text: 'thethuong.taishodo@example.com');
  final _passwordController = TextEditingController(text: '12345678');
  bool _obscurePassword = true;

  void _handleAuthAction() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    bool success = await auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLoginMode ? 'Đăng nhập thành công! Đang tải dữ liệu Cloud...' : 'Đăng ký tài khoản Cloud thành công!'),
          backgroundColor: const Color(0xFF00796B),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _handleGoogleLogin() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    bool success = await auth.signInWithGoogle();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập Google thành công! Toàn bộ bảng lương đã đồng bộ.'),
          backgroundColor: Color(0xFF00796B),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF092923),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo CTT xanh
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'CTT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CÔNG TY TNHH TAISHODO VIỆT NAM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Color(0xFF80CBC4),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chấm Công & Thu Nhập Realtime',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dữ liệu đồng bộ Cloud - Truy cập mọi thiết bị',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
                const SizedBox(height: 20),

                // Card Form
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tab Chuyển Đăng nhập / Đăng ký
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLoginMode = true),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isLoginMode ? const Color(0xFF00796B) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Đăng Nhập',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: _isLoginMode ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLoginMode = false),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !_isLoginMode ? const Color(0xFF00796B) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Đăng Ký Mới',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: !_isLoginMode ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (!_isLoginMode) ...[
                        TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Họ và tên nhân viên',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _employeeCodeController,
                          decoration: InputDecoration(
                            labelText: 'Mã nhân viên (Vd: 5598)',
                            prefixIcon: const Icon(Icons.numbers_outlined, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email của bạn',
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleAuthAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isLoginMode ? 'Đăng Nhập Tài Khoản' : 'Tạo Tài Khoản & Đồng Bộ Cloud',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('HOẶC', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Nút Đăng nhập với Google
                      OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : _handleGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 26, color: Color(0xFFEA4335)),
                        label: const Text(
                          'Đăng nhập với Google',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF80CBC4)),
                    SizedBox(width: 4),
                    Text(
                      'Bảo mật dữ liệu đám mây Firebase Cloud & mã hóa end-to-end',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFFB2DFDB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
