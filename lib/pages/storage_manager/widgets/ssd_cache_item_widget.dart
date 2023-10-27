import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/pages/dashboard/enums/volume_status_enum.dart';
import 'package:dsm_helper/pages/storage_manager/enums/disk_status_enum.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/line_progress_bar.dart';
import 'package:flutter/material.dart';

class SharedCacheItemWidget extends StatelessWidget {
  final SharedCaches sharedCache;
  final bool isLast;
  const SharedCacheItemWidget(this.sharedCache, {this.isLast = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "SSD 缓存群组 ${sharedCache.numId}",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
        Text(
          "${sharedCache.size!.usedPercent.toStringAsFixed(1)}%",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        LineProgressBar(value: sharedCache.size!.usedPercent),
        SizedBox(height: 5),
        DefaultTextStyle(
          style: TextStyle(fontSize: 12),
          child: Row(
            children: [
              Text(
                "已用 ${Utils.formatSize(sharedCache.size!.usedNum)} ",
                style: TextStyle(color: sharedCache.size!.usedPercent > 80 ? AppTheme.of(context)?.errorColor : AppTheme.of(context)?.primaryColor),
              ),
              Text(
                "/ ${Utils.formatSize(sharedCache.size!.totalNum)}",
                style: TextStyle(color: AppTheme.of(context)?.placeholderColor),
              ),
              Spacer(),
              Text(
                "可用：${Utils.formatSize(sharedCache.size!.freeNum)}",
                style: TextStyle(color: AppTheme.of(context)?.successColor),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(),
      ],
    );
  }
}
