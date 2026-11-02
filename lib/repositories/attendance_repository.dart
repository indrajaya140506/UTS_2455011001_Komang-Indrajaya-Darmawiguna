import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService _attendanceService;

  AttendanceRepository(this._attendanceService);

  Future<List<AttendanceModel>> getAttendances({
    required List<String> playerIds,
    DateTime? date,
  }) {
    return _attendanceService.getAttendances(playerIds: playerIds, date: date);
  }

  Future<AttendanceModel> saveAttendance(AttendanceModel attendance) {
    return _attendanceService.saveAttendance(attendance);
  }

  Future<void> deleteAttendance(String id) {
    return _attendanceService.deleteAttendance(id);
  }
}
