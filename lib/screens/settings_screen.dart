import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/payroll_config.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: BHXH, BHYT, BHTN & Công đoàn
  late bool _enableBhxh;
  late TextEditingController _bhxhRateController;
  late bool _enableBhyt;
  late TextEditingController _bhytRateController;
  late bool _enableBhtn;
  late TextEditingController _bhtnRateController;

  late bool _useCustomInsuranceSalary;
  late TextEditingController _customInsuranceSalaryController;
  late TextEditingController _maxInsuranceCapController;

  late bool _enableUnionFee;
  late String _unionFeeType;
  late TextEditingController _unionFeeFixedController;
  late TextEditingController _unionFeeRateController;
  late TextEditingController _unionFeeCapController;

  late bool _enablePit;
  late TextEditingController _personalDeductionController;
  late TextEditingController _dependentDeductionController;
  late TextEditingController _dependentsCountController;

  // Tab 2: Lương & Phụ cấp
  late TextEditingController _baseSalaryController;
  late TextEditingController _baseSalaryAllowanceController;
  late TextEditingController _positionAllowanceController;
  late TextEditingController _housingTransportController;
  late TextEditingController _attendanceBonusController;
  late TextEditingController _workingDaysController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final config = Provider.of<AppState>(context, listen: false).config;

    // BHXH, BHYT, BHTN
    _enableBhxh = config.enableBhxh;
    _bhxhRateController =
        TextEditingController(text: (config.bhxhRate * 100).toStringAsFixed(1));
    _enableBhyt = config.enableBhyt;
    _bhytRateController =
        TextEditingController(text: (config.bhytRate * 100).toStringAsFixed(1));
    _enableBhtn = config.enableBhtn;
    _bhtnRateController =
        TextEditingController(text: (config.bhtnRate * 100).toStringAsFixed(1));

    _useCustomInsuranceSalary = config.useCustomInsuranceSalary;
    _customInsuranceSalaryController = TextEditingController(
        text: config.customInsuranceSalary.toStringAsFixed(0));
    _maxInsuranceCapController = TextEditingController(
        text: config.maxInsuranceSalaryCap.toStringAsFixed(0));

    // Công đoàn
    _enableUnionFee = config.enableUnionFee;
    _unionFeeType = config.unionFeeType;
    _unionFeeFixedController =
        TextEditingController(text: config.unionFee.toStringAsFixed(0));
    _unionFeeRateController = TextEditingController(
        text: (config.unionFeeRate * 100).toStringAsFixed(1));
    _unionFeeCapController =
        TextEditingController(text: config.unionFeeCap.toStringAsFixed(0));

    // Thuế TNCN
    _enablePit = config.enablePit;
    _personalDeductionController = TextEditingController(
        text: config.personalDeduction.toStringAsFixed(0));
    _dependentDeductionController = TextEditingController(
        text: config.dependentDeduction.toStringAsFixed(0));
    _dependentsCountController =
        TextEditingController(text: config.numberOfDependents.toString());

    // Lương & Phụ cấp
    _baseSalaryController =
        TextEditingController(text: config.baseSalary.toStringAsFixed(0));
    _baseSalaryAllowanceController = TextEditingController(
        text: config.baseSalaryAllowance.toStringAsFixed(0));
    _positionAllowanceController = TextEditingController(
        text: config.positionAllowance.toStringAsFixed(0));
    _housingTransportController = TextEditingController(
        text: config.housingTransportAllowance.toStringAsFixed(0));
    _attendanceBonusController = TextEditingController(
        text: config.attendanceBonus.toStringAsFixed(0));
    _workingDaysController =
        TextEditingController(text: config.standardWorkingDays.toString());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveAllSettings() async {
    final appState = Provider.of<AppState>(context, listen: false);

    PayrollConfig newConfig = PayrollConfig(
      // Lương & Phụ cấp
      baseSalary: double.tryParse(_baseSalaryController.text) ?? 15509700,
      baseSalaryAllowance:
          double.tryParse(_baseSalaryAllowanceController.text) ?? 1654598,
      positionAllowance:
          double.tryParse(_positionAllowanceController.text) ?? 1500000,
      housingTransportAllowance:
          double.tryParse(_housingTransportController.text) ?? 700000,
      attendanceBonus:
          double.tryParse(_attendanceBonusController.text) ?? 500000,
      standardWorkingDays: int.tryParse(_workingDaysController.text) ?? 24,

      // BHXH, BHYT, BHTN
      enableBhxh: _enableBhxh,
      bhxhRate: (double.tryParse(_bhxhRateController.text) ?? 8.0) / 100.0,
      enableBhyt: _enableBhyt,
      bhytRate: (double.tryParse(_bhytRateController.text) ?? 1.5) / 100.0,
      enableBhtn: _enableBhtn,
      bhtnRate: (double.tryParse(_bhtnRateController.text) ?? 1.0) / 100.0,
      useCustomInsuranceSalary: _useCustomInsuranceSalary,
      customInsuranceSalary:
          double.tryParse(_customInsuranceSalaryController.text) ?? 18664298,
      maxInsuranceSalaryCap:
          double.tryParse(_maxInsuranceCapController.text) ?? 46800000,

      // Công đoàn
      enableUnionFee: _enableUnionFee,
      unionFeeType: _unionFeeType,
      unionFee: double.tryParse(_unionFeeFixedController.text) ?? 40000,
      unionFeeRate: (double.tryParse(_unionFeeRateController.text) ?? 1.0) / 100.0,
      unionFeeCap: double.tryParse(_unionFeeCapController.text) ?? 234000,

      // Thuế TNCN
      enablePit: _enablePit,
      personalDeduction:
          double.tryParse(_personalDeductionController.text) ?? 11000000,
      dependentDeduction:
          double.tryParse(_dependentDeductionController.text) ?? 4400000,
      numberOfDependents: int.tryParse(_dependentsCountController.text) ?? 0,
    );

    await appState.updateConfig(newConfig);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật toàn bộ cấu hình BHXH & bảng lương!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(amount.round())} đ';
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = Provider.of<AppState>(context).config;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Cấu Hình BHXH & Bảng Lương'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.shield_outlined), text: 'BHXH, BHYT & KPCĐ'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Lương & Phụ Cấp'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Cấu hình BHXH, BHYT, BHTN, KPCĐ & Thuế TNCN
          _buildInsuranceAndUnionTab(currentConfig),

          // Tab 2: Cấu hình Lương cơ bản & các khoản phụ cấp
          _buildSalaryAndAllowancesTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text(
            'LƯU CẤU HÌNH & ÁP DỤNG NGAY',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveAllSettings,
        ),
      ),
    );
  }

  Widget _buildInsuranceAndUnionTab(PayrollConfig currentConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner tóm tắt số tiền đóng hiện tại
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF1565C0), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lương làm căn cứ đóng BHXH hiện tại:',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      Text(
                        _formatCurrency(currentConfig.insuranceBaseSalary),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      Text(
                        'Tổng trừ BH + KPCĐ: -${_formatCurrency(currentConfig.totalDeductions)}/tháng',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nhóm 1: Tỷ lệ trích nộp các quỹ Bảo hiểm
          _buildCardContainer(
            title: '1. Tỷ lệ Bảo hiểm (Người lao động đóng)',
            children: [
              // BHXH (8%)
              SwitchListTile(
                title: const Text('Bảo hiểm xã hội (BHXH)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Quy định chuẩn: 8.0%'),
                value: _enableBhxh,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) => setState(() => _enableBhxh = val),
              ),
              if (_enableBhxh)
                _buildNumberField(
                  label: 'Tỷ lệ trừ BHXH (%)',
                  controller: _bhxhRateController,
                  suffix: '%',
                ),

              const Divider(),

              // BHYT (1.5%)
              SwitchListTile(
                title: const Text('Bảo hiểm y tế (BHYT)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Quy định chuẩn: 1.5%'),
                value: _enableBhyt,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) => setState(() => _enableBhyt = val),
              ),
              if (_enableBhyt)
                _buildNumberField(
                  label: 'Tỷ lệ trừ BHYT (%)',
                  controller: _bhytRateController,
                  suffix: '%',
                ),

              const Divider(),

              // BHTN (1.0%)
              SwitchListTile(
                title: const Text('Bảo hiểm thất nghiệp (BHTN)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Quy định chuẩn: 1.0%'),
                value: _enableBhtn,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) => setState(() => _enableBhtn = val),
              ),
              if (_enableBhtn)
                _buildNumberField(
                  label: 'Tỷ lệ trừ BHTN (%)',
                  controller: _bhtnRateController,
                  suffix: '%',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Nhóm 2: Mức lương căn cứ đóng BH
          _buildCardContainer(
            title: '2. Căn cứ tính mức lương đóng BHXH',
            children: [
              RadioListTile<bool>(
                title: const Text('Tự động theo Lương CB + Phụ cấp đóng BH',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Khớp 100% với phiếu lương công ty'),
                value: false,
                groupValue: _useCustomInsuranceSalary,
                onChanged: (val) =>
                    setState(() => _useCustomInsuranceSalary = val!),
              ),
              RadioListTile<bool>(
                title: const Text('Tự nhập mức lương đóng BH riêng biệt',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Vd: Đóng theo mức tối thiểu vùng hoặc thỏa thuận'),
                value: true,
                groupValue: _useCustomInsuranceSalary,
                onChanged: (val) =>
                    setState(() => _useCustomInsuranceSalary = val!),
              ),
              if (_useCustomInsuranceSalary)
                _buildNumberField(
                  label: 'Mức lương đóng BH cố định (VNĐ)',
                  controller: _customInsuranceSalaryController,
                  suffix: 'đ',
                ),
              const SizedBox(height: 6),
              _buildNumberField(
                label: 'Mức lương trần đóng BHXH/BHYT (20 lần lương cơ sở)',
                controller: _maxInsuranceCapController,
                suffix: 'đ',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nhóm 3: Phí công đoàn (KPCĐ)
          _buildCardContainer(
            title: '3. Kinh phí Công đoàn (KPCĐ / Đoàn phí)',
            children: [
              SwitchListTile(
                title: const Text('Trừ Kinh phí công đoàn',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Khoản trừ số 35 trên phiếu Taishodo'),
                value: _enableUnionFee,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) => setState(() => _enableUnionFee = val),
              ),
              if (_enableUnionFee) ...[
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cố định',
                            style: TextStyle(fontSize: 13)),
                        value: 'fixed',
                        groupValue: _unionFeeType,
                        onChanged: (val) =>
                            setState(() => _unionFeeType = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Theo % (1%)',
                            style: TextStyle(fontSize: 13)),
                        value: 'percentage',
                        groupValue: _unionFeeType,
                        onChanged: (val) =>
                            setState(() => _unionFeeType = val!),
                      ),
                    ),
                  ],
                ),
                if (_unionFeeType == 'fixed')
                  _buildNumberField(
                    label: 'Số tiền KPCĐ cố định mỗi tháng',
                    controller: _unionFeeFixedController,
                    suffix: 'đ',
                  )
                else ...[
                  _buildNumberField(
                    label: 'Tỷ lệ trích KPCĐ (%)',
                    controller: _unionFeeRateController,
                    suffix: '%',
                  ),
                  _buildNumberField(
                    label: 'Mức trần KPCĐ tối đa',
                    controller: _unionFeeCapController,
                    suffix: 'đ',
                  ),
                ],
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Nhóm 4: Thuế Thu nhập cá nhân (TNCN)
          _buildCardContainer(
            title: '4. Thuế Thu Nhập Cá Nhân (TNCN)',
            children: [
              SwitchListTile(
                title: const Text('Tự động tính thuế TNCN',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Theo biểu thuế lũy tiến từng phần 7 bậc'),
                value: _enablePit,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) => setState(() => _enablePit = val),
              ),
              if (_enablePit) ...[
                _buildNumberField(
                  label: 'Giảm trừ bản thân (tháng)',
                  controller: _personalDeductionController,
                  suffix: 'đ',
                ),
                _buildNumberField(
                  label: 'Giảm trừ người phụ thuộc (tháng/người)',
                  controller: _dependentDeductionController,
                  suffix: 'đ',
                ),
                _buildNumberField(
                  label: 'Số người phụ thuộc đăng ký',
                  controller: _dependentsCountController,
                  suffix: 'người',
                ),
              ],
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSalaryAndAllowancesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCardContainer(
            title: 'Lương & Phụ Cấp Cơ Bản Taishodo',
            children: [
              _buildNumberField(
                  label: 'Lương cơ bản', controller: _baseSalaryController, suffix: 'đ'),
              _buildNumberField(
                  label: 'PC Lương cơ bản', controller: _baseSalaryAllowanceController, suffix: 'đ'),
              _buildNumberField(
                  label: 'PC Chức vụ', controller: _positionAllowanceController, suffix: 'đ'),
              _buildNumberField(
                  label: 'Trợ cấp nhà ở, đi lại (Miễn BH)',
                  controller: _housingTransportController,
                  suffix: 'đ'),
              _buildNumberField(
                  label: 'Tiền chuyên cần (Khi đủ công)',
                  controller: _attendanceBonusController,
                  suffix: 'đ'),
              _buildNumberField(
                  label: 'Số ngày công chuẩn trong tháng (Ngày)',
                  controller: _workingDaysController,
                  suffix: 'ngày'),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCardContainer(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
