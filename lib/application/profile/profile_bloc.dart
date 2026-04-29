import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/domain/interface/profile.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository _repository;

  ProfileBloc({required IProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
    on<ProfileFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoading) return;

    debugPrint('[ProfileBloc] ProfileRequested');
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    try {
      final profile = await _repository.getProfile();
      emit(state.copyWith(
        profile: profile,
        isLoading: false,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ));
    } on DioException catch (e) {
      final message = _extractDioError(e);
      debugPrint(
        '[ProfileBloc] load DioException: $message | status: ${e.response?.statusCode}',
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: message,
        clearSuccessMessage: true,
      ));
    } catch (e, st) {
      debugPrint('[ProfileBloc] load unknown error: $e\n$st');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Profilni yuklab bo\'lmadi. Qayta urinib ko\'ring.',
        clearSuccessMessage: true,
      ));
    }
  }

  Future<void> _onUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isSaving) return;

    debugPrint('[ProfileBloc] ProfileUpdateSubmitted');
    emit(state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    try {
      final updatedProfile = await _repository.updateProfile(event.request);
      emit(state.copyWith(
        profile: updatedProfile,
        isSaving: false,
        successMessage: 'Profil muvaffaqiyatli saqlandi.',
      ));
    } on DioException catch (e) {
      final message = _extractDioError(e);
      debugPrint(
        '[ProfileBloc] update DioException: $message | status: ${e.response?.statusCode}',
      );
      emit(state.copyWith(
        isSaving: false,
        errorMessage: message,
        clearSuccessMessage: true,
      ));
    } catch (e, st) {
      debugPrint('[ProfileBloc] update unknown error: $e\n$st');
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Profilni saqlab bo\'lmadi. Qayta urinib ko\'ring.',
        clearSuccessMessage: true,
      ));
    }
  }

  void _onFeedbackCleared(
    ProfileFeedbackCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
  }

  String _extractDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'Sessiya tugagan. Qayta kiring.';
    }

    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }

    if (data is Map) {
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Server bilan aloqa yo\'q. Internetni tekshiring.';
    }

    return 'Xatolik yuz berdi. Qayta urinib ko\'ring.';
  }
}
