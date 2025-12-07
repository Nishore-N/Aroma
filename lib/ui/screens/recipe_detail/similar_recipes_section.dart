import 'package:flutter/material.dart';

class SimilarRecipesSection extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;

  const SimilarRecipesSection({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ---- Title ----
        const Text(
          "More recipes like this",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 18),

        /// ---- GRID CARD UI ----
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: 0.60, // controls height
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// --- Recipe Image ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    recipe['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 10),

                /// --- Name ---
                Text(
                  recipe['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                /// --- Category & Type ---
                Text(
                  "${recipe['tag']} • ${recipe['type']}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                /// ---- Time + Cook Count ----
                Text(
                  "${recipe['time']}  •  ${recipe['cooked']} times",
                  style: const TextStyle(
                    color: Color(0xFFFF6A45),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}