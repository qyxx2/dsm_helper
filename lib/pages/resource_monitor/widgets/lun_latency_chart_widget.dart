import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LunLatencyChartWidget extends StatelessWidget {
  const LunLatencyChartWidget(this.luns, {this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Lun> luns;
  final Function(ChartSeriesController)? onReadRendererCreated;
  final Function(ChartSeriesController)? onWriteRendererCreated;

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
        ),
        enableAxisAnimation: true,
        series: <AreaSeries<Lun, num>>[
          AreaSeries<Lun, num>(
            onRendererCreated: onWriteRendererCreated,
            animationDuration: 1000,
            dataSource: luns,
            xValueMapper: (Lun lun, index) => index,
            yValueMapper: (Lun lun, _) => lun.writeAvgLatency,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '写入',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: Colors.lightGreen,
            gradient: LinearGradient(colors: [Colors.lightGreen.withOpacity(0.1), Colors.lightGreen.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
          AreaSeries<Lun, num>(
            onRendererCreated: onReadRendererCreated,
            animationDuration: 1000,
            dataSource: luns,
            xValueMapper: (Lun lun, index) => index,
            yValueMapper: (Lun lun, _) => lun.readAvgLatency,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '读取',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: Colors.cyan,
            gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.1), Colors.cyan.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
        ],
      ),
    );
  }
}
