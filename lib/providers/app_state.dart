import 'package:flutter/foundation.dart';
import '../models/payroll_config.dart';
import '../models/daily_record.dart';
import '../services/payroll_calculator.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  PayrollConfig _config = PayrollConfig();
  List<DailyRecord> _records = [];
  int _selectedMonth = 9;
  int _selectedYear = 2026;
  bool _isLoading = true;

  PayrollConfig get config => _config;
  List<DailyRecord> get records => _records;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get isLoading => _isLoading;

  MonthlyPayrollSummary get currentSummary => MonthlyPayrollSummary(
        month: _selectedMonth,
        year: _selectedYear,
        config: _config,
        records: _records,
      );

  AppState() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _config = await _storage.loadConfig();
    _records = await _storage.loadRecords();

    _isLoading = false;
    notifyListeners();
  }

  void changeMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  Future<void> updateConfig(PayrollConfig newConfig) async {
    _config = newConfig;
    await _storage.saveConfig(newConfig);
    notifyListeners();
  }

  Future<void> saveDailyRecord(DailyRecord record) async {
    int index = _records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  Future<void> deleteDailyRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  DailyRecord? getRecordForDate(DateTime date) {
    try {
      return _records.firstWhere((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  double getTodayEarnings() {
    final now = DateTime(2026, 9, DateTime.now().day.clamp(1, 24));
    final record = getRecordForDate(now);
    if (record == null) return 0;
    return record.calculateTotalDailyEarnings(_config);
  }
}
