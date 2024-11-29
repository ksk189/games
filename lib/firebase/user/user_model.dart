import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String nickname;
  final String age;
  final String email;
  final String phone;

  UserModel({
    required this.userId,
    required this.nickname,
    required this.age,
    required this.email,
    required this.phone,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
      'age': age,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.now(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      nickname: map['nickname'] ?? '',
      age: map['age'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}