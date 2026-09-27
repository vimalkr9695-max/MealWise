import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../meal.dart';
import 'edit_meal_page.dart';
 
class CalendarPage extends StatefulWidget {
  final List<Meal> allMeals;
  final VoidCallback onDataChanged;
  const CalendarPage(
      {super.key, required this.allMeals, required this.onDataChanged});
 
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}
 
class _CalendarPageState extends State<CalendarPage> {
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
 
  Map<int, List<Meal>> _groupMonthMeals() {
    final map = <int, List<Meal>>{};
    for (final m in widget.allMeals) {
      if (m.createdAt.year == _displayMonth.year &&
          m.createdAt.month == _displayMonth.month) {
        map.putIfAbsent(m.createdAt.day, () => []).add(m);
      }
    }
    return map;
  }

  List<Meal> _mealsForDay(Map<int, List<Meal>> grouped, DateTime day) {
    if (day.year != _displayMonth.year || day.month != _displayMonth.month) {
      return const [];
    }
    return grouped[day.day] ?? const [];
  }

  double _totalForDay(Map<int, List<Meal>> grouped, DateTime day) {
    return _mealsForDay(grouped, day).fold(0.0, (s, m) => s + m.amount);
  }

  int? _highestSpendDayNum(Map<int, List<Meal>> grouped) {
    if (grouped.isEmpty) return null;
    double bestTotal = -1;
    int? bestDay;
    grouped.forEach((day, meals) {
      final total = meals.fold(0.0, (s, m) => s + m.amount);
      if (total > bestTotal) {
        bestTotal = total;
        bestDay = day;
      }
    });
    return bestDay;
  }

  double _monthTotal(Map<int, List<Meal>> grouped) {
    var total = 0.0;
    for (final meals in grouped.values) {
      total += meals.fold(0.0, (s, m) => s + m.amount);
    }
    return total;
  }

  int _daysTracked(Map<int, List<Meal>> grouped) => grouped.length;

  double _avgPerDay(Map<int, List<Meal>> grouped) {
    final tracked = _daysTracked(grouped);
    return tracked == 0 ? 0 : _monthTotal(grouped) / tracked;
  }

  double _highestDayAmount(Map<int, List<Meal>> grouped) {
    final hd = _highestSpendDayNum(grouped);
    if (hd == null) return 0;
    return grouped[hd]!.fold(0.0, (s, m) => s + m.amount);
  }
 
  @override
  Widget build(BuildContext context) {
    final grouped = _groupMonthMeals();
    final firstDay =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final highestDayNum = _highestSpendDayNum(grouped);
    final today = DateTime.now();
 
    final cells = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_displayMonth),
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0EDE6),
                    ),
                  ),
                  Row(
                    children: [
                      _navButton('‹', () {
                        setState(() {
                          _displayMonth = DateTime(
                              _displayMonth.year, _displayMonth.month - 1);
                          _selectedDay = null;
                        });
                      }),
                      const SizedBox(width: 8),
                      _navButton('›', () {
                        setState(() {
                          _displayMonth = DateTime(
                              _displayMonth.year, _displayMonth.month + 1);
                          _selectedDay = null;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return SizedBox(
                  width: 30,
                  height: 34,
                  child: Center(
                    child: Text(d,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C5A56),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
 
            const SizedBox(height: 8),
 
            ...List.generate(cells.length ~/ 7, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (col) {
                    final day = cells[row * 7 + col];
                    if (day == null) {
                      return const SizedBox(width: 30, height: 34);
                    }
 
                    final hasMeals = _mealsForDay(grouped, day).isNotEmpty;
                    final isSelected = _selectedDay != null &&
                        _selectedDay!.year == day.year &&
                        _selectedDay!.month == day.month &&
                        _selectedDay!.day == day.day;
                    final isHighest = highestDayNum != null &&
                        highestDayNum == day.day;
                    final isToday = today.year == day.year &&
                        today.month == day.month &&
                        today.day == day.day;
 
                    Color bg = Colors.transparent;
                    Color textColor = const Color(0xFF5C5A56);
                    Color? borderColor;
 
                    if (isSelected) {
                      bg = const Color(0xFFD4A853);
                      textColor = const Color(0xFF1A1A18);
                    } else if (isHighest) {
                      bg = const Color(0xFF4A2E2E);
                      textColor = const Color(0xFFE07070);
                      borderColor = const Color(0xFFE07070);
                    } else if (isToday) {
                      textColor = const Color(0xFFD4A853);
                    }
 
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay =
                              (_selectedDay?.day == day.day && _selectedDay?.month == day.month)
                                  ? null
                                  : day;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(6),
                          border: borderColor != null
                              ? Border.all(color: borderColor)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (hasMeals && !isSelected)
                              Container(
                                width: 5, height: 5,
                                decoration: BoxDecoration(
                                  color: isHighest
                                      ? const Color(0xFFE07070)
                                      : const Color(0xFF7EB98A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
 
            const SizedBox(height: 8),
 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1806), Color(0xFF130F03)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A2A0C)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('MONTHLY TOTAL',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA07830),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('₹${_monthTotal(grouped).toStringAsFixed(1)}',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4A853),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMMM yyyy').format(_displayMonth)} · ${_daysTracked(grouped)} days tracked',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: const Color(0xFF7A6030),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _miniBadge(
                          '₹${_highestDayAmount(grouped).toStringAsFixed(0)}', 'Highest'),
                      const SizedBox(width: 10),
                      _miniBadge('₹${_avgPerDay(grouped).toStringAsFixed(0)}', 'Avg/day'),
                    ],
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 16),
 
            if (_selectedDay != null) _buildSelectedDayPanel(grouped),
 
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
 
  Widget _navButton(String arrow, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 41, height: 41,
        decoration: const BoxDecoration(
          color: Color(0xFF222220),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(arrow,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w200,
              color: const Color(0xFF9B9890),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _miniBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4A853).withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4A853),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 7,
              color: const Color(0xFFA07830).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildSelectedDayPanel(Map<int, List<Meal>> grouped) {
    final meals = _mealsForDay(grouped, _selectedDay!);
    final total = _totalForDay(grouped, _selectedDay!);
    final dateStr = DateFormat('EEEE, MMMM d').format(_selectedDay!);
 
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$dateStr — Selected',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9B9890),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meals.isEmpty)
            Text('No meals on this day',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF5C5A56),
              ),
            )
          else
            ...meals.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditMealPage(
                          meal: m, onSaved: widget.onDataChanged),
                    ),
                  );
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${m.type} · ${m.name}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFFF0EDE6),
                      ),
                    ),
                    Text('₹${m.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4A853),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          const Divider(color: Color(0xFF2E2E2B)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day Total',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9B9890),
                ),
              ),
              Text('₹${total.toStringAsFixed(2)}',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: const Color(0xFFF0EDE6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}