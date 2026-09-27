import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../meal.dart';
import '../storage.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'log_meal_page.dart';
import 'edit_meal_page.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Meal> _allMeals = [];
  double _budget = 10000.0;
  String _userName = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetAndName();
    // Listen to Firestore meals stream
    FirestoreService.getMeals().listen((meals) {
      if (mounted) {
        setState(() => _allMeals = meals);
      }
    });
  }

  Future<void> _loadBudgetAndName() async {
    final budget = await Storage.loadBudget();
    final firebaseName = AuthService.displayName;
    setState(() {
      _budget = budget;
      _userName = firebaseName.isNotEmpty ? firebaseName : 'User';
    });
  }

  // Keep this so profile page can trigger a name refresh
  Future<void> _loadData() async {
    final budget = await Storage.loadBudget();
    final firebaseName = AuthService.displayName;
    setState(() {
      _budget = budget;
      _userName = firebaseName.isNotEmpty ? firebaseName : 'User';
    });
  }

  List<Meal> get _todayMeals {
    final today = DateTime.now();
    return _allMeals.where((m) {
      return m.createdAt.year == today.year &&
          m.createdAt.month == today.month &&
          m.createdAt.day == today.day;
    }).toList();
  }

  double get _todaySpend =>
      _todayMeals.fold(0.0, (sum, m) => sum + m.amount);

  double get _monthSpend {
    final now = DateTime.now();
    return _allMeals
        .where((m) =>
            m.createdAt.year == now.year && m.createdAt.month == now.month)
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          CalendarPage(allMeals: _allMeals, onDataChanged: _loadData),
          StatsPage(allMeals: _allMeals, budget: _budget),
          ProfilePage(
            allMeals: _allMeals,
            budget: _budget,
            userName: _userName,
            onDataChanged: _loadData,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d · yyyy').format(now);
    final monthName = DateFormat('MMMM').format(now);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: const Color(0xFF9B9890),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0EDE6),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  dateStr,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF5C5A56),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBudgetCard(monthName),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "TODAY'S MEALS",
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: const Color(0xFF9B9890),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            if (_todayMeals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No meals logged today yet',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF5C5A56),
                    ),
                  ),
                ),
              )
            else
              ...(_todayMeals.map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildMealCard(meal),
                  ))),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LogMealPage(onSaved: _loadData)),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A853),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: Center(
                  child: Text(
                    '+ Log a Meal',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A0A09),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(String monthName) {
    final fillFraction =
        (_budget > 0 ? (_monthSpend / _budget).clamp(0.0, 1.0) : 0.0);

    return Container(
      width: double.infinity,
      height: 154,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 1.0],
          colors: [Color(0xFF241C07), Color(0xFF241C07), Color(0xFF110F03)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E2F0E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TODAY'S SPEND",
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA07830),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_todaySpend.toStringAsFixed(1)}',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 34,
                    color: const Color(0xFFD4A853),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$monthName budget · ₹${_monthSpend.toStringAsFixed(0)} of ₹${_budget.toStringAsFixed(0)} used',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF7A6030),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  return Stack(
                    children: [
                      Container(
                        width: maxW,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2208),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: maxW * fillFraction,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC09040), Color(0xFFF0C870)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹0',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: const Color(0xFF7A6030))),
                    Text('₹${_monthSpend.toStringAsFixed(0)} spent',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: const Color(0xFF7A6030))),
                    Text('₹${_budget.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: const Color(0xFF7A6030))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    final icons = {
      'Breakfast': Icons.free_breakfast_outlined,
      'Lunch': Icons.lunch_dining_outlined,
      'Dinner': Icons.dinner_dining_outlined,
      'Snack': Icons.fastfood_outlined,
    };

    final hour = meal.createdAt.hour;
    final minute = meal.createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final timeStr = '$displayHour:$minute $period';

    final locationAndTime = [
      if (meal.location.isNotEmpty) meal.location,
      timeStr,
    ].join(' · ');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditMealPage(meal: meal, onSaved: _loadData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2E2B)),
        ),
        child: Row(
          children: [
            Icon(icons[meal.type] ?? Icons.restaurant_outlined,
                color: const Color(0xFF9B9890), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        meal.type,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0EDE6),
                        ),
                      ),
                      Text(
                        ' · ${meal.name}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFFF0EDE6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locationAndTime,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF9B9890),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${meal.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A853),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3322),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DONE',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7EB98A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Calendar'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Stats'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0E),
        border: Border(top: BorderSide(color: Color(0xFF2E2E2B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _currentIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: active
                      ? const Color(0xFFD4A853)
                      : const Color(0xFF5C5A56),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: active
                        ? const Color(0xFFD4A853)
                        : const Color(0xFF5C5A56),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}