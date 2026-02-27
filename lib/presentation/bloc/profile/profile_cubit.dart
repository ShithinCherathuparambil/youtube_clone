import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/user_service.dart';

// State
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String handle;
  final String? profileImagePath;

  const ProfileLoaded({
    required this.name,
    required this.handle,
    this.profileImagePath,
  });

  @override
  List<Object?> get props => [name, handle, profileImagePath];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final UserService _userService;

  ProfileCubit(this._userService) : super(ProfileInitial());

  void loadProfile() {
    emit(ProfileLoading());
    try {
      final name = _userService.getName();
      final handle = _userService.getHandle();
      final imagePath = _userService.getProfileImagePath();
      emit(
        ProfileLoaded(name: name, handle: handle, profileImagePath: imagePath),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? handle,
    String? profileImagePath,
  }) async {
    try {
      await _userService.updateProfile(
        name: name,
        handle: handle,
        profileImagePath: profileImagePath,
      );
      loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
