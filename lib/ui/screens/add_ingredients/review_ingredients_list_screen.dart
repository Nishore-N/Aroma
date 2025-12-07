import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/ingredient_row.dart';
import '../preferences/cooking_preference_screen.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/services/api_client.dart';

class ReviewIngredientsListScreen extends StatefulWidget {
  const ReviewIngredientsListScreen({super.key});

  @override
  State<ReviewIngredientsListScreen> createState() => _ReviewIngredientsListScreenState();
}

class _ReviewIngredientsListScreenState extends State<ReviewIngredientsListScreen> {
  final ApiClient _apiClient = ApiClient();
  List<IngredientModel> _ingredients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    try {
      final list = await _apiClient.getList(ApiEndpoints.ingredients);
      setState(() {
        _ingredients = list
            .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load ingredients: ' + e.toString();
        _isLoading = false;
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),

      /// ---------- HEADER ----------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 40, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Back + Add More Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),

                  /// Add More Button
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFFFF0E9),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Color(0xFFFF6A45)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Add more',
                        style: TextStyle(
                          color: Color(0xFFFF6A45),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              /// Title
              const Text(
                'Review Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),

      /// ---------- BODY ----------
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),

          /// ---------- FOOTER WITH BUTTON ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CookingPreferenceScreen(),
                  ),
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_ingredients.isEmpty) {
      return const Center(child: Text('No ingredients found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final item = _ingredients[index];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: IngredientRow(
                emoji: item.emoji,
                name: item.name,
                matchPercent: item.match,
                onRemove: () => _removeIngredient(index),
              ),
            ),

            /// Divider
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        );
      },
    );
  }
}
