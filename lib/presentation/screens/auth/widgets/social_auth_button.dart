import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;
  final bool isDark;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.black : AppColors.white;
    final foregroundColor = isDark ? AppColors.white : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.black : AppColors.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
