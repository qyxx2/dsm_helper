import 'dart:ui';

import 'package:dsm_helper/pages/docker/container_detail/container_detail.dart';
import 'package:dsm_helper/pages/docker/dialogs/container_delete_dialog.dart';
import 'package:dsm_helper/pages/docker/dialogs/container_reset_dialog.dart';
import 'package:dsm_helper/pages/docker/dialogs/container_signal_dialog.dart';
import 'package:dsm_helper/pages/docker/enums/container_status_enum.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/datetime_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/dot_widget.dart';
import 'package:dsm_helper/widgets/line_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart' hide State;
import 'package:kumi_popup_window/kumi_popup_window.dart';

class ContainerItemWidget extends StatelessWidget {
  final Containers container;
  final bool loading;
  final Function()? startLoading;
  final Function()? endLoading;
  const ContainerItemWidget(this.container, {this.loading = false, this.startLoading, this.endLoading, super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey actionButtonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: CupertinoButton(
        onPressed: loading
            ? null
            : () {
                context.push(ContainerDetail(container.name!), name: 'docker_container_detail');
              },
        color: AppTheme.of(context)?.cardColor,
        borderRadius: BorderRadius.circular(22),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: DotWidget(
                        color: container.exporting == true ? AppTheme.of(context)?.primaryColor : container.statusEnum.color,
                      ),
                    ),
                    Text(
                      container.exporting == true ? '导出中' : container.statusEnum.label,
                      style: TextStyle(color: container.exporting == true ? AppTheme.of(context)?.primaryColor : container.statusEnum.color, fontSize: 13),
                    ),
                    SizedBox(width: 10),
                    if (container.statusEnum == ContainerStatusEnum.running)
                      Text(
                        DateTime.fromMillisecondsSinceEpoch(container.upTime! * 1000).timeAgo,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    Spacer(),
                    SizedBox(
                      height: 10,
                      child: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: container.statusEnum == ContainerStatusEnum.running,
                          onChanged: loading
                              ? null
                              : (v) async {
                                  startLoading?.call();
                                  try {
                                    if (v) {
                                      await container.start();
                                    } else {
                                      await container.stop();
                                    }
                                  } catch (e) {
                                    Utils.toast("操作失败");
                                  }
                                  endLoading?.call();
                                },
                        ),
                      ),
                    ),
                    CupertinoButton(
                      key: actionButtonKey,
                      onPressed: loading
                          ? null
                          : () async {
                              showPopupWindow(
                                context,
                                gravity: KumiPopupGravity.leftTop,
                                bgColor: Colors.transparent,
                                clickOutDismiss: true,
                                clickBackDismiss: true,
                                customAnimation: false,
                                customPop: false,
                                customPage: false,
                                underStatusBar: true,
                                underAppBar: true,
                                needSafeDisplay: true,
                                offsetX: 30,
                                offsetY: 30,
                                // curve: Curves.easeInSine,
                                duration: Duration(milliseconds: 200),
                                targetRenderBox: actionButtonKey.currentContext!.findRenderObject() as RenderBox,
                                childFun: (pop) {
                                  return BackdropFilter(
                                    key: GlobalKey(),
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      width: 150,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      margin: EdgeInsets.only(top: 50),
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context)?.cardColor,
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          PopupMenuItem(
                                            enabled: container.statusEnum == ContainerStatusEnum.running,
                                            onTap: () async {
                                              bool? confirm = await ContainerSignalDialog.show(context: context, container: container);
                                              if (confirm == true) {
                                                startLoading?.call();
                                                try {
                                                  await container.signal();
                                                } catch (e) {
                                                  print(e);
                                                  Utils.toast("强制停止失败");
                                                }
                                                endLoading?.call();
                                              }
                                            },
                                            child: Text("强制停止"),
                                          ),
                                          PopupMenuItem(
                                            enabled: container.statusEnum == ContainerStatusEnum.running,
                                            onTap: () async {
                                              startLoading?.call();
                                              try {
                                                await container.restart();
                                              } catch (e) {
                                                print(e);
                                                Utils.toast("重启失败");
                                              }
                                              endLoading?.call();
                                            },
                                            child: Text("重新启动"),
                                          ),
                                          PopupMenuItem(
                                            enabled: container.statusEnum != ContainerStatusEnum.running,
                                            onTap: () async {
                                              bool? confirm = await ContainerResetDialog.show(context: context, container: container);
                                              if (confirm == true) {
                                                startLoading?.call();
                                                try {
                                                  await container.delete(preserveProfile: true);
                                                } catch (e) {
                                                  print(e);
                                                  Utils.toast("重置失败");
                                                }
                                                endLoading?.call();
                                              }
                                            },
                                            child: Text("重置"),
                                          ),
                                          PopupMenuItem(
                                            enabled: container.statusEnum != ContainerStatusEnum.running,
                                            onTap: () async {
                                              bool? confirm = await ContainerDeleteDialog.show(context: context, container: container);
                                              if (confirm == true) {
                                                startLoading?.call();
                                                try {
                                                  await container.delete(preserveProfile: false);
                                                } catch (e) {
                                                  print(e);
                                                  Utils.toast("删除失败");
                                                }
                                                endLoading?.call();
                                              }
                                            },
                                            child: Text(
                                              "删除",
                                              style: TextStyle(color: AppTheme.of(context)?.errorColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                      padding: EdgeInsets.zero,
                      minSize: 20,
                      child: Image.asset(
                        "assets/icons/more_vertical.png",
                        width: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  container.name!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                Text(
                  container.image!,
                  style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                ),
              ],
            ),
            if (container.statusEnum == ContainerStatusEnum.running) ...[
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "CPU",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            Spacer(),
                            Text(
                              "${container.resource?.cpu == null ? '-' : container.resource!.cpu!.toStringAsFixed(2)}%",
                              style: TextStyle(color: AppTheme.of(context)?.primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        LineProgressBar(
                          value: container.resource?.cpu ?? 0,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "RAM",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            Spacer(),
                            Text(
                              "${Utils.formatSize(container.resource?.memory ?? 0, fixed: 0)}",
                              style: TextStyle(color: AppTheme.of(context)?.successColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        LineProgressBar(
                          value: container.resource?.memoryPercent ?? 0,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
