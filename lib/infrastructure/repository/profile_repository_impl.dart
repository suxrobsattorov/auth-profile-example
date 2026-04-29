import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:auth_profile_example/domain/interface/profile.dart';
import 'package:auth_profile_example/domain/model/profile_update_request.dart';
import 'package:auth_profile_example/domain/model/user_profile.dart';
import 'package:auth_profile_example/infrastructure/network/dio_client.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

  @override
  Future<UserProfile> getProfile() async {
    final response = await _dioClient.client(requireAuth: true).get(
          '/api/users/profile/',
        );

    return UserProfile.fromJson(_parseJson(response.data));
  }

  @override
  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    final formData = FormData.fromMap({
      'first_name': request.firstName.trim(),
      'last_name': request.lastName.trim(),
      'country': request.country.trim(),
      if (request.includeEmail) 'email': request.email.trim(),
    });

    if (request.avatarFile != null) {
      final fileName = request.avatarFile!.uri.pathSegments.isNotEmpty
          ? request.avatarFile!.uri.pathSegments.last
          : 'avatar.jpg';

      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            request.avatarFile!.path,
            filename: fileName,
          ),
        ),
      );
    }

    final response = await _dioClient.client(requireAuth: true).patch(
          '/api/users/profile/',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

    return UserProfile.fromJson(_parseJson(response.data));
  }

  Map<String, dynamic> _parseJson(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    throw FormatException('Unexpected response type: ${raw.runtimeType}');
  }
}
