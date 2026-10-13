import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_operation_contract.dart';
import 'package:flutter_test/flutter_test.dart';

FileItem file(String? path, {String name = 'same', bool folder = false,
    bool? write, bool? delete}) => FileItem(
  path: path,
  name: name,
  isdir: folder,
  additional: FileAdditional(perm: Perm(acl: Acl(write: write, del: delete))),
);

FileOperationSelection snapshot(List<FileItem> loaded, Set<String> selected, {
  String context = 'NAS-A/user-1', String? folder = '/share',
  bool complete = true,
}) => FileOperationSelection.capture(
  contextId: context,
  folderPath: folder,
  isComplete: complete,
  loadedItems: loaded,
  selectedPaths: selected,
);

void main() {
  test('copies and duplicate names preserve distinct exact DSM path identities', () {
    final original = file('/share/a', name: 'duplicate');
    final clone = original.copyWith();
    final other = file('/share/b', name: 'duplicate');
    final selected = <String>{'/share/a', '/share/b'};
    final captured = snapshot([clone, other], selected);
    expect(captured.contextId, 'NAS-A/user-1');
    expect(captured.folderPath, '/share');
    expect(captured.targets.map((e) => e.path), ['/share/a', '/share/b']);
    selected.clear();
    clone.path = '/share/changed';
    other.name = 'changed';
    expect(captured.targets.map((e) => e.path), ['/share/a', '/share/b']);
    expect(captured.targets.first.name, 'duplicate');
    expect(() => captured.targets.clear(), throwsUnsupportedError);
  });

  test('root, invalid paths, absent/unloaded paths and partial pages never become targets', () {
    final loaded = [file('/share/a'), file(''), file(null), file('/share/b')];
    expect(snapshot(loaded, {'/share/a', '/share/b', '/share/unloaded'},
      complete: false).targets.map((e) => e.path), ['/share/a', '/share/b']);
    expect(snapshot(loaded, {'/share/a'}, folder: null).targets, isEmpty);
    expect(snapshot(loaded, {'/share/a'}, folder: '').targets, isEmpty);
    expect(snapshot(loaded, {'/share/a'}, folder: '/share')
      .eligibility(FileOperationAction.delete), isNot(FileOperationEligibility.denied));
  });

  test('eligibility freezes cardinality and nullable ACL without assuming grants', () {
    final one = snapshot([file('/share/a', write: true, delete: true)], {'/share/a'});
    expect(one.eligibility(FileOperationAction.rename), FileOperationEligibility.allowed);
    expect(one.eligibility(FileOperationAction.delete), FileOperationEligibility.allowed);
    final two = snapshot([file('/share/a'), file('/share/b')],
      {'/share/a', '/share/b'}, complete: false);
    expect(two.eligibility(FileOperationAction.rename), FileOperationEligibility.denied);
    expect(two.eligibility(FileOperationAction.shareLink), FileOperationEligibility.denied);
    expect(two.eligibility(FileOperationAction.copy),
      FileOperationEligibility.requiresServerCheck);
    final unknown = snapshot([file('/share/a')], {'/share/a'});
    expect(unknown.eligibility(FileOperationAction.rename),
      FileOperationEligibility.requiresServerCheck);
    expect(unknown.eligibility(FileOperationAction.delete),
      FileOperationEligibility.requiresServerCheck);
    final denied = snapshot([file('/share/a', write: false, delete: false)],
      {'/share/a'});
    expect(denied.eligibility(FileOperationAction.rename), FileOperationEligibility.denied);
    expect(denied.eligibility(FileOperationAction.delete), FileOperationEligibility.denied);
  });

  test('create folder requires a verified non-root current directory', () {
    expect(snapshot([], {}, folder: null)
      .eligibility(FileOperationAction.createFolder), FileOperationEligibility.denied);
    expect(snapshot([], {}, folder: '/share')
      .eligibility(FileOperationAction.createFolder),
      FileOperationEligibility.requiresServerCheck);
    expect(snapshot([file('/share/a')], {'/share/a'}, folder: '/share')
      .eligibility(FileOperationAction.createFolder), FileOperationEligibility.denied);
  });

  test('a share-root path or current folder cannot become its own mutation target', () {
    final selected = snapshot(
      [file('/share', folder: true), file('/')],
      {'/share', '/'},
      folder: '/share',
    );
    expect(selected.targets, isEmpty);
    expect(selected.eligibility(FileOperationAction.delete),
      FileOperationEligibility.denied);
  });

  test('explicit read-only directory ACL never authorizes rename or delete', () {
    final selected = snapshot(
      [file('/share/readonly', folder: true, write: false, delete: false)],
      {'/share/readonly'},
    );
    expect(selected.eligibility(FileOperationAction.rename),
      FileOperationEligibility.denied);
    expect(selected.eligibility(FileOperationAction.delete),
      FileOperationEligibility.denied);
  });

  test('unverified virtual/scheme path is not authorized for mutations', () {
    final special = snapshot([file('scheme://host/share/file')],
      {'scheme://host/share/file'}, folder: 'scheme://host/share');
    expect(special.eligibility(FileOperationAction.copy), FileOperationEligibility.denied);
    expect(special.eligibility(FileOperationAction.delete), FileOperationEligibility.denied);
  });
}
