import 'package:cloud_firestore/cloud_firestore.dart';

class Spin {
  final int points;
  final bool isExtraSpin;
  final DateTime spinDate;

  Spin({
    required this.points,
    required this.isExtraSpin,
    required this.spinDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'isExtraSpin': isExtraSpin,
      'spinDate': spinDate,
    };
  }

  factory Spin.fromDocument(DocumentSnapshot doc) {
    return Spin(
      points: doc['points'] ?? 0,
      isExtraSpin: doc['isExtraSpin'] ?? false,
      spinDate: (doc['spinDate'] as Timestamp).toDate(),
    );
  }
}