import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
      ),
      body: const Center(
        child: Text('Belum ada notifikasi', textAlign: TextAlign.center),
      ),
    );
  }
}

