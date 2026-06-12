import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../services/cloud_service.dart';
import 'home/home_screen.dart';
import 'mood/mood_tracker_screen.dart';
import 'journal/journal_screen.dart';
import 'relaxation/relaxation_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  int _unreadNotifs = 0;

  final _screens = const [
    HomeScreen(),
    MoodTrackerScreen(),
    JournalScreen(),
    RelaxationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifCount();
  }

  Future<void> _loadNotifCount() async {
    final count = await CloudService.getUnreadNotifCount();
    if (mounted) setState(() => _unreadNotifs = count);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                    label: 'Beranda', index: 0, current: _idx,
                    onTap: (i) => setState(() => _idx = i)),
                _NavItem(icon: Icons.mood_outlined, activeIcon: Icons.mood_rounded,
                    label: 'Mood', index: 1, current: _idx,
                    onTap: (i) => setState(() => _idx = i)),
                _NavItem(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note_rounded,
                    label: 'Jurnal', index: 2, current: _idx,
                    onTap: (i) => setState(() => _idx = i)),
                _NavItem(icon: Icons.self_improvement_outlined, activeIcon: Icons.self_improvement,
                    label: 'Relaksasi', index: 3, current: _idx,
                    onTap: (i) => setState(() => _idx = i)),
                _NavItemProfile(
                    index: 4, current: _idx,
                    avatarEmoji: user.avatarEmoji,
                    isPremium: user.isPremium,
                    onTap: (i) => setState(() => _idx = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? activeIcon : icon,
              color: active ? AppTheme.primary : AppTheme.textLt(context), size: 24),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppTheme.primary : AppTheme.textLt(context))),
        ]),
      ),
    );
  }
}

class _NavItemProfile extends StatelessWidget {
  final int index, current;
  final String avatarEmoji;
  final bool isPremium;
  final ValueChanged<int> onTap;
  const _NavItemProfile({required this.index, required this.current,
    required this.avatarEmoji, required this.isPremium, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppTheme.primary.withOpacity(0.15) : AppTheme.card2(context),
                border: active ? Border.all(color: AppTheme.primary, width: 1.5) : null,
              ),
              child: Center(child: Text(avatarEmoji,
                  style: const TextStyle(fontSize: 14))),
            ),
            if (isPremium)
              Positioned(right: 0, top: 0,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B), shape: BoxShape.circle),
                  child: const Center(child: Text('★',
                      style: TextStyle(fontSize: 6, color: Colors.white))),
                )),
          ]),
          const SizedBox(height: 2),
          Text('Profil', style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppTheme.primary : AppTheme.textLt(context))),
        ]),
      ),
    );
  }
}