import 'package:cool_ui/cool_ui.dart';
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_response.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerImage.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerImageUpgradeTask.dart';
import 'package:dsm_helper/pages/docker/dialogs/image_upgrade_popup.dart';
import 'package:dsm_helper/pages/docker/enums/upgrade_state_enum.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageTab extends StatefulWidget {
  const ImageTab({super.key});

  @override
  State<ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<ImageTab> with AutomaticKeepAliveClientMixin {
  bool loading = true;
  DockerImage dockerImage = DockerImage();
  Map<String, DockerImageUpgradeTask> upgradeTasks = {};
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    dockerImage = await DockerImage.list();
    setState(() {
      loading = false;
    });
  }

  getUpgradeTask(String taskId) async {
    try {
      DockerImageUpgradeTask task = await DockerImageUpgradeTask.upgradeStatus(taskId);
      if (mounted) {
        if (task.finished == true) {
          upgradeTasks.remove(task.image);
          getData();
        } else if (task.image == null) {
          return;
        } else if (task.image != null) {
          upgradeTasks[task.image!] = task;
        }
        setState(() {});
        await Future.delayed(Duration(seconds: 5));
        getUpgradeTask(taskId);
      }
    } on DsmException catch (e) {
      print(e);
      if (e.code == 103) {
        getData();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? LoadingWidget(size: 30)
        : dockerImage.images != null && dockerImage.images!.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: dockerImage.images!.length,
                  itemBuilder: (context, i) {
                    return _buildImageItem(dockerImage.images![i]);
                  },
                ),
              )
            : EmptyWidget(
                text: "未添加镜像",
              );
  }

  Widget _buildImageItem(Images image) {
    bool upgrading = upgradeTasks.containsKey("${image.repository}:${image.tags?.join(",")}");
    DockerImageUpgradeTask? upgradeTask = upgradeTasks["${image.repository}:${image.tags?.join(",")}"];

    return Container(
      margin: EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: AppTheme.of(context)?.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${image.repository}:${image.tags?.join(",")}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 5),
                      if (image.upgradable == true && !upgrading) ...[
                        CupertinoButton(
                          child: Image.asset(
                            "assets/icons/upgrade.png",
                            width: 24,
                            color: AppTheme.of(context)?.primaryColor,
                          ),
                          minSize: 30,
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            bool? confirm = await ImageUpgradePopup.show(context: context, image: image);
                            if (confirm == true) {
                              String? taskId = await image.upgradeStart();
                              print(taskId);
                              if (taskId != null) {
                                getUpgradeTask(taskId);
                              }
                            }
                          },
                        ),
                        SizedBox(width: 10),
                      ],
                      CupertinoButton(
                        child: Image.asset(
                          "assets/icons/delete.png",
                          width: 24,
                        ),
                        minSize: 30,
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          var hide = showWeuiLoadingToast(context: context, message: Text("删除中"));

                          DsmResponse res = await image.delete();
                          var data = res.data?['image_objects']?[image.repository]?[image.tags![0]];
                          if (data['error'] == 1200) {
                            Utils.toast("镜像删除成功");
                          } else if (data['error'] == 1400) {
                            Utils.toast("容器${data['containers'].join(",")}正在使用此镜像，无法删除");
                          } else if (data['error'] == 1401) {
                            Utils.toast("镜像不存在");
                          }
                          hide();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      if (upgrading)
                        Padding(padding: EdgeInsets.only(right: 5), child: Label("${upgradeTask?.stateEnum != UpgradeStateEnum.unknown ? upgradeTask?.stateEnum.label : upgradeTask?.state}:${upgradeTask?.percent?.toStringAsFixed(2) ?? '-'}%", AppTheme.of(context)?.successColor ?? Colors.green))
                      else if (image.tags != null)
                        ...image.tags!.map(
                          (tag) => Padding(padding: EdgeInsets.only(right: 5), child: Label(tag, AppTheme.of(context)?.primaryColor ?? Colors.blue)),
                        ),
                      Label(Utils.formatSize(image.size!, fixed: 0), AppTheme.of(context)?.placeholderColor ?? Colors.grey),
                    ],
                  ),
                  if (image.description != null && image.description != '') ...[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${image.description}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.of(context)?.placeholderColor,
                      ),
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
