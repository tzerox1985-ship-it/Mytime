import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payroll_config.dart';
import '../models/daily_record.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _keyConfig = 'payroll_config';
  static const String _keyRecords = 'daily_records';
  static const String _keyUser = 'user_profile';

  Future<PayrollConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyConfig);
    if (jsonStr != null) {
      try {
        return PayrollConfig.fromJson(jsonStr);
      } catch (_) {}
    }
    // Mặc định chuẩn theo phiếu lương Taishodo
    return PayrollConfig(
      baseSalary: 15509700,
      baseSalaryAllowance: 1654598,
      positionAllowance: 1500000,
      housingTransportAllowance: 700000,
      attendanceBonus: 500000,
      standardWorkingDays: 24,
      bhxhRate: 0.08,
      bhytRate: 0.015,
      bhtnRate: 0.01,
      unionFee: 40000,
    );
  }

  Future<void> saveConfig(PayrollConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyConfig, config.toJson());
  }

  Future<List<DailyRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyRecords);
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        return jsonList.map((e) => DailyRecord.fromJson(e)).toList();
      } catch (_) {}
    }

    // Tự động khởi tạo dữ liệu mẫu khớp 100% phiếu lương Tháng 9/2026:
    // 21.5 ngày đi làm, 0.5 ngày nghỉ phép, 2 ngày nghỉ hưởng lương, 23h OT 150%
    return _generateTaishodoSeptember2026Sample();
  }

  Future<void> saveRecords(List<DailyRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyRecords, jsonList);
  }

  Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUser);
    if (jsonStr != null) {
      try {
        return UserProfile.fromJson(jsonStr);
      } catch (_) {}
    }
    return UserProfile(
      id: 'USR_5598',
      fullName: 'Trần Thế Thưởng',
      employeeCode: '5598',
      companyName: 'CÔNG TY TNHH TAISHODO VIỆT NAM',
      department: 'Sản xuất - PP 1',
    );
  }

  Future<void> saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, user.toJson());
  }

  List<DailyRecord> _generateTaishodoSeptember2026Sample() {
    List<DailyRecord> sample = [];
    final now = DateTime(2026, 9, 1);

    // Ngày 1, 2: Nghỉ lễ Quốc Khánh 2/9 hưởng 100% lương (2.0 ngày)
    sample.add(DailyRecord(
      id: '2026-09-01',
      date: DateTime(2026, 9, 1),
      status: WorkDayStatus.paidHoliday,
      note: 'Nghỉ lễ Quốc Khánh',
    ));
    sample.add(DailyRecord(
      id: '2026-09-02',
      date: DateTime(2026, 9, 2),
      status: WorkDayStatus.paidHoliday,
      note: 'Nghỉ lễ Quốc Khánh',
    ));

    // Ngày 3: Nghỉ phép năm nửa ngày (0.5 ngày phép + 0.5 ngày làm việc)
    sample.add(DailyRecord(
      id: '2026-09-03',
      date: DateTime(2026, 9, 3),
      status: WorkDayStatus.annualLeave,
      note: 'Nghỉ phép 0.5 ngày',
    ));

    // 21 ngày làm việc còn lại (trong đó phân bổ 23 giờ OT 150%)
    for (int day = 4; day <= 24; day++) {
      // Phân bổ OT 150% vào các ngày trong tuần
      List<OvertimeItem> ot = [];
      if (day <= 15) {
        ot.add(OvertimeItem(type: OvertimeType.normal150, hours: 2.0));
      } else if (day == 16) {
        ot.add(OvertimeItem(type: OvertimeType.normal150, hours: 1.0));
      }

      sample.add(DailyRecord(
        id: '2026-09-${day.toString().padLeft(2, '0')}',
        date: DateTime(2026, 9, day),
        status: WorkDayStatus.fullDay,
        overtimes: ot,
        note: ot.isNotEmpty ? 'Tăng ca 150% ${ot.first.hours}h' : 'Ca làm chuẩn',
      ));
    }

    return sample;
  }
}
