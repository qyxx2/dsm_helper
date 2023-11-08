import 'package:dsm_helper/models/Syno/FileStation/BackgroundTask.dart';
import 'package:dsm_helper/pages/file/dialogs/cancel_background_task_dialog.dart';
import 'package:dsm_helper/providers/background_task_provider.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/strings.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/glass/glass_modal_popup.dart';
import 'package:dsm_helper/widgets/glass/popup_header.dart';
import 'package:dsm_helper/widgets/line_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundTaskPopupContent extends StatefulWidget {
  const BackgroundTaskPopupContent({super.key});

  @override
  State<BackgroundTaskPopupContent> createState() => _BackgroundTaskPopupContentState();
}

class _BackgroundTaskPopupContentState extends State<BackgroundTaskPopupContent> {
  @override
  Widget build(BuildContext context) {
    BackgroundTaskProvider backgroundTaskProvider = context.watch<BackgroundTaskProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PopupHeader(title: "后台任务"),
        SizedBox(height: 10),
        Expanded(
          child: backgroundTaskProvider.backgroundTask.tasks != null && backgroundTaskProvider.backgroundTask.tasks!.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, i) {
                    return _buildBackgroundTaskItem(backgroundTaskProvider.backgroundTask.tasks![i]);
                  },
                  itemCount: backgroundTaskProvider.backgroundTask.tasks!.length,
                )
              : EmptyWidget(
                  text: "暂无后台任务",
                ),
        ),
      ],
    );
  }

  Widget _buildBackgroundTaskItem(Tasks task) {
    List<String> actions = task.background!.title![1].split(":");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${task.background!.title![2]}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              CupertinoButton(
                child: Image.asset(
                  "assets/icons/remove_circle_fill.png",
                  width: 24,
                ),
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () async {
                  bool? res = await CancelBackgroundTaskDialog.show(context: context, task: task);
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          LineProgressBar(
            value: task.progress! * 100,
            progressColor: AppTheme.of(context)?.successColor,
            backgroundColor: AppTheme.of(context)?.primaryColor,
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Text(
                "${webManagerStrings[actions[0]][actions[1]]} ${task.progress! >= 0 ? "${(task.progress! * 100).toStringAsFixed(2)}%" : '准备中…'}",
                style: TextStyle(fontSize: 14, color: AppTheme.of(context)?.successColor),
              ),
              Spacer(),
              if (task.processedSize != null && task.processedSize! > 0)
                Text(
                  "${Utils.formatSize(task.processedSize!)}",
                  style: TextStyle(fontSize: 14, color: AppTheme.of(context)?.successColor),
                ),
              if (task.processedSize != null && task.processedSize! > 0 && task.total != null && task.total! > 0)
                Text(
                  " / ",
                  style: TextStyle(fontSize: 14, color: AppTheme.of(context)?.placeholderColor),
                ),
              if (task.total != null && task.total! > 0)
                Text(
                  "${Utils.formatSize(task.total!)}",
                  style: TextStyle(fontSize: 14, color: AppTheme.of(context)?.primaryColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BackgroundTaskPopup {
  static show({required BuildContext context}) {
    showGlassModalPopup(
      context,
      content: BackgroundTaskPopupContent(),
      buttons: [
        Button(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Theme.of(context).disabledColor,
          child: Text("关闭"),
        ),
      ],
    );
  }
}
