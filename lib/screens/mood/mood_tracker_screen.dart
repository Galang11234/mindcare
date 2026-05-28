import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/storage_service.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<MoodEntry> _entries = [];
  bool _loading = true;

  final _moods = [
    {'level': 5, 'label': 'Luar Biasa', 'emoji': '😄', 'color': AppTheme.moodGreat},
    {'level': 4, 'label': 'Baik', 'emoji': '😊', 'color': AppTheme.moodGood},
    {'level': 3, 'label': 'Biasa', 'emoji': '😐', 'color': AppTheme.moodOkay},
    {'level': 2, 'label': 'Buruk', 'emoji': '😟', 'color': AppTheme.moodBad},
    {'level': 1, 'label': 'Sangat Buruk', 'emoji': '😢', 'color': AppTheme.moodTerrible},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await StorageService.getMoodEntries();
    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  void _showAddMoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMoodSheet(
        moods: _moods,
        onSave: (entry) async {
          await StorageService.saveMoodEntry(entry);
          _loadEntries();
        },
      ),
    );
  }

  Color _getMoodColor(int level) {
    return (_moods.firstWhere((m) => m['level'] == level)['color'] as Color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Mood Tracker', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 30),
            onPressed: _showAddMoodSheet,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Belum ada data mood',
            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat bagaimana perasaanmu\nhari ini!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddMoodSheet,
            icon: const Icon(Icons.add),
            label: const Text('Catat Mood'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (ctx, i) {
        final entry = _entries[i];
        final color = _getMoodColor(entry.moodLevel);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(entry.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.moodLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entry.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ),
                    if (entry.emotions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.emotions
                              .map((e) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      e,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                DateFormat('d MMM\nHH:mm', 'id').format(entry.date),
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Add Mood Bottom Sheet ────────────────────────────────────────────────────
class _AddMoodSheet extends StatefulWidget {
  final List<Map<String, dynamic>> moods;
  final Function(MoodEntry) onSave;

  const _AddMoodSheet({required this.moods, required this.onSave});

  @override
  State<_AddMoodSheet> createState() => _AddMoodSheetState();
}

class _AddMoodSheetState extends State<_AddMoodSheet> {
  int? _selectedLevel;
  final _noteCtrl = TextEditingController();
  final List<String> _selectedEmotions = [];

  final _emotionOptions = [
    'Bahagia', 'Bersyukur', 'Bersemangat', 'Tenang', 'Percaya Diri',
    'Lelah', 'Cemas', 'Sedih', 'Marah', 'Frustasi', 'Kesepian', 'Bingung',
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedLevel == null) return;
    final mood = widget.moods.firstWhere((m) => m['level'] == _selectedLevel);
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moodLevel: _selectedLevel!,
      moodLabel: mood['label'] as String,
      emoji: mood['emoji'] as String,
      date: DateTime.now(),
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      emotions: List.from(_selectedEmotions),
    );
    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bagaimana perasaanmu?',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            // Mood selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.moods.map((mood) {
                final isSelected = _selectedLevel == mood['level'];
                final color = mood['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = mood['level'] as int),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(mood['emoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          (mood['label'] as String).split(' ').first,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isSelected ? color : AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Emosi yang kamu rasakan:',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotionOptions.map((e) {
                final isSelected = _selectedEmotions.contains(e);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedEmotions.remove(e);
                    } else {
                      _selectedEmotions.add(e);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Catatan (opsional):',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ceritakan lebih lanjut...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedLevel != null ? _save : null,
                child: const Text('Simpan Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}