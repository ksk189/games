class PointsModel {
  final String levelName;
  final int points;

  PointsModel({required this.levelName, required this.points});

  // Convert PointsModel to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'levelName': levelName,
      'points': points,
    };
  }

  // Create PointsModel from Firebase data
  factory PointsModel.fromMap(Map<String, dynamic> map) {
    return PointsModel(
      levelName: map['levelName'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}