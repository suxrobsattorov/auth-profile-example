import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
import 'package:auth_profile_example/domain/di/injection.dart';
import 'package:auth_profile_example/presentation/screens/home/widgets/info_card.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

class HomePage extends StatelessWidget {
  final String phoneNumber;
  final String flagEmoji;

  const HomePage({
    super.key,
    required this.phoneNumber,
    required this.flagEmoji,
  });

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhoneNumber =
        AppPhoneNumberFormatter.tryFormatSupportedInternational(phoneNumber);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$flagEmoji  OTP tasdiqlandi',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: AssetIcon(
                            assetPath: AppConstants.homeIconAsset,
                            size: 26,
                            color: AppColors.white,
                            fallback: Icons.home_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Tabriklaymiz',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Raqamingiz muvaffaqiyatli tasdiqlandi.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    formattedPhoneNumber,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const InfoCard(
              icon: Icons.shield_rounded,
              title: 'OTP muvaffaqiyatli tasdiqlandi',
              subtitle: 'Asosiy qismga o\'tdingiz.',
            ),
            const SizedBox(height: 16),
            const InfoCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Pastdagi navigation ishlaydi',
              subtitle: 'Bemalol almashtiring.',
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.bug_report_rounded,
              title: 'HTTP Inspector',
              subtitle: 'Barcha so\'rov va javoblarni ko\'rish.',
              onTap: () => sl<Alice>().showInspector(),
            ),
          ],
        ),
      ),
    );
  }
}
