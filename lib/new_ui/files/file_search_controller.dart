import 'package:dio/dio.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_exception.dart';
import 'package:dsm_helper/models/Syno/FileStation/FileStationList.dart';
import 'package:dsm_helper/new_ui/files/file_search_data_source.dart';
import 'package:flutter/foundation.dart';

enum FileSearchPhase {
  idle,
  starting,
  searching,
  partial,
  complete,
  empty,
  incomplete,
  offline,
  unavailable,
  reauthNeeded,
}

typedef FileSearchWait = Future<void> Function(Duration delay);

/// Owns one folder-scoped Search route.
///
/// Search jobs are local-route state. Leaving/replacing the route invalidates
/// callbacks and polling, but never invents a remote Search/stop request.
class FileSearchController extends ChangeNotifier {
  FileSearchController({
    required FileSearchDataSource dataSource,
    required String contextId,
    required String folderPath,
    VoidCallback? onReauthNeeded,
    FileSearchWait? wait,
    Duration pollDelay = const Duration(seconds: 2),
    int pageSize = 100,
    int maxPollAttempts = 5,
  })  : _source = dataSource,
        _contextId = contextId,
        _folderPath = folderPath,
        _onReauthNeeded = onReauthNeeded,
        _wait = wait ?? Future<void>.delayed,
        _pollDelay = pollDelay,
        _pageSize = pageSize,
        _maxPollAttempts = maxPollAttempts;

  final FileSearchDataSource _source;
  final String _contextId;
  final String _folderPath;
  final VoidCallback? _onReauthNeeded;
  final FileSearchWait _wait;
  final Duration _pollDelay;
  final int _pageSize;
  final int _maxPollAttempts;

  FileSearchPhase _phase = FileSearchPhase.idle;
  String _pattern = '';
  String? _taskId;
  List<FileItem> _items = <FileItem>[];
  Object? _error;
  int? _total;
  int _nextOffset = 0;
  int _generation = 0;
  bool _disposed = false;
  bool _reauthSignalled = false;
  bool _recursive = true;
  bool _searchContent = false;

  FileSearchPhase get phase => _phase;
  String get contextId => _contextId;
  String get folderPath => _folderPath;
  String get pattern => _pattern;
  String? get taskId => _taskId;
  List<FileItem> get items => List<FileItem>.unmodifiable(_items);
  Object? get error => _error;
  int? get total => _total;
  int get nextOffset => _nextOffset;
  bool get isComplete =>
      _phase == FileSearchPhase.complete || _phase == FileSearchPhase.empty;

  Future<void> search(
    String pattern, {
    bool recursive = true,
    bool searchContent = false,
  }) async {
    if (_disposed) return;
    final trimmed = pattern.trim();
    final generation = ++_generation;
    _pattern = trimmed;
    _recursive = recursive;
    _searchContent = searchContent;
    _taskId = null;
    _items = <FileItem>[];
    _error = null;
    _total = null;
    _nextOffset = 0;
    _phase = FileSearchPhase.starting;
    notifyListeners();

    if (trimmed.isEmpty) {
      _fail(
        const FileSearchDataException('Search pattern is empty'),
        generation,
      );
      return;
    }

    try {
      final start = await _source.startSearch(
        folderPath: _folderPath,
        pattern: trimmed,
        recursive: recursive,
        searchContent: searchContent,
      );
      if (!_isActive(generation)) return;
      _taskId = start.taskId;
      _phase = FileSearchPhase.searching;
      notifyListeners();
      await _readResults(generation, start.taskId);
    } catch (exception) {
      if (_isActive(generation)) _fail(exception, generation);
    }
  }

  Future<void> retry() {
    if (_disposed || _pattern.isEmpty) return Future<void>.value();
    return search(
      _pattern,
      recursive: _recursive,
      searchContent: _searchContent,
    );
  }

  Future<void> _readResults(int generation, String taskId) async {
    var pollAttempts = 0;
    while (_isActive(generation)) {
      final requestedOffset = _nextOffset;
      FileSearchPage page;
      try {
        page = await _source.loadPage(
          taskId: taskId,
          offset: requestedOffset,
          limit: _pageSize,
        );
      } catch (exception) {
        if (_isActive(generation)) _fail(exception, generation);
        return;
      }
      if (!_isActive(generation)) return;

      if (page.offset != requestedOffset) {
        _markIncomplete(
          const FileSearchDataException('Search page offset did not advance'),
          generation,
        );
        return;
      }
      if (page.items.length > _pageSize) {
        _markIncomplete(
          const FileSearchDataException('Search page exceeds requested limit'),
          generation,
        );
        return;
      }

      final previousTotal = _total;
      final pageTotal = page.total;
      if (previousTotal != null &&
          pageTotal != null &&
          previousTotal != pageTotal) {
        _markIncomplete(
          const FileSearchDataException('Search total changed mid-job'),
          generation,
        );
        return;
      }
      _total ??= pageTotal;

      final seen = <String>{
        for (final item in _items)
          if (item.path != null && item.path!.isNotEmpty) item.path!,
      };
      final merged = <FileItem>[..._items];
      var newPaths = 0;
      for (final item in page.items) {
        final path = item.path;
        if (path == null || path.isEmpty) {
          _markIncomplete(
            const FileSearchDataException(
              'Search result is missing exact path identity',
            ),
            generation,
          );
          return;
        }
        if (seen.add(path)) {
          merged.add(item);
          newPaths++;
        }
      }

      final rawNextOffset = requestedOffset + page.items.length;
      final knownTotal = _total;
      if (knownTotal != null &&
          (rawNextOffset > knownTotal || merged.length > knownTotal)) {
        _markIncomplete(
          const FileSearchDataException('Search result exceeds reported total'),
          generation,
        );
        return;
      }

      final fullPage = page.items.length == _pageSize;
      if (fullPage && newPaths == 0) {
        _markIncomplete(
          const FileSearchDataException('Search page did not make progress'),
          generation,
        );
        return;
      }

      _items = merged;
      _nextOffset = rawNextOffset;
      _error = null;
      _phase = page.finished && !fullPage
          ? FileSearchPhase.searching
          : (_items.isEmpty
              ? FileSearchPhase.searching
              : FileSearchPhase.partial);
      notifyListeners();

      if (page.finished) {
        if (fullPage) {
          continue;
        }
        if (knownTotal != null &&
            (rawNextOffset < knownTotal || _items.length < knownTotal)) {
          _markIncomplete(
            const FileSearchDataException(
              'Finished search is missing reported results',
            ),
            generation,
          );
          return;
        }
        _phase =
            _items.isEmpty ? FileSearchPhase.empty : FileSearchPhase.complete;
        _error = null;
        notifyListeners();
        return;
      }

      if (fullPage) {
        continue;
      }

      pollAttempts++;
      if (pollAttempts >= _maxPollAttempts) {
        _markIncomplete(
          const FileSearchDataException('Search polling limit reached'),
          generation,
        );
        return;
      }

      await _wait(_pollDelay);
      if (!_isActive(generation)) return;
    }
  }

  void _fail(Object exception, int generation) {
    if (!_isActive(generation)) return;
    _error = exception;
    if (exception is DsmException && exception.code == 119) {
      _phase = FileSearchPhase.reauthNeeded;
      if (!_reauthSignalled) {
        _reauthSignalled = true;
        _onReauthNeeded?.call();
      }
    } else if (exception is DioException) {
      _phase =
          _items.isEmpty ? FileSearchPhase.offline : FileSearchPhase.partial;
    } else {
      _phase =
          _items.isEmpty ? FileSearchPhase.unavailable : FileSearchPhase.partial;
    }
    notifyListeners();
  }

  void _markIncomplete(Object exception, int generation) {
    if (!_isActive(generation)) return;
    _error = exception;
    _phase = FileSearchPhase.incomplete;
    notifyListeners();
  }

  bool _isActive(int generation) =>
      !_disposed && generation == _generation;

  void cancelLocal() {
    if (_disposed) return;
    _generation++;
    _pattern = '';
    _taskId = null;
    _items = <FileItem>[];
    _error = null;
    _total = null;
    _nextOffset = 0;
    _phase = FileSearchPhase.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _generation++;
    _disposed = true;
    super.dispose();
  }
}
