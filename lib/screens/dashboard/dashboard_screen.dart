import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/global_loader.dart';

class DashboardScreen extends StatefulWidget {
  final String nickname;
  final String? logoUrl;

  const DashboardScreen({super.key, this.nickname = 'Indrajaya', this.logoUrl});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _coachName = 'Nama Pelatih';
  String? _logoUrl;

  int _totalPlayers = 0;
  int _presentToday = 0;
  int _permissionToday = 0;

  bool _isLoadingSummary = true;
  String? _summaryError;

  @override
  void initState() {
    super.initState();

    _loadClubSummary();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<WeatherProvider>().initialize();
    });
  }

  // DATA KLUB, PEMAIN, DAN ABSENSI
  Future<void> _loadClubSummary() async {
    if (mounted) {
      setState(() {
        _isLoadingSummary = true;
        _summaryError = null;
      });
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Pengguna belum login.');
      }

      // Ambil informasi klub
      final club = await _supabase
          .from('clubs')
          .select('coach_name, logo_url')
          .eq('id', user.id)
          .maybeSingle();

      // Ambil seluruh pemain milik klub
      final players = await _supabase
          .from('players')
          .select('id')
          .eq('club_id', user.id);

      final playerIds = players
          .map<String>((player) => player['id'].toString())
          .toList();

      int present = 0;
      int permission = 0;

      if (playerIds.isNotEmpty) {
        final now = DateTime.now();

        final dateKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        // Ambil absensi hari ini untuk pemain klub
        final attendance = await _supabase
            .from('attendances')
            .select('status')
            .inFilter('player_id', playerIds)
            .eq('attendance_date', dateKey);

        for (final item in attendance) {
          final status = item['status'].toString().trim().toLowerCase();

          if (status == 'hadir') {
            present++;
          } else if (status == 'izin') {
            permission++;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _coachName = club?['coach_name']?.toString().isNotEmpty == true
            ? club!['coach_name'].toString()
            : widget.nickname;

        _logoUrl = club?['logo_url']?.toString();

        _totalPlayers = players.length;
        _presentToday = present;
        _permissionToday = permission;

        _isLoadingSummary = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _summaryError = e.toString();
        _isLoadingSummary = false;
      });
    }
  }

  // REFRESH DASHBOARD
  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadClubSummary(),
      context.read<WeatherProvider>().fetchWeather(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan global loading sebelum dashboard siap.
    if (_isLoadingSummary) {
      return const Scaffold(
        body: GlobalLoader(message: 'Menyiapkan Home..', showBrand: true),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveLayout(
          maxWidth: 1200,
          child: RefreshIndicator(
            color: AppTheme.navy,
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 32),

                  const SectionHeader(
                    title: 'Cuaca Kota Indonesia',
                    subtitle: 'Informasi kondisi cuaca terkini.',
                  ),
                  const SizedBox(height: 14),
                  _buildWeatherCard(),

                  const SizedBox(height: 30),

                  const SectionHeader(
                    title: 'Ringkasan Pemain',
                    subtitle: 'Pantau jumlah dan kehadiran anggota tim.',
                  ),
                  const SizedBox(height: 14),
                  _buildPlayerSummary(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    final imageUrl = _logoUrl ?? widget.logoUrl;

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
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultLogo(),
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
                _coachName,
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

  Widget _buildDefaultLogo() {
    return const Center(
      child: Icon(
        Icons.sports_volleyball_rounded,
        color: AppTheme.navy,
        size: 25,
      ),
    );
  }

  // WEATHER INFORMATION
  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.currentWeather;

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
              // HEADER CARD
              Row(
                children: [
                  const Icon(
                    Icons.cloud_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Cuaca Kota di indonesia',
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
                      'cuaca',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // LOADING
              if (provider.isLoading && weather == null)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              // ERROR
              else if (provider.errorMessage != null && weather == null)
                _buildWeatherMessage(
                  'Gagal mengambil data cuaca.',
                  showRetry: true,
                )
              // EMPTY
              else if (weather == null)
                _buildWeatherMessage('Data cuaca belum tersedia.')
              // WEATHER DATA
              else ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        weather.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(weather.weatherCode),
                      color: const Color(0xFFFFD166),
                      size: 42,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 43,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  weather.condition,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 22),

                // WEATHER DETAILS
                Row(
                  children: [
                    Expanded(
                      child: _buildWeatherDetail(
                        Icons.thermostat_rounded,
                        'Terasa',
                        '${weather.apparentTemperature.toStringAsFixed(1)}°C',
                      ),
                    ),
                    Expanded(
                      child: _buildWeatherDetail(
                        Icons.water_drop_outlined,
                        'Kelembapan',
                        '${weather.humidity}%',
                      ),
                    ),
                    Expanded(
                      child: _buildWeatherDetail(
                        Icons.air_rounded,
                        'Angin',
                        '${weather.windSpeed.toStringAsFixed(1)} km/j',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Divider(color: Colors.white.withValues(alpha: 0.15)),

                // DATA TIME
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white54,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Waktu data: ${weather.time.replaceFirst('T', ' ')}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),

                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Pembaruan gagal. Menampilkan data terakhir.',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  // WEATHER ICON BASED ON WMO CODE
  IconData _getWeatherIcon(int code) {
    if (code == 0) {
      return Icons.wb_sunny_rounded;
    }

    if (code <= 3) {
      return Icons.cloud_rounded;
    }

    if (code <= 48) {
      return Icons.foggy;
    }

    if (code <= 67) {
      return Icons.grain_rounded;
    }

    if (code <= 77) {
      return Icons.ac_unit_rounded;
    }

    if (code <= 82) {
      return Icons.water_drop_rounded;
    }

    if (code <= 86) {
      return Icons.ac_unit_rounded;
    }

    if (code <= 99) {
      return Icons.thunderstorm_rounded;
    }

    return Icons.cloud_outlined;
  }

  // WEATHER DETAIL ITEM
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 19),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  // WEATHER MESSAGE
  Widget _buildWeatherMessage(String message, {bool showRetry = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (showRetry) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.read<WeatherProvider>().fetchWeather();
              },
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // RINGKASAN PEMAIN
  Widget _buildPlayerSummary() {
    if (_isLoadingSummary) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: AppTheme.navy)),
      );
    }

    if (_summaryError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            const Text(
              'Gagal mengambil ringkasan pemain.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            TextButton(
              onPressed: _loadClubSummary,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

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
              child: _SummaryCard(
                title: 'Total Pemain',
                value: _totalPlayers.toString(),
                icon: Icons.groups_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 112,
              child: _SummaryCard(
                title: 'Hadir Hari Ini',
                value: _presentToday.toString().padLeft(2, '0'),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 112,
              child: _SummaryCard(
                title: 'Izin Hari Ini',
                value: _permissionToday.toString().padLeft(2, '0'),
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
