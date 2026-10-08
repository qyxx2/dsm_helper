import 'package:drift/native.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/api_model.dart';
import 'package:dsm_helper/new_ui/auth/server_form_controller.dart';
import 'package:dsm_helper/new_ui/auth/server_form_page.dart';
import 'package:dsm_helper/new_ui/theme/new_ui_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database db;
  setUp(() => db = Database.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('add form shows only approved endpoint fields and saves on final action', (tester) async {
    String? probedUrl;
    bool? probedCheckSsl;
    final controller = ServerFormController(
      db: db,
      probe: ({required baseUrl, required checkSsl}) async {
        probedUrl = baseUrl;
        probedCheckSsl = checkSsl;
        return {'SYNO.API.Info': ApiModel(maxVersion: 1)};
      },
    );
    addTearDown(controller.dispose);
    Server? submitted;
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(),
      home: ServerFormPage(controller: controller, onSaved: (server) => submitted = server),
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
    expect(probedUrl, 'https://nas.local:5443');
    expect(probedCheckSsl, isFalse);
    expect(await db.select(db.servers).get(), hasLength(1));
    expect(await db.select(db.accounts).get(), isEmpty);
  });

  testWidgets('invalid host stays on form with visible local feedback', (tester) async {
    var calls = 0;
    final controller = ServerFormController(
      db: db,
      probe: ({required baseUrl, required checkSsl}) async {
        calls++;
        return {};
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.dark(), home: ServerFormPage(controller: controller),
    ));
    await tester.enterText(find.byKey(const Key('server-form-host')), 'bad host');
    await tester.ensureVisible(find.byKey(const Key('server-form-submit')));
    await tester.tap(find.byKey(const Key('server-form-submit')));
    await tester.pump();
    expect(calls, 0);
    expect(controller.errorMessage, isNotNull);
    expect(find.text(controller.errorMessage!), findsOneWidget);
    expect(await db.select(db.servers).get(), isEmpty);
  });

  testWidgets('edit form prefills persisted settings and preserves linked accounts', (tester) async {
    final id = await db.into(db.servers).insert(
      ServersCompanion.insert(
        groupId: 1, ssl: true, qcid: '', domain: 'nas.example.com',
        port: 5443, checkSsl: false, remark: 'Original', macAddress: '',
        createTime: 1,
      ),
    );
    final server = await (db.select(db.servers)..where((t) => t.id.equals(id))).getSingle();
    await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        serverId: id, account: 'user', password: 'secret',
        remark: '', createTime: 1, lastLoginTime: 1,
        isDefault: true, deviceId: 'device', sid: 'sid',
        ikMessage: '', synoToken: '',
      ),
    );
    final controller = ServerFormController(
      db: db, existingServer: server,
      probe: ({required baseUrl, required checkSsl}) async => {
        'SYNO.API.Info': ApiModel(maxVersion: 1),
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: NewUiTheme.light(), home: ServerFormPage(controller: controller),
    ));
    expect(tester.widget<TextField>(find.byKey(const Key('server-form-host'))).controller!.text,
        'nas.example.com');
    expect(tester.widget<TextField>(find.byKey(const Key('server-form-port'))).controller!.text,
        '5443');
    expect(tester.widget<TextField>(find.byKey(const Key('server-form-remark'))).controller!.text,
        'Original');
    await tester.enterText(find.byKey(const Key('server-form-remark')), 'Updated');
    await tester.ensureVisible(find.byKey(const Key('server-form-submit')));
    await tester.tap(find.byKey(const Key('server-form-submit')));
    await tester.pump();
    expect((await db.select(db.servers).get()).single.remark, 'Updated');
    expect((await db.select(db.accounts).get()).single.sid, 'sid');
  });
}
