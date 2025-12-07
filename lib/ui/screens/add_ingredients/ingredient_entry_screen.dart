import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'capture_preview_screen.dart';
import 'review_ingredients_screen.dart';

class IngredientEntryScreen extends StatelessWidget {
  const IngredientEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          /// --- Background ---
          Positioned.fill(
            child: Container(color: Colors.grey.shade300),
          ),

          /// --- Close Button ---
          Align(
            alignment: const Alignment(0, 0.2),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          /// --- Bottom Sheet ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 42),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Title
                    Text(
                      'Start Adding Ingredients',
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 26),

                    /// --- Action Icons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _OptionCard(
                          label: 'Search',
                          icon: Icons.search_rounded,
                          onTap: () {},
                        ),
                        _OptionCard(
                          label: 'Camera',
                          icon: Icons.camera_alt_rounded,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const CapturePreviewScreen(),
                            ));
                          },
                        ),
                        _OptionCard(
                          label: 'Gallery',
                          icon: Icons.photo_library_rounded,
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1200,
                              maxHeight: 1600,
                              imageQuality: 85,
                            );
                            
                            if (image != null && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ReviewIngredientsScreen(capturedImage: image),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// -------- Option Cards --------
class _OptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.body2.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}