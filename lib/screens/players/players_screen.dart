import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/layout/responsive_layout.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedPosition = 'Semua';

  final List<Map<String, dynamic>> _players = [
    {
      'name': 'Andi Pratama',
      'number': 7,
      'position': 'Setter',
      'height': '175 cm',
      'country': 'Indonesia',
      'initial': 'AP',
    },
    {
      'name': 'Budi Santoso',
      'number': 10,
      'position': 'Spiker',
      'height': '183 cm',
      'country': 'Indonesia',
      'initial': 'BS',
    },
    {
      'name': 'Candra Wijaya',
      'number': 4,
      'position': 'Libero',
      'height': '170 cm',
      'country': 'Indonesia',
      'initial': 'CW',
    },
    {
      'name': 'Dewa Mahendra',
      'number': 12,
      'position': 'Middle Blocker',
      'height': '188 cm',
      'country': 'Indonesia',
      'initial': 'DM',
    },
    {
      'name': 'Eka Saputra',
      'number': 8,
      'position': 'Opposite',
      'height': '181 cm',
      'country': 'Indonesia',
      'initial': 'ES',
    },
    {
      'name': 'Fajar Ramadhan',
      'number': 3,
      'position': 'Spiker',
      'height': '179 cm',
      'country': 'Indonesia',
      'initial': 'FR',
    },
  ];

  final List<String> _positions = [
    'Semua',
    'Setter',
    'Spiker',
    'Libero',
    'Middle Blocker',
    'Opposite',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPlayers {
    final query = _searchController.text.toLowerCase();

    return _players.where((player) {
      final matchesSearch =
          player['name'].toString().toLowerCase().contains(query) ||
          player['number'].toString().contains(query);

      final matchesPosition =
          _selectedPosition == 'Semua' ||
          player['position'] == _selectedPosition;

      return matchesSearch && matchesPosition;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final players = _filteredPlayers;

    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveLayout(
          maxWidth: 1200,
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

              if (players.isEmpty)
                _buildEmptyState()
              else if (isMobile)
                _buildPlayerList(players)
              else
                _buildPlayerGrid(players, isDesktop ? 3 : 2),
            ],
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah pemain akan dibuat berikutnya.'),
            ),
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

  // MOBILE LIST
  Widget _buildPlayerList(List<Map<String, dynamic>> players) {
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
  Widget _buildPlayerGrid(List<Map<String, dynamic>> players, int columns) {
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
            'Coba gunakan kata kunci atau posisi lain.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// PLAYER CARD
class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              player['initial'].toString(),
              style: const TextStyle(
                color: AppTheme.navy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'].toString(),
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
                  player['position'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  player['height'].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${player['number']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}
