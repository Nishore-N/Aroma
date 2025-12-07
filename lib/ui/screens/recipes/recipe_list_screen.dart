import 'dart:ui';
import 'package:flutter/material.dart';

import '../recipe_detail/recipe_detail_screen.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../data/services/api_client.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final ApiClient _apiClient = ApiClient();
  final List<_RecipeData> _allRecipes = <_RecipeData>[];

  int _visibleCount = 3;
  final Set<int> _likedIndices = {};

  final ScrollController _scrollController = ScrollController();
  double _fadeValue = 1.0;

  @override
  void initState() {
    super.initState();

    _fetchRecipes();

    _scrollController.addListener(() {
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.position.pixels;

      if (max <= 0) return;

      double factor = (cur / max).clamp(0.0, 1.0);
      setState(() => _fadeValue = 1.0 - (factor * 0.45));
    });
  }

  Future<void> _fetchRecipes() async {
    try {
      final List<dynamic> list =
          await _apiClient.getList(ApiEndpoints.recipes);

      final recipes = list.whereType<Map<String, dynamic>>().map((json) {
        final dynamic rawCookTime = json['cookTime'];
        String time;
        if (rawCookTime is int) {
          time = '${rawCookTime.toString()} min';
        } else if (rawCookTime is String) {
          time = '$rawCookTime min';
        } else {
          time = '0 min';
        }

        return _RecipeData(
          image: (json['image'] ?? '') as String,
          title: (json['title'] ?? '') as String,
          cuisine: (json['cuisine'] ?? '') as String,
          time: time,
        );
      }).toList();

      setState(() {
        _allRecipes
          ..clear()
          ..addAll(recipes);
        _visibleCount = _allRecipes.isEmpty
            ? 0
            : (_allRecipes.length >= 3 ? 3 : _allRecipes.length);
      });
    } catch (_) {
      // For now, ignore errors to avoid UI changes; list will stay empty.
    }
  }

  void _loadMore() {
    if (_visibleCount >= _allRecipes.length) return;

    setState(() {
      _visibleCount = (_visibleCount + 2).clamp(0, _allRecipes.length);
    });
  }

  void _toggleLike(int index) {
    setState(() {
      if (_likedIndices.contains(index)) {
        _likedIndices.remove(index);
      } else {
        _likedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------------------
      // Floating Frosted Button Layout
      // ------------------------------
      body: Stack(
        children: [
          // ===========================
          // Main Scroll Content
          // ===========================
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.black.withOpacity(0.15)),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Recipes for you',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),

                const SizedBox(height: 28),

                for (int i = 0; i < _visibleCount; i++) ...[
                  _RecipeCard(
                    data: _allRecipes[i],
                    isLiked: _likedIndices.contains(i),
                    onToggleLike: () => _toggleLike(i),
                  ),
                  const SizedBox(height: 30),
                ],

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _visibleCount < _allRecipes.length ? _loadMore : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF6A45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Load more recipes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Add navigation or action for showing categories
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.black.withOpacity(0.2),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Show All Categories',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF4EC),
                        Color(0xFFFFEDE5),
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/4049/4049043.png',
                        height: 75,
                        width: 75,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Not what you're looking for?",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B6B6B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Help us improve',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ======================================================================
//  MODEL
// ======================================================================

class _RecipeData {
  final String image;
  final String title;
  final String cuisine;
  final String time;

  const _RecipeData({
    required this.image,
    required this.title,
    required this.cuisine,
    required this.time,
  });
}

// ======================================================================
//  RECIPE CARD
// ======================================================================

class _RecipeCard extends StatelessWidget {
  final _RecipeData data;
  final bool isLiked;
  final VoidCallback onToggleLike;

  const _RecipeCard({
    required this.data,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 470,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[300]),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _infoIcon(Icons.auto_awesome, 'Gen-AI'),
                      const SizedBox(width: 14),
                      _infoIcon(Icons.restaurant_menu, data.cuisine),
                      const SizedBox(width: 14),
                      _infoIcon(Icons.access_time, data.time),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(
                                  image: data.image,
                                  title: data.title,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Cook now',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      GestureDetector(
                        onTap: onToggleLike,
                        child: Container(
                          height: 52,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white70,
                              width: 1.4,
                            ),
                            color: Colors.white.withOpacity(0.22),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: const Color(0xFFFF8FA7),
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Save',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
//  INFO ICON WIDGET
// ======================================================================

Widget _infoIcon(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 15, color: Colors.white.withOpacity(0.95)),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.95),
        ),
      ),
    ],
  );
}
