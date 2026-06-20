import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/models.dart';
import '../../services/cloud_service.dart';
import '../../utils/app_theme.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  List<MoodEntry> _moods = [];
  List<Dass21Result> _dass = [];
  bool _loading = true;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    final moods = await CloudService.getMoods(limit: 90);
    final dass = await CloudService.getDassResults(limit: 50);

    // Map Supabase rows -> model
    final m = moods.map((row) {
      final id = (row['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()) as String;
      return MoodEntry(
        id: id,
        moodLevel: (row['mood_level'] as int?) ?? 0,
        moodLabel: (row['mood_label'] as String?) ?? '',
        emoji: (row['emoji'] as String?) ?? '😊',
        date: DateTime.tryParse(row['recorded_at'] ?? '') ?? DateTime.now(),
        note: row['note'] as String?,
        emotions: List<String>.from(row['emotions'] ?? []),
      );
    }).toList();

    final d = dass.map((row) {
      return Dass21Result(
        id: (row['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()) as String,
        date: DateTime.tryParse(row['recorded_at'] ?? '') ?? DateTime.now(),
        depressionScore: (row['depression_score'] as int?) ?? 0,
        anxietyScore: (row['anxiety_score'] as int?) ?? 0,
        stressScore: (row['stress_score'] as int?) ?? 0,
        answers: List<int>.from(row['answers'] ?? []),
      );
    }).toList();


    if (mounted) {
      setState(() {
        _moods = m;
        _dass = d;
        _loading = false;
      });
    }
  }


  // helper: last 7 unique days
  List<_DayMood> _last7() {
    final result = <_DayMood>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final entries = _moods.where((m) =>
          m.date.year == day.year && m.date.month == day.month && m.date.day == day.day).toList();
      if (entries.isNotEmpty) {
        result.add(_DayMood(day, entries.first.moodLevel.toDouble(), entries.first.emoji));
      } else {
        result.add(_DayMood(day, 0, ''));
      }
    }
    return result;
  }

  double get _avgMood {
    if (_moods.isEmpty) return 0;
    final w = _moods.take(7).toList();
    return w.map((m) => m.moodLevel).reduce((a, b) => a + b) / w.length;
  }

  Color _mc(int level) {
    switch (level) {
      case 5: return AppTheme.moodGreat;
      case 4: return AppTheme.moodGood;
      case 3: return AppTheme.moodOkay;
      case 2: return AppTheme.moodBad;
      default: return AppTheme.moodTerrible;
    }
  }

  Color _levelColor(String lv) {
    switch (lv) {
      case 'Normal': return AppTheme.success;
      case 'Ringan': return AppTheme.warning;
      case 'Sedang': return AppTheme.orange;
      case 'Berat':  return AppTheme.danger;
      default:       return const Color(0xFFC0392B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text('Statistik', style: Theme.of(context).textTheme.headlineMedium),
        bottom: TabBar(controller: _tab, tabs: const [
          Tab(text: '😊  Mood'),
          Tab(text: '🧠  Tes DASS'),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tab, children: [_moodTab(), _dassTab()]),
    );
  }

  // ── Mood Tab ─────────────────────────────────────────────────────────────
  Widget _moodTab() {
    if (_moods.isEmpty) return _empty('Belum ada data mood',
        'Mulai catat moodmu dari halaman Mood Tracker', '📊');

    final week = _last7();
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final m in _moods) dist[m.moodLevel] = (dist[m.moodLevel] ?? 0) + 1;
    final maxDist = dist.values.fold(0, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary row
        Row(children: [
          _SCard('${_moods.length}', 'Total\nEntri', '📝', AppTheme.primary, context),
          const SizedBox(width: 10),
          _SCard(_avgMood.toStringAsFixed(1), 'Rata-rata\nMood', '⭐', AppTheme.warning, context),
          const SizedBox(width: 10),
          _SCard('${_moods.where((m) => m.moodLevel >= 4).length}', 'Hari\nBaik', '🌟', AppTheme.success, context),
        ]),
        const SizedBox(height: 24),

        // Line chart
        Text('Tren Mood 7 Hari', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Container(
          height: 230,
          padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
          decoration: BoxDecoration(
            color: AppTheme.card(context), borderRadius: BorderRadius.circular(20)),
          child: LineChart(_lineData(week)),
        ),
        const SizedBox(height: 24),

        // Bar chart distribution
        Text('Distribusi Mood', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            color: AppTheme.card(context), borderRadius: BorderRadius.circular(20)),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxDist + 1).toDouble(),
            barTouchData: BarTouchData(enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // Gunakan tooltipBgColor jika getTooltipColor merah (untuk versi fl_chart lama)
                // Tapi untuk versi 0.68+, getTooltipColor adalah callback
                tooltipBgColor: AppTheme.card(context).withValues(alpha: 0.9),
                getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                  '${rod.toY.toInt()} hari',
                  GoogleFonts.poppins(fontWeight: FontWeight.w600,
                      color: AppTheme.text(context))),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const e = ['😢','😟','😐','😊','😄'];
                  final i = v.toInt();
                  if (i < 0 || i >= 5) return const SizedBox();
                  return Text(e[i], style: const TextStyle(fontSize: 18));
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 24,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLt(context))),
              )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(5, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (dist[i + 1] ?? 0).toDouble(),
                color: _mc(i + 1),
                width: 36,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ])),
          )),
        ),
        const SizedBox(height: 24),

        // Recent entries
        Text('Entri Terbaru', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ..._moods.take(5).map((m) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _mc(m.moodLevel).withOpacity(0.3)),
          ),
          child: Row(children: [
            Text(m.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.moodLabel, style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: _mc(m.moodLevel), fontSize: 14)),
              if (m.note != null && m.note!.isNotEmpty)
                Text(m.note!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed(context))),
            ])),
            Text(DateFormat('d MMM\nHH:mm', 'id').format(m.date),
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLt(context))),
          ]),
        )),
      ]),
    );
  }

  LineChartData _lineData(List<_DayMood> week) {
    final spots = <FlSpot>[];
    for (int i = 0; i < week.length; i++) {
      if (week[i].level > 0) spots.add(FlSpot(i.toDouble(), week[i].level));
    }
    if (spots.isEmpty) spots.add(const FlSpot(0, 3));
    return LineChartData(
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (v) => FlLine(
          color: AppTheme.divider(context), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, interval: 1, reservedSize: 36,
          getTitlesWidget: (v, _) {
            const e = {1:'😢',2:'😟',3:'😐',4:'😊',5:'😄'};
            return Text(e[v.toInt()] ?? '', style: const TextStyle(fontSize: 13));
          },
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i >= week.length) return const SizedBox();
            return Text(DateFormat('d/M').format(week[i].date),
                style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textLt(context)));
          },
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0, maxX: 6, minY: 1, maxY: 5,
      lineBarsData: [LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppTheme.primary,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
            radius: 6,
            color: _mc(s.y.toInt()),
            strokeColor: AppTheme.card(context),
            strokeWidth: 2.5,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [AppTheme.primary.withOpacity(0.25), AppTheme.primary.withOpacity(0)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
      )],
    );
  }

  // ── DASS Tab ──────────────────────────────────────────────────────────────
  Widget _dassTab() {
    if (_dass.isEmpty) return _empty('Belum ada tes DASS',
        'Lakukan tes DASS-21 dari halaman Beranda', '🧠');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Latest result highlight
        _dassHighlight(_dass.first),
        const SizedBox(height: 24),

        // History line chart
        if (_dass.length >= 2) ...[
          Text('Tren DASS (${_dass.length} tes)',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.card(context), borderRadius: BorderRadius.circular(20)),
            child: LineChart(_dassLineData()),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Legend('Depresi', AppTheme.danger),
            const SizedBox(width: 20),
            _Legend('Kecemasan', AppTheme.warning),
            const SizedBox(width: 20),
            _Legend('Stres', AppTheme.purple),
          ]),
          const SizedBox(height: 24),
        ],

        Text('Riwayat Tes', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ..._dass.take(5).map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card(context), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('EEEE, d MMMM yyyy · HH:mm', 'id').format(r.date),
                style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context))),
            const SizedBox(height: 10),
            Row(children: [
              _DassBadge('Depresi', r.depressionScore, r.depressionLevel,
                  _levelColor(r.depressionLevel)),
              const SizedBox(width: 8),
              _DassBadge('Cemas', r.anxietyScore, r.anxietyLevel,
                  _levelColor(r.anxietyLevel)),
              const SizedBox(width: 8),
              _DassBadge('Stres', r.stressScore, r.stressLevel,
                  _levelColor(r.stressLevel)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _dassHighlight(Dass21Result r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
          color: const Color(0xFF6C5CE7).withOpacity(0.35),
          blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🧠', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(child: Text('Hasil Tes Terbaru',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
          Text(DateFormat('d MMM', 'id').format(r.date),
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _DassGauge('Depresi', r.depressionScore, r.depressionLevel,
              _levelColor(r.depressionLevel)),
          const SizedBox(width: 10),
          _DassGauge('Kecemasan', r.anxietyScore, r.anxietyLevel,
              _levelColor(r.anxietyLevel)),
          const SizedBox(width: 10),
          _DassGauge('Stres', r.stressScore, r.stressLevel,
              _levelColor(r.stressLevel)),
        ]),
      ]),
    );
  }

  LineChartData _dassLineData() {
    final reversed = _dass.reversed.toList();
    return LineChartData(
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => FlLine(
          color: AppTheme.divider(context), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i >= reversed.length) return const SizedBox();
            return Text(DateFormat('d/M').format(reversed[i].date),
                style: GoogleFonts.poppins(fontSize: 8, color: AppTheme.textLt(context)));
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) => Text('${v.toInt()}',
              style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textLt(context))),
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minX: 0, maxX: (reversed.length - 1).toDouble(),
      minY: 0, maxY: 42,
      lineBarsData: [
        _dassLine(reversed.map((d) => d.depressionScore.toDouble()).toList(), AppTheme.danger),
        _dassLine(reversed.map((d) => d.anxietyScore.toDouble()).toList(), AppTheme.warning),
        _dassLine(reversed.map((d) => d.stressScore.toDouble()).toList(), AppTheme.purple),
      ],
    );
  }

  LineChartBarData _dassLine(List<double> scores, Color color) =>
      LineChartBarData(
        spots: scores.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), // Convert scores to FlSpot
        isCurved: true, color: color, barWidth: 3, // Thicker line
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 0,
          ),
        ),
      );

  Widget _empty(String title, String sub, String emoji) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 60)),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(sub, textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMed(context)))),
    ]));
  }
}

class _DayMood {
  final DateTime date;
  final double level;
  final String emoji;
  _DayMood(this.date, this.level, this.emoji);
}

class _SCard extends StatelessWidget {
  final String v, label, emoji;
  final Color color;
  final BuildContext ctx;
  const _SCard(this.v, this.label, this.emoji, this.color, this.ctx);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.card(ctx),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(v, style: GoogleFonts.nunito(
            fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10,
                color: AppTheme.textMed(ctx), height: 1.3)),
      ]),
    ));
  }
}

class _Legend extends StatelessWidget {
  final String label; final Color color;
  const _Legend(this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 18, height: 3, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 5),
    Text(label, style: GoogleFonts.poppins(
        fontSize: 11, color: AppTheme.textMed(context))),
  ]);
}

class _DassBadge extends StatelessWidget {
  final String label, level;
  final int score;
  final Color color;
  const _DassBadge(this.label, this.score, this.level, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(label, style: GoogleFonts.poppins(
            fontSize: 10, color: AppTheme.textMed(context))),
        Text('$score', style: GoogleFonts.nunito(
            fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(level, style: GoogleFonts.poppins(
            fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}

class _DassGauge extends StatelessWidget {
  final String label, level;
  final int score;
  final Color color;
  const _DassGauge(this.label, this.score, this.level, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(label, style: GoogleFonts.poppins(
          fontSize: 10, color: Colors.white70)),
      const SizedBox(height: 4),
      Text('$score', style: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(level, style: GoogleFonts.poppins(
            fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    ]));
  }
}