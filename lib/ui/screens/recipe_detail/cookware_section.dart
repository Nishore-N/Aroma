import 'package:flutter/material.dart';

class CookwareSection extends StatelessWidget {
  final int servings;
  final List<String> cookwareItems;

  const CookwareSection({
    super.key,
    required this.servings,
    this.cookwareItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// --- TITLE ---
        const Text(
          "Cookware",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 6),

        /// --- SERVINGS SUB-TEXT ---
        Text(
          "$servings servings",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 14),

        /// --- TEXT LIST FROM BACKEND ---
        Text(
          cookwareItems.isEmpty
              ? "Pressure Cooker, Deep Pan / Kadai, Mixing Bowl, Strainer, "
                  "Ladle / Spoon, Knife & Cutting Board, Blender / Grinder, "
                  "Small Bowls, Tongs and Serving Bowl & Spoon"
              : cookwareItems.join(', '),
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}