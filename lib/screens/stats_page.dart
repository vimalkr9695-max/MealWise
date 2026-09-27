import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../meal.dart';

class _HealthTheme {
  final Color gradientTop;
  final Color gradientBottom;
  final Color border;
  final Color accent;
  final Color trackBg;
  final String label;
  const _HealthTheme({
    required this.gradientTop,
    required this.gradientBottom,
    required this.border,
    required this.accent,
    required this.trackBg,
    required this.label,
  });
}

class StatsPage extends StatelessWidget {
  final List<Meal> allMeals;
  final double budget;
  const StatsPage({super.key, required this.allMeals, required this.budget});

  static const Map<String, int> _categoryPoints = {
    'Fruits': 2,
    'Vegetables': 2,
    'Protein': 2,
    'Grains': 1,
  };

  List<Meal> get _monthMeals {
    final now = DateTime.now();
    return allMeals
        .where((m) =>
            m.createdAt.year == now.year && m.createdAt.month == now.month)
        .toList();
  }

  List<Meal> get _categorizedMonthMeals =>
      _monthMeals.where((m) => m.category != null).toList();

  double get _totalSpend =>
      _monthMeals.fold(0.0, (s, m) => s + m.amount);

  int get _daysTracked {
    final days = <String>{};
    for (final m in _monthMeals) {
      days.add('${m.createdAt.day}');
    }
    return days.length;
  }

  double get _dailyAverage =>
      _daysTracked == 0 ? 0 : _totalSpend / _daysTracked;

  Map<String, double> _dailyTotals() {
    final map = <String, double>{};
    for (final m in _monthMeals) {
      final key = '${m.createdAt.day}';
      map[key] = (map[key] ?? 0) + m.amount;
    }
    return map;
  }

  MapEntry<String, double>? _highestDay() {
    final dt = _dailyTotals();
    if (dt.isEmpty) return null;
    return dt.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<String, double>? _lowestDay() {
    final dt = _dailyTotals();
    if (dt.isEmpty) return null;
    return dt.entries.reduce((a, b) => a.value < b.value ? a : b);
  }

  Map<String, double> _spendByType() {
    final map = {'Breakfast': 0.0, 'Lunch': 0.0, 'Dinner': 0.0, 'Snack': 0.0};
    for (final m in _monthMeals) {
      map[m.type] = (map[m.type] ?? 0) + m.amount;
    }
    return map;
  }

  Map<String, int> _categoryCounts() {
    final map = {'Fruits': 0, 'Vegetables': 0, 'Protein': 0, 'Grains': 0};
    for (final m in _categorizedMonthMeals) {
      map[m.category!] = (map[m.category!] ?? 0) + 1;
    }
    return map;
  }

  static const Map<String, int> _categoryDelta = {
    'Fruits': 3,
    'Vegetables': 3,
    'Protein': 3,
    'Grains': -3,
  };

  int get _healthScore {
    final categorized = List<Meal>.from(_categorizedMonthMeals)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (categorized.isEmpty) return 0;
    double running = 50.0;
    for (final m in categorized) {
      final delta = _categoryDelta[m.category] ?? 0;
      running = (running + delta).clamp(0.0, 100.0);
    }
    return running.round();
  }

  _HealthTheme _themeForScore(int score, int categorizedCount) {
    if (categorizedCount == 0) {
      return const _HealthTheme(
        gradientTop: Color(0xFF1E1E1C),
        gradientBottom: Color(0xFF121210),
        border: Color(0xFF2E2E2B),
        accent: Color(0xFF9B9890),
        trackBg: Color(0xFF2A2A27),
        label: 'NO DATA YET',
      );
    }
    if (score >= 80) {
      return const _HealthTheme(
        gradientTop: Color(0xFF17301A),
        gradientBottom: Color(0xFF0C1A0D),
        border: Color(0xFF2E5A32),
        accent: Color(0xFF7ED957),
        trackBg: Color(0xFF1B3A1E),
        label: 'HEALTHY',
      );
    }
            if (score > 50) {
      return const _HealthTheme(
        gradientTop: Color(0xFF2E2A0C),
        gradientBottom: Color(0xFF1A1706),
        border: Color(0xFF5E5518),
        accent: Color(0xFFE8D45C),
        trackBg: Color(0xFF423C0F),
        label: 'MODERATE',
      );
    }
    return const _HealthTheme(
      gradientTop: Color(0xFF2E1212),
      gradientBottom: Color(0xFF160A0A),
      border: Color(0xFF5A2A2A),
      accent: Color(0xFFE07070),
      trackBg: Color(0xFF3A1818),
      label: 'UNHEALTHY',
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final highest = _highestDay();
    final lowest = _lowestDay();
    final byType = _spendByType();
    final maxType =
        byType.values.isEmpty ? 1.0 : byType.values.reduce((a, b) => a > b ? a : b);
    final categoryCounts = _categoryCounts();
    final maxCategoryCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce((a, b) => a > b ? a : b);
    final score = _healthScore;
    final categorizedCount = _categorizedMonthMeals.length;
    final theme = _themeForScore(score, categorizedCount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Report',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0EDE6),
              ),
            ),
            const SizedBox(height: 4),
            Text('$monthName · $_daysTracked days tracked',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF5C5A56),
              ),
            ),

            const SizedBox(height: 22),

            _buildBudgetCard(monthName),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '₹${highest?.value.toStringAsFixed(2) ?? '0.00'}',
                    'Highest Day',
                    highest != null ? 'Day ${highest.key}' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    '₹${lowest?.value.toStringAsFixed(2) ?? '0.00'}',
                    'Lowest Day',
                    lowest != null ? 'Day ${lowest.key}' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '₹${_dailyAverage.toStringAsFixed(2)}',
                    'Daily Average',
                    null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    '${_monthMeals.length}',
                    'Meals Logged',
                    null,
                    isPrice: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text('Spend by Meal Type',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF0EDE6),
              ),
            ),

            const SizedBox(height: 10),

            ...['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((type) {
              final amount = byType[type] ?? 0.0;
              final fillRatio = maxType > 0 ? amount / maxType : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(type,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF9B9890),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2B),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: fillRatio.clamp(0.0, 1.0),
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A853),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('₹${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4A853),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 28),

            _sectionHeading('Monthly Health Score'),

            const SizedBox(height: 14),

            _buildHealthScoreCard(monthName, score, categorizedCount, theme),

            const SizedBox(height: 20),

            Text('Food Category Breakdown',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF0EDE6),
              ),
            ),

            const SizedBox(height: 10),

            if (_categorizedMonthMeals.isEmpty)
              Text(
                'Log meals with a food category to see your pattern here.',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF5C5A56),
                ),
              )
            else
              ...['Fruits', 'Vegetables', 'Protein', 'Grains'].map((category) {
                final count = categoryCounts[category] ?? 0;
                final points = count * (_categoryPoints[category] ?? 0);
                final fillRatio =
                    maxCategoryCount > 0 ? count / maxCategoryCount : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(category,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF9B9890),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E2E2B),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: fillRatio.clamp(0.0, 1.0),
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: theme.accent,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$count · +$points',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Text(text,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFF0EDE6),
      ),
    );
  }

  Widget _buildBudgetCard(String monthName) {
    final fillFraction =
        budget > 0 ? (_totalSpend / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241C07), Color(0xFF110F03)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E2F0E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("MONTHLY SPEND",
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA07830),
            ),
          ),
          const SizedBox(height: 4),
          Text('₹${_totalSpend.toStringAsFixed(1)}',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 34,
              color: const Color(0xFFD4A853),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthName budget · ₹${_totalSpend.toStringAsFixed(0)} of ₹${budget.toStringAsFixed(0)} used',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: const Color(0xFF7A6030),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2208),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: constraints.maxWidth * fillFraction,
                  height: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC09040), Color(0xFFF0C870)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹0',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 10, color: const Color(0xFF7A6030))),
              Text('₹${_totalSpend.toStringAsFixed(0)} spent',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 10, color: const Color(0xFF7A6030))),
              Text('₹${budget.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 10, color: const Color(0xFF7A6030))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(
      String monthName, int score, int categorizedCount, _HealthTheme theme) {
    final fillFraction = (score / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.gradientTop, theme.gradientBottom],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MONTHLY HEALTH SCORE",
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: theme.accent.withOpacity(0.75),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.accent.withOpacity(0.4)),
                ),
                child: Text(theme.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$score',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 34,
                  color: theme.accent,
                ),
              ),
              Text(' / 100',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16,
                  color: theme.accent.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            categorizedCount == 0
                ? '$monthName · no categorized meals yet'
                : '$monthName · based on $categorizedCount categorized meal${categorizedCount == 1 ? '' : 's'}',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: theme.accent.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.trackBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: constraints.maxWidth * fillFraction,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, String? sub,
      {bool isPrice = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: isPrice
                ? GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A853),
                  )
                : GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A853),
                  ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9B9890),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: const Color(0xFF5C5A56),
              ),
            ),
          ],
        ],
      ),
    );
  }
}