import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player_model.dart';
import '../../providers/attendance_provider.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<PlayerModel> players;
  final Map<String, String> statuses;

  const AttendanceDetailScreen({
    super.key,
    required this.selectedDate,
    required this.players,
    required this.statuses,
  });

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  static const Color navy = Color(0xFF142B4A);
  static const Color secondary = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color orange = Color(0xFFD97706);
  static const Color red = Color(0xFFDC2626);

  late DateTime selectedDate;

  bool loading = true;

  Map<String, String> statuses = {};

  @override
  void initState() {
    super.initState();

    selectedDate = widget.selectedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAttendance();
    });
  }

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.year}';
  }

  int get hadir => statuses.values.where((status) => status == 'Hadir').length;

  int get izin => statuses.values.where((status) => status == 'Izin').length;

  int get alpa => statuses.values.where((status) => status == 'Alpa').length;

  double get percentage {
    if (widget.players.isEmpty) return 0;
    return hadir / widget.players.length * 100;
  }

  Future<void> loadAttendance() async {
    setState(() {
      loading = true;
    });

    await context.read<AttendanceProvider>().loadAttendances(
      playerIds: widget.players.map((player) => player.id).toList(),
      date: selectedDate,
    );

    if (!mounted) return;

    final records = context.read<AttendanceProvider>().attendances;

    setState(() {
      statuses = {for (final record in records) record.playerId: record.status};

      loading = false;
    });
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal absensi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });

    await loadAttendance();
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'Hadir':
        return green;
      case 'Izin':
        return orange;
      case 'Alpa':
        return red;
      default:
        return secondary;
    }
  }

  Color statusBackground(String? status) {
    switch (status) {
      case 'Hadir':
        return const Color(0xFFDCFCE7);
      case 'Izin':
        return const Color(0xFFFEF3C7);
      case 'Alpa':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = statuses.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        foregroundColor: navy,
        title: const Text(
          'Detail Absensi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAttendance,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // FILTER TANGGAL
                  const Text(
                    'Riwayat Kehadiran',
                    style: TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: selectDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: navy,
                            size: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Absensi',
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: secondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!isAvailable) ...[
                    // BELUM ADA DATA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_busy_outlined,
                              color: secondary,
                              size: 27,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Belum Ada Data Absensi',
                            style: TextStyle(
                              color: navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Belum terdapat catatan kehadiran '
                            'pemain pada tanggal ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // RINGKASAN KEHADIRAN
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Persentase Kehadiran',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$hadir dari ${widget.players.length} pemain hadir',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 7,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF86EFAC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Statistik Kehadiran',
                      style: TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _StatCard(title: 'Hadir', count: hadir, color: green),
                        const SizedBox(width: 10),
                        _StatCard(title: 'Izin', count: izin, color: orange),
                        const SizedBox(width: 10),
                        _StatCard(title: 'Alpa', count: alpa, color: red),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Daftar Kehadiran',
                            style: TextStyle(
                              color: navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${statuses.length}/${widget.players.length} Pemain',
                          style: const TextStyle(
                            color: secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...widget.players.map((player) {
                      final status = statuses[player.id];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child:
                                  player.photoUrl != null &&
                                      player.photoUrl!.isNotEmpty
                                  ? Image.network(
                                      player.photoUrl!,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _avatarFallback(),
                                    )
                                  : _avatarFallback(),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: statusBackground(status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status ?? 'Belum diisi',
                                style: TextStyle(
                                  color: statusColor(status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      color: const Color(0xFFEAF0F6),
      child: const Icon(Icons.person_outline_rounded, color: navy, size: 23),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
