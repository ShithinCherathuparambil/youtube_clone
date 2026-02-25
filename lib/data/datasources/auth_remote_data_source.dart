import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/exceptions.dart';

/// Firebase Auth integration point.
///
/// Keep this boundary in data layer and call FirebaseAuth SDK here.
abstract class AuthRemoteDataSource {
  Future<void> signInWithEmail({required String email, required String password});
  Future<void> signInWithPhoneOtp({required String phone, required String otp});
  Future<void> persistSessionToken(String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // TODO(shithin): Integrate FirebaseAuth.signInWithEmailAndPassword.
      if (email.isEmpty || password.isEmpty) {
        throw const FormatException('Email/password cannot be empty');
      }
    } catch (e) {
      throw ServerException('Email sign-in failed: $e');
    }
  }

  @override
  Future<void> signInWithPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      // TODO(shithin): Integrate FirebaseAuth PhoneAuthCredential flow.
      if (phone.isEmpty || otp.isEmpty) {
        throw const FormatException('Phone/OTP cannot be empty');
      }
    } catch (e) {
      throw ServerException('Phone sign-in failed: $e');
    }
  }

  @override
  Future<void> persistSessionToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', token);
    } catch (e) {
      throw CacheException('Failed to persist auth session: $e');
    }
  }
}
