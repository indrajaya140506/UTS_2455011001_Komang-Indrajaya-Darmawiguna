import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/player_model.dart';
import '../../models/country_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/country_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedPosition;
  CountryModel? _selectedCountry;

  // FOTO PEMAIN
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final countryProvider = context.read<CountryProvider>();

      if (countryProvider.countries.isEmpty && !countryProvider.isLoading) {
        countryProvider.loadCountries();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // ==========================================
  // PILIH FOTO PEMAIN
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
  // SIMPAN PEMAIN
  // ==========================================
  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    final player = PlayerModel(
      id: '',
      name: _nameController.text.trim(),
      jerseyNumber: int.parse(_numberController.text.trim()),
      position: _selectedPosition!,
      height: double.parse(_heightController.text.trim().replaceAll(',', '.')),
      countryName: _selectedCountry?.name,
      countryCode: _selectedCountry?.code,
    );

    final success = await context.read<PlayerProvider>().addPlayer(
      player,
      photo: _selectedPhoto,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemain berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      final message =
          context.read<PlayerProvider>().errorMessage ??
          'Gagal menambahkan pemain.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.navy),
        title: const Text(
          'Tambah Pemain',
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

                    // FOTO PEMAIN (TAMBAHAN)
                    _buildPhotoPicker(),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Nama Pemain',
                      hintText: 'Masukkan nama pemain',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama pemain wajib diisi.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    CustomTextField(
                      label: 'Nomor Punggung',
                      hintText: 'Contoh: 7',
                      controller: _numberController,
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
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

                    CustomTextField(
                      label: 'Tinggi Badan (cm)',
                      hintText: 'Contoh: 175',
                      controller: _heightController,
                      prefixIcon: Icons.height_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffixText: 'cm',
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
                        return CustomButton(
                          text: provider.isLoading
                              ? 'Menyimpan...'
                              : 'Simpan Pemain',
                          icon: Icons.save_rounded,
                          isLoading: provider.isLoading,
                          onPressed: _savePlayer,
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
  // WIDGET FOTO PEMAIN (TAMBAHAN)
  // ==========================================
  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Foto Pemain (Opsional)'),
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
                child: _photoBytes != null
                    ? Image.memory(
                        _photoBytes!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 65,
                        color: AppTheme.textSecondary,
                      ),
              ),
              const SizedBox(height: 14),
              Text(
                _selectedPhoto != null
                    ? _selectedPhoto!.name
                    : 'Belum ada foto dipilih',
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
                  _selectedPhoto == null ? 'Pilih Foto' : 'Ganti Foto',
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

        return DropdownButtonFormField<CountryModel>(
          initialValue: _selectedCountry,
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
          Icon(Icons.person_add_alt_1_rounded, color: AppTheme.navy, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pemain',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lengkapi informasi anggota baru tim Anda.',
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
