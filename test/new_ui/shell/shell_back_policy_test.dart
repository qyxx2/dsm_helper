import 'package:dsm_helper/new_ui/shell/shell_back_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Back pops the current tab when it has a secondary route', () {
    expect(
      ShellBackPolicy.resolve(currentTabCanPop: true),
      ShellBackAction.popCurrentTab,
    );
  });

  test('Back at any primary root exits through the system', () {
    expect(
      ShellBackPolicy.resolve(currentTabCanPop: false),
      ShellBackAction.exitSystem,
    );
  });
}
