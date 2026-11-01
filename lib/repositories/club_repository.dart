import '../services/club_service.dart';

class ClubRepository {
  final ClubService _clubService;

  ClubRepository(this._clubService);

  // Mengambil profil klub
  Future<Map<String, dynamic>?> getClub(String userId) async {
    return await _clubService.getClub(userId);
  }

  // Memperbarui profil klub
  Future<void> updateClub({
    required String userId,
    required String clubName,
    required String coachName,
    String? description,
  }) async {
    await _clubService.updateClub(
      userId: userId,
      clubName: clubName,
      coachName: coachName,
      description: description,
    );
  }
}
