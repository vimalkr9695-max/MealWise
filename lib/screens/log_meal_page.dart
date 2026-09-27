import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../meal.dart';
import '../services/firestore_service.dart';

class LogMealPage extends StatefulWidget {
  final VoidCallback onSaved;
  const LogMealPage({super.key, required this.onSaved});

  @override
  State<LogMealPage> createState() => _LogMealPageState();
}

class _LogMealPageState extends State<LogMealPage> {
  String _selectedType = 'Breakfast';
  String? _selectedCategory;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _types = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _categories = ['Fruits', 'Vegetables', 'Protein', 'Grains'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4A853),
              surface: Color(0xFF1A1A18),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a meal name',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A18),
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a food category',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A18),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final mealTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0.0,
      note: _noteController.text.trim(),
      createdAt: mealTime,
      category: _selectedCategory,
    );

    await FirestoreService.addMeal(meal);

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 41,
                      height: 41,
                      decoration: const BoxDecoration(
                        color: Color(0xFF222220),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '‹',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w200,
                            color: const Color(0xFF9B9890),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    'Log a Meal',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0EDE6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLabel('MEAL TYPE'),
              const SizedBox(height: 15),
              Row(
                children: _types.map((type) {
                  final active = _selectedType == type;
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: type != 'Snack' ? 10 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0x1FD4A853)
                                : const Color(0x1F1A1A18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFFD4A853)
                                  : const Color(0xFF2E2E2B),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              type,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? const Color(0xFFD4A853)
                                    : const Color(0xFF9B9890),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabel('FOOD CATEGORY'),
              const SizedBox(height: 15),
              Row(
                children: _categories.map((category) {
                  final active = _selectedCategory == category;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: category != 'Grains' ? 8 : 0),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0x1FD4A853)
                                : const Color(0x1F1A1A18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFFD4A853)
                                  : const Color(0xFF2E2E2B),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? const Color(0xFFD4A853)
                                    : const Color(0xFF9B9890),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabel('MEAL NAME'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'e.g. Avocado Toast', 40),

              const SizedBox(height: 16),

              _buildLabel('RESTAURANT / LOCATION'),
              const SizedBox(height: 8),
              _buildTextField(_locationController, 'e.g. Home, Cafe...', 40),

              const SizedBox(height: 16),

              _buildLabel('AMOUNT SPENT'),
              const SizedBox(height: 8),
              _buildAmountField(),

              const SizedBox(height: 16),

              _buildLabel('TIME OF MEAL'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2E2E2B)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF0EDE6),
                        ),
                      ),
                      const Icon(Icons.access_time,
                          color: Color(0xFF5C5A56), size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('NOTE (OPTIONAL)'),
              const SizedBox(height: 8),
              Container(
                height: 71,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFFF0EDE6),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add a note about this meal...',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF5C5A56),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A853),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2E2B)),
                  ),
                  child: Center(
                    child: Text(
                      'Save Meal',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A09),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF9B9890),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF0EDE6),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF5C5A56),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4A853)),
      ),
      child: Row(
        children: [
          Text(
            '₹ ',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4A853),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4A853),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: const Color(0xFF5C5A56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}