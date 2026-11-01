import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/player_model.dart';

class PlayerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // GET DATA PEMAIN
  // ==========================================
  Future<List<PlayerModel>> getPlayers() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final response = await _supabase
        .from('players')
        .select()
        .eq('club_id', user.id)
        .order('name', ascending: true);

    return (response as List)
        .map((item) => PlayerModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ==========================================
  // UPLOAD FOTO PEMAIN
  // ==========================================
  Future<String> uploadPlayerPhoto(XFile photo) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    try {
      final fileBytes = await photo.readAsBytes();

      final fileExtension = photo.name.contains('.')
          ? photo.name.split('.').last.toLowerCase()
          : 'jpg';

      final filePath =
          '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$fileExtension';

      await _supabase.storage
          .from('player-photos')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: photo.mimeType ?? 'image/jpeg',
              upsert: false,
            ),
          );

      final photoUrl = _supabase.storage
          .from('player-photos')
          .getPublicUrl(filePath);

      return photoUrl;
    } catch (e) {
      throw Exception('Gagal mengunggah foto pemain: $e');
    }
  }

  // ==========================================
  // CREATE DATA PEMAIN
  // ==========================================
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final response = await _supabase
        .from('players')
        .insert({
          'club_id': user.id,
          'name': player.name,
          'jersey_number': player.jerseyNumber,
          'position': player.position,
          'height': player.height,
          'country_name': player.countryName,
          'country_code': player.countryCode,
          'photo_url': player.photoUrl,
        })
        .select()
        .single();

    return PlayerModel.fromJson(response);
  }
}
