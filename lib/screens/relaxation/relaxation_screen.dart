import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/relaxation_data.dart';
import '../../utils/app_theme.dart';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({super.key});

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> {
  String _selectedCategory = 'Semua';
  final _categories = ['Semua', 'Pernapasan', 'Meditasi', 'Relaksasi', 'Gerakan'];

  List<Map<String, dynamic>> get _filteredExercises {
    if (_selectedCategory == 'Semua') return RelaxationData.exercises;
    return RelaxationData.exercises
        .where((e) => e['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Relaksasi & Meditasi',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredExercises.length,
              itemBuilder: (ctx, i) {
                final ex = _filteredExercises[i];
                final color = Color(ex['color'] as int);
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ExerciseDetailScreen(exercise: ex),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Text(ex['emoji'] as String,
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ex['category'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ex['title'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  ex['subtitle'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 14, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      ex['duration'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.play_circle_fill,
                              color: AppTheme.primary, size: 36),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Detail & Player ─────────────────────────────────────────────────
class _ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  const _ExerciseDetailScreen({required this.exercise});

  @override
  State<_ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<_ExerciseDetailScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isDone = false;
  int _currentStep = 0;
  int _stepTimeLeft = 0;
  int _totalTimeLeft = 0;
  int _currentCycle = 0;
  Timer? _timer;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;

  List<Map<String, dynamic>> get steps =>
      List<Map<String, dynamic>>.from(widget.exercise['steps'] as List);
  int get cycles => widget.exercise['cycles'] as int;
  int get totalDuration => widget.exercise['durationSeconds'] as int;
  Color get color => Color(widget.exercise['color'] as int);

  @override
  void initState() {
    super.initState();
    _totalTimeLeft = totalDuration;
    _stepTimeLeft = (steps.first['duration'] as int);
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breatheAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breatheController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isPlaying) {
      _timer?.cancel();
      _breatheController.stop();
      setState(() => _isPlaying = false);
    } else {
      _startSession();
    }
  }

  void _startSession() {
    setState(() {
      _isPlaying = true;
      _currentStep = 0;
      _currentCycle = 0;
      _stepTimeLeft = steps.first['duration'] as int;
    });
    _breatheController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    if (!mounted) { t.cancel(); return; }
    setState(() {
      if (_totalTimeLeft > 0) _totalTimeLeft--;
      if (_stepTimeLeft > 1) {
        _stepTimeLeft--;
      } else {
        // Move to next step
        if (_currentStep < steps.length - 1) {
          _currentStep++;
          _stepTimeLeft = steps[_currentStep]['duration'] as int;
        } else if (_currentCycle < cycles - 1) {
          _currentCycle++;
          _currentStep = 1; // Skip preparation step
          _stepTimeLeft = steps[_currentStep]['duration'] as int;
        } else {
          // Done
          t.cancel();
          _breatheController.stop();
          _isPlaying = false;
          _isDone = true;
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[_currentStep];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withOpacity(0.6), AppTheme.bgLight],
            stops: const [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.exercise['title'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _isDone
                    ? _buildDoneView()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Breathing circle
                          AnimatedBuilder(
                            animation: _breatheAnim,
                            builder: (ctx, child) {
                              return Transform.scale(
                                scale: _isPlaying ? _breatheAnim.value : 1.0,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.exercise['emoji'] as String,
                                          style: const TextStyle(fontSize: 52),
                                        ),
                                        if (_isPlaying) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatTime(_stepTimeLeft),
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Current phase
                          if (_isPlaying) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                step['phase'] as String,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _isPlaying
                                  ? step['instruction'] as String
                                  : widget.exercise['description'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                          ),
                          if (_isPlaying && cycles > 1) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Siklus ${_currentCycle + 1} dari $cycles',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 48),
                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isPlaying)
                                TextButton.icon(
                                  onPressed: () {
                                    _timer?.cancel();
                                    _breatheController.stop();
                                    setState(() {
                                      _isPlaying = false;
                                      _currentStep = 0;
                                      _totalTimeLeft = totalDuration;
                                      _stepTimeLeft = steps.first['duration'] as int;
                                    });
                                  },
                                  icon: const Icon(Icons.stop,
                                      color: Colors.white),
                                  label: Text('Stop',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white)),
                                ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _toggle,
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: color,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isPlaying) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Sisa waktu: ${_formatTime(_totalTimeLeft)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        Text(
          'Selesai!',
          style: GoogleFonts.nunito(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Kerja bagus! Kamu telah menyelesaikan sesi ${widget.exercise['title']}. Semoga kamu merasa lebih tenang.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isDone = false;
              _currentStep = 0;
              _totalTimeLeft = totalDuration;
              _stepTimeLeft = steps.first['duration'] as int;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: color,
          ),
          child: const Text('Ulangi'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Kembali',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}