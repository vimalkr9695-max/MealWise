import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../meal.dart';
import '../storage.dart';
import 'edit_profile_page.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  final List<Meal> allMeals;
  final double budget;
  final String userName;
  final VoidCallback onDataChanged;

  const ProfilePage({
    super.key,
    required this.allMeals,
    required this.budget,
    required this.userName,
    required this.onDataChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _reminders = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final r = await Storage.loadReminders();
    if (mounted) setState(() => _reminders = r);
  }

  Future<void> _changeBudget() async {
    final controller =
        TextEditingController(text: widget.budget.toStringAsFixed(0));

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A18),
        title: Text(
          'Change Budget',
          style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFFF0EDE6)),
        ),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.dmSans(color: const Color(0xFFF0EDE6)),
          decoration: InputDecoration(
            hintText: 'Enter monthly budget',
            hintStyle:
                GoogleFonts.dmSans(color: const Color(0xFF5C5A56)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4A853)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4A853)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFF9B9890))),
          ),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                await Storage.saveBudget(val);
                widget.onDataChanged();
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text('Save',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFD4A853))),
          ),
        ],
      ),
    );
  }

  Future<void> _showHistory() async {
    final sorted = [...widget.allMeals]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A18),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Meal History',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0EDE6),
              ),
            ),
          ),
          const Divider(color: Color(0xFF2E2E2B)),
          Expanded(
            child: sorted.isEmpty
                ? Center(
                    child: Text(
                      'No meals logged yet',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF5C5A56)),
                    ),
                  )
                : ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final m = sorted[i];
                      final date =
                          '${m.createdAt.month}/${m.createdAt.day}/${m.createdAt.year}';
                      return ListTile(
                        title: Text(
                          '${m.type} · ${m.name} · $date',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFFF0EDE6),
                          ),
                        ),
                        trailing: Text(
                          '₹${m.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4A853),
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

  Future<void> _dataReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A18),
        title: Text(
          'Reset All Data',
          style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFFF0EDE6)),
        ),
        content: Text(
          'This will erase ALL meal history. Are you sure?',
          style:
              GoogleFonts.dmSans(color: const Color(0xFF9B9890)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFF9B9890))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Erase',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFE05252))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.deleteAllMeals();
      await Storage.clearAll();
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'A';

    final photoUrl = AuthService.currentUser?.photoURL;
    final email = AuthService.currentUser?.email ?? 'no email';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0EDE6),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          currentName: widget.userName,
                          onSaved: widget.onDataChanged,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Edit',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFFD4A853),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── AVATAR ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A853).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4A853).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              gaplessPlayback: true,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD4A853),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initial,
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4A853),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4A853),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0EDE6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF9B9890),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── MONTHLY BUDGET CARD ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2B)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY BUDGET',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA07830),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${widget.budget.toStringAsFixed(2)}',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4A853),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Resets on the 1st of each month',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: const Color(0xFF5C5A56),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _changeBudget,
                    child: Container(
                      width: 80,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A853).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD4A853).withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Change',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFFF0EDE6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── PREFERENCES ─────────────────────────────────
            Text(
              'Preferences',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFFF0EDE6),
              ),
            ),

            const SizedBox(height: 12),

            _prefRow(
              'Meal Reminders',
              'Get reminded to log breakfast, lunch & dinner',
              trailing: Switch(
                value: _reminders,
                onChanged: (val) async {
                  setState(() => _reminders = val);
                  await Storage.saveReminders(val);
                },
                activeColor: const Color(0xFFD4A853),
                activeTrackColor:
                    const Color(0xFFD4A853).withOpacity(0.3),
                inactiveTrackColor: const Color(0xFF2E2E2B),
                inactiveThumbColor: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            _prefRow(
              'Show History',
              'View your past meals and spending',
              onTap: _showHistory,
            ),

            const SizedBox(height: 8),

            _prefRow(
              'Data & Reset',
              'Clear or reset your data anytime',
              onTap: _dataReset,
              isDestructive: true,
            ),

            const SizedBox(height: 24),

            // ── SIGN OUT BUTTON ──────────────────────────────
            GestureDetector(
              onTap: () async {
                await AuthService.signOut();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE05252).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE05252).withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_outlined,
                        color: Color(0xFFE05252),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE05252),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _prefRow(
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2E2B)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: isDestructive
                          ? const Color(0xFFE05252)
                          : const Color(0xFFF0EDE6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: const Color(0xFF5C5A56),
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF5C5A56),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}