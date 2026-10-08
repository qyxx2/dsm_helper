import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_form_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-only double: no asynchronous Drift work inside Flutter's fake-async
/// test binding. Real persistence and account preservation are covered by
/// server_form_controller_test.dart using SQLite.
class FakeServerFormController extends ServerFormController {
  FakeServerFormController({
    required super.db,
    super.existingServer,
  });

  String? receivedUrl;
  bool? receivedCheckSsl;
  String? receivedRemark;
  String? _message;

  @override
  String? get errorMessage => _message;

  @override
  Future<Server?> submit({
    required bool https,
    required String host,
    required String port,
    required bool checkSsl,
    required String remark,
  }) async {
    _message = null;
    try {
      final endpoint = ServerFormController.parseEndpoint(
        https: https,
        host: host,
        port: port,
      );
      receivedUrl = endpoint.baseUrl;
      receivedCheckSsl = checkSsl;
      receivedRemark = remark;
      final existing = existingServer;
      if (existing != null) {
        return existing.copyWith(
          ssl: endpoint.https,
          domain: endpoint.host,
          port: endpoint.port,
          checkSsl: checkSsl,
          remark: remark,
        );
      }
      return Server(
        id: 12,
        groupId: 1,
        ssl: endpoint.https,
        qcid: '',
        domain: endpoint.host,
        port: endpoint.port,
        checkSsl: checkSsl,
        remark: remark,
        macAddress: '',
        createTime: 1,
      );
    } on FormatException catch (error) {
      _message = error.message;
      notifyListeners();
      return null;
    }
  }
}

void main() {
  late Database db;
  setUp(() => db = Database.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('add form exposes only approved fields and forwards submit values',
      (tester) async {
    final controller = FakeServerFormController(db: db);
    addTearDown(controller.dispose);
    Server? submitted;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: ServerFormPage(
        controller: controller,
        onSaved: (server) => submitted = server,
      ),
    ));

    expect(find.byKey(const Key('server-form-https')), findsOneWidget);
    expect(find.byKey(const Key('server-form-host')), findsOneWidget);
    expect(find.byKey(const Key('server-form-port')), findsOneWidget);
    expect(find.byKey(const Key('server-form-check-ssl')), findsOneWidget);
    expect(find.byKey(const Key('server-form-remark')), findsOneWidget);
    expect(find.byKey(const Key('server-form-submit')), findsOneWidget);
    expect(find.textContaining('QuickConnect'), findsNothing);
    expect(find.textContaining('扫描'), findsNothing);

    await tester.enterText(find.byKey(const Key('server-form-host')), 'nas.local');
    await tester.tap(find.byKey(const Key('server-form-https')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('server-form-check-ssl')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('server-form-port')), '5443');
    await tester.enterText(find.byKey(const Key('server-form-remark')), 'Home NAS');
    await tester.ensureVisible(find.byKey(const Key('server-form-submit')));
    await tester.tap(find.byKey(const Key('server-form-submit')));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.remark, 'Home NAS');
    expect(controller.receivedUrl, 'https://nas.local:5443');
    expect(controller.receivedCheckSsl, isFalse);
    expect(controller.receivedRemark, 'Home NAS');
  });

  testWidgets('invalid host stays on form with visible local feedback',
      (tester) async {
    final controller = FakeServerFormController(db: db);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.dark(),
      home: ServerFormPage(controller: controller),
    ));
    await tester.enterText(find.byKey(const Key('server-form-host')), 'bad host');
    await tester.ensureVisible(find.byKey(const Key('server-form-submit')));
    await tester.tap(find.byKey(const Key('server-form-submit')));
    await tester.pump();

    expect(controller.receivedUrl, isNull);
    expect(controller.errorMessage, isNotNull);
    expect(find.text(controller.errorMessage!), findsOneWidget);
  });

  testWidgets('edit form prefills settings and returns same Server identity',
      (tester) async {
    const server = Server(
      id: 7,
      groupId: 1,
      ssl: true,
      qcid: '',
      domain: 'nas.example.com',
      port: 5443,
      checkSsl: false,
      remark: 'Original',
      macAddress: '',
      createTime: 1,
    );
    final controller = FakeServerFormController(
      db: db,
      existingServer: server,
    );
    addTearDown(controller.dispose);
    Server? saved;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: ServerFormPage(
        controller: controller,
        onSaved: (result) => saved = result,
      ),
    ));

    expect(
      tester.widget<TextField>(find.byKey(const Key('server-form-host')))
          .controller!
          .text,
      'nas.example.com',
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('server-form-port')))
          .controller!
          .text,
      '5443',
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('server-form-remark')))
          .controller!
          .text,
      'Original',
    );

    await tester.enterText(
      find.byKey(const Key('server-form-remark')),
      'Updated',
    );
    await tester.ensureVisible(find.byKey(const Key('server-form-submit')));
    await tester.tap(find.byKey(const Key('server-form-submit')));
    await tester.pump();

    expect(saved?.id, server.id);
    expect(saved?.remark, 'Updated');
    expect(controller.receivedCheckSsl, isFalse);
  });
}
