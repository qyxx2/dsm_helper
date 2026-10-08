import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A standalone form; the caller handles the post-save navigation.
class ServerFormPage extends StatefulWidget {
  const ServerFormPage({
    super.key,
    required this.controller,
    this.onSaved,
  });

  final ServerFormController controller;
  final ValueChanged<Server>? onSaved;

  @override
  State<ServerFormPage> createState() => _ServerFormPageState();
}

class _ServerFormPageState extends State<ServerFormPage> {
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _remark;
  late bool _https;
  late bool _checkSsl;

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.existingServer;
    _https = existing?.ssl ?? false;
    _checkSsl = existing?.checkSsl ?? true;
    _host = TextEditingController(text: existing?.domain ?? '');
    _port = TextEditingController(
      text: existing == null ||
              existing.port == (existing.ssl ? 5001 : 5000)
          ? ''
          : existing.port.toString(),
    );
    _remark = TextEditingController(text: existing?.remark ?? '');
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _host.dispose();
    _port.dispose();
    _remark.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSubmitting) return;
    final saved = await widget.controller.submit(
      https: _https,
      host: _host.text,
      port: _port.text,
      checkSsl: _checkSsl,
      remark: _remark.text.trim(),
    );
    if (saved != null && mounted) widget.onSaved?.call(saved);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final editing = controller.existingServer != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? '编辑服务器' : '添加服务器')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              key: const Key('server-form-https'),
              contentPadding: EdgeInsets.zero,
              title: const Text('HTTPS'),
              value: _https,
              onChanged: controller.isSubmitting
                  ? null
                  : (value) => setState(() => _https = value),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('server-form-host'),
              controller: _host,
              enabled: !controller.isSubmitting,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '域名或 IP 地址'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('server-form-port'),
              controller: _port,
              enabled: !controller.isSubmitting,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '端口（可选）',
                hintText: _https ? '5001' : '5000',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              key: const Key('server-form-check-ssl'),
              contentPadding: EdgeInsets.zero,
              title: const Text('校验 SSL 证书'),
              value: _checkSsl,
              onChanged: !_https || controller.isSubmitting
                  ? null
                  : (value) => setState(() => _checkSsl = value),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('server-form-remark'),
              controller: _remark,
              enabled: !controller.isSubmitting,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: '备注'),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('server-form-submit'),
                onPressed: controller.isSubmitting ? null : _submit,
                child: controller.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(editing ? '保存' : '下一步'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
