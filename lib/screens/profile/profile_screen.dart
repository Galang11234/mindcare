import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/models.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();

    if (mounted) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _user?.avatarEmoji ?? "😊",
                        style: const TextStyle(
                          fontSize: 60,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _user?.name ?? "Pengguna",
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _user?.email ?? "email@example.com",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textMedium,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: "Edit Profil",
                    onTap: () {},
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    title: "Notifikasi",
                    onTap: () {},
                  ),

                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: "Privasi",
                    onTap: () {},
                  ),

                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: "Tentang Aplikasi",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "MindCare",
                        applicationVersion: "1.0",
                        applicationLegalese:
                            "Mental Health App",
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Logout berhasil"),
                          ),
                        );

                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: AppTheme.primary,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}