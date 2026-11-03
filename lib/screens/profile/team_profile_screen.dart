import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../providers/club_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/global_loader.dart';
import '../players/favorite_players_screen.dart';

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
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClubProvider>().fetchClub();
    });
  }

  // NAVIGASI KE HALAMAN PEMAIN FAVORIT
  void _openFavoritePlayers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritePlayersScreen()),
    );
  }

  // KONFIRMASI LOGOUT
  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun VCLUB?',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // TAMPILKAN GLOBAL LOADER
    setState(() {
      _isLoggingOut = true;
    });

    // PASTIKAN LOADER SUDAH DIRENDER
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    try {
      // JALANKAN PROSES LOGOUT
      await authProvider.logout();

      if (!mounted) return;

      // JIKA LOGOUT GAGAL
      if (authProvider.errorMessage != null) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      // LOGOUT BERHASIL.
      // AuthGate akan mendeteksi perubahan status autentikasi
      // dan mengarahkan pengguna ke halaman Login.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // GLOBAL LOADER SAAT LOGOUT
    if (_isLoggingOut) {
      return const FullScreenLoader(
        message: 'Sedang keluar dari akun...',
        showBrand: true,
      );
    }

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

                  // HEADER KLUB
                  _buildClubHeader(isMobile, clubName, logoUrl),

                  // INFORMASI KLUB TERMASUK PEMAIN FAVORIT
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
          const Expanded(
            child: Text(
              'Profile Team',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // TOMBOL LOGOUT
          IconButton(
            tooltip: 'Logout',
            onPressed: _isLoggingOut ? null : _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // HEADER PROFIL KLUB
  Widget _buildClubHeader(bool isMobile, String clubName, String? logoUrl) {
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

  // PANEL INFORMASI KLUB
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

            // NAMA KLUB
            _buildInformationItem(
              icon: Icons.groups_outlined,
              title: 'Nama Klub',
              value: clubName,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: AppTheme.border),
            ),

            // NAMA PELATIH
            _buildInformationItem(
              icon: Icons.person_outline_rounded,
              title: 'Nama Pelatih',
              value: coachName,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: AppTheme.border),
            ),

            // PEMAIN FAVORIT
            _buildFavoriteItem(),

            // DESKRIPSI KLUB
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

  // ITEM PEMAIN FAVORIT
  Widget _buildFavoriteItem() {
    return InkWell(
      onTap: _openFavoritePlayers,
      borderRadius: BorderRadius.circular(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9ED),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFE85D75),
              size: 22,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemain Favorit',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),

                SizedBox(height: 5),

                Text(
                  'Daftar pemain favorit',
                  style: TextStyle(
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
