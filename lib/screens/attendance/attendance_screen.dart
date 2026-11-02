import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attendance_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/common/section_header.dart';
import 'attendance_detail_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final VoidCallback onBackToPlayers;

  const AttendanceScreen({super.key, required this.onBackToPlayers});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const navy = Color(0xFF142B4A);
  static const secondary = Color(0xFF64748B);

  DateTime selectedDate = DateTime.now();
  final Map<String, String> statuses = {};

  bool loadingPlayers = true;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PlayerProvider>().fetchPlayers();

      if (!mounted) return;

      setState(() {
        loadingPlayers = false;
      });

      await loadExistingAttendance();
    });
  }

  String get dateKey =>
      '${selectedDate.day.toString().padLeft(2, '0')}-'
      '${selectedDate.month.toString().padLeft(2, '0')}-'
      '${selectedDate.year}';

  Future<void> loadExistingAttendance() async {
    final players = context.read<PlayerProvider>().players;

    await context.read<AttendanceProvider>().loadAttendances(
      playerIds: players.map((p) => p.id).toList(),
      date: selectedDate,
    );

    if (!mounted) return;

    final records = context.read<AttendanceProvider>().attendances;

    setState(() {
      statuses.clear();

      for (final record in records) {
        statuses[record.playerId] = record.status;
      }

      isSaved =
          players.isNotEmpty &&
          players.every((player) => statuses.containsKey(player.id));
    });
  }

  Future<void> selectDate() async {
    if (context.read<AttendanceProvider>().isLoading) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
      statuses.clear();
      isSaved = false;
    });

    await loadExistingAttendance();
  }

  Future<void> saveAttendance() async {
    final players = context.read<PlayerProvider>().players;

    if (players.isEmpty || isSaved) return;

    if (!players.every((player) => statuses.containsKey(player.id))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi status absensi semua pemain.')),
      );
      return;
    }

    final data = players.map((player) {
      return AttendanceModel(
        id: '',
        playerId: player.id,
        attendanceDate: selectedDate,
        status: statuses[player.id]!,
      );
    }).toList();

    final success = await context.read<AttendanceProvider>().saveAttendances(
      data,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AttendanceProvider>().errorMessage ??
                'Gagal menyimpan absensi.',
          ),
        ),
      );
    }
  }

  void openAttendanceDetail() {
    final players = context.read<PlayerProvider>().players;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailScreen(
          selectedDate: selectedDate,
          players: players,
          statuses: Map<String, String>.from(statuses),
        ),
      ),
    );
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'Hadir':
        return const Color(0xFF16A34A);
      case 'Izin':
        return const Color(0xFFD97706);
      case 'Alpa':
        return const Color(0xFFDC2626);
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
    final players = context.watch<PlayerProvider>().players;
    final attendanceProvider = context.watch<AttendanceProvider>();

    final isComplete =
        players.isNotEmpty &&
        players.every((player) => statuses.containsKey(player.id));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackToPlayers,
                    icon: const Icon(Icons.arrow_back_rounded, color: navy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Absensi Pemain',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // PILIH TANGGAL
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
                        child: Text(
                          dateKey,
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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

              const SizedBox(height: 24),

              // SECTION HEADER
              SectionHeader(
                title: 'Daftar Pemain',
                subtitle: 'Atur kehadiran anggota tim.',
                trailing: players.isNotEmpty
                    ? TextButton.icon(
                        onPressed: openAttendanceDetail,
                        icon: const Icon(Icons.article_outlined, size: 17),
                        label: const Text(
                          'Detail',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: navy,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 16),

              // DAFTAR PEMAIN
              Expanded(
                child: loadingPlayers
                    ? const Center(
                        child: CircularProgressIndicator(color: navy),
                      )
                    : players.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada pemain.',
                          style: TextStyle(color: secondary, fontSize: 13),
                        ),
                      )
                    : Column(
                        children: [
                          // INFORMASI JUMLAH PEMAIN
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Anggota Tim',
                                    style: TextStyle(
                                      color: navy,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${statuses.length}/${players.length} diisi',
                                  style: const TextStyle(
                                    color: secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // LIST PEMAIN
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: players.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 9),
                              itemBuilder: (context, index) {
                                final player = players[index];
                                final status = statuses[player.id];

                                final color = statusColor(status);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // FOTO PEMAIN
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:
                                            player.photoUrl != null &&
                                                player.photoUrl!.isNotEmpty
                                            ? Image.network(
                                                player.photoUrl!,
                                                width: 42,
                                                height: 42,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    defaultAvatar(),
                                              )
                                            : defaultAvatar(),
                                      ),

                                      const SizedBox(width: 11),

                                      // NAMA PEMAIN
                                      Expanded(
                                        child: Text(
                                          player.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: navy,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // STATUS ABSENSI
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBackground(status),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: status,
                                          hint: const Text(
                                            'Pilih',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondary,
                                            ),
                                          ),
                                          icon: Icon(
                                            isSaved
                                                ? Icons.lock_outline
                                                : Icons.keyboard_arrow_down,
                                            color: color,
                                            size: 17,
                                          ),
                                          underline: const SizedBox(),
                                          isDense: true,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          items: [
                                            statusItem(
                                              'Hadir',
                                              const Color(0xFF16A34A),
                                            ),
                                            statusItem(
                                              'Izin',
                                              const Color(0xFFD97706),
                                            ),
                                            statusItem(
                                              'Alpa',
                                              const Color(0xFFDC2626),
                                            ),
                                          ],
                                          onChanged: isSaved
                                              ? null
                                              : (value) {
                                                  if (value == null) {
                                                    return;
                                                  }

                                                  setState(() {
                                                    statuses[player.id] = value;
                                                  });
                                                },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          // TOMBOL SIMPAN
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed:
                                  isSaved ||
                                      !isComplete ||
                                      attendanceProvider.isLoading
                                  ? null
                                  : saveAttendance,
                              icon: attendanceProvider.isLoading
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isSaved
                                          ? Icons.check_circle_outline
                                          : Icons.save_outlined,
                                      size: 19,
                                    ),
                              label: Text(
                                attendanceProvider.isLoading
                                    ? 'Menyimpan...'
                                    : isSaved
                                    ? 'Absensi Tersimpan'
                                    : 'Simpan Absensi',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                disabledBackgroundColor: isSaved
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFE2E8F0),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: isSaved
                                    ? const Color(0xFF15803D)
                                    : secondary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
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

  Widget defaultAvatar() {
    return Container(
      width: 42,
      height: 42,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.person_outline_rounded, color: secondary),
    );
  }

  DropdownMenuItem<String> statusItem(String value, Color color) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
