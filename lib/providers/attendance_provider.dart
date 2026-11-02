import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceProvider(this._repository);

  List<AttendanceModel> _attendances = [];

  List<AttendanceModel> get attendances => List.unmodifiable(_attendances);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengambil absensi berdasarkan daftar pemain dan tanggal.
  Future<void> loadAttendances({
    required List<String> playerIds,
    required DateTime date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendances = await _repository.getAttendances(
        playerIds: playerIds,
        date: date,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menyimpan seluruh absensi pemain.
  Future<bool> saveAttendances(List<AttendanceModel> data) async {
    if (data.isEmpty) {
      _errorMessage = 'Belum ada data absensi untuk disimpan.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final attendance in data) {
        final savedAttendance = await _repository.saveAttendance(attendance);

        final index = _attendances.indexWhere(
          (item) =>
              item.playerId == savedAttendance.playerId &&
              _sameDate(item.attendanceDate, savedAttendance.attendanceDate),
        );

        if (index >= 0) {
          _attendances[index] = savedAttendance;
        } else {
          _attendances.add(savedAttendance);
        }
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus satu data absensi.
  Future<bool> deleteAttendance(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAttendance(id);
      _attendances.removeWhere((item) => item.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void clearAttendances() {
    _attendances = [];
    _errorMessage = null;
    notifyListeners();
  }
}
