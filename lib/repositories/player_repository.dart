import '../models/player_model.dart';
import '../services/player_service.dart';

class PlayerRepository {
  final PlayerService _playerService;

  PlayerRepository(this._playerService);

  Future<List<PlayerModel>> getPlayers() {
    return _playerService.getPlayers();
  }

  Future<PlayerModel> createPlayer(PlayerModel player) {
    return _playerService.createPlayer(player);
  }
}
