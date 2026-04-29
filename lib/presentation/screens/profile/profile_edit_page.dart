import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:auth_profile_example/application/profile/profile_bloc.dart';
import 'package:auth_profile_example/application/profile/profile_event.dart';
import 'package:auth_profile_example/application/profile/profile_state.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/domain/model/profile_update_request.dart';
import 'package:auth_profile_example/presentation/widgets/common/app_button.dart';
import 'package:auth_profile_example/presentation/widgets/common/asset_icon.dart';

class ProfileEditPage extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialLocation;
  final String? initialAvatarUrl;

  const ProfileEditPage({
    super.key,
    this.initialFirstName = '',
    this.initialLastName = '',
    this.initialEmail = '',
    this.initialLocation = '',
    this.initialAvatarUrl,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _newEmailController;
  late final TextEditingController _emailCodeController;
  late final FocusNode _emailCodeFocusNode;

  File? _pickedImage;
  String? _pendingEmail;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _locationController = TextEditingController(text: widget.initialLocation);
    _newEmailController = TextEditingController(text: widget.initialEmail);
    _emailCodeController = TextEditingController();
    _emailCodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _newEmailController.dispose();
    _emailCodeController.dispose();
    _emailCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (file != null && mounted) {
        setState(() => _pickedImage = File(file.path));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ruxsat berilmadi yoki xatolik yuz berdi'),
        ),
      );
    }
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
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
                const Text(
                  'Rasm qo\'shish',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ImageSourceOption(
                        assetPath: AppConstants.camera,
                        label: 'Kamera',
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ImageSourceOption(
                        assetPath: AppConstants.galery,
                        label: 'Galereya',
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pickImage(ImageSource.gallery);
                        },
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
  }

  void _save() {
    FocusScope.of(context).unfocus();

    context.read<ProfileBloc>().add(
          ProfileUpdateSubmitted(
            ProfileUpdateRequest(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              country: _locationController.text,
              avatarFile: _pickedImage,
            ),
          ),
        );
  }

  void _requestEmailCode() {
    FocusScope.of(context).unfocus();

    final newEmail = _newEmailController.text.trim();

    if (newEmail.isEmpty) {
      _showSnackBar('Emailni kiriting.');
      return;
    }

    if (!_emailPattern.hasMatch(newEmail)) {
      _showSnackBar('Email formatini to\'g\'ri kiriting.');
      return;
    }

    context.read<ProfileBloc>().add(ProfileEmailCodeRequested(newEmail));
  }

  void _verifyEmailChange(String pendingEmail) {
    FocusScope.of(context).unfocus();

    final code = _emailCodeController.text.trim();

    if (code.length != 6) {
      _showSnackBar('6 xonali tasdiqlash kodini kiriting.');
      return;
    }

    context.read<ProfileBloc>().add(
          ProfileEmailVerifySubmitted(
            email: pendingEmail,
            code: code,
          ),
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileBloc>().state;
    final isSaving = state.isSaving;
    final isSendingEmailCode = state.isSendingEmailCode;
    final isVerifyingEmailCode = state.isVerifyingEmailCode;
    final pendingEmail = _pendingEmail?.trim() ?? '';
    final hasPendingEmail = pendingEmail.isNotEmpty;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage ||
          previous.successType != current.successType,
      listener: (context, state) {
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

        if (state.errorMessage != null) {
          _showSnackBar(state.errorMessage!);
          context.read<ProfileBloc>().add(const ProfileFeedbackCleared());
          return;
        }

        if (state.successMessage != null && state.successType != null) {
          if (state.successType == ProfileSuccessType.emailCodeSent) {
            setState(() {
              _pendingEmail = _newEmailController.text.trim();
            });
            _emailCodeController.clear();
            _emailCodeFocusNode.requestFocus();
          } else if (state.successType == ProfileSuccessType.emailUpdated) {
            setState(() {
              _newEmailController.text =
                  state.profile?.email?.trim() ?? pendingEmail;
              _emailCodeController.clear();
              _pendingEmail = null;
            });
          }

          _showSnackBar(state.successMessage!);
          context.read<ProfileBloc>().add(const ProfileFeedbackCleared());

          if (state.successType == ProfileSuccessType.profileUpdated) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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
          title: const Text(
            'Profilni tahrirlash',
            style: AppTextStyles.titleLarge,
          ),
        ),
        body: SafeArea(
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundStrong, AppColors.background],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarSection(
                    pickedImage: _pickedImage,
                    initialAvatarUrl: widget.initialAvatarUrl,
                    onPickImage: _showImageSourceSheet,
                  ),
                  const SizedBox(height: 28),
                  _SectionCard(
                    children: [
                      const Text(
                        'Asosiy ma\'lumotlar',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Profil rasmi, ism va hudud shu bo\'lim orqali yangilanadi.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      _EditField(
                        label: 'Ism',
                        controller: _firstNameController,
                        hintText: 'Ismingizni kiriting',
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 10),
                      _EditField(
                        label: 'Familiya',
                        controller: _lastNameController,
                        hintText: 'Familiyangizni kiriting',
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 10),
                      _EditField(
                        label: 'Hudud',
                        controller: _locationController,
                        hintText: 'Hududingizni kiriting',
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 20,
                    children: [
                      const Text(
                        'Emailni o\'zgartirish',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Email alohida tasdiqlanadi. Kod kiritgan email manzilingizga yuboriladi.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      _EditField(
                        label: 'Email',
                        controller: _newEmailController,
                        hintText: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      if (!hasPendingEmail) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Tasdiqlash kodini yuborish',
                          onPressed: isSendingEmailCode || isVerifyingEmailCode
                              ? null
                              : _requestEmailCode,
                          isLoading: isSendingEmailCode,
                          height: 52,
                        ),
                      ],
                      if (hasPendingEmail) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emailni tasdiqlash',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kod $pendingEmail manziliga yuborildi.',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              _EditField(
                                label: 'Tasdiqlash kodi',
                                controller: _emailCodeController,
                                hintText: '123456',
                                keyboardType: TextInputType.number,
                                focusNode: _emailCodeFocusNode,
                                maxLength: 6,
                                showLabel: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                              ),
                              const SizedBox(height: 10),
                              AppButton(
                                label: 'Emailni tasdiqlash',
                                onPressed: isVerifyingEmailCode
                                    ? null
                                    : () => _verifyEmailChange(pendingEmail),
                                isLoading: isVerifyingEmailCode,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Saqlash',
                    onPressed: isSaving ? null : _save,
                    isLoading: isSaving,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final File? pickedImage;
  final String? initialAvatarUrl;
  final VoidCallback onPickImage;

  const _AvatarSection({
    required this.pickedImage,
    required this.initialAvatarUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = _resolveAvatarUrl(initialAvatarUrl);
    final ImageProvider<Object>? backgroundImage = pickedImage != null
        ? FileImage(pickedImage!)
        : resolvedAvatarUrl != null
            ? NetworkImage(resolvedAvatarUrl)
            : null;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 63,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? const AssetIcon(
                    assetPath: AppConstants.profileIconAsset,
                    size: 52,
                    color: AppColors.primaryDark,
                    fallback: Icons.person_rounded,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: -2,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const AssetIcon(
                  assetPath: AppConstants.camera,
                  size: 18,
                  color: AppColors.primary,
                  fallback: Icons.camera_alt_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const _SectionCard({
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
        children: children,
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AssetIcon(
                    assetPath: assetPath,
                    size: 24,
                    color: AppColors.primaryDark,
                    fallback: Icons.image_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool showLabel;

  const _EditField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.maxLength,
    this.inputFormatters,
    this.contentPadding,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: AppColors.surfaceMuted,
            contentPadding: contentPadding,
          ),
        ),
      ],
    );
  }
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
