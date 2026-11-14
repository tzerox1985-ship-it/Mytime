import 'dart:convert';
import 'payroll_config.dart';

/// Định nghĩa các loại hệ số tăng ca (OT) theo chuẩn phiếu lương Taishodo
enum OvertimeType {
  normal150(1.5, 'Giờ làm thường 150%'),
  after10pm200(2.0, 'Tăng ca sau 10h 200%'),
  nightShiftContinuous210(2.1, 'Tăng ca đêm thường liên tục 210%'),
  sunday200(2.0, 'Tăng ca chủ nhật 200%'),
  sundayAfter10pm270(2.7, 'Tăng ca CN sau 10h 270%'),
  holiday300(3.0, 'Tăng ca ngày lễ 300%'),
  holidayAfter10pm390(3.9, 'Tăng ca sau 10h ngày lễ 390%'),
  nightShiftBonus130(1.3, 'Ca đêm 130%');

  final double multiplier;
  final String label;
  const OvertimeType(this.multiplier, this.label);
}

class OvertimeItem {
  final OvertimeType type;
  final double hours;

  OvertimeItem({required this.type, required this.hours});

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'hours': hours,
      };

  factory OvertimeItem.fromMap(Map<String, dynamic> map) => OvertimeItem(
        type: OvertimeType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => OvertimeType.normal150,
        ),
        hours: (map['hours'] as num).toDouble(),
      );
}

/// Loại ngày công làm việc / nghỉ hưởng lương
enum WorkDayStatus {
  fullDay(1.0, 'Đi làm đủ công (1.0)'),
  halfDay(0.5, 'Làm nửa ngày (0.5)'),
  annualLeave(1.0, 'Nghỉ phép năm (100%)'),
  paidHoliday(1.0, 'Nghỉ lễ/chế độ (100%)'),
  leave70Percent(0.7, 'Nghỉ ngừng việc (70%)'),
  unpaidLeave(0.0, 'Nghỉ không lương (0)');

  final double paidRatio;
  final String label;
  const WorkDayStatus(this.paidRatio, this.label);
}

/// Bản ghi chấm công và thu nhập từng ngày
class DailyRecord {
  final String id;
  final DateTime date;
  final WorkDayStatus status;
  final List<OvertimeItem> overtimes;
  final int lateMinutes; // Đi muộn (phút)
  final double adjustmentAmount; // Điều chỉnh +/-
  final String note;

  DailyRecord({
    required this.id,
    required this.date,
    this.status = WorkDayStatus.fullDay,
    this.overtimes = const [],
    this.lateMinutes = 0,
    this.adjustmentAmount = 0.0,
    this.note = '',
  });

  /// Tính tiền công cơ bản kiếm được trong ngày
  double calculateBaseEarnings(PayrollConfig config) {
    if (config.standardWorkingDays <= 0) return 0;
    double dailyRate = config.totalGrossFixed / config.standardWorkingDays;
    return dailyRate * status.paidRatio;
  }

  /// Tính tổng tiền Tăng ca (OT) trong ngày
  double calculateOvertimeEarnings(PayrollConfig config) {
    double total = 0;
    for (var ot in overtimes) {
      total += ot.hours * config.hourlyRate * ot.type.multiplier;
    }
    return total;
  }

  /// Tổng thu nhập thực tế phát sinh trong ngày
  double calculateTotalDailyEarnings(PayrollConfig config) {
    return calculateBaseEarnings(config) +
        calculateOvertimeEarnings(config) +
        adjustmentAmount;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'status': status.name,
        'overtimes': overtimes.map((e) => e.toMap()).toList(),
        'lateMinutes': lateMinutes,
        'adjustmentAmount': adjustmentAmount,
        'note': note,
      };

  factory DailyRecord.fromMap(Map<String, dynamic> map) => DailyRecord(
        id: map['id'] ?? '',
        date: DateTime.parse(map['date']),
        status: WorkDayStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => WorkDayStatus.fullDay,
        ),
        overtimes: (map['overtimes'] as List<dynamic>?)
                ?.map((e) => OvertimeItem.fromMap(e))
                .toList() ??
            [],
        lateMinutes: (map['lateMinutes'] as num?)?.toInt() ?? 0,
        adjustmentAmount: (map['adjustmentAmount'] as num?)?.toDouble() ?? 0.0,
        note: map['note'] ?? '',
      );

  String toJson() => json.encode(toMap());
  factory DailyRecord.fromJson(String source) =>
      DailyRecord.fromMap(json.decode(source));
}
