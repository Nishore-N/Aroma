import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../state/home_provider.dart';
import '../../widgets/popular_recipe_tile.dart';
import '../../widgets/recipe_card.dart';
import '../add_ingredients/ingredient_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  late final ScrollController _scrollController;
  int _currentPage = 0;
  int _visibleRecipeCount = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset <= 50) {
      setState(() {
        // Reset back to base preview count (2 or less if fewer recipes)
        _visibleRecipeCount = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider provider, _) {
        if (provider.recipes.isEmpty && !provider.isLoading && provider.error == null) {
          provider.loadRecipes();
        }

        final int totalRecipes = provider.recipes.length;
        int previewCount = 0;
        if (totalRecipes > 0) {
          final int minVisible = totalRecipes >= 2 ? 2 : 1;
          if (_visibleRecipeCount < minVisible) {
            _visibleRecipeCount = minVisible;
          } else if (_visibleRecipeCount > totalRecipes) {
            _visibleRecipeCount = totalRecipes;
          }

          // Show up to 2 extra faded preview cards beyond the visible ones
          previewCount = _visibleRecipeCount;
          final int remaining = totalRecipes - _visibleRecipeCount;
          if (remaining > 0) {
            final int extra = remaining >= 2 ? 2 : remaining;
            previewCount += extra;
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFFFFBF6), // almost white with a hint of orange
                    Color(0xFFFFF3E6), // very soft pastel orange
                  ],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(child: Text(provider.error!))
                        : CustomScrollView(
                            controller: _scrollController,
                            slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.headlineMedium,
                                            children: [
                                              const TextSpan(text: 'Welcome '),
                                              const TextSpan(
                                                text: '👋',
                                                style: TextStyle(fontSize: 28),
                                              ),
                                              TextSpan(
                                                text: '\nVelmurugan',
                                                style: TextStyle(
                                                  color: const Color(0xFFFF4500), // Red-orange color
                                                  fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize != null 
                                                      ? Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.2 
                                                      : 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0), // Increased top padding to align with text
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.shopping_basket_outlined,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 24), // Increased space between icons
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.notifications_outlined,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 4), // Additional padding from the edge
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Builder(
                                    builder: (BuildContext context) {
                                      final double screenWidth =
                                          MediaQuery.of(context).size.width;
                                      final double cardWidth =
                                          screenWidth * _pageController.viewportFraction;
                                      final double cardHeight =
                                          cardWidth * 3 / 2;

                                      return SizedBox(
                                        height: cardHeight,
                                        child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: provider.recipes.length,
                                      physics: const BouncingScrollPhysics(),
                                      onPageChanged: (int index) {
                                        setState(() {
                                          _currentPage = index;
                                        });
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final recipe = provider.recipes[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: AnimatedScale(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            scale: index == _currentPage
                                                ? 1.0
                                                : 0.92,
                                            child: SizedBox(
                                              width: cardWidth,
                                              height: cardHeight,
                                              child: RecipeCard(
                                                recipe: recipe,
                                                isActive: index == _currentPage,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        'Explore popular recipes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon:
                                            const Icon(Icons.search, size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.only(bottom: 8),
                              sliver: SliverMasonryGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childCount: previewCount,
                                itemBuilder: (BuildContext context, int index) {
                                  // Safely get the recipe or return an empty container if index is invalid
                                  if (index >= provider.recipes.length) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  final recipe = provider.recipes[index];
                                  final bool isLarge = index.isEven;
                                  final bool isPreview = index >= _visibleRecipeCount;

                                  if (!isPreview) {
                                    return PopularRecipeTile(
                                      recipe: recipe,
                                      isLarge: isLarge,
                                    );
                                  }

                                  // Preview cards: only fade the bottom edge using a soft dark gradient overlay
                                  return Stack(
                                    children: <Widget>[
                                      PopularRecipeTile(
                                        recipe: recipe,
                                        isLarge: isLarge,
                                      ),
                                      IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.25),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _visibleRecipeCount >= totalRecipes
                                        ? null
                                        : () {
                                            setState(() {
                                              final int remaining =
                                                  totalRecipes - _visibleRecipeCount;
                                              final int step = remaining >= 2 ? 2 : remaining;
                                              _visibleRecipeCount += step;
                                            });
                                          },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: Colors.grey.withOpacity(0.35),
                                        width: 1.1,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      overlayColor:
                                          Colors.black.withOpacity(0.04),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('Show All Categories'),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home_filled,
                    color: Color(0xFFFC6E3C),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext _) => const IngredientEntryScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFC6E3C),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

