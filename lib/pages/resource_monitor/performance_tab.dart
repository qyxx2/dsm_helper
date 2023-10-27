import 'dart:async';
import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/pages/resource_monitor/widgets/cpu_chart_widget.dart';
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

class _PerformanceTabState extends State<PerformanceTab> with SingleTickerProviderStateMixin {
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
  List colors = [Colors.red, Colors.purpleAccent, Colors.redAccent, Colors.green, Colors.amber, Colors.orange, Colors.teal, Colors.indigoAccent, Colors.cyanAccent, Colors.yellow, Colors.black, Colors.lightGreenAccent, Colors.pinkAccent];
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
    _tabController = TabController(initialIndex: widget.tabIndex, length: 6, vsync: this);
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
    print("1111111111");
    if (utilizations.length >= 30) {
      utilizations.removeAt(0);
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
                      Placeholder(),
                      Placeholder(),
                      Placeholder(),
                      Placeholder(),
                      Placeholder(),
                    ],
                  ),
                ),
                // Expanded(
                //   child: TabBarView(
                //     controller: _tabController,
                //     children: [
                //       ListView(
                //         children: [
                //           AspectRatio(
                //             aspectRatio: 1,
                //             child: Padding(
                //               padding: const EdgeInsets.all(20),
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: Theme.of(context).scaffoldBackgroundColor,
                //                   borderRadius: BorderRadius.circular(20),
                //                 ),
                //                 // padding: EdgeInsets.symmetric(horizontal: 10),
                //                 child: Padding(
                //                   padding: EdgeInsets.all(10),
                //                   child: LineChart(
                //                     LineChartData(
                //                       lineTouchData: LineTouchData(
                //                         touchTooltipData: LineTouchTooltipData(
                //                             tooltipBgColor: Colors.white.withOpacity(0.6),
                //                             tooltipRoundedRadius: 20,
                //                             fitInsideHorizontally: true,
                //                             fitInsideVertically: true,
                //                             getTooltipItems: (items) {
                //                               return [
                //                                 LineTooltipItem("用户：${items[2].y}%", TextStyle(color: Color(0xffBAE050))),
                //                                 LineTooltipItem("系统：${items[1].y - items[2].y}%", TextStyle(color: Color(0xff73B0EE))),
                //                                 LineTooltipItem("I/O：${items[0].y - items[1].y}%", TextStyle(color: Color(0xff5584C8))),
                //                               ];
                //                             }),
                //                       ),
                //                       gridData: FlGridData(
                //                         show: false,
                //                       ),
                //                       titlesData: FlTitlesData(
                //                         show: true,
                //                         bottomTitles: AxisTitles(
                //                           sideTitles: SideTitles(
                //                             showTitles: false,
                //                             reservedSize: 22,
                //                           ),
                //                         ),
                //                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                         leftTitles: AxisTitles(
                //                             sideTitles: SideTitles(
                //                           showTitles: true,
                //                           getTitlesWidget: (value, _) {
                //                             return Text(
                //                               "${value.toInt()}%",
                //                               style: TextStyle(
                //                                 color: Color(0xff67727d),
                //                                 fontSize: 12,
                //                               ),
                //                             );
                //                           },
                //                           // getTextStyles: (value, _) => const ,
                //                           // getTitles: Utils.formatSize,
                //                           // getTitles: (value) {
                //                           //   value = value / 1000 / 1000;
                //                           //   return (value.floor() * 1000).toString();
                //                           // },
                //                           reservedSize: 35,
                //                           interval: 10,
                //                         )),
                //                       ),
                //                       minY: 0,
                //                       maxY: 100,
                //                       // maxY: 20,
                //                       borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                       lineBarsData: [
                //                         LineChartBarData(
                //                           spots: cpus.map((cpu) {
                //                             return FlSpot(cpus.indexOf(cpu).toDouble(), (cpu['user_load'] + cpu['system_load'] + cpu['other_load']).toDouble());
                //                           }).toList(),
                //                           isCurved: true,
                //                           color: Color(0xff5584C8),
                //                           barWidth: 2,
                //                           isStrokeCapRound: true,
                //                           dotData: FlDotData(
                //                             show: false,
                //                           ),
                //                           belowBarData: BarAreaData(
                //                             show: true,
                //                             color: Color(0xff5584C8),
                //                           ),
                //                         ),
                //                         LineChartBarData(
                //                           spots: cpus.map((cpu) {
                //                             return FlSpot(cpus.indexOf(cpu).toDouble(), (cpu['user_load'] + cpu['system_load']).toDouble());
                //                           }).toList(),
                //                           isCurved: true,
                //                           color: Color(0xff73B0EE),
                //                           barWidth: 2,
                //                           isStrokeCapRound: true,
                //                           dotData: FlDotData(
                //                             show: false,
                //                           ),
                //                           belowBarData: BarAreaData(
                //                             show: true,
                //                             color: Color(0xff73B0EE),
                //                           ),
                //                         ),
                //                         LineChartBarData(
                //                           spots: cpus.map((cpu) {
                //                             return FlSpot(cpus.indexOf(cpu).toDouble(), cpu['user_load'].toDouble());
                //                           }).toList(),
                //                           isCurved: true,
                //                           color: Color(0xffBAE050),
                //                           barWidth: 2,
                //                           isStrokeCapRound: true,
                //                           dotData: FlDotData(
                //                             show: false,
                //                           ),
                //                           belowBarData: BarAreaData(
                //                             show: true,
                //                             color: Color(0xffBAE050),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           Container(
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //             child: Padding(
                //               padding: EdgeInsets.all(20),
                //               child: Column(
                //                 children: [
                //                   Row(
                //                     children: [
                //                       Text(
                //                         "利用率",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                       Spacer(),
                //                       Text(
                //                         "${cpus.last['user_load'] + cpus.last['system_load']} %",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                     ],
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Row(
                //                     children: [
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['user_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                     TextSpan(text: " %"),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Color(0xffBAE050)),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("用户"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       Spacer(),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['system_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                     TextSpan(text: " %"),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Color(0xff73B0EE)),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("系统"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       Spacer(),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['other_load']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                     TextSpan(text: " %"),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Color(0xff5584C8)),
                //                               ),
                //                               SizedBox(
                //                                 height: 10,
                //                               ),
                //                               Text("I/O"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Container(
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //             child: Padding(
                //               padding: EdgeInsets.all(20),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     "负载平均",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Row(
                //                     children: [
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['1min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("1分钟"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       Spacer(),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['5min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("5分钟"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       Spacer(),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${cpus.last['15min_load'] / 100}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                               ),
                //                               SizedBox(
                //                                 height: 10,
                //                               ),
                //                               Text("15分钟"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //       ListView(
                //         children: [
                //           AspectRatio(
                //             aspectRatio: 1,
                //             child: Padding(
                //               padding: const EdgeInsets.all(20),
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: Theme.of(context).scaffoldBackgroundColor,
                //                   borderRadius: BorderRadius.circular(20),
                //                 ),
                //                 // padding: EdgeInsets.symmetric(horizontal: 10),
                //                 child: Padding(
                //                   padding: EdgeInsets.all(10),
                //                   child: LineChart(
                //                     LineChartData(
                //                       lineTouchData: LineTouchData(
                //                         touchTooltipData: LineTouchTooltipData(
                //                             tooltipBgColor: Colors.white.withOpacity(0.6),
                //                             tooltipRoundedRadius: 20,
                //                             fitInsideHorizontally: true,
                //                             fitInsideVertically: true,
                //                             getTooltipItems: (items) {
                //                               return [
                //                                 LineTooltipItem("利用率：${items[0].y}%", TextStyle(color: Colors.blue)),
                //                               ];
                //                             }),
                //                       ),
                //                       gridData: FlGridData(
                //                         show: false,
                //                       ),
                //                       titlesData: FlTitlesData(
                //                         show: true,
                //                         bottomTitles: AxisTitles(
                //                           sideTitles: SideTitles(
                //                             showTitles: false,
                //                             reservedSize: 22,
                //                           ),
                //                         ),
                //                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                         leftTitles: AxisTitles(
                //                             sideTitles: SideTitles(
                //                           showTitles: true,
                //                           getTitlesWidget: (value, _) {
                //                             return Text(
                //                               "${value.toInt()}%",
                //                               style: TextStyle(
                //                                 color: Color(0xff67727d),
                //                                 fontSize: 12,
                //                               ),
                //                             );
                //                           },
                //                           // getTextStyles: (value, _) => const ,
                //                           // getTitles: Utils.formatSize,
                //                           // getTitles: (value) {
                //                           //   value = value / 1000 / 1000;
                //                           //   return (value.floor() * 1000).toString();
                //                           // },
                //                           reservedSize: 35,
                //                           interval: 10,
                //                         )),
                //                       ),
                //                       minY: 0,
                //                       maxY: 100,
                //                       // maxY: 20,
                //                       borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                       lineBarsData: [
                //                         LineChartBarData(
                //                           spots: memories.map((memory) {
                //                             return FlSpot(memories.indexOf(memory).toDouble(), memory['real_usage'].toDouble());
                //                           }).toList(),
                //                           isCurved: true,
                //                           color: Colors.blue,
                //                           barWidth: 2,
                //                           isStrokeCapRound: true,
                //                           dotData: FlDotData(
                //                             show: false,
                //                           ),
                //                           belowBarData: BarAreaData(
                //                             show: true,
                //                             color: Colors.blue.withOpacity(0.2),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           Container(
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //             child: Padding(
                //               padding: EdgeInsets.all(20),
                //               child: Column(
                //                 children: [
                //                   Row(
                //                     children: [
                //                       Text(
                //                         "利用率",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                       SizedBox(
                //                         width: 20,
                //                       ),
                //                       Text(
                //                         "${memories.last['real_usage']} %",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                       Spacer(),
                //                       Text(
                //                         "总计",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                       SizedBox(
                //                         width: 20,
                //                       ),
                //                       Text(
                //                         "${Utils.formatSize(memories.last['memory_size'] * 1024, fixed: 0)}",
                //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                       ),
                //                     ],
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Row(
                //                     children: [
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${Utils.formatSize((memories.last['memory_size'] - memories.last['total_real']) * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Colors.grey),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("已保留"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       SizedBox(
                //                         width: 20,
                //                       ),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${Utils.formatSize(memories.last['real_usage'] * memories.last['memory_size'] * 10.24, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Colors.orange),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("已用"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       SizedBox(
                //                         width: 20,
                //                       ),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${Utils.formatSize(memories.last['buffer'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Colors.lightBlue),
                //                               ),
                //                               SizedBox(
                //                                 height: 10,
                //                               ),
                //                               Text("缓冲"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Row(
                //                     children: [
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${Utils.formatSize(memories.last['cached'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Colors.cyan),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("缓存"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       SizedBox(
                //                         width: 20,
                //                       ),
                //                       Container(
                //                         width: (MediaQuery.of(context).size.width - 120) / 3,
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         child: Padding(
                //                           padding: EdgeInsets.symmetric(vertical: 20),
                //                           child: Column(
                //                             children: [
                //                               Text.rich(
                //                                 TextSpan(
                //                                   children: [
                //                                     TextSpan(text: "${Utils.formatSize(memories.last['avail_real'] * 1024, fixed: 1)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                //                                   ],
                //                                 ),
                //                                 style: TextStyle(color: Colors.green),
                //                               ),
                //                               SizedBox(
                //                                 height: 5,
                //                               ),
                //                               Text("可用"),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       Spacer(),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //       ListView(
                //         children: [
                //           SizedBox(
                //             height: 20,
                //           ),
                //           for (int i = 0; i < networkCount; i++)
                //             Container(
                //               margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //               decoration: BoxDecoration(
                //                 color: Theme.of(context).scaffoldBackgroundColor,
                //                 borderRadius: BorderRadius.circular(20),
                //               ),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.symmetric(horizontal: 20),
                //                     child: Text(
                //                       i == 0 ? "总计" : "局域网 $i",
                //                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                     ),
                //                   ),
                //                   AspectRatio(
                //                     aspectRatio: 1.70,
                //                     child: Padding(
                //                       padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                       child: Container(
                //                         decoration: BoxDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(20),
                //                         ),
                //                         // padding: EdgeInsets.symmetric(horizontal: 10),
                //                         child: Padding(
                //                           padding: EdgeInsets.all(10),
                //                           child: LineChart(
                //                             LineChartData(
                //                               lineTouchData: LineTouchData(
                //                                 touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (List<LineBarSpot> items) {
                //                                     return items.map((LineBarSpot touchedSpot) {
                //                                       final textStyle = TextStyle(
                //                                         color: touchedSpot.bar.color,
                //                                         fontWeight: FontWeight.bold,
                //                                         fontSize: 14,
                //                                       );
                //                                       return LineTooltipItem('${touchedSpot.bar.color == Colors.blue ? "上传" : "下载"}:${Utils.formatSize(touchedSpot.y.floor())}', textStyle);
                //                                     }).toList();
                //                                   },
                //                                 ),
                //                               ),
                //                               gridData: FlGridData(
                //                                 show: false,
                //                               ),
                //                               titlesData: FlTitlesData(
                //                                 show: true,
                //                                 bottomTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                     showTitles: false,
                //                                     reservedSize: 22,
                //                                   ),
                //                                 ),
                //                                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                                 rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                                 leftTitles: AxisTitles(
                //                                     sideTitles: SideTitles(
                //                                   showTitles: true,
                //                                   getTitlesWidget: (value, _) {
                //                                     return Text(
                //                                       Utils.formatSize(value, fixed: 0),
                //                                       style: TextStyle(
                //                                         color: Color(0xff67727d),
                //                                         fontSize: 12,
                //                                       ),
                //                                     );
                //                                   },
                //                                   // getTextStyles: (value, _) => const ,
                //                                   // getTitles: Utils.formatSize,
                //                                   // getTitles: (value) {
                //                                   //   value = value / 1000 / 1000;
                //                                   //   return (value.floor() * 1000).toString();
                //                                   // },
                //                                   reservedSize: 28,
                //                                   interval: Utils.chartInterval(maxNetworkSpeed),
                //                                 )),
                //                               ),
                //                               // titlesData: FlTitlesData(
                //                               //   show: true,
                //                               //   bottomTitles: SideTitles(
                //                               //     showTitles: false,
                //                               //     reservedSize: 22,
                //                               //   ),
                //                               //   topTitles: SideTitles(showTitles: false),
                //                               //   rightTitles: SideTitles(showTitles: false),
                //                               //   leftTitles: SideTitles(
                //                               //     showTitles: true,
                //                               //     getTextStyles: (value, _) => const TextStyle(
                //                               //       color: Color(0xff67727d),
                //                               //       fontSize: 12,
                //                               //     ),
                //                               //     getTitles: (v) {
                //                               //       return Utils.formatSize(v, maxNetworkSpeed);
                //                               //     },
                //                               //     reservedSize: 28,
                //                               //     interval: Utils.chartInterval(maxNetworkSpeed),
                //                               //   ),
                //                               // ),
                //                               minY: 0,
                //                               // maxY: 20,
                //                               borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                               lineBarsData: [
                //                                 LineChartBarData(
                //                                   spots: networks.map((network) {
                //                                     return FlSpot(networks.indexOf(network).toDouble(), network[i]['tx'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: Colors.blue,
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                   belowBarData: BarAreaData(
                //                                     show: true,
                //                                     color: Colors.blue.withOpacity(0.2),
                //                                   ),
                //                                 ),
                //                                 LineChartBarData(
                //                                   spots: networks.map((network) {
                //                                     return FlSpot(networks.indexOf(network).toDouble(), network[i]['rx'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: Colors.green,
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                   belowBarData: BarAreaData(
                //                                     show: true,
                //                                     color: Colors.green.withOpacity(0.2),
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.symmetric(horizontal: 20),
                //                     child: Row(
                //                       children: [
                //                         Icon(
                //                           Icons.upload_sharp,
                //                           color: Colors.blue,
                //                         ),
                //                         Text(
                //                           Utils.formatSize(networks.last[i]['tx']) + "/S",
                //                           style: TextStyle(color: Colors.blue),
                //                         ),
                //                         Spacer(),
                //                         Icon(
                //                           Icons.download_sharp,
                //                           color: Colors.green,
                //                         ),
                //                         Text(
                //                           Utils.formatSize(networks.last[i]['rx']) + "/S",
                //                           style: TextStyle(color: Colors.green),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                   SizedBox(
                //                     height: 20,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //         ],
                //       ),
                //       ListView(
                //         children: [
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 20),
                //             child: Wrap(
                //               spacing: 10,
                //               runSpacing: 10,
                //               children: [
                //                 Label("总计", Colors.blue),
                //                 for (int i = 0; i < disks.last['disk'].length; i++)
                //                   Label(
                //                     "${disks.last['disk'][i]['display_name']}",
                //                     colors[i],
                //                     height: 22,
                //                   ),
                //               ],
                //             ),
                //           ),
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "利用率",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < disks.last['disk'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${disks.last['disk'][i]['display_name']}：${disks[items[0].spotIndex]['disk'][i]['utilization'].floor()}%",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${disks[items[0].spotIndex]['total']['utilization'].floor()}%", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}%",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 35,
                //                                 interval: 10,
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             maxY: 100,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: disks.map((disk) {
                //                                   return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['utilization'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < disks.last['disk'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: disks.map((disk) {
                //                                     return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['utilization'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "读取速度",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < disks.last['disk'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${disks.last['disk'][i]['display_name']}：${Utils.formatSize(disks[items[0].spotIndex]['disk'][i]['read_byte'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(disks[items[0].spotIndex]['total']['read_byte'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     Utils.formatSize(value, fixed: 0),
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 28,
                //                                 interval: Utils.chartInterval(maxDiskReadSpeed),
                //                               )),
                //                             ),
                //                             // titlesData: FlTitlesData(
                //                             //   show: true,
                //                             //   bottomTitles: SideTitles(
                //                             //     showTitles: false,
                //                             //     reservedSize: 22,
                //                             //   ),
                //                             //   topTitles: SideTitles(showTitles: false),
                //                             //   rightTitles: SideTitles(showTitles: false),
                //                             //   leftTitles: SideTitles(
                //                             //     showTitles: true,
                //                             //     getTextStyles: (value, _) => const TextStyle(
                //                             //       color: Color(0xff67727d),
                //                             //       fontSize: 12,
                //                             //     ),
                //                             //     getTitles: (v) {
                //                             //       return ;
                //                             //     },
                //                             //     reservedSize: 28,
                //                             //     interval:,
                //                             //   ),
                //                             // ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: disks.map((disk) {
                //                                   return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['read_byte'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < disks.last['disk'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: disks.map((disk) {
                //                                     return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['read_byte'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "写入速度",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < disks.last['disk'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${disks.last['disk'][i]['display_name']}：${Utils.formatSize(disks[items[0].spotIndex]['disk'][i]['write_byte'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(disks[items[0].spotIndex]['total']['write_byte'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     Utils.formatSize(value, fixed: 0),
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 28,
                //                                 interval: Utils.chartInterval(maxDiskWriteSpeed),
                //                               )),
                //                             ),
                //                             // titlesData: FlTitlesData(
                //                             //   show: true,
                //                             //   bottomTitles: SideTitles(
                //                             //     showTitles: false,
                //                             //     reservedSize: 22,
                //                             //   ),
                //                             //   topTitles: SideTitles(showTitles: false),
                //                             //   rightTitles: SideTitles(showTitles: false),
                //                             //   leftTitles: SideTitles(
                //                             //     showTitles: true,
                //                             //     getTextStyles: (value, _) => const TextStyle(
                //                             //       color: Color(0xff67727d),
                //                             //       fontSize: 12,
                //                             //     ),
                //                             //     getTitles: (v) {
                //                             //       return ;
                //                             //     },
                //                             //     reservedSize: 28,
                //                             //     interval: ,
                //                             //   ),
                //                             // ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: disks.map((disk) {
                //                                   return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['write_byte'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < disks.last['disk'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: disks.map((disk) {
                //                                     return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['write_byte'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "读取IOPS",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < disks.last['disk'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${disks.last['disk'][i]['display_name']}：${disks[items[0].spotIndex]['disk'][i]['read_access'].floor()}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${disks[items[0].spotIndex]['total']['read_access'].floor()}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 28,
                //                                 // interval: 10,
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: disks.map((disk) {
                //                                   return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['read_access'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < disks.last['disk'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: disks.map((disk) {
                //                                     return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['read_access'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "写入IOPS",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < disks.last['disk'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${disks.last['disk'][i]['display_name']}：${Utils.formatSize(disks[items[0].spotIndex]['disk'][i]['write_access'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(disks[items[0].spotIndex]['total']['write_access'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 reservedSize: 28,
                //                                 // interval: 10,
                //                               )),
                //                             ),
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: disks.map((disk) {
                //                                   return FlSpot(disks.indexOf(disk).toDouble(), disk['total']['write_access'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < disks.last['disk'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: disks.map((disk) {
                //                                     return FlSpot(disks.indexOf(disk).toDouble(), disk['disk'][i]['write_access'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //       ListView(
                //         children: [
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 20),
                //             child: Wrap(
                //               spacing: 10,
                //               runSpacing: 10,
                //               children: [
                //                 Label("总计", Colors.blue),
                //                 for (int i = 0; i < spaces.last['volume'].length; i++)
                //                   Label(
                //                     "${spaces.last['volume'][i]['display_name']}",
                //                     colors[i],
                //                     height: 22,
                //                   ),
                //               ],
                //             ),
                //           ),
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "利用率",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${spaces.last['volume'][i]['display_name']}：${spaces[items[0].spotIndex]['volume'][i]['utilization'].floor()}%",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${spaces[items[0].spotIndex]['total']['utilization'].floor()}%", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}%",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 reservedSize: 35,
                //                                 interval: 10,
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             maxY: 100,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: spaces.map((volume) {
                //                                   return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['utilization'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: spaces.map((volume) {
                //                                     return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['utilization'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "读取速度",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${spaces.last['volume'][i]['display_name']}：${Utils.formatSize(spaces[items[0].spotIndex]['volume'][i]['read_byte'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(spaces[items[0].spotIndex]['total']['read_byte'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     Utils.formatSize(value, fixed: 0),
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 reservedSize: 28,
                //                                 interval: Utils.chartInterval(maxVolumeReadSpeed),
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: spaces.map((volume) {
                //                                   return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['read_byte'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: spaces.map((volume) {
                //                                     return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['read_byte'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "写入速度",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${spaces.last['volume'][i]['display_name']}：${Utils.formatSize(spaces[items[0].spotIndex]['volume'][i]['write_byte'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(spaces[items[0].spotIndex]['total']['write_byte'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     Utils.formatSize(value, fixed: 0),
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 28,
                //                                 interval: Utils.chartInterval(maxVolumeWriteSpeed),
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: spaces.map((volume) {
                //                                   return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['write_byte'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: spaces.map((volume) {
                //                                     return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['write_byte'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "读取IOPS",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${spaces.last['volume'][i]['display_name']}：${spaces[items[0].spotIndex]['volume'][i]['read_access'].floor()}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${spaces[items[0].spotIndex]['total']['read_access'].floor()}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 reservedSize: 28,
                //                                 // interval: 10,
                //                               )),
                //                             ),
                //                             minY: 0,
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: spaces.map((volume) {
                //                                   return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['read_access'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: spaces.map((volume) {
                //                                     return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['read_access'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).scaffoldBackgroundColor,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.symmetric(horizontal: 20),
                //                   child: Text(
                //                     "写入IOPS",
                //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                   ),
                //                 ),
                //                 AspectRatio(
                //                   aspectRatio: 1.70,
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                //                     child: Container(
                //                       decoration: BoxDecoration(
                //                         color: Theme.of(context).scaffoldBackgroundColor,
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       // padding: EdgeInsets.symmetric(horizontal: 10),
                //                       child: Padding(
                //                         padding: EdgeInsets.all(10),
                //                         child: LineChart(
                //                           LineChartData(
                //                             lineTouchData: LineTouchData(
                //                               touchTooltipData: LineTouchTooltipData(
                //                                   tooltipBgColor: Colors.white.withOpacity(0.6),
                //                                   tooltipRoundedRadius: 20,
                //                                   fitInsideHorizontally: true,
                //                                   fitInsideVertically: true,
                //                                   getTooltipItems: (items) {
                //                                     return [
                //                                       for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                         LineTooltipItem(
                //                                           "${spaces.last['volume'][i]['display_name']}：${Utils.formatSize(spaces[items[0].spotIndex]['volume'][i]['write_access'].floor())}",
                //                                           TextStyle(color: colors[i]),
                //                                         ),
                //                                       LineTooltipItem("总计：${Utils.formatSize(spaces[items[0].spotIndex]['total']['write_access'].floor())}", TextStyle(color: Colors.blue)),
                //                                     ];
                //                                   }),
                //                             ),
                //                             gridData: FlGridData(
                //                               show: false,
                //                             ),
                //                             titlesData: FlTitlesData(
                //                               show: true,
                //                               bottomTitles: AxisTitles(
                //                                 sideTitles: SideTitles(
                //                                   showTitles: false,
                //                                   reservedSize: 22,
                //                                 ),
                //                               ),
                //                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //                               leftTitles: AxisTitles(
                //                                   sideTitles: SideTitles(
                //                                 showTitles: true,
                //                                 getTitlesWidget: (value, _) {
                //                                   return Text(
                //                                     "${value.toInt()}",
                //                                     style: TextStyle(
                //                                       color: Color(0xff67727d),
                //                                       fontSize: 12,
                //                                     ),
                //                                   );
                //                                 },
                //                                 // getTextStyles: (value, _) => const ,
                //                                 // getTitles: Utils.formatSize,
                //                                 // getTitles: (value) {
                //                                 //   value = value / 1000 / 1000;
                //                                 //   return (value.floor() * 1000).toString();
                //                                 // },
                //                                 reservedSize: 28,
                //                                 // interval: 10,
                //                               )),
                //                             ),
                //                             // maxY: 20,
                //                             borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12, width: 1)),
                //                             lineBarsData: [
                //                               LineChartBarData(
                //                                 spots: spaces.map((volume) {
                //                                   return FlSpot(spaces.indexOf(volume).toDouble(), volume['total']['write_access'].toDouble());
                //                                 }).toList(),
                //                                 isCurved: true,
                //                                 color: Colors.blue,
                //                                 barWidth: 2,
                //                                 isStrokeCapRound: true,
                //                                 dotData: FlDotData(
                //                                   show: false,
                //                                 ),
                //                               ),
                //                               for (int i = 0; i < spaces.last['volume'].length; i++)
                //                                 LineChartBarData(
                //                                   spots: spaces.map((volume) {
                //                                     return FlSpot(spaces.indexOf(volume).toDouble(), volume['volume'][i]['write_access'].toDouble());
                //                                   }).toList(),
                //                                   isCurved: true,
                //                                   color: colors[i],
                //                                   barWidth: 2,
                //                                   isStrokeCapRound: true,
                //                                   dotData: FlDotData(
                //                                     show: false,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
  }
}
