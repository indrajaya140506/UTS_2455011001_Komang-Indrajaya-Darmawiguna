import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../models/player_model.dart';
import 'edit_player_screen.dart';

class PlayerDetailScreen extends StatefulWidget {
  final PlayerModel player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isFavorite = false;
  bool _isFavoriteLoading = true;
  bool _isTogglingFavorite = false;

  PlayerModel get player => widget.player;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  String _getFlag(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) {
      return '';
    }

    return countryCode
        .toUpperCase()
        .codeUnits
        .map((code) => String.fromCharCode(code + 127397))
        .join();
  }

  // Memeriksa status favorite dari Supabase
  Future<void> _loadFavorite() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isFavoriteLoading = false);
      }
      return;
    }

    try {
      final response = await _supabase
          .from('player_favorites')
          .select('id')
          .eq('club_id', user.id)
          .eq('player_id', player.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _isFavorite = response != null;
        _isFavoriteLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isFavoriteLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat favorite: $e')));
    }
  }

  // Menambahkan atau menghapus favorite
  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    final user = _supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isTogglingFavorite = true);

    try {
      if (_isFavorite) {
        await _supabase
            .from('player_favorites')
            .delete()
            .eq('club_id', user.id)
            .eq('player_id', player.id);

        if (!mounted) return;

        setState(() => _isFavorite = false);
      } else {
        await _supabase.from('player_favorites').insert({
          'club_id': user.id,
          'player_id': player.id,
        });

        if (!mounted) return;

        setState(() => _isFavorite = true);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? '${player.name} ditambahkan ke favorit.'
                : '${player.name} dihapus dari favorit.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui favorite: $e')));
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF142B4A);

    return Scaffold(
      backgroundColor: navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF142B4A), Color(0xFF1D4168), Color(0xFF0B1729)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header foto pemain
                    Stack(
                      children: [
                        Container(
                          height: 390,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image:
                                player.photoUrl != null &&
                                    player.photoUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(player.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient:
                                player.photoUrl == null ||
                                    player.photoUrl!.isEmpty
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF27496D),
                                      Color(0xFF142B4A),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                          ),
                          child:
                              player.photoUrl == null ||
                                  player.photoUrl!.isEmpty
                              ? Center(
                                  child: Text(
                                    player.name.isNotEmpty
                                        ? player.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 100,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),

                        // Gradient foto
                        Container(
                          height: 390,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black45,
                                Colors.transparent,
                                Color(0xFF142B4A),
                              ],
                              stops: [0, 0.35, 1],
                            ),
                          ),
                        ),

                        // Tombol kembali
                        Positioned(
                          top: 16,
                          left: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        // Tombol favorite di kanan atas
                        Positioned(
                          top: 16,
                          right: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            child: IconButton(
                              onPressed:
                                  _isFavoriteLoading || _isTogglingFavorite
                                  ? null
                                  : _toggleFavorite,
                              icon: _isTogglingFavorite || _isFavoriteLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorite
                                          ? const Color(0xFFFF526F)
                                          : Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),

                        // Nama dan posisi pemain
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 28,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.sports_volleyball,
                                    color: Color(0xFF8ECAE6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    player.position.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF8ECAE6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  if (player.countryName != null &&
                                      player.countryName!.isNotEmpty) ...[
                                    const SizedBox(width: 14),
                                    Text(
                                      _getFlag(player.countryCode),
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        player.countryName!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Informasi pemain
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Pemain',
                              style: TextStyle(
                                color: navy,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            _infoItem(
                              icon: Icons.person_outline,
                              label: 'Nama Pemain',
                              value: player.name,
                            ),

                            _infoItem(
                              icon: Icons.numbers,
                              label: 'Nomor Punggung',
                              value: '#${player.jerseyNumber}',
                            ),

                            _infoItem(
                              icon: Icons.sports_volleyball,
                              label: 'Posisi',
                              value: player.position,
                            ),

                            _infoItem(
                              icon: Icons.height,
                              label: 'Tinggi Badan',
                              value: '${player.height} cm',
                            ),

                            // Negara dengan bendera
                            _infoItem(
                              icon: Icons.flag_outlined,
                              label: 'Negara',
                              value: player.countryName ?? '-',
                              valueWidget: Row(
                                children: [
                                  if (_getFlag(
                                    player.countryCode,
                                  ).isNotEmpty) ...[
                                    Text(
                                      _getFlag(player.countryCode),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      player.countryName ?? '-',
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              isLast: true,
                            ),

                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditPlayerScreen(player: player),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text(
                                  'Edit Pemain',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: navy,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? valueWidget,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF142B4A), size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                valueWidget ??
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF142B4A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
