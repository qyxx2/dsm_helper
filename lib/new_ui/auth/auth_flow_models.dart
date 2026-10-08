import 'package:dsm_helper/database/tables.dart';

enum AuthFlowStage {
  credentials,
  verification,
  authenticated,
  failure,
}

enum AuthVerificationKind {
  otp,
  email,
}

class AuthFlowState {
  const AuthFlowState({
    required this.stage,
    required this.account,
    required this.password,
    required this.isDefault,
    this.verificationKind,
    this.verificationEmail,
    this.message,
    this.authenticatedAccount,
    this.error,
  });

  final AuthFlowStage stage;
  final String account;
  final String password;
  final bool isDefault;
  final AuthVerificationKind? verificationKind;
  final String? verificationEmail;
  final String? message;
  final Account? authenticatedAccount;
  final Object? error;
}
