import 'package:flutter/material.dart';

class GlobalLoader extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final bool showBrand;

  const GlobalLoader({
    super.key,
    this.message = 'Sedang memuat data...',
    this.backgroundColor = Colors.white,
    this.showBrand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF142B4A),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String message;
  final bool showBrand;

  const FullScreenLoader({
    super.key,
    this.message = 'Sedang memuat data...',
    this.showBrand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GlobalLoader(message: message, showBrand: showBrand),
    );
  }
}

class InlineLoader extends StatelessWidget {
  final double size;
  final Color color;

  const InlineLoader({
    super.key,
    this.size = 18,
    this.color = const Color(0xFF142B4A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
    );
  }
}
