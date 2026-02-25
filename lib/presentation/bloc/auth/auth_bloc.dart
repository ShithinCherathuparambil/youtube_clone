import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<PhoneVerificationRequested>(_onPhoneVerificationRequested);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<_PhoneCodeSentInternal>(_onPhoneCodeSentInternal);
    on<_PhoneVerificationFailedInternal>(_onPhoneVerificationFailedInternal);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithEmailAndPassword(
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.registerWithEmailAndPassword(
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> _onPhoneVerificationRequested(
    PhoneVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // We cannot fully await this inside the bloc map easily without completer or callbacks
    // So we handle the repository's callbacks:
    final result = await _authRepository.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      onCodeSent: (verificationId) {
        add(_PhoneCodeSentInternal(verificationId));
      },
      onVerificationFailed: (failure) {
        add(_PhoneVerificationFailedInternal(failure.message));
      },
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {
      // Success means it started successfully. Do not emit authenticated yet.
      // Waiting for callbacks.
    });
  }

  Future<void> _onOtpVerificationRequested(
    OtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithCredential(
      event.verificationId,
      event.smsCode,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthAuthenticated()),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthInitial()), // Optionally add a 'PasswordResetSent' state
    );
  }

  // Internal event handlers for callbacks
  void _onPhoneCodeSentInternal(
    _PhoneCodeSentInternal event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthOtpSent(verificationId: event.verificationId));
  }

  void _onPhoneVerificationFailedInternal(
    _PhoneVerificationFailedInternal event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthError(message: event.message));
  }
}

// Internal events to handle Stream-like callbacks from Firebase Auth Phone verification
class _PhoneCodeSentInternal extends AuthEvent {
  final String verificationId;
  const _PhoneCodeSentInternal(this.verificationId);
}

class _PhoneVerificationFailedInternal extends AuthEvent {
  final String message;
  const _PhoneVerificationFailedInternal(this.message);
}
