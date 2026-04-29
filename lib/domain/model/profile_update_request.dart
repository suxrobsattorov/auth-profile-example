import 'dart:io';

import 'package:equatable/equatable.dart';

class ProfileUpdateRequest extends Equatable {
  final String firstName;
  final String lastName;
  final String country;
  final File? avatarFile;

  const ProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.country,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        country,
        avatarFile?.path,
      ];
}
