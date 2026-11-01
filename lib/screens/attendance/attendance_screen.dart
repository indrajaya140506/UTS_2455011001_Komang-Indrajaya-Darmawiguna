import 'package:flutter/material.dart';

import '../../widgets/layout/responsive_layout.dart';

class AttendanceScreen extends StatefulWidget {
  final VoidCallback onBackToPlayers;

  const AttendanceScreen({super.key, required this.onBackToPlayers});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const Color navy = Color(0xFF142B4A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color secondary = Color(0xFF64748B);
  static const Color green = Color(0xFF16A34A);
  static const Color orange = Color(0xFFD97706);
  static const Color red = Color(0xFFDC2626);

  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _players = [
    {'name': 'Andi Pratama', 'position': 'Setter', 'number': '7'},
    {'name': 'Budi Santoso', 'position': 'Spiker', 'number': '10'},
    {'name': 'Candra Wijaya', 'position': 'Libero', 'number': '4'},
    {'name': 'Dewa Mahendra', 'position': 'Middle Blocker', 'number': '12'},
    {'name': 'Eka Saputra', 'position': 'Opposite', 'number': '8'},
    {'name': 'Fajar Ramadhan', 'position': 'Spiker', 'number': '3'},
  ];

  // Data absensi dipisahkan berdasarkan tanggal.
  final Map<String, Map<String, String>> _attendanceByDate = {};

  String get _dateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Map<String, String> get _attendanceStatuses =>
      _attendanceByDate.putIfAbsent(_dateKey, () => {});

  int get _presentCount =>
      _attendanceStatuses.values.where((s) => s == 'Hadir').length;

  int get _permissionCount =>
      _attendanceStatuses.values.where((s) => s == 'Izin').length;

  int get _absentCount =>
      _attendanceStatuses.values.where((s) => s == 'Alpa').length;

  int get _unfilledCount => _players.length - _attendanceStatuses.length;

  double get _attendancePercentage =>
      _players.isEmpty ? 0 : (_presentCount / _players.length) * 100;

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDay(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return days[date.weekday - 1];
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: navy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _changeStatus(String name, String status) {
    setState(() {
      _attendanceStatuses[name] = status;
    });
  }

  Color _statusColor(String? status) {
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

  void _showSummary() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF0F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: navy,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Kehadiran',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: navy,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Statistik absensi pemain',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Absensi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_formatDay(_selectedDate)}, ${_formatDate(_selectedDate)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_attendancePercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 7, left: 8),
                                child: Text(
                                  'tingkat kehadiran',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: _presentCount / _players.length,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF86EFAC),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$_presentCount dari ${_players.length} pemain hadir',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Detail Kehadiran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Hadir',
                            count: _presentCount,
                            color: green,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Izin',
                            count: _permissionCount,
                            color: orange,
                            icon: Icons.event_busy_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Alpa',
                            count: _absentCount,
                            color: red,
                            icon: Icons.cancel_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Belum diisi',
                            count: _unfilledCount,
                            color: secondary,
                            icon: Icons.pending_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: secondary,
                            size: 21,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Total pemain terdaftar',
                              style: TextStyle(fontSize: 12, color: secondary),
                            ),
                          ),
                          Text(
                            '${_players.length} pemain',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: navy,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: ResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBackToPlayers,
                  icon: const Icon(Icons.arrow_back_rounded, color: navy),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Absensi Pemain',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Kelola dan pantau kehadiran anggota tim.',
              style: TextStyle(fontSize: 13, color: secondary),
            ),

            const SizedBox(height: 22),

            // Pemilihan tanggal
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0F6),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: navy,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal Absensi',
                            style: TextStyle(fontSize: 12, color: secondary),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_formatDay(_selectedDate)}, ${_formatDate(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_calendar_outlined,
                      color: secondary,
                      size: 21,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Pemain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ),
                Text(
                  '${_attendanceStatuses.length}/${_players.length} diisi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ..._players.map((player) {
              final name = player['name']!;
              final status = _attendanceStatuses[name];

              return Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        name
                            .split(' ')
                            .map((word) => word[0])
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${player['position']} • #${player['number']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status,
                        hint: const Text(
                          'Pilih',
                          style: TextStyle(fontSize: 12),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hadir',
                            child: Text('Hadir'),
                          ),
                          DropdownMenuItem(value: 'Izin', child: Text('Izin')),
                          DropdownMenuItem(value: 'Alpa', child: Text('Alpa')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _changeStatus(name, value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 51,
              child: ElevatedButton.icon(
                onPressed: _showSummary,
                icon: const Icon(Icons.analytics_outlined, size: 19),
                label: const Text('Lihat Ringkasan Kehadiran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
