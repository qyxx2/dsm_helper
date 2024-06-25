import 'package:dsm_helper/models/Syno/Docker/DockerContainerDetail.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab(this.name, {super.key});
  final String name;
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool loading = true;
  DockerContainerDetail detail = DockerContainerDetail();
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    detail = await DockerContainerDetail.get(widget.name);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingWidget(size: 30)
        : ListView(
            children: [
              WidgetCard(
                title: widget.name,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "启动时间",
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${DateTime.fromMillisecondsSinceEpoch((detail.details?.upTime ?? 0) * 1000).timeAgo}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "快捷方式",
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${detail.profile?.shortcut?.enableShortcut == true ? detail.profile?.shortcut?.enableStatusPage == true ? '状态页面' : '${detail.profile?.shortcut?.webPageUrl}' : '已停用'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "CPU优先顺序",
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${detail.profile!.cpuPriority! > 50 ? '高' : detail.profile!.cpuPriority! == 50 ? '中' : '低'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "内存限制",
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${detail.profile!.memoryLimit! > 0 ? Utils.formatSize(detail.profile!.memoryLimit!) : "自动"}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "执行命令",
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${detail.details?.exeCmd}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              WidgetCard(
                title: "端口设置",
                body: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                      child: Row(
                        children: [
                          Expanded(child: Text("本地端口")),
                          Expanded(child: Text("容器端口")),
                          SizedBox(width: 30, child: Text("类型")),
                        ],
                      ),
                    ),
                    ...detail.profile!.portBindings!
                        .map((e) => Column(
                              children: [
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(child: Text("${e.hostPort}")),
                                    Expanded(child: Text("${e.containerPort}")),
                                    SizedBox(width: 30, child: Text("${e.type}")),
                                  ],
                                ),
                              ],
                            ))
                        .toList()
                  ],
                ),
              ),
              WidgetCard(
                title: "存储空间",
                body: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                      child: Row(
                        children: [
                          Expanded(child: Text("文件/文件夹")),
                          Expanded(child: Text("装载路径")),
                          SizedBox(width: 30, child: Text("类型")),
                        ],
                      ),
                    ),
                    ...detail.profile!.volumeBindings!
                        .map((e) => Column(
                              children: [
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(child: Text("${e.hostVolumeFile}")),
                                    Expanded(child: Text("${e.mountPoint}")),
                                    SizedBox(width: 30, child: Text("${e.type}")),
                                  ],
                                ),
                              ],
                            ))
                        .toList()
                  ],
                ),
              ),
              WidgetCard(
                title: "链接",
                body: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                      child: Row(
                        children: [
                          Expanded(child: Text("容器名称")),
                          Expanded(child: Text("别名")),
                        ],
                      ),
                    ),
                    ...detail.profile!.links!
                        .map((e) => Column(
                              children: [
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(child: Text("${e.linkContainer}")),
                                    Expanded(child: Text("${e.alias}")),
                                  ],
                                ),
                              ],
                            ))
                        .toList()
                  ],
                ),
              ),
              WidgetCard(
                title: "网络",
                body: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                      child: Row(
                        children: [
                          Expanded(child: Text("网络名称")),
                          Expanded(child: Text("驱动程序")),
                        ],
                      ),
                    ),
                    ...detail.profile!.network!
                        .map((e) => Column(
                              children: [
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(child: Text("${e.name}")),
                                    Expanded(child: Text("${e.driver}")),
                                  ],
                                ),
                              ],
                            ))
                        .toList()
                  ],
                ),
              ),
              WidgetCard(
                title: "环境变量",
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: detail.profile!.envVariables!
                      .map((e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${e.key}",
                                style: TextStyle(color: AppTheme.of(context).placeholderColor, fontSize: 13),
                              ),
                              Text(
                                "${e.value}",
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(),
                            ],
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 16),
            ],
          );
  }
}
