import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  String _formatNumber(double amount, {bool isNegative = false}) {
    if (amount == 0) return '-';
    final formatter = NumberFormat("#,###", "vi_VN");
    String formatted = formatter.format(amount.round());
    return isNegative ? '($formatted)' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    final summary = appState.currentSummary;
    final config = appState.config;

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text('Bảng Lương Điện Tử'),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Chia sẻ / Xuất file',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang xuất bảng lương Taishodo...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Container tờ phiếu lương giả lập giấy
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          user?.companyName.toUpperCase() ??
                              'CÔNG TY TNHH TAISHODO VIỆT NAM',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Working days: ${config.standardWorkingDays}   Holidays: 6',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'BẢNG LƯƠNG THÁNG ${appState.selectedMonth.toString().padLeft(2, '0')}/${appState.selectedYear}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info Bar xanh lá nhạt như mẫu gốc
                  Container(
                    color: const Color(0xFFAED581),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            user?.fullName ?? 'Trần Thế Thưởng',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            user?.department ?? 'PP 1',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Text(
                          user?.employeeCode ?? '5598',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // Bảng 37 dòng chi tiết
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade400, width: 0.8),
                    columnWidths: const {
                      0: FixedColumnWidth(34),
                      1: FlexColumnWidth(2.2),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.4),
                    },
                    children: [
                      _buildRow(1, 'Lương cơ bản', '', _formatNumber(config.baseSalary)),
                      _buildRow(2, 'PC Lương cơ bản', '', _formatNumber(config.baseSalaryAllowance)),
                      _buildRow(3, 'PC chức vụ', '', _formatNumber(config.positionAllowance)),
                      _buildRow(4, 'PC PCCC', '', _formatNumber(config.firePreventionAllowance)),
                      _buildRow(5, 'PC xe tải', '', _formatNumber(config.truckAllowance)),
                      _buildRow(6, 'Phụ cấp ATVSV', '', _formatNumber(config.safetyAllowance)),
                      _buildRow(7, 'Ngoại ngữ', '', _formatNumber(config.languageAllowance)),
                      _buildRow(8, 'Phụ cấp vận hành máy Xray', '', _formatNumber(config.xrayMachineAllowance)),
                      _buildRow(9, 'Phụ cấp thao tác liên quan hóa chất', '', _formatNumber(config.chemicalAllowance)),
                      _buildRow(10, 'Phụ cấp Lái xe Forklift', '', _formatNumber(config.forkliftAllowance)),
                      _buildRow(11, 'Trợ cấp nhà ở, đi lại', '', _formatNumber(config.housingTransportAllowance)),
                      _buildRow(12, 'Đi muộn', summary.totalLateMinutes > 0 ? '${summary.totalLateMinutes}p' : '-', '-'),
                      _buildRow(13, 'Nghỉ không lương', summary.unpaidLeaveDays > 0 ? '${summary.unpaidLeaveDays}' : '-', '-'),
                      _buildRow(14, 'Số ngày đi làm', '${summary.actualWorkDays}', ''),
                      _buildRow(15, 'Nghỉ phép', '${summary.annualLeaveDays}', ''),
                      _buildRow(16, 'Nghỉ hưởng lương 100%', '${summary.paidHolidayDays}', ''),
                      _buildRow(17, 'Nghỉ hưởng lương 70%', summary.leave70Days > 0 ? '${summary.leave70Days}' : '-', '-'),
                      _buildRow(18, 'Chuyên cần', '', _formatNumber(summary.earnedAttendanceBonus)),
                      _buildRow(19, 'Giờ làm thường 150%', '${summary.otHours150}', _formatNumber(summary.otAmount150)),
                      _buildRow(20, 'Tăng ca sau 10h 200%', summary.otHours200After10 > 0 ? '${summary.otHours200After10}' : '-', _formatNumber(summary.otAmount200After10)),
                      _buildRow(21, 'Tăng ca đêm ngày thường liên tục 210%', summary.otHours210Continuous > 0 ? '${summary.otHours210Continuous}' : '-', _formatNumber(summary.otAmount210Continuous)),
                      _buildRow(22, 'Tăng ca chủ nhật 200%', summary.otHoursSunday200 > 0 ? '${summary.otHoursSunday200}' : '-', _formatNumber(summary.otAmountSunday200)),
                      _buildRow(23, 'Tăng ca chủ nhật sau 10h 270%', summary.otHoursSunday270 > 0 ? '${summary.otHoursSunday270}' : '-', _formatNumber(summary.otAmountSunday270)),
                      _buildRow(24, 'Tăng ca ngày lễ 300%', summary.otHoursHoliday300 > 0 ? '${summary.otHoursHoliday300}' : '-', _formatNumber(summary.otAmountHoliday300)),
                      _buildRow(25, 'Tăng ca sau 10h ngày lễ 390%', summary.otHoursHoliday390 > 0 ? '${summary.otHoursHoliday390}' : '-', _formatNumber(summary.otAmountHoliday390)),
                      _buildRow(26, 'Ca đêm 130%', summary.otHoursNightShift130 > 0 ? '${summary.otHoursNightShift130}' : '-', _formatNumber(summary.otAmountNightShift130)),
                      _buildRow(27, 'Điều chỉnh +/-', '', _formatNumber(summary.totalAdjustments)),
                      _buildRow(28, 'Hỗ trợ con nhỏ', '', _formatNumber(config.childSupportAllowance)),
                      _buildRow(29, 'Hỗ trợ nữ giới', '', _formatNumber(config.femaleSupportAllowance)),
                      _buildRow(30, 'Trợ cấp đa năng', '', _formatNumber(config.multiSkillAllowance)),
                      _buildRow(31, 'Phụ cấp thâm niên', '', _formatNumber(config.seniorityAllowance)),
                      _buildRow(32, 'BHXH (8%)', '', _formatNumber(summary.deductionBhxh, isNegative: true)),
                      _buildRow(33, 'BHYT (1.5%)', '', _formatNumber(summary.deductionBhyt, isNegative: true)),
                      _buildRow(34, 'BHTN (1%)', '', _formatNumber(summary.deductionBhtn, isNegative: true)),
                      _buildRow(35, 'KPCĐ', '', _formatNumber(summary.deductionUnion, isNegative: true)),
                      _buildRow(36, 'Khấu trừ thuế TNCN', '', '-'),
                      _buildRow(37, 'Số tiền thực lĩnh', '', _formatNumber(summary.netEarnings), isHighlight: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(
    int index,
    String title,
    String col2,
    String col3, {
    bool isHighlight = false,
  }) {
    Color? rowBg = isHighlight ? const Color(0xFFFFF9C4) : null;
    FontWeight weight = isHighlight ? FontWeight.w900 : FontWeight.normal;
    Color textColor = isHighlight ? const Color(0xFFB71C1C) : Colors.black87;

    return TableRow(
      decoration: BoxDecoration(color: rowBg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
          child: Text(
            '$index',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: weight, color: textColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Text(
            col2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: weight, color: textColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          child: Text(
            col3,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, fontWeight: weight, color: textColor),
          ),
        ),
      ],
    );
  }
}
