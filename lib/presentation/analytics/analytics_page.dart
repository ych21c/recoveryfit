import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  int _periodTab = 0; // 0=주간, 1=월간

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 나의 진척도',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '재활 운동의 효과를 한눈에 확인하세요',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 12),
                    // Period tabs
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: ['주간', '월간'].asMap().entries.map((e) {
                          final i = e.key;
                          final label = e.value;
                          final isSel = _periodTab == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _periodTab = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSel
                                          ? AppTheme.primary
                                          : Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: progressAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (data) => _buildBody(data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProgressData data) {
    final painTrend = data.painTrend;
    final completionRate = data.completionRate;
    final weeklyVolume = data.weeklyVolume;

    // KPI values
    final avgPain = painTrend.isEmpty
        ? 0
        : (painTrend.map((e) => e.value).reduce((a, b) => a + b) / painTrend.length).round();
    final avgCompletion = completionRate.isEmpty
        ? 0.0
        : completionRate.map((e) => e.value).reduce((a, b) => a + b) /
            completionRate.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // KPI row
        Row(children: [
          Expanded(
            child: _KpiCard(
              value: avgPain == 0 ? '-' : '$avgPain점',
              label: '평균 통증 점수',
              delta: '추이 분석 중',
              isPositive: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KpiCard(
              value: '${(avgCompletion * 100).round()}%',
              label: '평균 완료율',
              delta: avgCompletion >= 0.7 ? '▲ 양호' : '분석 중',
              isPositive: avgCompletion >= 0.7,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // Pain trend chart
        _ChartCard(
          title: '😌 통증 추이 (NRS 1~10)',
          subtitle: '최근 7일 — 탭하면 상세 정보가 표시됩니다',
          child: painTrend.isEmpty
              ? const _EmptyChart()
              : _PainLineChart(data: painTrend),
        ),
        const SizedBox(height: 14),

        // Completion bar chart
        _ChartCard(
          title: '✅ 주간 완료율',
          subtitle: '각 운동 세션의 달성 비율',
          child: completionRate.isEmpty
              ? const _EmptyChart()
              : _CompletionBarChart(data: completionRate),
        ),
        const SizedBox(height: 14),

        // Volume chart
        _ChartCard(
          title: '📈 주간 운동 볼륨 추이',
          subtitle: '완료된 운동 세트 수 기준',
          child: weeklyVolume.isEmpty
              ? const _EmptyChart()
              : _VolumeBarChart(data: weeklyVolume),
        ),
      ],
    );
  }
}

// ── KPI Card ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final String delta;
  final bool isPositive;

  const _KpiCard({
    required this.value,
    required this.label,
    required this.delta,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 3),
          Text(delta,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppTheme.success : AppTheme.error)),
        ]),
      );
}

// ── Chart Card ────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          SizedBox(height: 140, child: child),
        ]),
      );
}

// ── Empty Chart ───────────────────────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text('데이터가 아직 없습니다\n운동을 완료하면 통계가 표시됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textDisabled)),
          ],
        ),
      );
}

// ── Pain Line Chart ───────────────────────────────────────────────────────────

class _PainLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, int>> data;
  const _PainLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 5,
              getTitlesWidget: (v, _) => Text('${v.round()}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textDisabled)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                const days = ['월', '화', '수', '목', '금', '토', '일'];
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                final d = data[i].key;
                return Text(days[d.weekday - 1],
                    style: const TextStyle(fontSize: 10, color: AppTheme.textDisabled));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primary,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion Bar Chart ──────────────────────────────────────────────────────

class _CompletionBarChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  const _CompletionBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['월', '화', '수', '목', '금', '토', '일'];
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                final d = data[i].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(days[d.weekday - 1],
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textDisabled)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final rate = e.value.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: rate * 100,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                color: rate >= 0.9
                    ? AppTheme.primary
                    : rate >= 0.6
                        ? AppTheme.primaryLight
                        : AppTheme.secondary,
              ),
            ],
          );
        }).toList(),
        maxY: 100,
      ),
    );
  }
}

// ── Volume Bar Chart ──────────────────────────────────────────────────────────

class _VolumeBarChart extends StatelessWidget {
  final List<MapEntry<DateTime, int>> data;
  const _VolumeBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty
        ? 1
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${i + 1}주차',
                      style: const TextStyle(
                          fontSize: 9, color: AppTheme.textDisabled)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final isLast = e.key == data.length - 1;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: isLast
                    ? const LinearGradient(
                        colors: [Color(0xFFF4A261), Color(0xFFE07B2A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)
                    : const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
              ),
            ],
          );
        }).toList(),
        maxY: maxVal * 1.2,
      ),
    );
  }
}
