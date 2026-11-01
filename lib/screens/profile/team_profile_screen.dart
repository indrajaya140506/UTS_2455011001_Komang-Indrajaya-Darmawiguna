import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../providers/club_provider.dart';

class TeamProfileScreen extends StatefulWidget {
  final String clubName;
  final String coachName;
  final Uint8List? logoBytes;
  final VoidCallback onBackToAttendance;

  const TeamProfileScreen({
    super.key,
    this.clubName = 'Nama Klub',
    this.coachName = 'Nama Pelatih',
    this.logoBytes,
    required this.onBackToAttendance,
  });

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClubProvider>().fetchClub();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<ClubProvider>(
      builder: (context, provider, child) {
        final club = provider.club;

        if (provider.isLoading && club == null) {
          return const Scaffold(
            backgroundColor: AppTheme.navy,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (provider.errorMessage != null && club == null) {
          return Scaffold(
            backgroundColor: AppTheme.navy,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchClub(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                    TextButton(
                      onPressed: widget.onBackToAttendance,
                      child: const Text(
                        'Kembali',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final clubName = club?['club_name']?.toString() ?? widget.clubName;

        final coachName = club?['coach_name']?.toString() ?? widget.coachName;

        final logoUrl = club?['logo_url']?.toString();

        final description = club?['description']?.toString() ?? '';

        return Scaffold(
          backgroundColor: AppTheme.navy,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPageHeader(),
                  _buildClubHeader(isMobile, clubName, coachName, logoUrl),
                  _buildInformationPanel(clubName, coachName, description),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // HEADER HALAMAN
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBackToAttendance,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Profile Team',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // HEADER PROFIL KLUB
  Widget _buildClubHeader(
    bool isMobile,
    String clubName,
    String coachName,
    String? logoUrl,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: isMobile ? 40 : 50,
        bottom: 65,
        left: 24,
        right: 24,
      ),
      color: AppTheme.navy,
      child: Column(
        children: [
          Container(
            width: isMobile ? 120 : 140,
            height: isMobile ? 120 : 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: ClipOval(child: _buildLogo(logoUrl)),
          ),
          const SizedBox(height: 20),
          Text(
            clubName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            coachName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Pelatih Klub',
            style: TextStyle(color: Color(0xFFB8C8D9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // LOGO KLUB
  Widget _buildLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultLogo();
        },
      );
    }

    if (widget.logoBytes != null) {
      return Image.memory(
        widget.logoBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return const Icon(
      Icons.sports_volleyball_rounded,
      size: 58,
      color: AppTheme.navy,
    );
  }

  // PANEL INFORMASI
  Widget _buildInformationPanel(
    String clubName,
    String coachName,
    String description,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ResponsiveLayout(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Klub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildInformationItem(
              icon: Icons.groups_outlined,
              title: 'Nama Klub',
              value: clubName,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: AppTheme.border),
            ),
            _buildInformationItem(
              icon: Icons.person_outline_rounded,
              title: 'Nama Pelatih',
              value: coachName,
            ),
            if (description.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: AppTheme.border),
              ),
              _buildInformationItem(
                icon: Icons.description_outlined,
                title: 'Deskripsi Klub',
                value: description,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ITEM INFORMASI
  Widget _buildInformationItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppTheme.navy, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textSecondary,
          size: 22,
        ),
      ],
    );
  }
}
