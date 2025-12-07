import 'package:flutter/material.dart';

class ReviewSection extends StatelessWidget {
  final double rating;
  final int totalComments;
  final int totalReviewed;
  final List<Map<String, String>> reviews;

  const ReviewSection({
    super.key,
    required this.rating,
    required this.totalComments,
    required this.totalReviewed,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ---- HEADER (Reviews + Rating) ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            Row(
              children: [
                const Text(
                  "Rating",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// ---- META TEXT ----
        Text(
          "$totalComments Comments  •  Reviewed by $totalReviewed",
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 22),

        /// ---- FIRST 2 REVIEWS ----
        Column(
          children: reviews.take(2).map((review) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(review["avatar"] ?? ""),
                  ),

                  const SizedBox(width: 14),

                  /// Name + Comment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review["name"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          review["comment"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        /// ---- ACTION BUTTONS ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _actionButton(Icons.edit, "Write review"),
            _actionButton(Icons.read_more, "Read More"),
          ],
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  /// ---- REUSABLE BUTTON ----
  Widget _actionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6A45), size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFFF6A45),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}