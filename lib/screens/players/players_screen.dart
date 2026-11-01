import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/player_model.dart';
import '../../providers/player_provider.dart';
import '../../widgets/layout/responsive_layout.dart';
import 'add_player_screen.dart';
import 'edit_player_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedPosition = 'Semua';

  final List<String> _positions = [
    'Semua',
    'Setter',
    'Spiker',
    'Libero',
    'Middle Blocker',
    'Opposite',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlayerProvider>().fetchPlayers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlayerModel> _filterPlayers(List<PlayerModel> players) {
    final query = _searchController.text.toLowerCase();

    return players.where((player) {
      final matchesSearch =
          player.name.toLowerCase().contains(query) ||
          player.jerseyNumber.toString().contains(query);

      final matchesPosition =
          _selectedPosition == 'Semua' || player.position == _selectedPosition;

      return matchesSearch && matchesPosition;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveLayout(
          maxWidth: 1200,
          child: Consumer<PlayerProvider>(
            builder: (context, provider, child) {
              final players = _filterPlayers(provider.players);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile),
                    const SizedBox(height: 24),

                    _buildSearchField(),
                    const SizedBox(height: 16),

                    _buildPositionFilter(),
                    const SizedBox(height: 12),

                    _buildAddButton(),
                    const SizedBox(height: 24),

                    _buildPlayerSummary(players.length),
                    const SizedBox(height: 16),

                    if (provider.isLoading && provider.players.isEmpty)
                      _buildLoadingState()
                    else if (provider.errorMessage != null &&
                        provider.players.isEmpty)
                      _buildErrorState(provider)
                    else if (players.isEmpty)
                      _buildEmptyState()
                    else if (isMobile)
                      _buildPlayerList(players)
                    else
                      _buildPlayerGrid(players, isDesktop ? 3 : 2),

                    if (provider.isLoading && provider.players.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pemain',
          style: TextStyle(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola seluruh anggota tim Anda.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // SEARCH
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari nama atau nomor pemain...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }

  // POSITION FILTER
  Widget _buildPositionFilter() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _positions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final position = _positions[index];
          final selected = _selectedPosition == position;

          return ChoiceChip(
            label: Text(position),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedPosition = position;
              });
            },
            selectedColor: AppTheme.navy,
            backgroundColor: AppTheme.surface,
            side: BorderSide(color: selected ? AppTheme.navy : AppTheme.border),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  // ADD PLAYER BUTTON
  Widget _buildAddButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlayerScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 17),
        label: const Text('Tambah Pemain'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.navy,
          side: const BorderSide(color: AppTheme.border),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // PLAYER SUMMARY
  Widget _buildPlayerSummary(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Anggota Tim',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          '$count pemain',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // LOADING STATE
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(color: AppTheme.navy),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState(PlayerProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 42, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Pemain',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.errorMessage ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => provider.fetchPlayers(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 44,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'Pemain tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Belum ada pemain atau data tidak sesuai dengan pencarian.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // MOBILE LIST
  Widget _buildPlayerList(List<PlayerModel> players) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _PlayerCard(player: players[index]);
      },
    );
  }

  // TABLET & DESKTOP GRID
  Widget _buildPlayerGrid(List<PlayerModel> players, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 118,
      ),
      itemBuilder: (context, index) {
        return _PlayerCard(player: players[index]);
      },
    );
  }
}

// ==========================================
// PLAYER CARD
// ==========================================
class _PlayerCard extends StatelessWidget {
  final PlayerModel player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final initials = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                ? Image.network(
                    player.photoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _buildInitials(initials);
                    },
                  )
                : _buildInitials(initials),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  player.position,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${player.height} cm',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${player.jerseyNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 6),

              // TOMBOL EDIT
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPlayerScreen(player: player),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.navy,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: AppTheme.navy,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
