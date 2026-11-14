import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_record.dart';
import '../models/payroll_config.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import 'payslip_screen.dart';
import 'settings_screen.dart';
import 'timekeeping_screen.dart';
import 'admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0; // 0: Tổng quan, 1: Chấm công, 2: Phiếu lương, 3: Hệ số & BH, 4: Lưu & APK

  String _formatCurrency(double amount, {bool isNegative = false}) {
    final formatter = NumberFormat("#,###", "vi_VN");
    String text = formatter.format(amount.round());
    return isNegative ? '($text)' : text;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final summary = appState.currentSummary;
    final config = appState.config;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ==================== KHỐI HEADER XANH ĐEN GỌN GÀNG DÙNG CHUNG ====================
            _buildTopDarkHeader(context, appState, user, summary, config),

            // ==================== PHẦN THÂN THAY ĐỔI THEO TAB ====================
            Expanded(
              child: IndexedStack(
                index: _currentNavIndex,
                children: [
                  // 0: Tổng quan (Cơ cấu thu nhập + Đơn giá OT)
                  _buildOverviewContent(context, appState, user, summary, config),
                  // 1: Chấm công (Lịch 30 ngày chuẩn theo ảnh mới)
                  const TimekeepingScreen(),
                  // 2: Phiếu lương (Bản sao 37 dòng Taishodo)
                  const PayslipScreen(),
                  // 3: Cấu hình hệ số & BH (Giao diện 2x2 grid không bị che)
                  const SettingsScreen(),
                  // 4: Lưu & APK
                  _buildApkExportTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00796B),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded, size: 20),
              activeIcon: _PillNavIcon(icon: Icons.trending_up_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 19),
              activeIcon: _PillNavIcon(icon: Icons.calendar_today_rounded),
              label: 'Chấm công',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 19),
              activeIcon: _PillNavIcon(icon: Icons.receipt_long_rounded),
              label: 'Phiếu lương',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 19),
              activeIcon: _PillNavIcon(icon: Icons.settings_rounded),
              label: 'Hệ số & BH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_android_rounded, size: 19),
              activeIcon: _PillNavIcon(icon: Icons.phone_android_rounded),
              label: 'Lưu & APK',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDarkHeader(
    BuildContext context,
    AppState appState,
    dynamic user,
    dynamic summary,
    PayrollConfig config,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF092923),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng 1: Logo CTT + Tên công ty + ID + Nút Cloud
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'CTT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.companyName ?? 'CÔNG TY TNHH TAISHODO VIỆ...',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00796B),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            user?.department ?? 'PP 1',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                        children: [
                          TextSpan(text: user?.fullName ?? 'Trần Thế Thưởng'),
                          const TextSpan(text: ' • ID: '),
                          TextSpan(
                            text: user?.employeeCode ?? '5598',
                            style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('👑 Admin', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.cloud_done_rounded, size: 13, color: Color(0xFF81C784)),
                        SizedBox(width: 3),
                        Text('Cloud', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hàng 2: Selector Tháng + Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      int m = appState.selectedMonth - 1;
                      int y = appState.selectedYear;
                      if (m < 1) {
                        m = 12;
                        y--;
                      }
                      appState.changeMonth(m, y);
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'THÁNG ${appState.selectedMonth.toString().padLeft(2, '0')}/${appState.selectedYear}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      int m = appState.selectedMonth + 1;
                      int y = appState.selectedYear;
                      if (m > 12) {
                        m = 1;
                        y++;
                      }
                      appState.changeMonth(m, y);
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _currentNavIndex = 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Phiếu lương', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: const Text('Lũy kế ngày', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Card Thực lĩnh
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3B32),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD54F), size: 13),
                        SizedBox(width: 4),
                        Text('Thực lĩnh dự kiến cuối tháng:', style: TextStyle(color: Color(0xFFB2DFDB), fontSize: 10.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Đã lưu đám mây', style: TextStyle(color: Color(0xFF81C784), fontSize: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatCurrency(summary.netEarnings),
                          style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 3),
                        const Text('VNĐ', style: TextStyle(color: Color(0xFF80CBC4), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Chấm công', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: const Color(0xFF1B2E28),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => setState(() => _currentNavIndex = 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniMetricPill('Ngày đi làm', '${summary.actualWorkDays}', '/${config.standardWorkingDays}'),
                    const SizedBox(width: 4),
                    _buildMiniMetricPill('Phép + Lễ', '${summary.annualLeaveDays + summary.paidHolidayDays}', ' ngày', val1Color: const Color(0xFFFFD54F)),
                    const SizedBox(width: 4),
                    _buildMiniMetricPill('Giờ Tăng ca', '${summary.otHours150}', ' giờ'),
                    const SizedBox(width: 4),
                    _buildMiniMetricPill('Tiền Tăng ca', '+${_formatCurrency(summary.totalOvertimeAmount)}', '', val1Color: const Color(0xFF69F0AE)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewContent(
    BuildContext context,
    AppState appState,
    dynamic user,
    dynamic summary,
    PayrollConfig config,
  ) {
    double hourlyRate = config.hourlyRate;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Thẻ thông tin công ty nhỏ gọn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business_rounded, color: Color(0xFF2E7D32), size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.companyName ?? 'CÔNG TY TNHH TAISHODO VIỆT NAM',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        'NV: ${user?.fullName ?? 'Trần Thế Thưởng'} • Mã: ${user?.employeeCode ?? '5598'} • BP: ${user?.department ?? 'PP 1'}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 12),
                  label: const Text('Sửa hồ sơ', style: TextStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => setState(() => _currentNavIndex = 3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. KHỐI CƠ CẤU THU NHẬP REALTIME
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.trending_up_rounded, color: Color(0xFF00897B), size: 16),
                        SizedBox(width: 5),
                        Text(
                          'CƠ CẤU THU NHẬP REALTIME',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Đơn giá OT: ${_formatCurrency(hourlyRate)}/h',
                        style: const TextStyle(color: Color(0xFF00796B), fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                _buildIncomeRow(
                  title: '1. Tổng Lương & Phụ cấp (Mục 1-11)',
                  subtitle: 'Công hưởng lương: ${summary.totalFullPaidDays}/${config.standardWorkingDays} ngày',
                  amount: '+${_formatCurrency(config.totalGrossFixed)}',
                  amountColor: const Color(0xFF0F172A),
                  bgColor: const Color(0xFFF8FAFC),
                ),
                const SizedBox(height: 4),

                _buildIncomeRow(
                  title: '2. Thưởng chuyên cần (Mục 18)',
                  subtitle: summary.earnedAttendanceBonus > 0 ? 'Đủ điều kiện hưởng 100%' : 'Chưa đủ điều kiện',
                  amount: '+${_formatCurrency(summary.earnedAttendanceBonus)}',
                  amountColor: const Color(0xFF00897B),
                  bgColor: const Color(0xFFF8FAFC),
                ),
                const SizedBox(height: 4),

                _buildIncomeRow(
                  title: '3. Tiền Tăng ca & Ca đêm (Mục 19-26)',
                  subtitle: 'Tổng ${summary.otHours150} giờ OT (${summary.otHours150}h x 150%...)',
                  amount: '+${_formatCurrency(summary.totalOvertimeAmount)}',
                  amountColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFF0F9FF),
                ),
                const SizedBox(height: 4),

                _buildIncomeRow(
                  title: '4. Khấu trừ BHXH, BHYT, BHTN, KPCĐ',
                  subtitle: 'BHXH (${(config.bhxhRate * 100).toStringAsFixed(0)}%) • BHYT (${(config.bhytRate * 100).toStringAsFixed(1)}%) • BHTN (${(config.bhtnRate * 100).toStringAsFixed(0)}%) • KPCĐ',
                  amount: _formatCurrency(summary.totalDeductions, isNegative: true),
                  amountColor: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                  isRed: true,
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng thu nhập (Gross):', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                          Text('${_formatCurrency(summary.grossEarnings)} đ',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Số tiền thực lĩnh (Mục 37):', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                          Text('${_formatCurrency(summary.netEarnings)} đ',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. KHỐI BẢNG ĐƠN GIÁ TĂNG CA (2x2)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calculate_outlined, color: Color(0xFF4F46E5), size: 16),
                    SizedBox(width: 5),
                    Text(
                      'BẢNG ĐƠN GIÁ 1 GIỜ TĂNG CA CỦA BẠN',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _buildOtRate('OT Thường\n(150%)', '${_formatCurrency(hourlyRate * 1.5)}/h')),
                    const SizedBox(width: 6),
                    Expanded(child: _buildOtRate('Sau 10h / CN\n(200%)', '${_formatCurrency(hourlyRate * 2.0)}/h')),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(child: _buildOtRate('Đêm liên tục\n(210%)', '${_formatCurrency(hourlyRate * 2.1)}/h')),
                    const SizedBox(width: 6),
                    Expanded(child: _buildOtRate('Ngày Lễ (300%)', '${_formatCurrency(hourlyRate * 3.0)}/h')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricPill(String title, String val1, String val2, {Color val1Color = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 8.5)),
            const SizedBox(height: 1),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(text: val1, style: TextStyle(color: val1Color, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  TextSpan(text: val2, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeRow({
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required Color bgColor,
    bool isRed = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isRed ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isRed ? const Color(0xFF991B1B) : const Color(0xFF1E293B))),
                const SizedBox(height: 1),
                Text(subtitle, style: TextStyle(fontSize: 9.5, color: isRed ? const Color(0xFFDC2626) : const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildOtRate(String label, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF475569), height: 1.2)),
          Text(rate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildApkExportTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lưu & Đóng Gói APK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('File APK tự động build thông qua GitHub Actions (.github/workflows/build-apk.yml)', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Xuất file Bảng lương'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _PillNavIcon extends StatelessWidget {
  final IconData icon;
  const _PillNavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF00796B), size: 18),
    );
  }
}
