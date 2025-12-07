import 'package:flutter/material.dart';
import 'ingredient_section.dart';
import 'cookware_section.dart';
import 'preparation_section.dart';
import 'review_section.dart';
import 'similar_recipes_section.dart';
import '../ingredients_needed/ingredients_needed_screen.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../data/services/api_client.dart';

const String longText =
    "Dal Makhani is a rich and creamy North Indian comfort dish made from "
    "slow-cooked black lentils and kidney beans infused with butter, cream, "
    "and aromatic spices. Traditionally simmered overnight, this recipe "
    "captures the same depth of flavor in a shorter time.";

class RecipeDetailScreen extends StatefulWidget {
  final String image;
  final String title;

  const RecipeDetailScreen({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isExpanded = false;
  bool isFavorite = false;
  bool isSaved = false;
  int servings = 4;

  final ApiClient _apiClient = ApiClient();
  List<String> _cookingSteps = <String>[];
  List<Map<String, dynamic>> _cookingStepsDetailed = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> _ingredientData = <Map<String, dynamic>>[];
  List<Map<String, String>> _reviewData = <Map<String, String>>[];
  List<Map<String, dynamic>> _similarRecipeData = <Map<String, dynamic>>[];
  List<String> _cookwareItems = <String>[];

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _ingredientsKey = GlobalKey();
  final GlobalKey _cookwareKey = GlobalKey();
  final GlobalKey _preparationKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    try {
      final stepsRaw = await _apiClient.getList(ApiEndpoints.cookingSteps);
      final detailedStepsRaw =
          await _apiClient.getList(ApiEndpoints.cookingStepsDetailed);

      final cookwareRaw = await _apiClient.getList(ApiEndpoints.cookware);

      final ingredientRaw =
          await _apiClient.getList(ApiEndpoints.ingredientData);
      final reviewRaw = await _apiClient.getList(ApiEndpoints.reviewData);
      final similarRaw =
          await _apiClient.getList(ApiEndpoints.similarRecipes);

      setState(() {
        _cookingSteps = stepsRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => (m['text'] ?? '').toString())
            .toList(growable: false);

        _cookwareItems = cookwareRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => (m['name'] ?? '').toString())
            .where((name) => name.isNotEmpty)
            .toList(growable: false);

        final ingredientData = ingredientRaw
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);

        _ingredientData = ingredientData;

        _cookingStepsDetailed = detailedStepsRaw
            .whereType<Map<String, dynamic>>()
            .map((step) {
          final ids = (step['ingredientIds'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[];

          final stepIngredients = ingredientData
              .where((ing) => ids.contains(ing['id']?.toString()))
              .toList(growable: false);

          return <String, dynamic>{
            'instruction': (step['instruction'] ?? '').toString(),
            'ingredients': stepIngredients,
            'tips': (step['tips'] as List?)
                    ?.map((t) => t.toString())
                    .toList(growable: false) ??
                <String>[],
          };
        }).toList(growable: false);

        _reviewData = reviewRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => <String, String>{
                  'name': (m['name'] ?? '').toString(),
                  'comment': (m['comment'] ?? '').toString(),
                  'avatar': (m['avatar'] ?? '').toString(),
                })
            .toList(growable: false);
        _similarRecipeData = similarRaw
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      });
    } catch (_) {
      // Ignore errors here to avoid changing UI; sections will just see empty lists.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomButton(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ------------------ IMAGE + ACTION BAR ------------------
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,

            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    /// Background Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                  ],
                );
              },
            ),

            /// Action Buttons
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => setState(() => isSaved = !isSaved),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                      size: 20,
                    ),
                    onPressed: () => setState(() => isFavorite = !isFavorite),
                  ),
                ),
              ),
            ],
          ),

          // ------------------ DETAILS CONTAINER ------------------
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -120),

              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 8, 26, 200),
                  child: _content(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ CONTENT UI ------------------
  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _InfoChip(icon: Icons.restaurant, label: "Indian"),
            _InfoChip(icon: Icons.local_fire_department, label: "215 kcal"),
            _InfoChip(icon: Icons.access_time, label: "40m"),
            _InfoChip(icon: Icons.people, label: "4"),
          ],
        ),

        const SizedBox(height: 22),

        AnimatedCrossFade(
          firstChild:
              Text(longText, maxLines: 3, overflow: TextOverflow.ellipsis),
          secondChild: Text(longText),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Text(
            isExpanded ? "Read less" : "Read more..",
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 30),

        const Text(
          "Nutrition per serving",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 20,
          runSpacing: 18,
          children: const [
            _NutritionTile(icon: Icons.grass, label: "65g Carbs"),
            _NutritionTile(icon: Icons.fitness_center, label: "30g Protein"),
            _NutritionTile(icon: Icons.local_fire_department, label: "215 Kcal"),
            _NutritionTile(icon: Icons.lunch_dining, label: "46g Fat"),
          ],
        ),

        const SizedBox(height: 35),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tabItem("Ingredients", 0, _ingredientsKey),
            _tabItem("Cookware", 1, _cookwareKey),
            _tabItem("Preparation", 2, _preparationKey),
          ],
        ),

        const SizedBox(height: 30),

        Container(
          key: _ingredientsKey,
          child: IngredientSection(
            servings: servings,
            onServingChange: (newServings) {
              setState(() => servings = newServings);
            },
            ingredientData: _ingredientData,
          ),
        ),

        const SizedBox(height: 35),

        Container(
          key: _cookwareKey,
          child: CookwareSection(
            servings: servings,
            cookwareItems: _cookwareItems,
          ),
        ),

        const SizedBox(height: 35),

        Container(
          key: _preparationKey,
          child: PreparationSection(steps: _cookingSteps),
        ),

        const SizedBox(height: 35),

        ReviewSection(
          rating: 4.5,
          totalComments: _reviewData.length,
          totalReviewed: 124,
          reviews: _reviewData,
        ),

        const SizedBox(height: 35),

        SimilarRecipesSection(recipes: _similarRecipeData),
      ],
    );
  }

  Widget _tabItem(String text, int index, GlobalKey key) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = index);
        _scrollTo(key);
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selectedTab == index
                  ? const Color(0xFFFF6A45)
                  : Colors.grey,
            ),
          ),
          if (selectedTab == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 100,
              height: 2,
              color: const Color(0xFFFF6A45),
            ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFF6A45), width: 2),
            ),
            child: const Icon(Icons.more_horiz, color: Colors.black, size: 26),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 270,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IngredientsNeededScreen(
                      servings: servings,
                      ingredients: _ingredientData.map((ingredient) => {
                        'icon': ingredient['icon'],
                        'name': ingredient['name'],
                        'qty': ingredient['qty'],
                      }).toList(),
                      steps: _cookingStepsDetailed,
                    ),
                  ),
                );
              },
              child: const Text(
                "Cook Now",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orange.shade50,
          child: Icon(icon, size: 18, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _NutritionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NutritionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 40,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: const Color(0xFFFF6A45)),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}