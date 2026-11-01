import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceModel> _attendances = [];

  List<AttendanceModel> get attendances => List.unmodifiable(_attendances);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengisi data absensi
  void setAttendances(List<AttendanceModel> data) {
    _attendances
      ..clear()
      ..addAll(data);

    _errorMessage = null;
    notifyListeners();
  }

  // Menambahkan absensi
  void addAttendance(AttendanceModel attendance) {
    _attendances.add(attendance);
    notifyListeners();
  }

  // Memperbarui absensi
  void updateAttendance(AttendanceModel updatedAttendance) {
    final index = _attendances.indexWhere(
      (item) => item.id == updatedAttendance.id,
    );

    if (index == -1) return;

    _attendances[index] = updatedAttendance;
    notifyListeners();
  }

  // Menghapus absensi
  void deleteAttendance(String attendanceId) {
    _attendances.removeWhere((item) => item.id == attendanceId);

    notifyListeners();
  }

  // Mengatur loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Mengatur error
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
