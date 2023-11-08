import 'dart:ui';

import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/pages/docker/enums/container_status_enum.dart';
import 'package:dsm_helper/pages/docker/enums/project_status_enum.dart';
import 'package:dsm_helper/pages/docker/project_detail/project_detail.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/dot_widget.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';

class ProjectTab extends StatefulWidget {
  const ProjectTab({super.key});

  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  Map<String, DockerProject> projects = {};
  bool loading = true;
  Map<DockerProject, bool> projectLoading = {};
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData({bool loop = true}) async {
    projects = await DockerProject.list();
    setState(() {
      loading = false;
    });
    await Future.delayed(Duration(seconds: 5));
    if (loop && mounted) {
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingWidget(size: 30)
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemBuilder: (context, i) {
                return _buildProjectItem(projects.values.elementAt(i));
              },
              itemCount: projects.length,
            ),
          );
  }

  Widget _buildProjectItem(DockerProject project) {
    GlobalKey actionButtonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: CupertinoButton(
        onPressed: projectLoading[project] == true
            ? null
            : () {
                context.push(ProjectDetail(project), name: 'docker_project_detail');
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
                        color: project.statusEnum.color,
                      ),
                    ),
                    Text(
                      project.statusEnum.label,
                      style: TextStyle(color: project.statusEnum.color, fontSize: 13),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${DateTime.parse(project.createdAt!).format("Y-m-d H:i")}创建",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 10,
                      child: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: project.statusEnum == ProjectStatusEnum.RUNNING,
                          onChanged: projectLoading[project] == true
                              ? null
                              : (v) async {
                                  setState(() {
                                    projectLoading[project] = true;
                                  });
                                  try {
                                    if (v) {
                                      await project.start();
                                    } else {
                                      await project.stop();
                                    }
                                    getData(loop: false);
                                  } catch (e) {
                                    Utils.toast("操作失败");
                                  }
                                  setState(() {
                                    projectLoading[project] = false;
                                  });
                                },
                        ),
                      ),
                    ),
                    CupertinoButton(
                      key: actionButtonKey,
                      onPressed: projectLoading[project] == true
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
                                            enabled: project.statusEnum == ProjectStatusEnum.RUNNING,
                                            onTap: () async {
                                              // setState(() {
                                              //   projectLoading[project] = true;
                                              // });
                                              // try {
                                              //   await project.restart();
                                              //   getData(loop: false);
                                              // } catch (e) {
                                              //   print(e);
                                              //   Utils.toast("重启失败");
                                              // }
                                              // setState(() {
                                              //   projectLoading[project] = false;
                                              // });
                                            },
                                            child: Text("重新启动"),
                                          ),
                                          PopupMenuItem(
                                            enabled: project.statusEnum != ProjectStatusEnum.RUNNING,
                                            onTap: () async {
                                              // bool? confirm = await ContainerResetDialog.show(context: context, container: container);
                                              // if (confirm == true) {
                                              //   setState(() {
                                              //     projectLoading[project] = true;
                                              //   });
                                              //   try {
                                              //     await project.delete(preserveProfile: true);
                                              //     getData(loop: false);
                                              //   } catch (e) {
                                              //     print(e);
                                              //     Utils.toast("重置失败");
                                              //   }
                                              //   setState(() {
                                              //     projectLoading[project] = false;
                                              //   });
                                              // }
                                            },
                                            child: Text("重置"),
                                          ),
                                          PopupMenuItem(
                                            enabled: project.statusEnum != ProjectStatusEnum.RUNNING,
                                            onTap: () async {
                                              // bool? confirm = await ContainerDeleteDialog.show(context: context, container: container);
                                              // if (confirm == true) {
                                              //   setState(() {
                                              //     projectLoading[project] = true;
                                              //   });
                                              //   try {
                                              //     await project.delete(preserveProfile: false);
                                              //     getData(loop: false);
                                              //   } catch (e) {
                                              //     print(e);
                                              //     Utils.toast("删除失败");
                                              //   }
                                              //   setState(() {
                                              //     projectLoading[project] = false;
                                              //   });
                                              // }
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
                  height: 5,
                ),
                Text(
                  project.name!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                Text(
                  project.path!,
                  style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
