import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/player_model.dart';
import '../../models/country_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/country_provider.dart';
import '../../widgets/common/global_loader.dart';

class EditPlayerScreen extends StatefulWidget {
  final PlayerModel player;

  const EditPlayerScreen({super.key, required this.player});

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _heightController;

  String? _selectedPosition;
  CountryModel? _selectedCountry;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _photoBytes;

  final List<String> _positions = [
    'Setter',
    'Spiker',
    'Libero',
    'Middle Blocker',
    'Opposite',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.player.name);

    _numberController = TextEditingController(
      text: widget.player.jerseyNumber.toString(),
    );

    _heightController = TextEditingController(
      text: widget.player.height.toString(),
    );

    _selectedPosition = widget.player.position;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final countryProvider = context.read<CountryProvider>();

      if (countryProvider.countries.isEmpty && !countryProvider.isLoading) {
        countryProvider.loadCountries();
      }

      _selectExistingCountry();
    });
  }

  void _selectExistingCountry() {
    final countries = context.read<CountryProvider>().countries;

    if (widget.player.countryCode == null) return;

    final matchedCountry = countries.where(
      (country) =>
          country.code.toUpperCase() ==
          widget.player.countryCode!.toUpperCase(),
    );

    if (matchedCountry.isNotEmpty && mounted) {
      setState(() {
        _selectedCountry = matchedCountry.first;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // ==========================================
  // PILIH FOTO BARU
  // ==========================================
  Future<void> _pickPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPhoto = photo;
        _photoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // SIMPAN PERUBAHAN
  // ==========================================
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedPlayer = PlayerModel(
      id: widget.player.id,
      name: _nameController.text.trim(),
      jerseyNumber: int.parse(_numberController.text.trim()),
      position: _selectedPosition!,
      height: double.parse(_heightController.text.trim().replaceAll(',', '.')),
      countryName: _selectedCountry?.name,
      countryCode: _selectedCountry?.code,
      photoUrl: widget.player.photoUrl,
    );

    final success = await context.read<PlayerProvider>().editPlayer(
      updatedPlayer,
      photo: _selectedPhoto,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pemain berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      final message =
          context.read<PlayerProvider>().errorMessage ??
          'Gagal memperbarui data pemain.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<PlayerProvider>().isLoading;

    if (isSaving) {
      return const FullScreenLoader(message: 'Memperbarui data pemain...');
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        // Lanjutkan kode AppBar kamu seperti sebelumnya.
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.navy),
        title: const Text(
          'Edit Pemain',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),

                    _buildPhotoPicker(),
                    const SizedBox(height: 24),

                    _buildLabel('Nama Pemain'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama pemain',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama pemain wajib diisi.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Nomor Punggung'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 7',
                        prefixIcon: Icon(Icons.numbers_rounded),
                      ),
                      validator: (value) {
                        final number = int.tryParse(value ?? '');

                        if (number == null) {
                          return 'Masukkan nomor yang valid.';
                        }

                        if (number < 1 || number > 99) {
                          return 'Nomor harus antara 1 sampai 99.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Posisi Pemain'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPosition,
                      decoration: const InputDecoration(
                        hintText: 'Pilih posisi pemain',
                        prefixIcon: Icon(Icons.sports_volleyball_rounded),
                      ),
                      items: _positions.map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Posisi pemain wajib dipilih.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Tinggi Badan (cm)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 175',
                        prefixIcon: Icon(Icons.height_rounded),
                        suffixText: 'cm',
                      ),
                      validator: (value) {
                        final height = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );

                        if (height == null || height <= 0) {
                          return 'Masukkan tinggi badan yang valid.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Negara (Opsional)'),
                    const SizedBox(height: 8),
                    _buildCountryDropdown(),

                    const SizedBox(height: 30),

                    Consumer<PlayerProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading ? null : _saveChanges,
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Simpan Perubahan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.navy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FOTO PEMAIN
  // ==========================================
  Widget _buildPhotoPicker() {
    final hasNewPhoto = _photoBytes != null;
    final hasOldPhoto =
        widget.player.photoUrl != null && widget.player.photoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Foto Pemain'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasNewPhoto
                    ? Image.memory(
                        _photoBytes!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : hasOldPhoto
                    ? Image.network(
                        widget.player.photoUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _photoPlaceholder();
                        },
                      )
                    : _photoPlaceholder(),
              ),
              const SizedBox(height: 14),
              Text(
                hasNewPhoto
                    ? _selectedPhoto!.name
                    : hasOldPhoto
                    ? 'Foto pemain saat ini'
                    : 'Belum ada foto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: Text(
                  hasOldPhoto || hasNewPhoto ? 'Ganti Foto' : 'Pilih Foto',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navy,
                  side: const BorderSide(color: AppTheme.navy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return const Icon(
      Icons.person_rounded,
      size: 65,
      color: AppTheme.textSecondary,
    );
  }

  // ==========================================
  // DROPDOWN NEGARA
  // ==========================================
  Widget _buildCountryDropdown() {
    return Consumer<CountryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.countries.isEmpty) {
          return const InputDecorator(
            decoration: InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Memuat daftar negara...'),
              ],
            ),
          );
        }

        if (provider.errorMessage != null && provider.countries.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.flag_outlined),
              errorText: 'Gagal memuat negara.',
              suffixIcon: IconButton(
                tooltip: 'Coba lagi',
                onPressed: provider.loadCountries,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            child: const Text('Silakan coba lagi.'),
          );
        }

        // Pastikan negara lama terpilih setelah data selesai dimuat.
        final selectedCountry = provider.countries.where(
          (country) =>
              country.code.toUpperCase() ==
              (widget.player.countryCode ?? '').toUpperCase(),
        );

        final currentCountry =
            _selectedCountry != null &&
                provider.countries.any(
                  (country) => country.code == _selectedCountry!.code,
                )
            ? provider.countries.firstWhere(
                (country) => country.code == _selectedCountry!.code,
              )
            : selectedCountry.isNotEmpty
            ? selectedCountry.first
            : null;

        return DropdownButtonFormField<CountryModel>(
          initialValue: currentCountry,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Pilih negara',
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items: provider.countries.map((country) {
            return DropdownMenuItem<CountryModel>(
              value: country,
              child: Row(
                children: [
                  Text(
                    country.flagUrl ?? '🌐',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(country.name, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    country.code,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (country) {
            setState(() {
              _selectedCountry = country;
            });
          },
        );
      },
    );
  }

  // ==========================================
  // INTRO
  // ==========================================
  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppTheme.navy, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Informasi Pemain',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Perbarui informasi anggota tim Anda.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
