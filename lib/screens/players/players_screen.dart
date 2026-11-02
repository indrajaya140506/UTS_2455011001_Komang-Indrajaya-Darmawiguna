import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/player_model.dart';
import '../../providers/player_provider.dart';
import '../../widgets/layout/responsive_layout.dart';
import 'add_player_screen.dart';
import 'edit_player_screen.dart';
import 'player_detail_screen.dart';
import '../../widgets/common/section_header.dart';
import '../main_navigation_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const Color navy = Color(0xFF142B4A);

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

  // FILTER PEMAIN

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

  // MAIN BUILD

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // TRANSPARENT HEADER
            _buildHeader(isMobile),

            // SCROLLABLE CONTENT
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final horizontalPadding = width < 600
                      ? 20.0
                      : width < 1024
                      ? 32.0
                      : 40.0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            24,
                            horizontalPadding,
                            24,
                          ),
                          child: Consumer<PlayerProvider>(
                            builder: (context, provider, child) {
                              final players = _filterPlayers(provider.players);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSearchField(),
                                  const SizedBox(height: 16),

                                  _buildPositionFilter(),
                                  const SizedBox(height: 12),

                                  _buildAddButton(),
                                  const SizedBox(height: 24),

                                  _buildPlayerSummary(players.length),
                                  const SizedBox(height: 16),

                                  if (provider.isLoading &&
                                      provider.players.isEmpty)
                                    _buildLoadingState()
                                  else if (provider.errorMessage != null &&
                                      provider.players.isEmpty)
                                    _buildErrorState(provider)
                                  else if (players.isEmpty)
                                    _buildEmptyState()
                                  else if (isMobile)
                                    _buildPlayerList(players)
                                  else
                                    _buildPlayerGrid(
                                      players,
                                      isDesktop ? 3 : 2,
                                    ),

                                  if (provider.isLoading &&
                                      provider.players.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: navy,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TRANSPARENT HEADER
  // ==========================================

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 8,
        right: 20,
        top: isMobile ? 8 : 12,
        bottom: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border.withValues(alpha: 0.65),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
                (route) => false,
              );
            },
            tooltip: 'Kembali ke Dashboard',
            icon: const Icon(Icons.arrow_back_rounded, color: navy, size: 23),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Daftar Pemain',
              style: TextStyle(
                fontSize: isMobile ? 20 : 23,
                fontWeight: FontWeight.w600,
                color: navy,
                letterSpacing: -0.4,
              ),
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded, color: navy, size: 21),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH
  // ==========================================

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

  // ==========================================
  // POSITION FILTER
  // ==========================================

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

  // ==========================================
  // ADD PLAYER BUTTON
  // ==========================================

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

  // ==========================================
  // PLAYER SUMMARY
  // ==========================================

  Widget _buildPlayerSummary(int count) {
    return SectionHeader(
      title: 'Anggota Tim',
      subtitle: 'Kelola tim anda!.',
      trailing: Text(
        '$count pemain',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  // ==========================================
  // LOADING STATE
  // ==========================================

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(color: AppTheme.navy),
      ),
    );
  }

  // ==========================================
  // ERROR STATE
  // ==========================================

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

  // ==========================================
  // EMPTY STATE
  // ==========================================

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

  // ==========================================
  // MOBILE PLAYER LIST
  // ==========================================

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

  // ==========================================
  // TABLET & DESKTOP GRID
  // ==========================================

  Widget _buildPlayerGrid(List<PlayerModel> players, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 160,
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

  // DETAIL PLAYER

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player)),
    );
  }

  // KONFIRMASI HAPUS

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Pemain?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${player.name} dari daftar pemain? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<PlayerProvider>().deletePlayer(
      player.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${player.name} berhasil dihapus.'
              : 'Gagal menghapus pemain: ${context.read<PlayerProvider>().errorMessage ?? "Terjadi kesalahan."}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // EDIT PLAYER

  void _editPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPlayerScreen(player: player)),
    );
  }

  // BUILD CARD

  @override
  Widget build(BuildContext context) {
    final initials = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // FOTO PEMAIN
              Container(
                width: 76,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                    ? Image.network(
                        player.photoUrl!,
                        width: 76,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _buildInitials(initials);
                        },
                      )
                    : _buildInitials(initials),
              ),

              const SizedBox(width: 14),

              // INFORMASI PEMAIN
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
                        fontWeight: FontWeight.w700,
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

                    const SizedBox(height: 3),

                    Text(
                      '${player.height} cm',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${player.jerseyNumber}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ACTION ICONS
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _editPlayer(context),
                    tooltip: 'Edit pemain',
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 19,
                      color: AppTheme.navy,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      fixedSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Hapus pemain',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: Colors.red,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.07),
                      fixedSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INITIALS FOTO

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: AppTheme.navy,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
