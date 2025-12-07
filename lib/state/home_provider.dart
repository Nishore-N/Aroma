import 'package:flutter/foundation.dart';

import '../core/constants/api_endpoints.dart';
import '../data/models/recipe_model.dart';
import '../data/services/api_client.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  final List<RecipeModel> _recipes = <RecipeModel>[];
  final ApiClient _apiClient = ApiClient();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RecipeModel> get recipes => List<RecipeModel>.unmodifiable(_recipes);

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<dynamic> list =
          await _apiClient.getList(ApiEndpoints.recipes);

      _recipes
        ..clear()
        ..addAll(
          list
              .whereType<Map<String, dynamic>>()
              .map(RecipeModel.fromJson),
        );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSaved(String id) async {
    for (int i = 0; i < _recipes.length; i++) {
      final recipe = _recipes[i];
      if (recipe.id == id) {
        final bool newSaved = !recipe.isSaved;

        // Optimistic local update
        _recipes[i] = RecipeModel(
          id: recipe.id,
          title: recipe.title,
          cuisine: recipe.cuisine,
          cookTime: recipe.cookTime,
          image: recipe.image,
          isSaved: newSaved,
        );
        notifyListeners();

        // Persist to backend (json-server will patch db.json)
        try {
          await _apiClient.patch('${ApiEndpoints.recipes}/${recipe.id}',
              <String, dynamic>{'isSaved': newSaved});
        } catch (_) {
          // If patch fails, we keep the optimistic state for now.
        }
        break;
      }
    }
  }
}

