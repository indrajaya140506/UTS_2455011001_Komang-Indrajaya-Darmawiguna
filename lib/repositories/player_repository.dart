import '../models/player_model.dart';
import '../services/player_service.dart';

class PlayerRepository {
  final PlayerService _playerService;

  PlayerRepository(this._playerService);

  // Get
  Future<List<PlayerModel>> getPlayers() {
    return _playerService.getPlayers();
  }

  // Create
  Future<PlayerModel> createPlayer(PlayerModel player) {
    return _playerService.createPlayer(player);
  }

  // Update
  Future<PlayerModel> updatePlayer(PlayerModel player) {
    return _playerService.updatePlayer(player);
  }

  // Delete
  Future<void> deletePlayer(String id) {
    return _playerService.deletePlayer(id);
  }
}
