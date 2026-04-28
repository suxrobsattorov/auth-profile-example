import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/presentation/screens/auth/otp_page.dart';
import 'package:auth_profile_example/presentation/widgets/background_orb.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/login_form.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/or_divider.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/social_auth_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _openOtp(
    BuildContext context,
    String phoneNumber,
    CountryOption country,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpPage(
          phoneNumber: phoneNumber,
          countryName: country.name,
          flagEmoji: country.flagEmoji,
        ),
      ),
    );
  }

  void _showSocialMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu tugma hozircha demo rejimida turibdi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStrong, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const BackgroundOrb(
              top: -90,
              right: -40,
              size: 220,
              color: AppColors.primaryLight,
            ),
            const BackgroundOrb(
              bottom: 140,
              left: -70,
              size: 180,
              color: AppColors.secondaryLight,
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        Image.asset(
                          AppConstants.logoAsset,
                          width: 155,
                          height: 155,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Telefon orqali kiring',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Davlatni tanlang, raqamingizni kiriting va bir martalik kodni tasdiqlang.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 30,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              LoginForm(
                                onContinue: (phoneNumber, country) {
                                  _openOtp(context, phoneNumber, country);
                                },
                              ),
                              const SizedBox(height: 24),
                              const OrDivider(),
                              const SizedBox(height: 24),
                              SocialAuthButton(
                                label: 'Google orqali kirish',
                                imagePath: AppConstants.googleAsset,
                                onTap: () => _showSocialMessage(context),
                              ),
                              const SizedBox(height: 16),
                              SocialAuthButton(
                                label: 'Apple orqali kirish',
                                imagePath: AppConstants.appleAsset,
                                onTap: () => _showSocialMessage(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
