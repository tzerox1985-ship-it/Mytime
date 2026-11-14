import '../models/payroll_config.dart';
import '../models/daily_record.dart';

class MonthlyPayrollSummary {
  final int month;
  final int year;
  final PayrollConfig config;

  // Tổng hợp ngày công
  double actualWorkDays = 0; // Số ngày đi làm thực tế (Vd: 21.5)
  double annualLeaveDays = 0; // Nghỉ phép (Vd: 0.5)
  double paidHolidayDays = 0; // Nghỉ hưởng lương 100% (Vd: 2.0)
  double leave70Days = 0; // Nghỉ hưởng 70%
  double unpaidLeaveDays = 0; // Nghỉ không lương
  int totalLateMinutes = 0; // Tổng số phút đi muộn

  // Tổng hợp giờ tăng ca (OT)
  double otHours150 = 0; // 150% (Vd: 23h)
  double otHours200After10 = 0; // 200% sau 22h
  double otHours210Continuous = 0; // 210% đêm thường liên tục
  double otHoursSunday200 = 0; // 200% Chủ nhật
  double otHoursSunday270 = 0; // 270% Chủ nhật sau 22h
  double otHoursHoliday300 = 0; // 300% Ngày lễ
  double otHoursHoliday390 = 0; // 390% Ngày lễ sau 22h
  double otHoursNightShift130 = 0; // 130% Ca đêm

  // Tổng hợp tiền
  double totalAdjustments = 0;

  MonthlyPayrollSummary({
    required this.month,
    required this.year,
    required this.config,
    required List<DailyRecord> records,
  }) {
    _aggregateRecords(records);
  }

  void _aggregateRecords(List<DailyRecord> records) {
    for (var r in records) {
      if (r.date.month == month && r.date.year == year) {
        switch (r.status) {
          case WorkDayStatus.fullDay:
            actualWorkDays += 1.0;
            break;
          case WorkDayStatus.halfDay:
            actualWorkDays += 0.5;
            break;
          case WorkDayStatus.annualLeave:
            annualLeaveDays += 1.0;
            break;
          case WorkDayStatus.paidHoliday:
            paidHolidayDays += 1.0;
            break;
          case WorkDayStatus.leave70Percent:
            leave70Days += 1.0;
            break;
          case WorkDayStatus.unpaidLeave:
            unpaidLeaveDays += 1.0;
            break;
        }

        totalLateMinutes += r.lateMinutes;
        totalAdjustments += r.adjustmentAmount;

        for (var ot in r.overtimes) {
          switch (ot.type) {
            case OvertimeType.normal150:
              otHours150 += ot.hours;
              break;
            case OvertimeType.after10pm200:
              otHours200After10 += ot.hours;
              break;
            case OvertimeType.nightShiftContinuous210:
              otHours210Continuous += ot.hours;
              break;
            case OvertimeType.sunday200:
              otHoursSunday200 += ot.hours;
              break;
            case OvertimeType.sundayAfter10pm270:
              otHoursSunday270 += ot.hours;
              break;
            case OvertimeType.holiday300:
              otHoursHoliday300 += ot.hours;
              break;
            case OvertimeType.holidayAfter10pm390:
              otHoursHoliday390 += ot.hours;
              break;
            case OvertimeType.nightShiftBonus130:
              otHoursNightShift130 += ot.hours;
              break;
          }
        }
      }
    }
  }

  /// Tổng số ngày công hưởng 100%
  double get totalFullPaidDays =>
      actualWorkDays + annualLeaveDays + paidHolidayDays;

  /// Lương thực tế tính theo ngày công
  double get calculatedFixedSalary {
    if (config.standardWorkingDays <= 0) return 0;
    double dailyRate = config.totalGrossFixed / config.standardWorkingDays;
    return (totalFullPaidDays * dailyRate) +
        (leave70Days * dailyRate * 0.7);
  }

  // Tiền các khoản OT
  double get otAmount150 => otHours150 * config.hourlyRate * 1.5;
  double get otAmount200After10 => otHours200After10 * config.hourlyRate * 2.0;
  double get otAmount210Continuous =>
      otHours210Continuous * config.hourlyRate * 2.1;
  double get otAmountSunday200 => otHoursSunday200 * config.hourlyRate * 2.0;
  double get otAmountSunday270 => otHoursSunday270 * config.hourlyRate * 2.7;
  double get otAmountHoliday300 => otHoursHoliday300 * config.hourlyRate * 3.0;
  double get otAmountHoliday390 => otHoursHoliday390 * config.hourlyRate * 3.9;
  double get otAmountNightShift130 =>
      otHoursNightShift130 * config.hourlyRate * 1.3;

  /// Tổng tiền làm thêm giờ (Tăng ca)
  double get totalOvertimeAmount =>
      otAmount150 +
      otAmount200After10 +
      otAmount210Continuous +
      otAmountSunday200 +
      otAmountSunday270 +
      otAmountHoliday300 +
      otAmountHoliday390 +
      otAmountNightShift130;

  /// Tiền chuyên cần (Nếu đủ công chuẩn và không nghỉ không phép)
  double get earnedAttendanceBonus {
    if (totalFullPaidDays >= config.standardWorkingDays && unpaidLeaveDays == 0) {
      return config.attendanceBonus;
    }
    return 0;
  }

  /// Tổng thu nhập trước giảm trừ (Gross)
  double get grossEarnings =>
      calculatedFixedSalary +
      totalOvertimeAmount +
      earnedAttendanceBonus +
      totalAdjustments;

  /// Các khoản khấu trừ (BHXH, BHYT, BHTN, KPCĐ, Thuế TNCN)
  double get deductionBhxh => config.monthlyBhxh;
  double get deductionBhyt => config.monthlyBhyt;
  double get deductionBhtn => config.monthlyBhtn;
  double get deductionUnion => config.monthlyUnionFee;

  /// Phần tiền tăng ca vượt mức được miễn thuế TNCN (phần 50% trong 150%, 100% trong 200%...)
  double get otNonTaxableAmount {
    double nonTaxable = 0;
    nonTaxable += otHours150 * config.hourlyRate * 0.5; // phần vượt 100%
    nonTaxable += otHours200After10 * config.hourlyRate * 1.0;
    nonTaxable += otHours210Continuous * config.hourlyRate * 1.1;
    nonTaxable += otHoursSunday200 * config.hourlyRate * 1.0;
    nonTaxable += otHoursSunday270 * config.hourlyRate * 1.7;
    nonTaxable += otHoursHoliday300 * config.hourlyRate * 2.0;
    nonTaxable += otHoursHoliday390 * config.hourlyRate * 2.9;
    nonTaxable += otHoursNightShift130 * config.hourlyRate * 0.3;
    return nonTaxable;
  }

  /// Khấu trừ thuế TNCN tạm tính
  double get deductionPit => config.calculatePit(grossEarnings, otNonTaxableAmount);

  double get totalDeductions =>
      deductionBhxh + deductionBhyt + deductionBhtn + deductionUnion + deductionPit;

  /// Số tiền THỰC LĨNH (NET)
  double get netEarnings => grossEarnings - totalDeductions;
}
