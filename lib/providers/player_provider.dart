import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/player_model.dart';
import '../repositories/player_repository.dart';
import '../services/player_service.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerService _service = PlayerService();
  late final PlayerRepository _repository = PlayerRepository(_service);

  List<PlayerModel> _players = [];

  List<PlayerModel> get players => List.unmodifiable(_players);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // GET DATA PEMAIN
  // ==========================================
  Future<void> fetchPlayers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _players = await _repository.getPlayers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // TAMBAH PEMAIN + UPLOAD FOTO
  // ==========================================
  Future<bool> addPlayer(PlayerModel player, {XFile? photo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? photoUrl = player.photoUrl;

      // Upload foto ke Supabase Storage jika dipilih
      if (photo != null) {
        photoUrl = await _service.uploadPlayerPhoto(photo);
      }

      // Buat objek pemain dengan URL foto
      final playerWithPhoto = PlayerModel(
        id: player.id,
        name: player.name,
        jerseyNumber: player.jerseyNumber,
        position: player.position,
        height: player.height,
        countryName: player.countryName,
        countryCode: player.countryCode,
        photoUrl: photoUrl,
      );

      // Simpan data pemain ke database
      final newPlayer = await _repository.createPlayer(playerWithPhoto);

      _players.add(newPlayer);

      // Urutkan pemain berdasarkan nama
      _players.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // SET DATA PEMAIN
  // ==========================================
  void setPlayers(List<PlayerModel> players) {
    _players = players;
    notifyListeners();
  }

  // ==========================================
  // UPDATE DATA PEMAIN
  // ==========================================
  void updatePlayer(PlayerModel updatedPlayer) {
    final index = _players.indexWhere(
      (player) => player.id == updatedPlayer.id,
    );

    if (index != -1) {
      _players[index] = updatedPlayer;
      notifyListeners();
    }
  }

  // ==========================================
  // DELETE DATA PEMAIN
  // ==========================================
  void deletePlayer(String id) {
    _players.removeWhere((player) => player.id == id);
    notifyListeners();
  }

  // ==========================================
  // SET LOADING
  // ==========================================
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
