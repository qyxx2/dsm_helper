import 'package:dsm_helper/models/Syno/FileStation/BackgroundTask.dart';
import 'package:dsm_helper/pages/file/bus/refresh_background_task_bus.dart';
import 'package:dsm_helper/pages/file/file.dart';
import 'package:dsm_helper/providers/background_task_provider.dart';
import 'package:dsm_helper/utils/bus/bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => FilePageState();
}

class FilePageState extends State<FilePage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    getBackgroundTask();
    bus.on<RefreshBackgroundTaskEvent>().listen((event) {
      getBackgroundTask(loop: false);
    });
    super.initState();
  }

  getBackgroundTask({bool loop = true}) async {
    if (!mounted) return;
    BackgroundTask backgroundTask = await BackgroundTask.list();
    BackgroundTaskProvider backgroundTaskProvider = context.read<BackgroundTaskProvider>();
    backgroundTaskProvider.setBackgroundTask(backgroundTask: backgroundTask);
    for (Tasks task in backgroundTask.tasks!) {
      task.taskStatus = await task.status();
      backgroundTaskProvider.setBackgroundTask(backgroundTask: backgroundTask);
    }
    if (loop) {
      await Future.delayed(Duration(seconds: 5));
      getBackgroundTask();
    }
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  push() {
    // navigatorKey.currentState.push(route);
  }
  pop() {}
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return CupertinoPageRoute(
            settings: settings,
            builder: (context) => Files(),
          );
        }
        return null;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
