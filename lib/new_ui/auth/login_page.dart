import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:dsm_helper/new_ui/auth/verification_page.dart';
import 'package:flutter/material.dart';

/// Stage-only UI. The caller owns the controller and performs shell activation
/// using [AuthFlowState.authenticatedAccount] in a later integration batch.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AuthFlowController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _account;
  late final TextEditingController _password;
  bool _showPassword = false;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _account = TextEditingController(text: widget.controller.state.account);
    _password = TextEditingController(text: widget.controller.state.password);
    _isDefault = widget.controller.state.isDefault;
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      _account.text = widget.controller.state.account;
      _password.text = widget.controller.state.password;
      _isDefault = widget.controller.state.isDefault;
      widget.controller.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSubmitting) return;
    if (_account.text.trim().isEmpty || _password.text.isEmpty) return;
    await widget.controller.submitCredentials(
      account: _account.text.trim(),
      password: _password.text,
      isDefault: _isDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final state = controller.state;
    if (state.stage == AuthFlowStage.verification) {
      return VerificationPage(controller: controller);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              controller.server.hostname?.isNotEmpty == true
                  ? controller.server.hostname!
                  : controller.server.domain,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('auth-account'),
              controller: _account,
              readOnly: controller.existingAccount != null,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '账号'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('auth-password'),
              controller: _password,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: '密码',
                suffixIcon: IconButton(
                  key: const Key('auth-toggle-password'),
                  tooltip: _showPassword ? '隐藏密码' : '显示密码',
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const Key('auth-default'),
              contentPadding: EdgeInsets.zero,
              title: const Text('设为默认账号'),
              value: _isDefault,
              onChanged: controller.isSubmitting
                  ? null
                  : (value) => setState(() => _isDefault = value ?? false),
            ),
            if (state.message != null) ...[
              const SizedBox(height: 8),
              Text(
                state.message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('auth-submit'),
                onPressed: controller.isSubmitting ? null : _submit,
                child: controller.isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.stage == AuthFlowStage.authenticated ? '已登录' : '登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
