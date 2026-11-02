import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/player_model.dart';
import 'player_detail_screen.dart';

class FavoritePlayersScreen extends StatefulWidget {
  const FavoritePlayersScreen({super.key});

  @override
  State<FavoritePlayersScreen> createState() => _FavoritePlayersScreenState();
}

class _FavoritePlayersScreenState extends State<FavoritePlayersScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<PlayerModel> _players = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFavoritePlayers();
  }

  Future<void> _fetchFavoritePlayers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      final response = await _supabase
          .from('player_favorites')
          .select('players(*)')
          .eq('club_id', user.id)
          .order('created_at', ascending: false);

      final List<PlayerModel> result = [];

      for (final item in response) {
        final playerData = item['players'];

        if (playerData != null) {
          result.add(
            PlayerModel.fromJson(Map<String, dynamic>.from(playerData)),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _players = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openPlayerDetail(PlayerModel player) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)),
    );

    if (mounted) {
      _fetchFavoritePlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142B4A)),
        ),
        title: const Text(
          'Pemain Favorite',
          style: TextStyle(
            color: Color(0xFF142B4A),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFavoritePlayers,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF142B4A)),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 130),
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 55,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Gagal Memuat Pemain',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF142B4A),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchFavoritePlayers,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (_players.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 140),
          Icon(
            Icons.favorite_border_rounded,
            size: 70,
            color: Color(0xFFB5BDC9),
          ),
          SizedBox(height: 18),
          Center(
            child: Text(
              'Belum Ada Pemain Favorite',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF142B4A),
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              'Pemain yang kamu tandai sebagai favorit akan ditampilkan di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8993A2),
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Pemain',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF142B4A),
                ),
              ),
            ),
            Text(
              '${_players.length} Pemain',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8993A2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._players.map(_buildPlayerCard),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerModel player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPlayerDetail(player),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                      ? Image.network(
                          player.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _playerPlaceholder(),
                        )
                      : _playerPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF142B4A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      player.position,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B8493),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Nomor punggung ${player.jerseyNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFE05265),
                size: 21,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerPlaceholder() {
    return Container(
      color: const Color(0xFFF0F3F7),
      child: const Icon(
        Icons.person_rounded,
        color: Color(0xFF9AA3AF),
        size: 32,
      ),
    );
  }
}
