import 'package:dio/io.dart';
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/dsm_active_context_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DsmApi disables certificate validation only for the opted-out instance', () {
    final relaxed = DsmApi(
      baseUrl: 'https://nas-relaxed:5001',
      checkSsl: false,
    );
    final strict = DsmApi(
      baseUrl: 'https://nas-strict:5001',
      checkSsl: true,
    );

    final relaxedAdapter = relaxed.dio!.httpClientAdapter as IOHttpClientAdapter;
    final strictAdapter = strict.dio!.httpClientAdapter as IOHttpClientAdapter;

    expect(relaxedAdapter.createHttpClient, isNotNull);
    expect(strictAdapter.createHttpClient, isNull);
  });

  test('active context adapter binds the selected server certificate policy', () async {
    final adapter = DsmActiveContextAdapter(
      discoverCapabilities: () async {},
      probeSession: () async {},
    );

    final result = await adapter.activate(
      const ActiveContextRequest(
        contextId: '7/42',
        baseUrl: 'https://nas:5001',
        deviceId: 'device-42',
        sid: 'sid-42',
        checkSsl: false,
      ),
    );

    expect(result.status, ActiveContextStatus.authenticated);
    expect(
      (Api.dsm.dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient,
      isNotNull,
    );
  });
}
