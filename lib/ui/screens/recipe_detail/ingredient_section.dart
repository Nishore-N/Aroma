import 'package:flutter/material.dart';

class IngredientSection extends StatelessWidget {
  final int servings;
  final Function(int) onServingChange;
  final List<Map<String, dynamic>> ingredientData;

  const IngredientSection({
    super.key,
    required this.servings,
    required this.onServingChange,
    required this.ingredientData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingredients",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$servings Servings",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            IngredientStepper(
              servings: servings,
              onChanged: onServingChange,
            ),
          ],
        ),

        const SizedBox(height: 22),

        Column(
          children: ingredientData.map(
            (item) => IngredientTile(
              name: item['name'],
              quantity: item['qty'],
              iconPath: item['icon'],
              spicy: item['spicy'] ?? false,
            ),
          ).toList(),
        ),
      ],
    );
  }
}

class IngredientTile extends StatelessWidget {
  final String name;
  final String quantity;
  final bool spicy;
  final String iconPath;

  const IngredientTile({
    required this.name,
    required this.quantity,
    required this.iconPath,
    this.spicy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Text(iconPath, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(quantity,
                    style: TextStyle(
                        color: Colors.orange.shade600, fontSize: 13)),
              ],
            ),
          ),
          if (spicy)
            Icon(Icons.local_fire_department, color: Colors.red.shade400)
        ],
      ),
    );
  }
}

class IngredientStepper extends StatelessWidget {
  final int servings;
  final Function(int) onChanged;

  const IngredientStepper({
    super.key,
    required this.servings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 194,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFA58A),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(servings > 1 ? servings - 1 : 1),
            child: Container(
              width: 55,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "−",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6A45),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                "$servings",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () => onChanged(servings + 1),
            child: Container(
              width: 55,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6A45),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}