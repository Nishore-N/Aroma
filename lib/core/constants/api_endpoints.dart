import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Update port if your json-server or backend runs on a different one.
  static const String baseUrl = 'http://10.124.97.169:3000';

  static const String ingredients = '$baseUrl/ingredients';
  static const String recipes = '$baseUrl/recipes';
  static const String cookingSteps = '$baseUrl/cookingSteps';
  static const String cookingStepsDetailed = '$baseUrl/cookingStepsDetailed';
  static const String cookware = '$baseUrl/cookware';
  static const String ingredientData = '$baseUrl/ingredientData';
  static const String reviewData = '$baseUrl/reviewData';
  static const String similarRecipes = '$baseUrl/similarRecipes';
  static const String preferences = '$baseUrl/preferences';

  // Helper for logging in debug mode
  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      debugPrint('API base URL: $baseUrl');
    }
  }
}

