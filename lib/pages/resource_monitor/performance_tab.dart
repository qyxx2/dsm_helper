import 'dart:async';
import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/cpu_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/cpu_detail_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/gpu_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/gpu_memory_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/lun_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/memory_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/network_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/nfs_chart_widget.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/storage_chart_widget.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PerformanceTab extends StatefulWidget {
  PerformanceTab({this.tabIndex = 0});
  final int tabIndex;
  @override
  _PerformanceTabState createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<PerformanceTab> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Utilization> utilizations = List.generate(30, (index) => Utilization());
  // ChartSeriesController? _cpuChartController;
  // ChartSeriesController? _memoryChartController;
  // ChartSeriesController? _lunReadChartController;
  // ChartSeriesController? _lunWriteChartController;
  // ChartSeriesController? _networkChartController;
  // ChartSeriesController? _diskChartController;
  bool loading = true;
  List networks = [];
  List disks = [];
  List spaces = [];
  List luns = [];
  Timer? timer;

  int get maxDiskSpeed {
    int maxSpeed = 0;
    for (var utilization in utilizations) {
      int maxVal = max(utilization.disk?.total?.readByte?.toInt() ?? 0, utilization.disk?.total?.writeByte?.toInt() ?? 0);
      if (maxSpeed < maxVal) {
        maxSpeed = maxVal;
      }
    }
    return maxSpeed;
  }

  int get maxVolumeSpeed {
    int maxSpeed = 0;
    for (var utilization in utilizations) {
      int maxVal = max(utilization.space?.total?.readByte?.toInt() ?? 0, utilization.space?.total?.writeByte?.toInt() ?? 0);
      if (maxSpeed < maxVal) {
        maxSpeed = maxVal;
      }
    }
    return maxSpeed;
  }

  num maxDiskReadSpeed = 0;
  num maxDiskWriteSpeed = 0;
  num maxVolumeReadSpeed = 0;
  num maxVolumeWriteSpeed = 0;
  @override
  void initState() {
    final settingProvider = Provider.of<SettingProvider>(context, listen: false);
    _tabController = TabController(initialIndex: widget.tabIndex, length: 8, vsync: this);
    getData();
    timer = Timer.periodic(Duration(seconds: settingProvider.refreshDuration), (timer) {
      getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    utilizations.clear();
    super.dispose();
  }

  getData() async {
    Utilization res = await Utilization.get();
    utilizations.add(res);
    if (utilizations.length >= 30) {
      utilizations.removeAt(0);
    }
    if (utilizations.last.gpu != null) {
      _tabController = TabController(initialIndex: widget.tabIndex, length: 9, vsync: this);
    }
    setState(() {
      loading = false;
    });
    // _cpuChartController?.updateDataSource(
    //   addedDataIndexes: <int>[utilizations.length - 1],
    //   removedDataIndexes: <int>[0],
    // );
    // _memoryChartController?.updateDataSource(
    //   addedDataIndexes: <int>[utilizations.length - 1],
    //   removedDataIndexes: <int>[0],
    // );
    // _lunReadChartController?.updateDataSource(
    //   addedDataIndexes: <int>[utilizations.length - 1],
    //   removedDataIndexes: <int>[0],
    // );
    // _lunWriteChartController?.updateDataSource(
    //   addedDataIndexes: <int>[utilizations.length - 1],
    //   removedDataIndexes: <int>[0],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: LoadingWidget(size: 30),
          )
        : SafeArea(
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  tabs: [
                    Tab(text: "概览"),
                    Tab(text: "CPU"),
                    Tab(text: "内存"),
                    Tab(text: "网络"),
                    Tab(text: "磁盘"),
                    Tab(text: "存储空间"),
                    Tab(text: "LUN"),
                    if (utilizations.last.gpu != null) Tab(text: "GPU"),
                    Tab(text: "NFS"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        children: [
                          WidgetCard(
                            title: "CPU",
                            icon: Text(
                              "${utilizations.last.cpu?.totalLoad ?? '-'} %",
                              style: TextStyle(
                                  color: utilizations.last.cpu?.totalLoad != null
                                      ? utilizations.last.cpu!.totalLoad > 80
                                          ? AppTheme.of(context)?.errorColor
                                          : AppTheme.of(context)?.successColor
                                      : AppTheme.of(context)?.placeholderColor),
                            ),
                            body: CpuChartWidget(utilizations.map((e) => e.cpu ?? Cpu()).toList()),
                          ),
                          if (utilizations.last.gpu != null)
                            WidgetCard(
                              title: "GPU",
                              icon: Text(
                                "${utilizations.last.gpu?.gpuUtilization ?? '-'} %",
                                style: TextStyle(
                                    color: utilizations.last.gpu?.gpuUtilization != null
                                        ? utilizations.last.gpu!.gpuUtilization! > 80
                                            ? AppTheme.of(context)?.errorColor
                                            : AppTheme.of(context)?.successColor
                                        : AppTheme.of(context)?.placeholderColor),
                              ),
                              body: GpuChartWidget(utilizations.map((e) => e.gpu ?? Gpu()).toList()),
                            ),
                          WidgetCard(
                            title: "内存",
                            icon: Text(
                              "${utilizations.last.memory?.realUsage ?? '-'} %",
                              style: TextStyle(
                                  color: utilizations.last.memory?.realUsage != null
                                      ? utilizations.last.memory!.realUsage! > 80
                                          ? AppTheme.of(context)?.errorColor
                                          : AppTheme.of(context)?.successColor
                                      : AppTheme.of(context)?.placeholderColor),
                            ),
                            body: MemoryChartWidget(utilizations.map((e) => e.memory ?? Memory()).toList()),
                          ),
                          if (utilizations.last.gpu != null)
                            WidgetCard(
                              title: "GPU内存",
                              icon: Text(
                                "${utilizations.last.gpu?.gpuMemoryUtilization ?? '-'} %",
                                style: TextStyle(
                                    color: utilizations.last.gpu?.gpuMemoryUtilization != null
                                        ? utilizations.last.gpu!.gpuMemoryUtilization! > 80
                                            ? AppTheme.of(context)?.errorColor
                                            : AppTheme.of(context)?.successColor
                                        : AppTheme.of(context)?.placeholderColor),
                              ),
                              body: GpuMemoryChartWidget(utilizations.map((e) => e.gpu ?? Gpu()).toList()),
                            ),
                          WidgetCard(
                            title: "网络",
                            icon: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/arrow_down.png",
                                  width: 20,
                                  height: 20,
                                ),
                                Text(
                                  utilizations.last.network == null ? '-' : Utils.formatSize(utilizations.last.network!.first.tx!, showByte: true) + "/S",
                                  style: TextStyle(color: AppTheme.of(context)?.primaryColor),
                                ),
                                SizedBox(width: 20),
                                Image.asset(
                                  "assets/icons/arrow_up.png",
                                  width: 20,
                                  height: 20,
                                ),
                                Text(
                                  utilizations.last.network == null ? '-' : Utils.formatSize(utilizations.last.network!.first.rx!, showByte: true) + "/S",
                                  style: TextStyle(color: AppTheme.of(context)?.successColor),
                                ),
                              ],
                            ),
                            body: NetworkChartWidget(utilizations.map((e) => e.network?.first ?? Network()).toList()),
                          ),
                          WidgetCard(
                            title: "存储空间",
                            icon: Row(
                              children: [
                                Label("R", Colors.orange, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.space?.total?.readByte != null ? Utils.formatSize(utilizations.last.space!.total!.readByte!) : '-'}/S",
                                  style: TextStyle(color: Colors.orange),
                                ),
                                SizedBox(width: 20),
                                Label("W", Colors.amber, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.space?.total?.writeByte != null ? Utils.formatSize(utilizations.last.space!.total!.writeByte!) : '-'}/S",
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ],
                            ),
                            body: SpaceChartWidget(utilizations.map((e) => e.space ?? Space()).toList()),
                          ),
                          WidgetCard(
                            title: "LUN",
                            icon: Row(
                              children: [
                                Label("R", Colors.cyan, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.totalLun?.readThroughput != null ? Utils.formatSize(utilizations.last.totalLun!.readThroughput!) : '-'}/S",
                                  style: TextStyle(color: Colors.cyan),
                                ),
                                SizedBox(width: 20),
                                Label("W", Colors.lightGreen, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.totalLun?.writeThroughput != null ? Utils.formatSize(utilizations.last.totalLun!.writeThroughput!) : '-'}/S",
                                  style: TextStyle(color: Colors.lightGreen),
                                ),
                              ],
                            ),
                            body: LunChartWidget(utilizations.map((e) => e.totalLun ?? Lun()).toList()),
                          ),
                          WidgetCard(
                            title: "NFS",
                            icon: Row(
                              children: [
                                Label("R", Colors.deepPurpleAccent, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.totalNfs?.readOPS ?? '-'}/S",
                                  style: TextStyle(color: Colors.deepPurpleAccent),
                                ),
                                SizedBox(width: 10),
                                Label("W", Colors.purpleAccent, fill: true),
                                SizedBox(width: 5),
                                Text(
                                  "${utilizations.last.totalNfs?.writeOPS ?? '-'}/S",
                                  style: TextStyle(color: Colors.purpleAccent),
                                ),
                              ],
                            ),
                            body: NfsChartWidget(utilizations.map((e) => e.totalNfs ?? Nfs()).toList()),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          WidgetCard(
                            bodyPadding: EdgeInsets.symmetric(vertical: 14),
                            body: SizedBox(
                              height: 300,
                              child: CpuDetailChartWidget(utilizations.map((e) => e.cpu ?? Cpu()).toList()),
                            ),
                          ),
                          WidgetCard(
                            title: "利用率",
                            icon: Text(
                              "${utilizations.last.cpu?.totalLoad ?? '-'} %",
                              style: TextStyle(
                                  color: utilizations.last.cpu?.totalLoad != null
                                      ? utilizations.last.cpu!.totalLoad > 80
                                          ? AppTheme.of(context)?.errorColor
                                          : AppTheme.of(context)?.successColor
                                      : AppTheme.of(context)?.placeholderColor),
                            ),
                            body: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "用户",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${utilizations.last.cpu?.userLoad}%",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.of(context)?.successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "系统",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${utilizations.last.cpu?.systemLoad}%",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightBlueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "I/O等待",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${utilizations.last.cpu?.otherLoad}%",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.of(context)?.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          WidgetCard(
                            title: "平均负载",
                            icon: Text(
                              "${utilizations.last.cpu?.totalLoad ?? '-'} %",
                              style: TextStyle(
                                  color: utilizations.last.cpu?.totalLoad != null
                                      ? utilizations.last.cpu!.totalLoad > 80
                                          ? AppTheme.of(context)?.errorColor
                                          : AppTheme.of(context)?.successColor
                                      : AppTheme.of(context)?.placeholderColor),
                            ),
                            body: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "1分钟",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${(utilizations.last.cpu?.minLoad1 ?? 0) / 100}",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "5分钟",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${(utilizations.last.cpu?.minLoad5 ?? 0) / 100}",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "15分钟",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.of(context)?.placeholderColor,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${(utilizations.last.cpu?.minLoad15 ?? 0) / 100}",
                                        strutStyle: StrutStyle(forceStrutHeight: true),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                        ],
                      ),
                      ListView(
                        children: [
                          WidgetCard(
                            bodyPadding: EdgeInsets.symmetric(vertical: 14),
                            body: SizedBox(
                              height: 300,
                              child: MemoryChartWidget(utilizations.map((e) => e.memory ?? Memory()).toList()),
                            ),
                          ),
                          WidgetCard(
                            title: "内存结构",
                            icon: Text(
                              "${utilizations.last.cpu?.totalLoad ?? '-'} %",
                              style: TextStyle(
                                  color: utilizations.last.cpu?.totalLoad != null
                                      ? utilizations.last.cpu!.totalLoad > 80
                                          ? AppTheme.of(context)?.errorColor
                                          : AppTheme.of(context)?.successColor
                                      : AppTheme.of(context)?.placeholderColor),
                            ),
                            body: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "已保留",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize(((utilizations.last.memory?.memorySize ?? 0) - (utilizations.last.memory?.totalReal ?? 0)) * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "已用",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize((utilizations.last.memory?.realUsage ?? 0) * (utilizations.last.memory?.memorySize ?? 0) / 100 * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.of(context)?.warningColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "缓冲",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize((utilizations.last.memory?.buffer ?? 0) * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "缓存",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize((utilizations.last.memory?.cached ?? 0) * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "可用",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize((utilizations.last.memory?.availReal ?? 0) * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.of(context)?.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "总计",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.of(context)?.placeholderColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${Utils.formatSize((utilizations.last.memory?.memorySize ?? 0) * 1024, fixed: 1)}",
                                            strutStyle: StrutStyle(forceStrutHeight: true),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.of(context)?.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                        ],
                      ),
                      ListView.builder(
                        itemBuilder: (context, i) {
                          int? deviceIndex = int.tryParse(utilizations.last.network![i + 1].device?.replaceAll("eth", "") ?? '0');

                          return WidgetCard(
                            title: "局域网 ${deviceIndex != null ? deviceIndex + 1 : ''}",
                            icon: Row(
                              children: [
                                Image.asset(
                                  "assets/icons/arrow_down.png",
                                  width: 20,
                                  height: 20,
                                ),
                                Text(
                                  utilizations.last.network == null ? '-' : Utils.formatSize(utilizations.last.network![i + 1].tx!, showByte: true) + "/S",
                                  style: TextStyle(color: AppTheme.of(context)?.primaryColor),
                                ),
                                SizedBox(width: 20),
                                Image.asset(
                                  "assets/icons/arrow_up.png",
                                  width: 20,
                                  height: 20,
                                ),
                                Text(
                                  utilizations.last.network == null ? '-' : Utils.formatSize(utilizations.last.network![i + 1].rx!, showByte: true) + "/S",
                                  style: TextStyle(color: AppTheme.of(context)?.successColor),
                                ),
                              ],
                            ),
                            body: NetworkChartWidget(utilizations.map((e) => e.network?[i + 1] ?? Network()).toList()),
                          );
                        },
                        itemCount: (utilizations.last.network?.length ?? 0) - 1,
                      ),
                      ListView(
                        children: [
                          WidgetCard(
                            title: "读取速度",
                            icon: Row(
                              children: [
                                Text(
                                  "${utilizations.last.space?.total?.readByte != null ? Utils.formatSize(utilizations.last.space!.total!.readByte!) : '-'}/S",
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                            body: SpaceChartWidget(
                              utilizations.map((e) => e.space ?? Space()).toList(),
                              showWrite: false,
                            ),
                          ),
                          WidgetCard(
                            title: "写入速度",
                            icon: Row(
                              children: [
                                Text(
                                  "${utilizations.last.space?.total?.writeByte != null ? Utils.formatSize(utilizations.last.space!.total!.writeByte!) : '-'}/S",
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ],
                            ),
                            body: SpaceChartWidget(
                              utilizations.map((e) => e.space ?? Space()).toList(),
                              showRead: false,
                            ),
                          ),
                        ],
                      ),
                      Placeholder(),
                      Placeholder(),
                      if (utilizations.last.gpu != null) Placeholder(),
                      Placeholder(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
