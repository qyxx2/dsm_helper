import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiskChartWidget extends StatelessWidget {
  const DiskChartWidget(this.disks, {this.showWrite = true, this.showRead = true, this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Disk> disks;
  final bool showWrite;
  final bool showRead;
  final Function(ChartSeriesController)? onReadRendererCreated;
  final Function(ChartSeriesController)? onWriteRendererCreated;

  num get maxSpeed {
    num maxSpeed = 0;
    for (var disk in disks) {
      num maxVal = max(disk.total?.readByte ?? 0, disk.total?.writeByte ?? 0);
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
          interval: Utils.chartInterval(maxSpeed),
          axisLabelFormatter: (args) {
            return ChartAxisLabel("${Utils.formatSize(args.value, fixed: 0)}", TextStyle());
          },
        ),
        enableAxisAnimation: true,
        series: <AreaSeries<Disk, num>>[
          if (showRead)
            AreaSeries<Disk, num>(
              onRendererCreated: onWriteRendererCreated,
              animationDuration: 1000,
              dataSource: disks,
              xValueMapper: (Disk disk, index) => index,
              yValueMapper: (Disk disk, _) => disk.total?.readByte ?? 0,
              // dataLabelSettings: DataLabelSettings(),
              // width: 2,
              name: '读取',
              markerSettings: const MarkerSettings(isVisible: false),
              // color: Colors.lightBlue,
              borderWidth: 2,
              borderColor: Colors.orange,
              gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            ),
          if (showWrite)
            AreaSeries<Disk, num>(
              onRendererCreated: onReadRendererCreated,
              animationDuration: 1000,
              dataSource: disks,
              xValueMapper: (Disk disk, index) => index,
              yValueMapper: (Disk disk, _) => disk.total?.writeByte ?? 0,
              // dataLabelSettings: DataLabelSettings(),
              // width: 2,
              name: '写入',
              markerSettings: const MarkerSettings(isVisible: false),
              // color: Colors.lightBlue,
              borderWidth: 2,
              borderColor: Colors.amber,
              gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.1), Colors.amber.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            ),
        ],
      ),
    );
  }
}
