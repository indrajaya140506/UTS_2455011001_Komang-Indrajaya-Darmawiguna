import '../models/player_model.dart';
import '../services/player_service.dart';

class PlayerRepository {
  final PlayerService _playerService;

  PlayerRepository(this._playerService);

  // GET
  Future<List<PlayerModel>> getPlayers() {
    return _playerService.getPlayers();
  }

  // CREATE
  Future<PlayerModel> createPlayer(PlayerModel player) {
    return _playerService.createPlayer(player);
  }

  // UPDATE
  Future<PlayerModel> updatePlayer(PlayerModel player) {
    return _playerService.updatePlayer(player);
  }

  // DELETE
  Future<void> deletePlayer(String id) {
    return _playerService.deletePlayer(id);
  }
}
