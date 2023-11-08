import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/glass/glass_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class ProjectDeleteDialog {
  static Future<bool?> show({required BuildContext context, required DockerProject project}) async {
    Utils.vibrate(FeedbackType.warning);
    return await showGlassDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "删除项目",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "容器${project.name}将被删除，删除后，项目内所有的容器和数据将丢失。是否确定要继续？",
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Button(
                    onPressed: () async {
                      context.pop();
                    },
                    color: Theme.of(context).disabledColor,
                    child: Text(
                      "取消",
                      style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Button(
                    onPressed: () async {
                      context.pop(true);
                    },
                    color: AppTheme.of(context)?.errorColor,
                    child: Text(
                      "删除项目",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
