import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/server_account_store.dart';
import 'package:flutter/foundation.dart';

typedef AuthLogin = Future<Auth> Function({
  required String account,
  required String password,
  String? optCode,
});

class AuthFlowController extends ChangeNotifier {
  AuthFlowController({
    required this.server,
    required this.store,
    this.existingAccount,
    AuthLogin? login,
    int Function()? nowEpochSeconds,
  })  : _login = login ?? Auth.login,
        _nowEpochSeconds = nowEpochSeconds ??
            (() => DateTime.now().millisecondsSinceEpoch ~/ 1000),
        _state = AuthFlowState(
          stage: AuthFlowStage.credentials,
          account: existingAccount?.account ?? '',
          password: existingAccount?.password ?? '',
          isDefault: existingAccount?.isDefault ?? false,
        );

  final Server server;
  final Account? existingAccount;
  final ServerAccountStore store;
  final AuthLogin _login;
  final int Function() _nowEpochSeconds;

  AuthFlowState _state;
  AuthFlowState get state => _state;

  String _account = '';
  String _password = '';
  bool _isDefault = false;

  Future<void> submitCredentials({
    required String account,
    required String password,
    required bool isDefault,
  }) async {
    _account = account;
    _password = password;
    _isDefault = isDefault;
    await _authenticate();
  }

  Future<void> submitVerification(String code) {
    return _authenticate(optCode: code);
  }

  Future<void> reauthenticateSavedAccount() async {
    final account = existingAccount;
    if (account == null) {
      throw StateError('No saved account is available for reauthentication');
    }
    _account = account.account;
    _password = account.password;
    _isDefault = account.isDefault;
    await _authenticate();
  }

  Future<void> _authenticate({String? optCode}) async {
    try {
      final auth = await _login(
        account: _account,
        password: _password,
        optCode: optCode,
      );
      final deviceId = auth.deviceId;
      final sid = auth.sid;
      final ikMessage = auth.ikMessage;
      final synoToken = auth.synotoken;
      if (deviceId == null ||
          sid == null ||
          ikMessage == null ||
          synoToken == null) {
        throw StateError('DSM authentication response is missing session fields');
      }

      final account = await store.saveAuthenticatedAccount(
        serverId: server.id,
        account: _account,
        password: _password,
        isDefault: _isDefault,
        deviceId: deviceId,
        sid: sid,
        ikMessage: ikMessage,
        synoToken: synoToken,
        timestamp: _nowEpochSeconds(),
      );
      _state = AuthFlowState(
        stage: AuthFlowStage.authenticated,
        account: _account,
        password: _password,
        isDefault: _isDefault,
        authenticatedAccount: account,
      );
    } on DsmException catch (error) {
      _state = _stateForDsmError(error);
    } catch (error) {
      _state = AuthFlowState(
        stage: AuthFlowStage.failure,
        account: _account,
        password: _password,
        isDefault: _isDefault,
        message: '登录失败',
        error: error,
      );
    }
    notifyListeners();
  }

  AuthFlowState _stateForDsmError(DsmException error) {
    switch (error.code) {
      case 400:
        return AuthFlowState(
          stage: AuthFlowStage.credentials,
          account: _account,
          password: _password,
          isDefault: _isDefault,
          message: '用户名/密码有误',
          error: error,
        );
      case 403:
        return AuthFlowState(
          stage: AuthFlowStage.verification,
          account: _account,
          password: _password,
          isDefault: _isDefault,
          verificationKind: AuthVerificationKind.otp,
          message: '您已开启双重验证，请输入验证码',
          error: error,
        );
      case 404:
        return AuthFlowState(
          stage: AuthFlowStage.verification,
          account: _account,
          password: _password,
          isDefault: _isDefault,
          verificationKind: AuthVerificationKind.otp,
          message: '错误的验证码。请再试一次',
          error: error,
        );
      case 414:
        final email = _verificationEmail(error.source);
        return AuthFlowState(
          stage: AuthFlowStage.verification,
          account: _account,
          password: _password,
          isDefault: _isDefault,
          verificationKind: AuthVerificationKind.email,
          verificationEmail: email,
          message: email == null
              ? '请输入邮件验证码'
              : '验证码已发送到$email，请在5分钟内输入验证码',
          error: error,
        );
      default:
        return AuthFlowState(
          stage: AuthFlowStage.failure,
          account: _account,
          password: _password,
          isDefault: _isDefault,
          message: '登录失败，代码：${error.code}',
          error: error,
        );
    }
  }

  String? _verificationEmail(dynamic source) {
    if (source is! Map) {
      return null;
    }
    final errors = source['errors'];
    if (errors is! Map) {
      return null;
    }
    return errors['email']?.toString();
  }
}
