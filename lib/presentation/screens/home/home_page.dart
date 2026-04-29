import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              subtitle: 'Asosiy qismga o‘tdingiz.',
            ),
            const SizedBox(height: 16),
            const InfoCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Pastdagi navigation ishlaydi',
              subtitle: 'bemalol almashtiring.',
            ),
            const SizedBox(height: 24),
            _StoreSection(onLaunch: _launchUrl),
          ],
        ),
      ),
    );
  }
}

class _StoreSection extends StatelessWidget {
  final Future<void> Function(String url) onLaunch;

  const _StoreSection({required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: AssetIcon(
                    assetPath: AppConstants.homeIconAsset,
                    size: 20,
                    color: AppColors.primaryDark,
                    fallback: Icons.download_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ilovani yuklab oling', style: AppTextStyles.titleMedium),
                    SizedBox(height: 2),
                    Text(
                      'OkeyBo ilovasini hoziroq o\'rnating',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StoreBadge(
                  assetPath: AppConstants.googlePlay,
                  onTap: () => onLaunch(AppConstants.googlePlayUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StoreBadge(
                  assetPath: AppConstants.appStore,
                  onTap: () => onLaunch(AppConstants.appStoreUrl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _StoreBadge({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }
}
