import 'package:dsm_helper/models/Syno/FileStation/BackgroundTask.dart';
import 'package:flutter/material.dart';

class BackgroundTaskProvider with ChangeNotifier {
  BackgroundTask _backgroundTask = BackgroundTask();
  BackgroundTask get backgroundTask => _backgroundTask;
  BackgroundTaskProvider();
  void setBackgroundTask({BackgroundTask? backgroundTask}) async {
    if (backgroundTask != null) _backgroundTask = backgroundTask;
    notifyListeners();
  }
}
