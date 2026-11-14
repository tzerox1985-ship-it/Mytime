import 'dart:convert';

class UserProfile {
  final String id;
  final String fullName;
  final String employeeCode;
  final String companyName;
  final String email;
  final String department;
  final String photoUrl;

  UserProfile({
    required this.id,
    this.fullName = 'Trần Thế Thưởng',
    this.employeeCode = '5598',
    this.companyName = 'CÔNG TY TNHH TAISHODO VIỆT NAM',
    this.email = 'thethuong.taishodo@example.com',
    this.department = 'Sản xuất - PP1',
    this.photoUrl = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'employeeCode': employeeCode,
        'companyName': companyName,
        'email': email,
        'department': department,
        'photoUrl': photoUrl,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] ?? '',
        fullName: map['fullName'] ?? 'Trần Thế Thưởng',
        employeeCode: map['employeeCode'] ?? '5598',
        companyName: map['companyName'] ?? 'CÔNG TY TNHH TAISHODO VIỆT NAM',
        email: map['email'] ?? '',
        department: map['department'] ?? 'Sản xuất',
        photoUrl: map['photoUrl'] ?? '',
      );

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
