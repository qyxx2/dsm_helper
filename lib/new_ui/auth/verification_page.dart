import 'package:dsm_helper/new_ui/auth/auth_flow_controller.dart';
import 'package:dsm_helper/new_ui/auth/auth_flow_models.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.controller});

  final AuthFlowController controller;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant VerificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSubmitting || _code.text.trim().isEmpty) return;
    await widget.controller.submitVerification(_code.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final isEmail = state.verificationKind == AuthVerificationKind.email;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('auth-verification-back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回账号密码',
          onPressed: widget.controller.isSubmitting
              ? null
              : widget.controller.returnToCredentials,
        ),
        title: Text(isEmail ? '邮件验证' : '双重验证'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.message != null)
              Text(
                state.message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: state.error is Exception &&
                          state.message!.contains('错误')
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('auth-verification-code'),
              controller: _code,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: '验证码'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('auth-verify-submit'),
                onPressed: widget.controller.isSubmitting ? null : _submit,
                child: widget.controller.isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('验证'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
