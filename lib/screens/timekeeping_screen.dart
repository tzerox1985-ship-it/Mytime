import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_record.dart';
import '../models/payroll_config.dart';
import '../providers/app_state.dart';

class TimekeepingScreen extends StatefulWidget {
  const TimekeepingScreen({super.key});

  @override
  State<TimekeepingScreen> createState() => _TimekeepingScreenState();
}

class _TimekeepingScreenState extends State<TimekeepingScreen> {
  int _selectedDay = 15;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(amount.round())} đ';
  }

  void _openDayEditSheet(BuildContext context, int day, AppState appState) {
    final date = DateTime(appState.selectedYear, appState.selectedMonth, day);
    final existing = appState.getRecordForDate(date);

    WorkDayStatus status = existing?.status ?? WorkDayStatus.fullDay;
    OvertimeType otType =
        existing?.overtimes.isNotEmpty == true ? existing!.overtimes.first.type : OvertimeType.normal150;
    double otHours = existing?.overtimes.isNotEmpty == true ? existing!.overtimes.first.hours : 0.0;

    final otController = TextEditingController(text: otHours > 0 ? otHours.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📅 Chấm Công Ngày $day/${appState.selectedMonth}/${appState.selectedYear}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Loại ngày công:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<WorkDayStatus>(
                      value: status,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: WorkDayStatus.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => status = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Hệ số tăng ca (OT):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<OvertimeType>(
                      value: otType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: OvertimeType.values.map((ot) {
                        return DropdownMenuItem(value: ot, child: Text(ot.label, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => otType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Số giờ tăng ca (giờ):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: otController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Nhập số giờ (Vd: 2.0 hoặc 1.5)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        double parsedHours = double.tryParse(otController.text.trim()) ?? 0;
                        List<OvertimeItem> otList = [];
                        if (parsedHours > 0) {
                          otList.add(OvertimeItem(type: otType, hours: parsedHours));
                        }
                        final record = DailyRecord(
                          id: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                          date: date,
                          status: status,
                          overtimes: otList,
                        );
                        await appState.saveDailyRecord(record);
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: const Text('LƯU & CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final config = appState.config;
    final summary = appState.currentSummary;

    // Tháng 9/2026: 30 ngày, ngày 1 là Thứ 3 (weekday = 2)
    // T2 (weekday 1) -> offset 1 ô trống
    int daysInMonth = 30;
    int firstWeekdayOffset = 1; // 1 ô trống cho Thứ 2

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ Lịch chấm công tháng
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LỊCH CHẤM CÔNG THÁNG ${appState.selectedMonth.toString().padLeft(2, '0')}/${appState.selectedYear}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Chạm vào ngày bất kỳ để nhập công & giờ tăng ca',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Chuẩn: ${config.standardWorkingDays} công',
                                style: const TextStyle(
                                  color: Color(0xFF00796B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Legend Ghi chú màu
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: const [
                            _LegendItem(color: Color(0xFF00C853), label: 'Đi làm (1.0)'),
                            _LegendItem(color: Color(0xFFF59E0B), label: 'Nghỉ phép (0.5/1.0)'),
                            _LegendItem(color: Color(0xFFA855F7), label: 'Lễ 100%'),
                            _LegendItem(color: Color(0xFF0284C7), label: 'Có Tăng ca (OT)'),
                          ],
                        ),

                        const Divider(height: 16),

                        // Header Thứ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text('T2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Text('T3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Text('T4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Text('T5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Text('T6', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Text('T7', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            Text('CN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Grid 30 ngày
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: daysInMonth + firstWeekdayOffset,
                          itemBuilder: (context, index) {
                            if (index < firstWeekdayOffset) {
                              return const SizedBox();
                            }
                            int day = index - firstWeekdayOffset + 1;
                            bool isSunday = (index % 7 == 6);
                            bool isSelected = (_selectedDay == day);

                            final record = appState.getRecordForDate(
                              DateTime(appState.selectedYear, appState.selectedMonth, day),
                            );

                            return InkWell(
                              onTap: () {
                                setState(() => _selectedDay = day);
                                _openDayEditSheet(context, day, appState);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF00796B) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSunday ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (record != null) ...[
                                          if (record.status == WorkDayStatus.fullDay)
                                            const _Dot(Color(0xFF00C853))
                                          else if (record.status == WorkDayStatus.paidHoliday)
                                            const _Dot(Color(0xFFA855F7))
                                          else if (record.status == WorkDayStatus.annualLeave)
                                            const _Dot(Color(0xFFF59E0B)),
                                          if (record.overtimes.isNotEmpty) ...[
                                            const SizedBox(width: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0284C7),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                '${record.overtimes.first.hours.toStringAsFixed(0)}h',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Card Nhật ký chấm công
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NHẬT KÝ CHẤM CÔNG & THU NHẬP TỪNG NGÀY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final selRecord = appState.getRecordForDate(
                              DateTime(appState.selectedYear, appState.selectedMonth, _selectedDay),
                            );
                            if (selRecord == null) {
                              return Text(
                                'Ngày $_selectedDay/${appState.selectedMonth}: Chưa có bản ghi chấm công.',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              );
                            }
                            double earned = selRecord.calculateTotalDailyEarnings(config);
                            return Text(
                              'Ngày $_selectedDay/${appState.selectedMonth}: ${selRecord.status.label} • Tăng ca: ${selRecord.overtimes.isNotEmpty ? '${selRecord.overtimes.first.hours}h (${selRecord.overtimes.first.type.label})' : '0h'} ➔ +${_formatCurrency(earned)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00796B)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
