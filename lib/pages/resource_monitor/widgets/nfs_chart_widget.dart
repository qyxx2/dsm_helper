import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NfsChartWidget extends StatelessWidget {
  const NfsChartWidget(this.nfs, {this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Nfs> nfs;
  final Function(ChartSeriesController)? onReadRendererCreated;
  final Function(ChartSeriesController)? onWriteRendererCreated;

  num get maxLunSpeed {
    num maxSpeed = 0;
    for (var nfs in nfs) {
      num maxVal = max(nfs.readOPS ?? 0, nfs.writeOPS ?? 0);
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
          interval: Utils.chartInterval(maxLunSpeed),
          axisLabelFormatter: (args) {
            return ChartAxisLabel("${Utils.formatSize(args.value, fixed: 0)}", TextStyle());
          },
        ),
        enableAxisAnimation: true,
        series: <AreaSeries<Nfs, num>>[
          AreaSeries<Nfs, num>(
            onRendererCreated: onWriteRendererCreated,
            animationDuration: 1000,
            dataSource: nfs,
            xValueMapper: (Nfs lun, index) => index,
            yValueMapper: (Nfs lun, _) => lun.writeOPS ?? 0,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '写入',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: Colors.purpleAccent,
            gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.1), Colors.purpleAccent.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
          AreaSeries<Nfs, num>(
            onRendererCreated: onReadRendererCreated,
            animationDuration: 1000,
            dataSource: nfs,
            xValueMapper: (Nfs lun, index) => index,
            yValueMapper: (Nfs lun, _) => lun.readOPS ?? 0,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '读取',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: Colors.deepPurpleAccent,
            gradient: LinearGradient(colors: [Colors.deepPurpleAccent.withOpacity(0.1), Colors.deepPurpleAccent.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
        ],
      ),
    );
  }
}
