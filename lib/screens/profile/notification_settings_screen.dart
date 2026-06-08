import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _moodEnabled = false;
  bool _journalEnabled = false;
  TimeOfDay _moodTime = const TimeOfDay(hour: 8, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await NotificationService.getSettings();
    if (mounted) setState(() {
      _moodEnabled = settings['enabled'] as bool;
      _moodTime = TimeOfDay(hour: settings['hour'] as int, minute: settings['minute'] as int);
      _loading = false;
    });
  }

  Future<void> _toggleMood(bool val) async {
    setState(() => _moodEnabled = val);
    if (val) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyMoodReminder(
        hour: _moodTime.hour, minute: _moodTime.minute);
      _showSnack('✅ Pengingat mood dijadwalkan pukul ${_moodTime.format(context)}');
    } else {
      await NotificationService.cancelAll();
      _showSnack('❌ Pengingat mood dimatikan');
    }
  }

  Future<void> _toggleJournal(bool val) async {
    setState(() => _journalEnabled = val);
    if (val) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleJournalReminder();
      _showSnack('✅ Pengingat jurnal dijadwalkan pukul 21:00');
    } else {
      _showSnack('❌ Pengingat jurnal dimatikan');
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _moodTime);
    if (picked != null) {
      setState(() => _moodTime = picked);
      if (_moodEnabled) {
        await NotificationService.scheduleDailyMoodReminder(
          hour: picked.hour, minute: picked.minute);
        _showSnack('✅ Waktu diperbarui ke ${picked.format(context)}');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Notifikasi Harian', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF2BAD9E)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('🔔', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pengingat Harian',
                                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text('Konsistensi adalah kunci kesehatan mental yang baik!',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Pengaturan', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // Mood reminder
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.moodGood.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(child: Text('😊', style: TextStyle(fontSize: 20))),
                          ),
                          title: Text('Pengingat Mood', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text('Ingatkan untuk mencatat mood harian',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLight)),
                          value: _moodEnabled,
                          onChanged: _toggleMood,
                          activeColor: AppTheme.primary,
                        ),
                        if (_moodEnabled) ...[
                          const Divider(height: 1, indent: 68),
                          ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(68, 0, 16, 0),
                            title: Text('Waktu Pengingat', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMedium)),
                            trailing: GestureDetector(
                              onTap: _pickTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                                ),
                                child: Text(_moodTime.format(context),
                                    style: GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Journal reminder
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      secondary: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('✍️', style: TextStyle(fontSize: 20))),
                      ),
                      title: Text('Pengingat Jurnal', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Setiap hari pukul 21:00',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLight)),
                      value: _journalEnabled,
                      onChanged: _toggleJournal,
                      activeColor: AppTheme.purple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Info', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          '• Notifikasi memerlukan izin dari sistem\n'
                          '• Pastikan izin notifikasi diaktifkan di Pengaturan HP\n'
                          '• Notifikasi berjalan di background meskipun aplikasi ditutup',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMedium, height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}