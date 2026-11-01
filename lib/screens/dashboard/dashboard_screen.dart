import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/layout/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  final String nickname;
  final String? logoUrl;

  const DashboardScreen({super.key, this.nickname = 'Indrajaya', this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveLayout(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(context),

              const SizedBox(height: 32),

              // LIVE VOLLEYBALL
              _buildSectionTitle('Live Volleyball'),
              const SizedBox(height: 14),
              _buildLiveVolleyballCard(),

              const SizedBox(height: 30),

              // RINGKASAN PEMAIN
              _buildSectionTitle('Ringkasan Pemain'),
              const SizedBox(height: 14),
              _buildPlayerSummary(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: logoUrl != null && logoUrl!.isNotEmpty
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultLogo();
                    },
                  )
                : _buildDefaultLogo(),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border),
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi belum tersedia.')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.navy,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // DEFAULT LOGO
  Widget _buildDefaultLogo() {
    return const Center(
      child: Icon(
        Icons.sports_volleyball_rounded,
        color: AppTheme.navy,
        size: 25,
      ),
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // LIVE VOLLEYBALL

  Widget _buildLiveVolleyballCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sports_volleyball_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Live Match',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE API',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.sports_volleyball_outlined,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(height: 12),
                Text(
                  'Data Pertandingan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Jadwal, tim bertanding, dan skor pertandingan\n'
                  'akan ditampilkan di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Menunggu integrasi REST API',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RINGKASAN PEMAIN
  Widget _buildPlayerSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;
        final crossAxisCount = isWide ? 3 : 2;
        const spacing = 12.0;

        final cardWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              height: 112,
              child: const _SummaryCard(
                title: 'Total Pemain',
                value: '24',
                icon: Icons.groups_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 112,
              child: const _SummaryCard(
                title: 'Hadir Hari Ini',
                value: '20',
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 112,
              child: const _SummaryCard(
                title: 'Izin Hari Ini',
                value: '02',
                icon: Icons.event_busy_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

// SUMMARY CARD
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.navy, size: 22),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
