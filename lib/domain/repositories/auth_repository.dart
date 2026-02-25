import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Either<Failure, void>> registerWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(Failure failure) onVerificationFailed,
  });

  Future<Either<Failure, void>> signInWithCredential(
    String verificationId,
    String smsCode,
  );

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, String?>> getCurrentUserId();
}
