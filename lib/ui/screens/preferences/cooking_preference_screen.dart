// lib/ui/screens/preferences/cooking_preference_screen.dart
import 'package:flutter/material.dart';
import '../recipes/recipe_list_screen.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../data/services/api_client.dart';

class CookingPreferenceScreen extends StatefulWidget {
  const CookingPreferenceScreen({super.key});

  @override
  State<CookingPreferenceScreen> createState() =>
      _CookingPreferenceScreenState();
}

class _CookingPreferenceScreenState extends State<CookingPreferenceScreen> {
  int servingCount = 4;

  final ApiClient _apiClient = ApiClient();

  /// Expanded state tracker
  final Map<String, bool> _expanded = <String, bool>{};

  /// Options loaded from backend
  final Map<String, List<String>> options = <String, List<String>>{};

  /// Per-section selected item
  final Map<String, String> _selectedPerSection = <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final List<dynamic> list =
          await _apiClient.getList(ApiEndpoints.preferences);

      final Map<String, List<String>> loaded = <String, List<String>>{};
      for (final dynamic item in list) {
        if (item is Map<String, dynamic>) {
          final String title = (item['title'] ?? '').toString();
          final dynamic rawItems = item['items'];
          if (title.isEmpty || rawItems is! List) continue;

          loaded[title] = rawItems.map((e) => e.toString()).toList();
        }
      }

      setState(() {
        options
          ..clear()
          ..addAll(loaded);
        _expanded
          ..clear()
          ..addEntries(loaded.keys.map((k) => MapEntry<String, bool>(k, false)));

        // Initialize selection per section (default to first item if available)
        _selectedPerSection
          ..clear()
          ..addEntries(loaded.entries.map((entry) {
            final String title = entry.key;
            final List<String> items = entry.value;
            return MapEntry<String, String>(
              title,
              items.isNotEmpty ? items.first : '',
            );
          }));
      });
    } catch (_) {
      // If loading fails, keep options empty; UI will just show nothing.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// FIXED FOOTER
      bottomNavigationBar: _bottomSection(),

      /// SCROLL BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              const SizedBox(height: 18),
              _title("Cooking Preference"),
              const SizedBox(height: 22),

              /// Render all expandable sections
              for (final section in options.keys)
                _buildSection(section, options[section]!),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- UI COMPONENTS ----------

  Widget _bottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Serving needed",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _servingBox(),
          const SizedBox(height: 18),
          _generateBtn(),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.15)),
        ),
        child: const Icon(Icons.arrow_back, size: 20),
      ),
    );
  }

  Widget _title(String text) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26));
  }

  /// ----- Expandable Section -----
  Widget _buildSection(String title, List<String> items) {
    final isExpanded = _expanded[title] ?? false;
    final visibleItems = isExpanded ? items : items.take(4).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleItems
                .map((item) => _chip(title, item, item == _selectedPerSection[title]))
                .toList(),
          ),

          const SizedBox(height: 6),

          GestureDetector(
            onTap: () => setState(() => _expanded[title] = !isExpanded),
            child: Text(
              isExpanded ? "View Less" : "View More",
              style: const TextStyle(
                color: Color(0xFFFF6A45),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String section, String text, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPerSection[section] = text),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE5DA) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFF6A45) : Colors.black12,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFFFF6A45) : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _servingBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF6A45), width: 1.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _stepper("-", () => servingCount = servingCount > 1 ? servingCount - 1 : 1)),
          const SizedBox(width: 14),
          Text("$servingCount",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 14),
          Expanded(child: _stepper("+", () => servingCount++)),
        ],
      ),
    );
  }

  Widget _stepper(String text, VoidCallback action) {
    return GestureDetector(
      onTap: () => setState(action),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEFE6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6A45))),
        ),
      ),
    );
  }

  Widget _generateBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecipeListScreen(),
          ),
        );
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6A45),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Text(
            "Generate Recipe ✨",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Title styling
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17));
  }
}