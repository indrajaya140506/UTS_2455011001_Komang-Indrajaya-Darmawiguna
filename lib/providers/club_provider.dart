import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/club_repository.dart';
import '../services/club_service.dart';

class ClubProvider extends ChangeNotifier {
  final ClubRepository _clubRepository;

  ClubProvider({ClubRepository? clubRepository})
    : _clubRepository = clubRepository ?? ClubRepository(ClubService());

  Map<String, dynamic>? _club;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get club => _club;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengambil ID pengguna yang sedang login
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  // READ: Mengambil data profil klub
  Future<void> fetchClub() async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage = 'Pengguna belum login.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _club = await _clubRepository.getClub(userId);

      if (_club == null) {
        _errorMessage = 'Data klub tidak ditemukan.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE: Memperbarui profil klub
  Future<bool> updateClub({
    required String clubName,
    required String coachName,
    String? description,
  }) async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage = 'Pengguna belum login.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _clubRepository.updateClub(
        userId: userId,
        clubName: clubName,
        coachName: coachName,
        description: description,
      );

      await fetchClub();

      return _errorMessage == null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
