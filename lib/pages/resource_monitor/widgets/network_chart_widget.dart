import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NetworkChartWidget extends StatelessWidget {
  const NetworkChartWidget(this.networks, {this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Network> networks;
  final Function(ChartSeriesController)? onReadRendererCreated;
  final Function(ChartSeriesController)? onWriteRendererCreated;

  int get maxNetworkSpeed {
    int maxSpeed = 0;
    for (var network in networks) {
      int maxVal = max(network.rx ?? 0, network.tx ?? 0);
      if (maxSpeed < maxVal) {
        maxSpeed = maxVal;
      }
    }
    return maxSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift, isVisible: false, interval: 1, majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
          // labelFormat: '{value}',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          interval: Utils.chartInterval(maxNetworkSpeed),
          axisLabelFormatter: (args) {
            return ChartAxisLabel("${Utils.formatSize(args.value, fixed: 0)}", TextStyle());
          },
        ),
        enableAxisAnimation: true,
        series: <AreaSeries<Network, num>>[
          AreaSeries<Network, num>(
            onRendererCreated: onWriteRendererCreated,
            animationDuration: 1000,
            dataSource: networks,
            xValueMapper: (Network lun, index) => index,
            yValueMapper: (Network lun, _) => lun.rx ?? 0,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '下载',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: AppTheme.of(context).successColor,
            gradient: LinearGradient(colors: [AppTheme.of(context).successColor.withOpacity(0.1), AppTheme.of(context).successColor.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
          AreaSeries<Network, num>(
            onRendererCreated: onReadRendererCreated,
            animationDuration: 1000,
            dataSource: networks,
            xValueMapper: (Network lun, index) => index,
            yValueMapper: (Network lun, _) => lun.tx ?? 0,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '上传',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: AppTheme.of(context).primaryColor,
            gradient: LinearGradient(colors: [AppTheme.of(context).primaryColor.withOpacity(0.1), AppTheme.of(context).primaryColor.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
        ],
      ),
    );
  }
}
