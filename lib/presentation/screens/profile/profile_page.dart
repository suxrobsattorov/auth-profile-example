import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/application/auth/auth_bloc.dart';
import 'package:auth_profile_example/application/auth/auth_event.dart';
import 'package:auth_profile_example/application/auth/auth_state.dart';
import 'package:auth_profile_example/application/profile/profile_bloc.dart';
import 'package:auth_profile_example/application/profile/profile_event.dart';
import 'package:auth_profile_example/application/profile/profile_state.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
import 'package:auth_profile_example/domain/di/injection.dart';
import 'package:auth_profile_example/domain/model/user_profile.dart';
import 'package:auth_profile_example/presentation/screens/profile/profile_edit_page.dart';
import 'package:auth_profile_example/presentation/screens/profile/profile_static_pages.dart';
import 'package:auth_profile_example/presentation/screens/profile/widgets/profile_info_row.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

import '../../widgets/background_orb.dart';

class ProfilePage extends StatefulWidget {
  final String phoneNumber;
  final String countryName;
  final String flagEmoji;
  final bool isActive;

  const ProfilePage({
    super.key,
    required this.phoneNumber,
    required this.countryName,
    required this.flagEmoji,
    this.isActive = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = sl<ProfileBloc>();

    if (widget.isActive) {
      _profileBloc.add(const ProfileRequested());
    }
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _profileBloc.add(const ProfileRequested());
    }
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  void _openProfileEdit(BuildContext context, UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _profileBloc,
          child: ProfileEditPage(
            initialFirstName: profile.firstName,
            initialLastName: profile.lastName,
            initialEmail: profile.email ?? '',
            initialLocation: profile.country,
            initialAvatarUrl: profile.avatar,
          ),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  void _openHelpCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutPage()),
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
                            'Yo\'q',
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

    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = context.select<AuthBloc, bool>(
      (bloc) => bloc.state is AuthLogoutInProgress,
    );

    return BlocProvider.value(
      value: _profileBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              if (state.errorMessage == null) return;
              if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
              context.read<ProfileBloc>().add(const ProfileFeedbackCleared());
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final profile = state.profile;
            final phoneNumber = profile?.phone ?? widget.phoneNumber;
            final formattedPhoneNumber =
                AppPhoneNumberFormatter.tryFormatSupportedInternational(
              phoneNumber,
            );
            final isHeaderLoading = state.isLoading;
            final avatarUrl = _resolveAvatarUrl(profile?.avatar);
            final country = _displayValue(profile?.country);
            final email = _displayValue(profile?.email);
            final authMethod = _formatAuthMethods(profile?.authMethods);
            final createdAt = _formatCreatedAt(profile?.createdAt);
            final lastLogin = _formatLastLogin(profile?.lastLogin);

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                AppColors.background,
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
                                    CircleAvatar(
                                      radius: 42,
                                      backgroundColor: AppColors.primaryLight,
                                      backgroundImage: avatarUrl != null
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: avatarUrl == null
                                          ? const AssetIcon(
                                              assetPath:
                                                  AppConstants.profileIconAsset,
                                              size: 35,
                                              color: AppColors.primaryDark,
                                              fallback: Icons.person_rounded,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _ProfileShimmerOverlay(
                                      enabled: isHeaderLoading,
                                      borderRadius: 14,
                                      child: Text(
                                        profile?.resolvedFullName.isNotEmpty ==
                                                true
                                            ? profile!.resolvedFullName
                                            : 'Shaxsiy profil',
                                        style: AppTextStyles.headlineSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _ProfileShimmerOverlay(
                                      enabled: isHeaderLoading,
                                      borderRadius: 10,
                                      child: Text(
                                        formattedPhoneNumber,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _ProfileShimmerOverlay(
                                      enabled: isHeaderLoading,
                                      borderRadius: 99,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          'Faol foydalanuvchi',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ProfileInfoRow(
                                      title: 'Hudud',
                                      value: country,
                                    ),
                                    const SizedBox(height: 10),
                                    ProfileInfoRow(
                                      title: 'Email',
                                      value: email,
                                    ),
                                    const SizedBox(height: 10),
                                    ProfileInfoRow(
                                      title: 'Kirish usuli',
                                      value: authMethod,
                                    ),
                                    const SizedBox(height: 10),
                                    ProfileInfoRow(
                                      title: 'Ro‘yxatdan o‘tgan sana',
                                      value: createdAt,
                                    ),
                                    const SizedBox(height: 10),
                                    ProfileInfoRow(
                                      title: 'Oxirgi kirish',
                                      value: lastLogin,
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
                      title: 'Profilni tahrirlash',
                      onTap: profile == null
                          ? null
                          : () => _openProfileEdit(context, profile),
                    ),
                    const SizedBox(height: 10),
                    _ProfileActionButton(
                      icon: AppConstants.notification,
                      title: 'Bildirishnomalar',
                      onTap: () => _openNotifications(context),
                    ),
                    const SizedBox(height: 10),
                    _ProfileActionButton(
                      icon: AppConstants.support,
                      title: 'Yordam markazi',
                      onTap: () => _openHelpCenter(context),
                    ),
                    const SizedBox(height: 10),
                    _ProfileActionButton(
                      icon: AppConstants.info,
                      title: 'Biz haqimizda',
                      onTap: () => _openAbout(context),
                    ),
                    const SizedBox(height: 10),
                    _ProfileActionButton(
                      icon: AppConstants.logout,
                      title: 'Chiqish',
                      isLogout: true,
                      onTap:
                          isLoggingOut ? null : () => _showLogoutSheet(context),
                    ),
                    const SizedBox(height: 115),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _displayValue(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String _formatAuthMethods(List<String>? methods) {
    if (methods == null || methods.isEmpty) return '-';

    final labels = methods.map((method) {
      switch (method.toLowerCase()) {
        case 'phone':
          return 'Telefon + OTP';
        case 'email':
          return 'Email';
        default:
          final normalized = method.replaceAll('_', ' ').trim();
          if (normalized.isEmpty) return method;
          return normalized[0].toUpperCase() + normalized.substring(1);
      }
    }).toSet();

    return labels.join(', ');
  }

  String _formatCreatedAt(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    return '${local.day} ${_monthName(local.month)} ${local.year}';
  }

  String _formatLastLogin(DateTime? value) {
    if (value == null) return '-';

    final local = value.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    if (_isSameDay(local, DateTime.now())) {
      return 'Bugun $time';
    }

    return '${local.day} ${_monthName(local.month)}, $time';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int month) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];

    return months[month - 1];
  }

  String? _resolveAvatarUrl(String? value) {
    final avatar = value?.trim() ?? '';
    if (avatar.isEmpty) return null;

    final uri = Uri.tryParse(avatar);
    if (uri != null && uri.hasScheme) {
      return avatar;
    }

    return '${AppConstants.baseUrl}$avatar';
  }
}

class _ProfileShimmerOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double borderRadius;

  const _ProfileShimmerOverlay({
    required this.child,
    required this.enabled,
    required this.borderRadius,
  });

  @override
  State<_ProfileShimmerOverlay> createState() => _ProfileShimmerOverlayState();
}

class _ProfileShimmerOverlayState extends State<_ProfileShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerOffset = (_controller.value * 2.4) - 1.2;

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(shimmerOffset - 1, 0),
                end: Alignment(shimmerOffset + 1, 0),
                colors: [
                  Colors.white.withValues(alpha: 0.88),
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.98),
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              ).createShader(bounds);
            },
            child: child,
          ),
        );
      },
      child: widget.child,
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
