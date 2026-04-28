import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';

class CountryOptionTile extends StatelessWidget {
  final String name;
  final String flagEmoji;
  final String dialCode;
  final bool isSelected;
  final VoidCallback onTap;

  const CountryOptionTile({
    super.key,
    required this.name,
    required this.flagEmoji,
    required this.dialCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? AppColors.primaryLight : AppColors.surface;
    final borderColor = isSelected ? AppColors.primary : AppColors.divider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Text(
                  flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        dialCode,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
