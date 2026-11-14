import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AdminEmployee {
  final String id;
  final String name;
  final String employeeCode;
  final String department;
  final double workDays;
  final double otHours;
  final double estimatedNet;
  final String status; // 'active', 'pending', 'locked'

  AdminEmployee({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.department,
    required this.workDays,
    required this.otHours,
    required this.estimatedNet,
    this.status = 'active',
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _searchQuery = '';
  String _selectedDept = 'Tất cả';

  // Danh sách nhân viên mẫu trong công ty Taishodo
  final List<AdminEmployee> _employees = [
    AdminEmployee(
      id: 'USR_5598',
      name: 'Trần Thế Thưởng',
      employeeCode: '5598',
      department: 'Sản xuất - PP 1',
      workDays: 24.0,
      otHours: 23.0,
      estimatedNet: 21218000,
      status: 'active',
    ),
    AdminEmployee(
      id: 'USR_5599',
      name: 'Nguyễn Văn An',
      employeeCode: '5599',
      department: 'Sản xuất - PP 1',
      workDays: 23.5,
      otHours: 18.0,
      estimatedNet: 19850000,
      status: 'active',
    ),
    AdminEmployee(
      id: 'USR_5601',
      name: 'Lê Thị Mai',
      employeeCode: '5601',
      department: 'Kho vận - Logistics',
      workDays: 24.0,
      otHours: 12.0,
      estimatedNet: 17400000,
      status: 'active',
    ),
    AdminEmployee(
      id: 'USR_5610',
      name: 'Phạm Quốc Hùng',
      employeeCode: '5610',
      department: 'Kỹ thuật - Bảo trì',
      workDays: 22.0,
      otHours: 30.5,
      estimatedNet: 23500000,
      status: 'active',
    ),
    AdminEmployee(
      id: 'USR_5615',
      name: 'Đặng Thu Trang',
      employeeCode: '5615',
      department: 'Hành chính - Nhân sự',
      workDays: 24.0,
      otHours: 4.0,
      estimatedNet: 16200000,
      status: 'active',
    ),
  ];

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(amount.round())} đ';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Tính toán tổng hợp toàn công ty
    double totalCompanySalary = _employees.fold(0, (sum, e) => sum + e.estimatedNet);
    double totalCompanyOtHours = _employees.fold(0, (sum, e) => sum + e.otHours);

    final filtered = _employees.where((e) {
      final matchQuery = e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.employeeCode.contains(_searchQuery);
      final matchDept = _selectedDept == 'Tất cả' || e.department.contains(_selectedDept);
      return matchQuery && matchDept;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Quản Trị Nhân Sự & Bảng Lương', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF092923),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Đồng bộ Firebase Cloud',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang đồng bộ dữ liệu nhân sự với Firebase Cloud...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ Tổng quan quỹ lương công ty
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF092923), Color(0xFF0F3B32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TỔNG QUỸ LƯƠNG DỰ KIẾN THÁNG',
                        style: TextStyle(color: Color(0xFFB2DFDB), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '${_employees.length} Nhân viên',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatCurrency(totalCompanySalary),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng giờ tăng ca (OT):', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                          Text('${totalCompanyOtHours.toStringAsFixed(1)} giờ',
                              style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Trạng thái nộp chấm công:', style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                          const Text('5/5 đã hoàn thành',
                              style: TextStyle(color: Color(0xFF69F0AE), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tìm kiếm & Bộ lọc phòng ban
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên hoặc mã NV...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDept,
                      items: const [
                        DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả PB', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Sản xuất', child: Text('Sản xuất', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Kho vận', child: Text('Kho vận', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Kỹ thuật', child: Text('Kỹ thuật', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Hành chính', child: Text('Hành chính', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDept = val);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Danh sách nhân viên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách nhân viên (${filtered.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person_add_outlined, size: 15),
                  label: const Text('Thêm NV', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng thêm nhân viên mới vào hệ thống.')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 4),

            ...filtered.map((emp) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE0F2F1),
                        child: Text(
                          emp.name.split(' ').last.substring(0, 1),
                          style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(emp.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Mã: ${emp.employeeCode}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(emp.department, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              'Công: ${emp.workDays} ngày • OT: ${emp.otHours}h',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF00796B), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(emp.estimatedNet),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Đã duyệt', style: TextStyle(fontSize: 9.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
