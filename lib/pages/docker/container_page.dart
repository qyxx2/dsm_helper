import 'dart:ui';

import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/models/Syno/Docker/Container/ContainerResource.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart' hide State;
import 'package:dsm_helper/pages/docker/container_detail.dart';
import 'package:dsm_helper/pages/docker/enums/docker_status_enum.dart';
import 'package:dsm_helper/providers/utilization_provider.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart' hide Api;
import 'package:dsm_helper/widgets/dot_widget.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/line_progress_bar.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> with AutomaticKeepAliveClientMixin {
  DockerContainer containers = DockerContainer();
  ContainerResource resource = ContainerResource();
  bool loading = true;
  Map<Containers, bool> containerLoading = {};
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData({bool loop = true}) async {
    List<DsmResponse> batchRes = await Api.dsm.batch(apis: [DockerContainer(), ContainerResource()]);
    batchRes.forEach((element) {
      switch (element.data.runtimeType.toString()) {
        case "DockerContainer":
          containers = element.data;
          containers.containers!.sort((a, b) => a.name!.compareTo(b.name!));
          break;
        case "ContainerResource":
          resource = element.data;
      }
    });
    if (mounted) {
      setState(() {
        containers.containers!.forEach((container) {
          container.resource = resource.resources!.firstWhere((element) => element.name == container.name);
        });
        loading = false;
      });
    }
    if (loop) {
      await Future.delayed(Duration(seconds: 10));
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    UtilizationProvider utilizationProvider = context.read<UtilizationProvider>();
    Utilization utilization = utilizationProvider.utilization;
    return loading
        ? LoadingWidget(
            size: 30,
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 140,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: SfRadialGauge(
                          animationDuration: 1000,
                          enableLoadingAnimation: true,
                          axes: <RadialAxis>[
                            RadialAxis(
                              showLabels: false,
                              showTicks: false,
                              // radiusFactor: 0.8,
                              maximum: 100,
                              axisLineStyle: AxisLineStyle(cornerStyle: CornerStyle.bothCurve, thickness: 8),
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.4,
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/icons/cpu_line.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${utilization.cpu?.totalLoad ?? '-'}',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                            ),
                                            TextSpan(
                                              text: '%',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black45),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "CPU",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              pointers: <GaugePointer>[
                                RangePointer(
                                  enableAnimation: true,
                                  animationDuration: 1000,
                                  value: (utilization.cpu?.totalLoad ?? 0).toDouble(),
                                  width: 8,
                                  cornerStyle: CornerStyle.bothCurve,
                                  gradient: SweepGradient(colors: (utilization.cpu?.totalLoad ?? 0) < 80 ? [Color(0xFF00BAAD), Color(0xFF4BD6CD)] : [AppTheme.of(context)!.errorColor!, AppTheme.of(context)!.warningColor!]),
                                ),
                                // MarkerPointer(
                                //   value: utilization.cpu!.totalLoad.toDouble() - 3,
                                //   color: Colors.white,
                                //   markerType: MarkerType.circle,
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 140,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: SfRadialGauge(
                          animationDuration: 1000,
                          enableLoadingAnimation: true,
                          axes: <RadialAxis>[
                            RadialAxis(
                              showLabels: false,
                              showTicks: false,
                              // radiusFactor: 0.8,
                              maximum: 100,
                              axisLineStyle: AxisLineStyle(cornerStyle: CornerStyle.bothCurve, thickness: 8),
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.4,
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/icons/memory.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${utilization.memory?.realUsage ?? '-'}',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                            ),
                                            TextSpan(
                                              text: '%',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black45),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "RAM",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              pointers: <GaugePointer>[
                                RangePointer(
                                  enableAnimation: true,
                                  animationDuration: 1000,
                                  value: (utilization.memory?.realUsage ?? 0).toDouble(),
                                  width: 8,
                                  cornerStyle: CornerStyle.bothCurve,
                                  gradient: SweepGradient(colors: (utilization.memory?.realUsage ?? 0) < 80 ? [AppTheme.of(context)!.primaryColor!, Color(0xFF75ACFF)] : [AppTheme.of(context)!.errorColor!, AppTheme.of(context)!.warningColor!]),
                                ),
                                // MarkerPointer(
                                //   value: utilization.cpu!.totalLoad.toDouble() - 3,
                                //   color: Colors.white,
                                //   markerType: MarkerType.circle,
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded(child: SizedBox()),
                  ],
                ),
                SizedBox(height: 20),
                if (containers.containers != null && containers.containers!.isNotEmpty) ...containers.containers!.map(_buildContainerItem).toList() else EmptyWidget(text: "未添加容器"),
              ],
            ),
          );
  }

  Widget _buildContainerItem(Containers container) {
    GlobalKey actionButtonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        onPressed: containerLoading[container] == true
            ? null
            : () {
                context.push(ContainerDetail(container.name!), name: 'docker_container_detail');
              },
        color: Colors.white,
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
                        color: container.statusEnum.color,
                      ),
                    ),
                    Text(
                      container.statusEnum.label,
                      style: TextStyle(color: container.statusEnum.color, fontSize: 13),
                    ),
                    SizedBox(width: 10),
                    if (container.statusEnum == DockerStatusEnum.running)
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
                          value: container.statusEnum == DockerStatusEnum.running,
                          onChanged: containerLoading[container] == true
                              ? null
                              : (v) async {
                                  setState(() {
                                    containerLoading[container] = true;
                                  });
                                  try {
                                    if (v) {
                                      await container.start();
                                    } else {
                                      await container.stop();
                                    }
                                    getData(loop: false);
                                  } catch (e) {
                                    Utils.toast("操作失败");
                                  }
                                  setState(() {
                                    containerLoading[container] = false;
                                  });
                                },
                        ),
                      ),
                    ),
                    CupertinoButton(
                      key: actionButtonKey,
                      onPressed: containerLoading[container] == true
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          PopupMenuItem(
                                            enabled: container.statusEnum == DockerStatusEnum.running,
                                            onTap: () async {
                                              setState(() {
                                                containerLoading[container] = true;
                                              });
                                              try {
                                                await container.signal();
                                                getData(loop: false);
                                              } catch (e) {
                                                print(e);
                                                Utils.toast("强制停止失败");
                                              }
                                              setState(() {
                                                containerLoading[container] = false;
                                              });
                                            },
                                            child: Text("强制停止"),
                                          ),
                                          PopupMenuItem(
                                            enabled: container.statusEnum == DockerStatusEnum.running,
                                            onTap: () async {
                                              setState(() {
                                                containerLoading[container] = true;
                                              });
                                              try {
                                                await container.restart();
                                                getData(loop: false);
                                              } catch (e) {
                                                print(e);
                                                Utils.toast("重启失败");
                                              }
                                              setState(() {
                                                containerLoading[container] = false;
                                              });
                                            },
                                            child: Text("重新启动"),
                                          ),
                                          PopupMenuItem(
                                            onTap: () async {
                                              setState(() {
                                                containerLoading[container] = true;
                                              });
                                              try {
                                                await container.delete(preserveProfile: true);
                                                getData(loop: false);
                                              } catch (e) {
                                                print(e);
                                                Utils.toast("操作失败");
                                              }
                                              setState(() {
                                                containerLoading[container] = false;
                                              });
                                            },
                                            child: Text("重置"),
                                          ),
                                          PopupMenuItem(
                                            onTap: () async {
                                              setState(() {
                                                containerLoading[container] = true;
                                              });
                                              try {
                                                await container.delete(preserveProfile: false);
                                                getData(loop: false);
                                              } catch (e) {
                                                print(e);
                                                Utils.toast("操作失败");
                                              }
                                              setState(() {
                                                containerLoading[container] = false;
                                              });
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
            if (container.statusEnum == DockerStatusEnum.running) ...[
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

  @override
  bool get wantKeepAlive => true;
}
