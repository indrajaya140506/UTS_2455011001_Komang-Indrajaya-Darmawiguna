class AttendanceModel {
  final String id;
  final String playerId;
  final DateTime attendanceDate;
  final String status;
  final String? notes;
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.playerId,
    required this.attendanceDate,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      attendanceDate: DateTime.parse(json['attendance_date']),
      status: json['status'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
