import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _generateInternalEmail(String clubName) {
    final slug = clubName.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

    if (slug.isEmpty) {
      throw Exception('Nama klub tidak valid.');
    }

    return '$slug@vclub.app';
  }

  Future<User> signUp({
    required String clubName,
    required String password,
    required String coachName,
    Uint8List? logoBytes,
  }) async {
    final email = _generateInternalEmail(clubName);

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      print('USER ID: ${user?.id}');
      print('SESSION: ${response.session != null}');
      print('CURRENT USER: ${_supabase.auth.currentUser?.id}');

      if (user == null) {
        throw Exception('Registrasi akun gagal.');
      }

      String? logoUrl;

      if (logoBytes != null) {
        final filePath = '${user.id}/club_logo.jpg';

        await _supabase.storage
            .from('club-logos')
            .uploadBinary(
              filePath,
              logoBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        logoUrl = _supabase.storage.from('club-logos').getPublicUrl(filePath);
      }

      await _supabase.from('clubs').insert({
        'id': user.id,
        'club_name': clubName.trim(),
        'coach_name': coachName.trim(),
        'logo_url': logoUrl,
      });

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on StorageException catch (e) {
      throw Exception('Gagal mengunggah logo: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User> signIn({
    required String clubName,
    required String password,
  }) async {
    final email = _generateInternalEmail(clubName);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Login gagal.');
      }

      final club = await _supabase
          .from('clubs')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (club == null) {
        await _supabase.auth.signOut();
        throw Exception('Profil klub tidak ditemukan.');
      }

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }
}
