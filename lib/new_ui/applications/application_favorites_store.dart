import 'package:sp_util/sp_util.dart';

abstract interface class ApplicationFavoritesStore {
  Future<List<String>> load();
  Future<void> save(List<String> ids);
}

typedef ApplicationFavoriteIdsRead = List<String> Function();
typedef ApplicationFavoriteIdsWrite = Future<bool> Function(List<String> ids);

class SpUtilApplicationFavoritesStore implements ApplicationFavoritesStore {
  static const storageKey = 'modern_ui_application_favorites_v1';

  SpUtilApplicationFavoritesStore({
    ApplicationFavoriteIdsRead? read,
    ApplicationFavoriteIdsWrite? write,
  })  : _read = read ?? _readFromSpUtil,
        _write = write ?? _writeToSpUtil;

  final ApplicationFavoriteIdsRead _read;
  final ApplicationFavoriteIdsWrite _write;

  static List<String> _readFromSpUtil() {
    return SpUtil.getStringList(storageKey, defValue: const <String>[]) ??
        const <String>[];
  }

  static Future<bool> _writeToSpUtil(List<String> ids) async {
    return await SpUtil.putStringList(storageKey, ids);
  }

  @override
  Future<List<String>> load() async {
    return List<String>.of(_read());
  }

  @override
  Future<void> save(List<String> ids) async {
    final saved = await _write(List<String>.of(ids));
    if (!saved) {
      throw StateError('Failed to persist application favorites.');
    }
  }
}
