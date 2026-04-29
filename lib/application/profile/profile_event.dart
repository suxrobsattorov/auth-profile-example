import 'package:equatable/equatable.dart';

import 'package:auth_profile_example/domain/model/profile_update_request.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileUpdateSubmitted extends ProfileEvent {
  final ProfileUpdateRequest request;

  const ProfileUpdateSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class ProfileFeedbackCleared extends ProfileEvent {
  const ProfileFeedbackCleared();
}
