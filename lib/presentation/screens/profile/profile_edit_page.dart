import 'dart:io';

import 'package:flutter/material.dart';
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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
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
              email: _emailController.text,
              includeEmail: _emailController.text.trim().isNotEmpty ||
                  widget.initialEmail.trim().isNotEmpty,
              country: _locationController.text,
              avatarFile: _pickedImage,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select(
      (ProfileBloc bloc) => bloc.state.isSaving,
    );

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<ProfileBloc>().add(const ProfileFeedbackCleared());
          return;
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          context.read<ProfileBloc>().add(const ProfileFeedbackCleared());
          Navigator.of(context).pop();
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
                        label: 'Email',
                        controller: _emailController,
                        hintText: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: 35),
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

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

  const _EditField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: AppColors.surfaceMuted,
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
