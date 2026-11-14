import 'dart:convert';

/// Cấu hình bảng lương & các hệ số BHXH, BHYT, BHTN, KPCĐ, Thuế TNCN
class PayrollConfig {
  // 1. Nhóm Lương & Phụ cấp đóng BHXH
  double baseSalary; // Lương cơ bản (Vd: 15,509,700)
  double baseSalaryAllowance; // Phụ cấp lương cơ bản (Vd: 1,654,598)
  double positionAllowance; // PC Chức vụ (Vd: 1,500,000)
  double firePreventionAllowance; // PC PCCC
  double truckAllowance; // PC Xe tải
  double safetyAllowance; // Phụ cấp ATVSV
  double languageAllowance; // Ngoại ngữ
  double xrayMachineAllowance; // Vận hành máy Xray
  double chemicalAllowance; // Thao tác liên quan hóa chất
  double forkliftAllowance; // Lái xe Forklift
  double seniorityAllowance; // Phụ cấp thâm niên
  double multiSkillAllowance; // Trợ cấp đa năng

  // 2. Nhóm Phụ cấp không đóng BHXH (Miễn bảo hiểm)
  double housingTransportAllowance; // Trợ cấp nhà ở, đi lại (Vd: 700,000)
  double childSupportAllowance; // Hỗ trợ con nhỏ
  double femaleSupportAllowance; // Hỗ trợ nữ giới

  // 3. Chế độ thưởng & công chuẩn
  double attendanceBonus; // Tiền chuyên cần (Vd: 500,000)
  int standardWorkingDays; // Ngày công chuẩn trong tháng (Vd: 24 ngày)

  // 4. Cấu hình chi tiết BHXH, BHYT, BHTN
  bool enableBhxh; // Bật / Tắt đóng BHXH
  double bhxhRate; // Tỷ lệ người lao động đóng BHXH (Mặc định: 8% = 0.08)
  
  bool enableBhyt; // Bật / Tắt đóng BHYT
  double bhytRate; // Tỷ lệ người lao động đóng BHYT (Mặc định: 1.5% = 0.015)
  
  bool enableBhtn; // Bật / Tắt đóng BHTN
  double bhtnRate; // Tỷ lệ người lao động đóng BHTN (Mặc định: 1% = 0.01)

  bool useCustomInsuranceSalary; // Cho phép nhập mức lương đóng BH riêng biệt
  double customInsuranceSalary; // Mức lương đóng BH cố định nếu người dùng chọn
  double maxInsuranceSalaryCap; // Mức lương trần đóng BHXH/BHYT (20 lần lương cơ sở = 46,800,000 đ)

  // 5. Cấu hình Phí công đoàn (KPCĐ / Đoàn phí)
  bool enableUnionFee; // Bật / Tắt trừ phí công đoàn
  String unionFeeType; // 'fixed' (cố định) hoặc 'percentage' (1% lương đóng BH)
  double unionFee; // Số tiền cố định nếu chọn fixed (Vd: 40,000 đ theo phiếu Taishodo)
  double unionFeeRate; // Tỷ lệ nếu chọn percentage (Mặc định 0.01 = 1%)
  double unionFeeCap; // Trần đoàn phí tối đa (10% mức lương cơ sở = 234,000 đ)

  // 6. Cấu hình Thuế Thu nhập cá nhân (TNCN) & Giảm trừ gia cảnh
  bool enablePit; // Bật / Tắt trừ thuế TNCN
  double personalDeduction; // Giảm trừ bản thân (Mặc định: 11,000,000 đ)
  double dependentDeduction; // Giảm trừ người phụ thuộc (Mặc định: 4,400,000 đ/người)
  int numberOfDependents; // Số người phụ thuộc (Vd: 0, 1, 2...)

  PayrollConfig({
    this.baseSalary = 15509700,
    this.baseSalaryAllowance = 1654598,
    this.positionAllowance = 1500000,
    this.firePreventionAllowance = 0,
    this.truckAllowance = 0,
    this.safetyAllowance = 0,
    this.languageAllowance = 0,
    this.xrayMachineAllowance = 0,
    this.chemicalAllowance = 0,
    this.forkliftAllowance = 0,
    this.seniorityAllowance = 0,
    this.multiSkillAllowance = 0,
    this.housingTransportAllowance = 700000,
    this.childSupportAllowance = 0,
    this.femaleSupportAllowance = 0,
    this.attendanceBonus = 500000,
    this.standardWorkingDays = 24,
    // BHXH, BHYT, BHTN
    this.enableBhxh = true,
    this.bhxhRate = 0.08,
    this.enableBhyt = true,
    this.bhytRate = 0.015,
    this.enableBhtn = true,
    this.bhtnRate = 0.01,
    this.useCustomInsuranceSalary = false,
    this.customInsuranceSalary = 18664298,
    this.maxInsuranceSalaryCap = 46800000,
    // Công đoàn
    this.enableUnionFee = true,
    this.unionFeeType = 'fixed',
    this.unionFee = 40000,
    this.unionFeeRate = 0.01,
    this.unionFeeCap = 234000,
    // Thuế TNCN
    this.enablePit = false,
    this.personalDeduction = 11000000,
    this.dependentDeduction = 4400000,
    this.numberOfDependents = 0,
  });

  /// Tổng mức lương căn cứ đóng BHXH thực tế áp dụng (sau khi xét trần)
  double get insuranceBaseSalary {
    double base = useCustomInsuranceSalary
        ? customInsuranceSalary
        : (baseSalary +
            baseSalaryAllowance +
            positionAllowance +
            firePreventionAllowance +
            truckAllowance +
            safetyAllowance +
            languageAllowance +
            xrayMachineAllowance +
            chemicalAllowance +
            forkliftAllowance +
            seniorityAllowance +
            multiSkillAllowance);

    // Giới hạn theo mức trần nếu có
    if (maxInsuranceSalaryCap > 0 && base > maxInsuranceSalaryCap) {
      return maxInsuranceSalaryCap;
    }
    return base;
  }

  /// Tổng thu nhập cố định chuẩn tháng (Gross danh nghĩa khi đủ công)
  double get totalGrossFixed =>
      (baseSalary +
          baseSalaryAllowance +
          positionAllowance +
          firePreventionAllowance +
          truckAllowance +
          safetyAllowance +
          languageAllowance +
          xrayMachineAllowance +
          chemicalAllowance +
          forkliftAllowance +
          seniorityAllowance +
          multiSkillAllowance) +
      housingTransportAllowance +
      childSupportAllowance +
      femaleSupportAllowance;

  /// Đơn giá 1 giờ làm việc tiêu chuẩn (Dùng để tính tiền Tăng ca - OT)
  double get hourlyRate {
    if (standardWorkingDays <= 0) return 0;
    return (baseSalary + baseSalaryAllowance + positionAllowance) /
        (standardWorkingDays * 8.0);
  }

  /// Tiền trích nộp BHXH hàng tháng
  double get monthlyBhxh =>
      enableBhxh ? (insuranceBaseSalary * bhxhRate) : 0.0;

  /// Tiền trích nộp BHYT hàng tháng
  double get monthlyBhyt =>
      enableBhyt ? (insuranceBaseSalary * bhytRate) : 0.0;

  /// Tiền trích nộp BHTN hàng tháng
  double get monthlyBhtn =>
      enableBhtn ? (insuranceBaseSalary * bhtnRate) : 0.0;

  /// Tiền Phí công đoàn (KPCĐ)
  double get monthlyUnionFee {
    if (!enableUnionFee) return 0.0;
    if (unionFeeType == 'fixed') {
      return unionFee;
    } else {
      double fee = insuranceBaseSalary * unionFeeRate;
      return (unionFeeCap > 0 && fee > unionFeeCap) ? unionFeeCap : fee;
    }
  }

  /// Tính thuế Thu nhập cá nhân (TNCN) theo biểu thuế lũy tiến từng phần
  double calculatePit(double totalIncomeGross, double totalOtNonTaxable) {
    if (!enablePit) return 0.0;

    // Các khoản được miễn/giảm trừ:
    // 1. Đóng bảo hiểm bắt buộc
    double insuranceDeduction = monthlyBhxh + monthlyBhyt + monthlyBhtn;
    // 2. Giảm trừ gia cảnh bản thân + người phụ thuộc
    double familyDeduction = personalDeduction + (numberOfDependents * dependentDeduction);
    // 3. Phần thu nhập miễn thuế (Vd: chênh lệch tăng ca vượt mức 100%)
    double nonTaxableIncome = totalOtNonTaxable;

    // Thu nhập tính thuế = Tổng Gross - Thu nhập miễn thuế - Các khoản BH - Giảm trừ gia cảnh
    double taxableIncome =
        totalIncomeGross - nonTaxableIncome - insuranceDeduction - familyDeduction;

    if (taxableIncome <= 0) return 0.0;

    // Biểu thuế lũy tiến từng phần
    if (taxableIncome <= 5000000) {
      return taxableIncome * 0.05;
    } else if (taxableIncome <= 10000000) {
      return (taxableIncome * 0.10) - 250000;
    } else if (taxableIncome <= 18000000) {
      return (taxableIncome * 0.15) - 750000;
    } else if (taxableIncome <= 32000000) {
      return (taxableIncome * 0.20) - 1650000;
    } else if (taxableIncome <= 52000000) {
      return (taxableIncome * 0.25) - 3250000;
    } else if (taxableIncome <= 80000000) {
      return (taxableIncome * 0.30) - 5850000;
    } else {
      return (taxableIncome * 0.35) - 9850000;
    }
  }

  /// Tổng tất cả các khoản khấu trừ
  double get totalDeductions =>
      monthlyBhxh + monthlyBhyt + monthlyBhtn + monthlyUnionFee;

  Map<String, dynamic> toMap() => {
        'baseSalary': baseSalary,
        'baseSalaryAllowance': baseSalaryAllowance,
        'positionAllowance': positionAllowance,
        'firePreventionAllowance': firePreventionAllowance,
        'truckAllowance': truckAllowance,
        'safetyAllowance': safetyAllowance,
        'languageAllowance': languageAllowance,
        'xrayMachineAllowance': xrayMachineAllowance,
        'chemicalAllowance': chemicalAllowance,
        'forkliftAllowance': forkliftAllowance,
        'seniorityAllowance': seniorityAllowance,
        'multiSkillAllowance': multiSkillAllowance,
        'housingTransportAllowance': housingTransportAllowance,
        'childSupportAllowance': childSupportAllowance,
        'femaleSupportAllowance': femaleSupportAllowance,
        'attendanceBonus': attendanceBonus,
        'standardWorkingDays': standardWorkingDays,
        'enableBhxh': enableBhxh,
        'bhxhRate': bhxhRate,
        'enableBhyt': enableBhyt,
        'bhytRate': bhytRate,
        'enableBhtn': enableBhtn,
        'bhtnRate': bhtnRate,
        'useCustomInsuranceSalary': useCustomInsuranceSalary,
        'customInsuranceSalary': customInsuranceSalary,
        'maxInsuranceSalaryCap': maxInsuranceSalaryCap,
        'enableUnionFee': enableUnionFee,
        'unionFeeType': unionFeeType,
        'unionFee': unionFee,
        'unionFeeRate': unionFeeRate,
        'unionFeeCap': unionFeeCap,
        'enablePit': enablePit,
        'personalDeduction': personalDeduction,
        'dependentDeduction': dependentDeduction,
        'numberOfDependents': numberOfDependents,
      };

  factory PayrollConfig.fromMap(Map<String, dynamic> map) => PayrollConfig(
        baseSalary: (map['baseSalary'] as num?)?.toDouble() ?? 15509700,
        baseSalaryAllowance: (map['baseSalaryAllowance'] as num?)?.toDouble() ?? 1654598,
        positionAllowance: (map['positionAllowance'] as num?)?.toDouble() ?? 1500000,
        firePreventionAllowance: (map['firePreventionAllowance'] as num?)?.toDouble() ?? 0,
        truckAllowance: (map['truckAllowance'] as num?)?.toDouble() ?? 0,
        safetyAllowance: (map['safetyAllowance'] as num?)?.toDouble() ?? 0,
        languageAllowance: (map['languageAllowance'] as num?)?.toDouble() ?? 0,
        xrayMachineAllowance: (map['xrayMachineAllowance'] as num?)?.toDouble() ?? 0,
        chemicalAllowance: (map['chemicalAllowance'] as num?)?.toDouble() ?? 0,
        forkliftAllowance: (map['forkliftAllowance'] as num?)?.toDouble() ?? 0,
        seniorityAllowance: (map['seniorityAllowance'] as num?)?.toDouble() ?? 0,
        multiSkillAllowance: (map['multiSkillAllowance'] as num?)?.toDouble() ?? 0,
        housingTransportAllowance: (map['housingTransportAllowance'] as num?)?.toDouble() ?? 700000,
        childSupportAllowance: (map['childSupportAllowance'] as num?)?.toDouble() ?? 0,
        femaleSupportAllowance: (map['femaleSupportAllowance'] as num?)?.toDouble() ?? 0,
        attendanceBonus: (map['attendanceBonus'] as num?)?.toDouble() ?? 500000,
        standardWorkingDays: (map['standardWorkingDays'] as num?)?.toInt() ?? 24,
        enableBhxh: map['enableBhxh'] as bool? ?? true,
        bhxhRate: (map['bhxhRate'] as num?)?.toDouble() ?? 0.08,
        enableBhyt: map['enableBhyt'] as bool? ?? true,
        bhytRate: (map['bhytRate'] as num?)?.toDouble() ?? 0.015,
        enableBhtn: map['enableBhtn'] as bool? ?? true,
        bhtnRate: (map['bhtnRate'] as num?)?.toDouble() ?? 0.01,
        useCustomInsuranceSalary: map['useCustomInsuranceSalary'] as bool? ?? false,
        customInsuranceSalary: (map['customInsuranceSalary'] as num?)?.toDouble() ?? 18664298,
        maxInsuranceSalaryCap: (map['maxInsuranceSalaryCap'] as num?)?.toDouble() ?? 46800000,
        enableUnionFee: map['enableUnionFee'] as bool? ?? true,
        unionFeeType: map['unionFeeType'] as String? ?? 'fixed',
        unionFee: (map['unionFee'] as num?)?.toDouble() ?? 40000,
        unionFeeRate: (map['unionFeeRate'] as num?)?.toDouble() ?? 0.01,
        unionFeeCap: (map['unionFeeCap'] as num?)?.toDouble() ?? 234000,
        enablePit: map['enablePit'] as bool? ?? false,
        personalDeduction: (map['personalDeduction'] as num?)?.toDouble() ?? 11000000,
        dependentDeduction: (map['dependentDeduction'] as num?)?.toDouble() ?? 4400000,
        numberOfDependents: (map['numberOfDependents'] as num?)?.toInt() ?? 0,
      );

  String toJson() => json.encode(toMap());
  factory PayrollConfig.fromJson(String source) =>
      PayrollConfig.fromMap(json.decode(source));
}
