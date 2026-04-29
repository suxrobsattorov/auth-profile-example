import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
import 'package:auth_profile_example/presentation/screens/auth/login_page.dart';
import 'package:auth_profile_example/presentation/screens/profile/profile_edit_page.dart';
import 'package:auth_profile_example/presentation/screens/profile/widgets/profile_info_row.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

import '../../widgets/background_orb.dart';

class ProfilePage extends StatelessWidget {
  final String phoneNumber;
  final String countryName;
  final String flagEmoji;

  const ProfilePage({
    super.key,
    required this.phoneNumber,
    required this.countryName,
    required this.flagEmoji,
  });

  void _openProfileEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(
          initialLocation: countryName,
        ),
      ),
    );
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const AssetIcon(
                    assetPath: AppConstants.logout,
                    color: AppColors.primaryDark,
                    fallback: Icons.add,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Rostdan ham profildan chiqishni istaysizmi?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Agar chiqib ketsangiz, qayta kirish uchun tasdiqlash kodini yuborishingiz kerak bo‘ladi.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryLight,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                          ),
                          child: Text(
                            "Yo'q",
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ha',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhoneNumber =
        AppPhoneNumberFormatter.tryFormatSupportedInternational(phoneNumber);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.backgroundStrong,
                        AppColors.background
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      const BackgroundOrb(
                        top: -100,
                        right: -60,
                        size: 200,
                        color: AppColors.primaryLight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.primaryLight,
                              child: AssetIcon(
                                assetPath: AppConstants.profileIconAsset,
                                size: 35,
                                color: AppColors.primaryDark,
                                fallback: Icons.person_rounded,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Shaxsiy profil',
                              style: AppTextStyles.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedPhoneNumber,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'Faol foydalanuvchi',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ProfileInfoRow(
                              title: 'Hudud',
                              value: countryName,
                            ),
                            const SizedBox(height: 10),
                            const ProfileInfoRow(
                              title: 'Email',
                              value: '-',
                            ),
                            const SizedBox(height: 10),
                            const ProfileInfoRow(
                              title: 'Kirish usuli',
                              value: 'Telefon + OTP',
                            ),
                            const SizedBox(height: 10),
                            const ProfileInfoRow(
                              title: 'Ro‘yxatdan o‘tgan sana',
                              value: '12 Fevral 2026',
                            ),
                            const SizedBox(height: 10),
                            const ProfileInfoRow(
                              title: 'Oxirgi kirish',
                              value: 'Bugun 14:20',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            _ProfileActionButton(
              icon: AppConstants.edit,
              title: "Profilni tahrirlash",
              onTap: () => _openProfileEdit(context),
            ),
            const SizedBox(height: 10),
            const _ProfileActionButton(
              icon: AppConstants.notification,
              title: "Bildirishnomalar",
            ),
            const SizedBox(height: 10),
            const _ProfileActionButton(
              icon: AppConstants.support,
              title: "Yordam markazi",
            ),
            const SizedBox(height: 10),
            const _ProfileActionButton(
              icon: AppConstants.info,
              title: "Biz haqimizda",
            ),
            const SizedBox(height: 10),
            _ProfileActionButton(
              icon: AppConstants.logout,
              title: "Chiqish",
              isLogout: true,
              onTap: () => _showLogoutSheet(context),
            ),
            const SizedBox(height: 115),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String icon;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.title,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                AppColors.backgroundStrong,
                AppColors.background,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                spreadRadius: 0.3,
                offset: const Offset(0, 1),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AssetIcon(
                assetPath: icon,
                color: isLogout ? AppColors.error : AppColors.black,
                fallback: Icons.add,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isLogout ? AppColors.error : AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isLogout ? AppColors.error : AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
