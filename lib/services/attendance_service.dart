import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mengambil data absensi berdasarkan pemain dan tanggal.
  Future<List<AttendanceModel>> getAttendances({
    required List<String> playerIds,
    DateTime? date,
  }) async {
    if (playerIds.isEmpty) return [];

    var query = _supabase
        .from('attendances')
        .select()
        .inFilter('player_id', playerIds);

    if (date != null) {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      query = query.eq('attendance_date', dateKey);
    }

    final response = await query.order('attendance_date', ascending: false);

    return response
        .map<AttendanceModel>((json) => AttendanceModel.fromJson(json))
        .toList();
  }

  // Menyimpan atau memperbarui absensi.
  Future<AttendanceModel> saveAttendance(AttendanceModel attendance) async {
    final response = await _supabase
        .from('attendances')
        .upsert({
          'player_id': attendance.playerId,
          'attendance_date': attendance.attendanceDate
              .toIso8601String()
              .split('T')
              .first,
          'status': attendance.status,
          'notes': attendance.notes,
        }, onConflict: 'player_id,attendance_date')
        .select()
        .single();

    return AttendanceModel.fromJson(response);
  }

  // Menghapus absensi.
  Future<void> deleteAttendance(String id) async {
    await _supabase.from('attendances').delete().eq('id', id);
  }
}
