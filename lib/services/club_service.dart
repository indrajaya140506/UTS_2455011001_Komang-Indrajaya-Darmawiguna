import 'package:supabase_flutter/supabase_flutter.dart';

class ClubService {
  final SupabaseClient _client = Supabase.instance.client;

  // READ: Mengambil data klub berdasarkan ID pengguna
  Future<Map<String, dynamic>?> getClub(String userId) async {
    final response = await _client
        .from('clubs')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  // UPDATE: Memperbarui profil klub
  Future<void> updateClub({
    required String userId,
    required String clubName,
    required String coachName,
    String? description,
  }) async {
    await _client
        .from('clubs')
        .update({
          'club_name': clubName,
          'coach_name': coachName,
          'description': description,
        })
        .eq('id', userId);
  }
}
