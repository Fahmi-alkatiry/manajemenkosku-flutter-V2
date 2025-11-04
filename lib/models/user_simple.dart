// lib/models/user_simple.dart
class UserSimple {
  final int id;
  final String nama;

  UserSimple({required this.id, required this.nama});

  factory UserSimple.fromJson(Map<String, dynamic> json) {
    return UserSimple(
      id: json['id'],
      nama: json['nama'],
    );
  }
}