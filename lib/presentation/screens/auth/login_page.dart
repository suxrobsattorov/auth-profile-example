import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/application/auth/auth_bloc.dart';
import 'package:auth_profile_example/application/auth/auth_event.dart';
import 'package:auth_profile_example/application/auth/auth_state.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:alice/alice.dart';
import 'package:auth_profile_example/domain/di/injection.dart';
import 'package:auth_profile_example/presentation/screens/auth/otp_page.dart';
import 'package:auth_profile_example/presentation/screens/main/main_shell_page.dart';
import 'package:auth_profile_example/presentation/widgets/background_orb.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/login_form.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/or_divider.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/social_auth_button.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _pendingPhone;
  CountryOption? _pendingCountry;

  void _onContinue(String phoneNumber, CountryOption country) {
    _pendingPhone = phoneNumber;
    _pendingCountry = country;
    context.read<AuthBloc>().add(AuthRequestOtp(phoneNumber));
  }

  void _showSocialMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu tugma hozircha demo rejimida turibdi.')),
    );
  }

  void _onGoogleSignIn() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  Future<void> _openAuthorizedHome(BuildContext context) async {
    final storage = sl<TokenStorage>();
    final phone = await storage.getPhone() ?? '';
    final countryName = await storage.getCountryName() ?? '';
    final flagEmoji = await storage.getFlagEmoji() ?? '';

    if (!context.mounted) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShellPage(
          phoneNumber: phone,
          countryName: countryName,
          flagEmoji: flagEmoji,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpPage(
                phoneNumber: _pendingPhone!,
                countryName: _pendingCountry!.name,
                flagEmoji: _pendingCountry!.flagEmoji,
              ),
            ),
          );
        } else if (state is AuthSuccess) {
          _openAuthorizedHome(context);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isGoogleLoading = state is AuthGoogleLoading;
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
                              GestureDetector(
                                onTap: () => sl<Alice>().showInspector(),
                                child: Image.asset(
                                  AppConstants.logoAsset,
                                  width: 155,
                                  height: 155,
                                  fit: BoxFit.contain,
                                ),
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
                                      isLoading: isLoading,
                                      onContinue: _onContinue,
                                    ),
                                    const SizedBox(height: 24),
                                    const OrDivider(),
                                    const SizedBox(height: 24),
                                    SocialAuthButton(
                                      label: 'Google orqali kirish',
                                      imagePath: AppConstants.googleAsset,
                                      onTap: _onGoogleSignIn,
                                      isLoading: isGoogleLoading,
                                    ),
                                    const SizedBox(height: 16),
                                    SocialAuthButton(
                                      label: 'Apple orqali kirish',
                                      imagePath: AppConstants.appleAsset,
                                      onTap: () => _showSocialMessage(context),
                                      isLoading: false,
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
        },
      ),
    );
  }
}
