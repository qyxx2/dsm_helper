import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/glass/glass_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class ContainerSignalDialog {
  static Future<bool?> show({required BuildContext context, required Containers container}) async {
    Utils.vibrate(FeedbackType.warning);
    return await showGlassDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "强制停止",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "确认强制停止容器${container.name}？所有未保存的数据将丢失！",
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Button(
                    onPressed: () async {
                      context.pop(true);
                    },
                    color: AppTheme.of(context).errorColor,
                    child: Text(
                      "强制停止",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
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
              ],
            ),
          ],
        );
      },
    );
  }
}
