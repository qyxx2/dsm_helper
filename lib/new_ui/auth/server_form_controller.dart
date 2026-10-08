import 'dart:io';

import 'package:drift/drift.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:flutter/foundation.dart';

typedef ServerFormProbe = Future<Map<String, ApiModel>> Function({
  required String baseUrl,
  required bool checkSsl,
});

@immutable
class ServerEndpoint {
  const ServerEndpoint({
    required this.https,
    required this.host,
    required this.port,
  });

  final bool https;
  final String host;
  final int port;

  String get baseUrl => '${https ? 'https' : 'http'}://$host:$port';
}

/// A form-level adapter. No active DSM session or shell state changes here.
class ServerFormController extends ChangeNotifier {
  ServerFormController({
    required this.db,
    this.existingServer,
    ServerFormProbe? probe,
    int Function()? nowEpochSeconds,
  })  : _probe = probe ?? _probeDsm,
        _nowEpochSeconds = nowEpochSeconds ??
            (() => DateTime.now().millisecondsSinceEpoch ~/ 1000);

  final Database db;
  final Server? existingServer;
  final ServerFormProbe _probe;
  final int Function() _nowEpochSeconds;

  bool _submitting = false;
  bool _disposed = false;
  String? _errorMessage;

  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;

  static ServerEndpoint parseEndpoint({
    required bool https,
    required String host,
    required String port,
  }) {
    final normalizedHost = host.trim();
    if (normalizedHost.isEmpty) {
      throw const FormatException('请输入服务器地址');
    }

    if (normalizedHost.startsWith('[') || normalizedHost.endsWith(']')) {
      if (!normalizedHost.startsWith('[') ||
          !normalizedHost.endsWith(']') ||
          normalizedHost.length < 4) {
        throw const FormatException('IPv6 地址须使用方括号');
      }
      final address = InternetAddress.tryParse(
        normalizedHost.substring(1, normalizedHost.length - 1),
      );
      if (address == null || address.type != InternetAddressType.IPv6) {
        throw const FormatException('无效的 IPv6 地址');
      }
    } else {
      final address = InternetAddress.tryParse(normalizedHost);
      if (address?.type != InternetAddressType.IPv4) {
        final ipv4Like = RegExp(r'^\d+(?:\.\d+){3}$');
        final validLabel = RegExp(
          r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$',
        );
        if (normalizedHost.length > 253 ||
            ipv4Like.hasMatch(normalizedHost) ||
            normalizedHost.split('.').any(
                  (label) => !validLabel.hasMatch(label),
                )) {
          throw const FormatException('请输入有效的域名或 IP 地址');
        }
      }
    }

    final normalizedPort = port.trim();
    final portNumber = normalizedPort.isEmpty
        ? (https ? 5001 : 5000)
        : int.tryParse(normalizedPort);
    if (portNumber == null || portNumber < 1 || portNumber > 65535) {
      throw const FormatException('端口必须在 1 到 65535 之间');
    }

    return ServerEndpoint(
      https: https,
      host: normalizedHost,
      port: portNumber,
    );
  }

  /// Probe the candidate client independently; never replace Api.dsm.
  static Future<Map<String, ApiModel>> _probeDsm({
    required String baseUrl,
    required bool checkSsl,
  }) async {
    final candidate = DsmApi(baseUrl: baseUrl, checkSsl: checkSsl);
    try {
      return await ApiModel.info(client: candidate);
    } finally {
      candidate.dio?.close(force: true);
    }
  }

  Future<Server?> submit({
    required bool https,
    required String host,
    required String port,
    required bool checkSsl,
    required String remark,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    _errorMessage = null;
    _notify();
    try {
      final endpoint = parseEndpoint(https: https, host: host, port: port);
      final apiInfo = await _probe(
        baseUrl: endpoint.baseUrl,
        checkSsl: checkSsl,
      );
      if (apiInfo.isEmpty) {
        throw StateError('DSM API discovery returned no APIs');
      }

      return await db.transaction(() async {
        final original = existingServer;
        if (original == null) {
          return db.into(db.servers).insertReturning(
                ServersCompanion.insert(
                  groupId: 1,
                  ssl: endpoint.https,
                  qcid: '',
                  domain: endpoint.host,
                  port: endpoint.port,
                  checkSsl: checkSsl,
                  remark: remark,
                  macAddress: '',
                  createTime: _nowEpochSeconds(),
                ),
              );
        }
        final updated = original.copyWith(
          ssl: endpoint.https,
          qcid: '',
          domain: endpoint.host,
          port: endpoint.port,
          checkSsl: checkSsl,
          remark: remark,
        );
        final replaced = await db.update(db.servers).replace(updated);
        if (!replaced) {
          throw StateError('Server no longer exists: ${original.id}');
        }
        return updated;
      });
    } on FormatException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = '服务器连接或保存失败，请检查地址、端口及证书设置';
      return null;
    } finally {
      _submitting = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
