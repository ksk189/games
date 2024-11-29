import 'package:cloud_firestore/cloud_firestore.dart';

class Streak {
  final String id;
  final DateTime date;
  final bool isMarked;

  Streak({required this.id, required this.date, required this.isMarked});

  // Convert Firestore document to Streak instance
  factory Streak.fromDocument(DocumentSnapshot doc) {
    return Streak(
      id: doc.id,
      date: (doc['date'] as Timestamp).toDate(),
      isMarked: doc['isMarked'] ?? false,
    );
  }

  // Convert Streak instance to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'isMarked': isMarked,
    };
  }
}