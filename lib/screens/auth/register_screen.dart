import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clubController = TextEditingController();
  final _coachController = TextEditingController();
  final _passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedLogoBytes;

  bool _obscurePassword = true;
  bool _isPickingLogo = false;

  static const Color _navy = Color(0xFF142B4A);
  static const Color _white = Colors.white;

  @override
  void dispose() {
    _clubController.dispose();
    _coachController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Memilih logo dari galeri.
  Future<void> _pickLogo() async {
    if (_isPickingLogo) return;

    setState(() {
      _isPickingLogo = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedLogoBytes = bytes;
      });
    } catch (e) {
      debugPrint('Gagal memilih logo: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih gambar. Silakan coba lagi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingLogo = false;
        });
      }
    }
  }

  // Proses registrasi menggunakan Supabase.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      clubName: _clubController.text.trim(),
      password: _passwordController.text,
      coachName: _coachController.text.trim(),
      logoBytes: _selectedLogoBytes,
    );

    if (!mounted) return;

    if (success) {
      await authProvider.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran klub berhasil! Silakan masuk.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Pendaftaran gagal.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Bagian header VCLUB.
  Widget _buildHero({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compact ? 32 : 45,
      ),
      decoration: const BoxDecoration(color: _navy),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 92 : 112,
            height: compact ? 92 : 112,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.sports_volleyball_rounded,
              size: compact ? 58 : 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Daftar Akun VCLUB',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 20 : 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // Input field.
  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 13, color: _navy),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, size: 19, color: const Color(0xFF8995A5)),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 19,
                      color: const Color(0xFF8995A5),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xFFEDF0F3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _navy, width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Upload logo.
  Widget _buildLogoPicker() {
    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFEDF0F3)),
          ),
          child: _selectedLogoBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_selectedLogoBytes!, fit: BoxFit.cover),
                )
              : const Icon(
                  Icons.image_outlined,
                  size: 27,
                  color: Color(0xFF8995A5),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Logo Club',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 7),
              OutlinedButton.icon(
                onPressed: _isPickingLogo ? null : _pickLogo,
                icon: _isPickingLogo
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_rounded, size: 16),
                label: Text(
                  _isPickingLogo
                      ? 'Memilih...'
                      : _selectedLogoBytes == null
                      ? 'Pilih Logo'
                      : 'Ganti Logo',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: Color(0xFFDCE2E9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Form pendaftaran.
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Buat Akun',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: _navy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun?',
                    style: TextStyle(fontSize: 12, color: Color(0xFF858D99)),
                  ),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 5),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 27),

          _buildLogoPicker(),

          const SizedBox(height: 24),

          _buildInput(
            label: 'Nama Club',
            hint: 'Masukkan nama Club',
            icon: Icons.groups_outlined,
            controller: _clubController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama klub wajib diisi';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          _buildInput(
            label: 'Nama Pelatih',
            hint: 'Masukkan nama pelatih',
            icon: Icons.person_outline_rounded,
            controller: _coachController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pelatih wajib diisi';
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          _buildInput(
            label: 'Password',
            hint: 'Minimal 6 karakter',
            icon: Icons.lock_outline_rounded,
            controller: _passwordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }

              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }

              return null;
            },
          ),

          const SizedBox(height: 28),

          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton(
                  onPressed: auth.isLoading || _isPickingLogo
                      ? null
                      : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _navy.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFEDF0F3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VCLUB',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Color(0xFFA0A8B3),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFEDF0F3))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            if (isWide) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Expanded(child: _buildHero(compact: false)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(42),
                              child: _buildRegisterForm(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                _buildHero(compact: true),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(26, 27, 26, 20),
                    decoration: const BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: _buildRegisterForm(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
