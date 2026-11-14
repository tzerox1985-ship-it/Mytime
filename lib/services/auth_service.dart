import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    // Mặc định đăng nhập với thông tin mẫu từ phiếu lương
    _currentUser = UserProfile(
      id: 'USR_5598',
      fullName: 'Trần Thế Thưởng',
      employeeCode: '5598',
      companyName: 'CÔNG TY TNHH TAISHODO VIỆT NAM',
      email: 'thethuong.taishodo@example.com',
      department: 'Sản xuất - PP 1',
    );
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserProfile(
      id: 'USR_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'Trần Thế Thưởng',
      employeeCode: '5598',
      companyName: 'CÔNG TY TNHH TAISHODO VIỆT NAM',
      email: email,
      department: 'Sản xuất - PP 1',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserProfile(
      id: 'GOOGLE_USER_5598',
      fullName: 'Trần Thế Thưởng',
      employeeCode: '5598',
      companyName: 'CÔNG TY TNHH TAISHODO VIỆT NAM',
      email: 'thethuong.google@gmail.com',
      department: 'Sản xuất - PP 1',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
