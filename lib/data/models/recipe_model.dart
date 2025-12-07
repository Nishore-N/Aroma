import 'package:flutter/foundation.dart';

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.cuisine,
    required this.cookTime,
    required this.image,
    this.isSaved = false,
  });

  final String id;
  final String title;
  final String cuisine;
  final int cookTime;
  final String image;
  final bool isSaved;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCookTime = json['cookTime'];
    int parsedCookTime;

    if (rawCookTime is int) {
      parsedCookTime = rawCookTime;
    } else if (rawCookTime is String) {
      parsedCookTime = int.tryParse(rawCookTime) ?? 0;
    } else {
      parsedCookTime = 0;
    }

    return RecipeModel(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '') as String,
      cuisine: (json['cuisine'] ?? '') as String,
      cookTime: parsedCookTime,
      image: (json['image'] ?? '') as String,
      isSaved: (json['isSaved'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'cuisine': cuisine,
      'cookTime': cookTime,
      'image': image,
      'isSaved': isSaved,
    };
  }
}
