import 'dart:convert';
import 'dart:io';

import 'package:dsm_helper/apis/api.dart' as legacy_api;
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/new_ui/app/dsm_new_ui_shell.dart';
import 'package:dsm_helper/providers/dark_mode.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

class _InitDataServer {
  _InitDataServer._(this.server, this.majorVersion, this.application);

  final HttpServer server;
  final String majorVersion;
  final String application;
  int requests = 0;

  static Future<_InitDataServer> start({
    required String majorVersion,
    required String application,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final result = _InitDataServer._(server, majorVersion, application);

    server.listen((request) async {
      result.requests += 1;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'success': true,
          'data': {
            'Session': {'majorversion': majorVersion},
            'UserSettings': {
              'Desktop': {
                'valid_appview_order': [application],
              },
            },
          },
        }),
      );
      await request.response.close();
    });

    return result;
  }

  String get baseUrl => 'http://127.0.0.1:${server.port}';

  Future<void> close() => server.close(force: true);
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required String baseUrl,
}) async {
  legacy_api.Api.dsm = DsmApi(
    baseUrl: baseUrl,
    deviceId: 'device',
    sid: 'sid',
  );

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => DarkModeProvider(0),
      child: const MaterialApp(
        home: DsmNewUiShell(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openApplications(WidgetTester tester) async {
  await tester.tap(find.text('应用'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-legacy-feature')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.getInstance();
  });

  testWidgets(
    'cold-start shell prepares legacy InitData before Dashboard is ever mounted',
    (tester) async {
      final server = await _InitDataServer.start(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
      );
      addTearDown(server.close);
      Utils.version = 6;

      await _pumpShell(tester, baseUrl: server.baseUrl);

      expect(server.requests, 1);
      expect(Utils.version, 7);

      await _openApplications(tester);

      expect(find.text('控制中心'), findsOneWidget);
    },
  );

  testWidgets(
    'new shell context replaces shared InitData and DSM version instead of exposing the previous NAS',
    (tester) async {
      final serverA = await _InitDataServer.start(
        majorVersion: '7',
        application: 'SYNO.SDS.AdminCenter.Application',
      );
      final serverB = await _InitDataServer.start(
        majorVersion: '6',
        application: 'SYNO.SDS.PkgManApp.Instance',
      );
      addTearDown(serverA.close);
      addTearDown(serverB.close);

      await _pumpShell(tester, baseUrl: serverA.baseUrl);
      expect(Utils.version, 7);

      await _openApplications(tester);
      expect(find.text('控制中心'), findsOneWidget);

      await _pumpShell(tester, baseUrl: serverB.baseUrl);
      expect(Utils.version, 6);

      await _openApplications(tester);
      expect(find.text('套件中心'), findsOneWidget);
      expect(find.text('控制中心'), findsNothing);
      expect(serverA.requests, 1);
      expect(serverB.requests, 1);
    },
  );
}
