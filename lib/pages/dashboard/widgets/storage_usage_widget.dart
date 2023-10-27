import 'package:dsm_helper/models/Syno/Storage/Cgi/Storage.dart';
import 'package:dsm_helper/pages/control_panel/info/info.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/pages/storage_manager/widgets/ssd_cache_item_widget.dart';
import 'package:dsm_helper/pages/storage_manager/widgets/volume_item_widget.dart';
import 'package:dsm_helper/providers/storage_provider.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class StorageUsageWidget extends StatelessWidget {
  const StorageUsageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Storage storage = context.watch<StorageProvider>().storage;
    return Column(
      children: [
        WidgetCard(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return SystemInfo(2);
            }));
          },
          // icon: Image.asset(
          //   "assets/icons/pie.png",
          //   width: 26,
          //   height: 26,
          // ),
          title: "存储信息",
          body: Column(
            children: [
              if (storage.volumes != null)
                ...storage.volumes!.map((volume) => VolumeItemWidget(volume, isLast: storage.volumes!.last == volume)).toList()
              else
                EmptyWidget(
                  text: "暂无存储空间",
                ),
            ],
          ),
        ),
        if (storage.ssdCaches != null && storage.ssdCaches!.length > 0)
          WidgetCard(
            title: "SSD 缓存",
            body: Column(
              children: storage.sharedCaches!.map((sharedCache) => SharedCacheItemWidget(sharedCache, isLast: storage.sharedCaches!.last == sharedCache)).toList(),
            ),
          ),
      ],
    );
  }
}
