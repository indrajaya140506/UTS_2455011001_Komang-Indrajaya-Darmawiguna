import '../models/player_model.dart';
import '../services/player_service.dart';

class PlayerRepository {
  final PlayerService _playerService;

  PlayerRepository(this._playerService);

  // ==========================================
  // GET DATA PEMAIN
  // ==========================================
  Future<List<PlayerModel>> getPlayers() {
    return _playerService.getPlayers();
  }

  // ==========================================
  // CREATE DATA PEMAIN
  // ==========================================
  Future<PlayerModel> createPlayer(PlayerModel player) {
    return _playerService.createPlayer(player);
  }

  // ==========================================
  // UPDATE DATA PEMAIN
  // ==========================================
  Future<PlayerModel> updatePlayer(PlayerModel player) {
    return _playerService.updatePlayer(player);
  }
}
