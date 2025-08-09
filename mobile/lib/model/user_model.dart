class UserModel {
  final String id;
  final String name;
  final String surname;
  final String schoolId;
  final String schoolName;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.schoolId,
    required this.schoolName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      schoolId: json['schoolId'].toString(),
      schoolName: json['schoolName'] ?? '',
    );
  }

  String get fullName => '$name $surname';
}
