//lib/ui/screens/cooking_steps/step_ingredients_bottomsheet.dart

import 'package:flutter/material.dart';

class StepIngredientsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;

  const StepIngredientsBottomSheet({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [

        /// =================== WHITE SHEET ===================
        Container(
          margin: const EdgeInsets.only(top: 60), // MORE SPACE for ❌
          padding: const EdgeInsets.fromLTRB(20, 38, 20, 30),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TITLE
              const Text(
                "Ingredients",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              /// ================= INGREDIENT BOX LIST =================
              ...ingredients.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFDCCD), // light orange border
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      /// ICON
                      Text(
                        item["icon"],
                        style: const TextStyle(fontSize: 30),
                      ),

                      const SizedBox(width: 14),

                      /// NAME + QTY
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["name"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["qty"],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// =================== CLOSE ❌ BUTTON ===================
        Positioned(
          top: 4, // MOVED MORE UP
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 46,
              width: 46,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}