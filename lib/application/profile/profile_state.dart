import 'package:equatable/equatable.dart';

import 'package:auth_profile_example/domain/model/user_profile.dart';

enum ProfileSuccessType {
  profileUpdated,
  emailCodeSent,
  emailUpdated,
}

class ProfileState extends Equatable {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final bool isSendingEmailCode;
  final bool isVerifyingEmailCode;
  final String? pendingEmail;
  final String? errorMessage;
  final String? successMessage;
  final ProfileSuccessType? successType;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.isSendingEmailCode = false,
    this.isVerifyingEmailCode = false,
    this.pendingEmail,
    this.errorMessage,
    this.successMessage,
    this.successType,
  });

  bool get isInitialLoading => isLoading && profile == null;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    bool? isSendingEmailCode,
    bool? isVerifyingEmailCode,
    String? pendingEmail,
    bool clearPendingEmail = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    ProfileSuccessType? successType,
    bool clearSuccessType = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSendingEmailCode: isSendingEmailCode ?? this.isSendingEmailCode,
      isVerifyingEmailCode: isVerifyingEmailCode ?? this.isVerifyingEmailCode,
      pendingEmail:
          clearPendingEmail ? null : (pendingEmail ?? this.pendingEmail),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      successType: clearSuccessType ? null : (successType ?? this.successType),
    );
  }

  @override
  List<Object?> get props => [
        profile,
        isLoading,
        isSaving,
        isSendingEmailCode,
        isVerifyingEmailCode,
        pendingEmail,
        errorMessage,
        successMessage,
        successType,
      ];
}
