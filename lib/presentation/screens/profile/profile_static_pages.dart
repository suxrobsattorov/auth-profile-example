import 'package:flutter/material.dart';

import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileStaticPageScaffold(
      title: 'Bildirishnomalar',
      assetPath: AppConstants.notification,
      fallbackIcon: Icons.notifications_none_rounded,
      child: _CenteredMessageCard(
        title: 'Bildirishnomalar hali mavjud emas',
        description:
            'Bu bo‘lim keyinroq to‘ldiriladi. Hozircha yangi bildirishnomalar yo‘q.',
      ),
    );
  }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileStaticPageScaffold(
      title: 'Yordam markazi',
      assetPath: AppConstants.support,
      fallbackIcon: Icons.support_agent_rounded,
      child: _InfoCard(
        title: 'Bog‘lanish raqami',
        content: '+998 (88) 888-88-88',
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileStaticPageScaffold(
      title: 'Biz haqimizda',
      assetPath: AppConstants.info,
      fallbackIcon: Icons.info_outline_rounded,
      child: _InfoCard(
        title: 'Ilova haqida',
        content:
            'Bu ilova foydalanuvchi profili, autentifikatsiya va asosiy account boshqaruv jarayonlarini sodda va qulay ko‘rinishda taqdim etish uchun tayyorlangan demo yechimdir.',
      ),
    );
  }
}

class _ProfileStaticPageScaffold extends StatelessWidget {
  final String title;
  final String assetPath;
  final IconData fallbackIcon;
  final Widget child;

  const _ProfileStaticPageScaffold({
    required this.title,
    required this.assetPath,
    required this.fallbackIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundStrong, AppColors.background],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AssetIcon(
                            assetPath: assetPath,
                            size: 28,
                            color: AppColors.primaryDark,
                            fallback: fallbackIcon,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      child,
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

class _CenteredMessageCard extends StatelessWidget {
  final String title;
  final String description;

  const _CenteredMessageCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
