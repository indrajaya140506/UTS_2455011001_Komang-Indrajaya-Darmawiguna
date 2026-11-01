import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerProvider extends ChangeNotifier {
  final List<PlayerModel> _players = [];

  List<PlayerModel> get players => List.unmodifiable(_players);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengisi data pemain
  void setPlayers(List<PlayerModel> players) {
    _players
      ..clear()
      ..addAll(players);

    _errorMessage = null;
    notifyListeners();
  }

  // Menambahkan pemain
  void addPlayer(PlayerModel player) {
    _players.add(player);
    notifyListeners();
  }

  // Memperbarui data pemain
  void updatePlayer(PlayerModel updatedPlayer) {
    final index = _players.indexWhere(
      (player) => player.id == updatedPlayer.id,
    );

    if (index == -1) return;

    _players[index] = updatedPlayer;
    notifyListeners();
  }

  // Menghapus pemain
  void deletePlayer(String playerId) {
    _players.removeWhere((player) => player.id == playerId);
    notifyListeners();
  }

  // Mengatur loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Mengatur pesan error
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
