import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NfsIopsChartWidget extends StatelessWidget {
  const NfsIopsChartWidget(this.nfs, {this.showTotal = false, this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Nfs> nfs;
  final bool showTotal;
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
        series: <AreaSeries<Nfs, num>>[
          AreaSeries<Nfs, num>(
            onRendererCreated: onWriteRendererCreated,
            animationDuration: 1000,
            dataSource: nfs,
            xValueMapper: (Nfs nfs, index) => index,
            yValueMapper: (Nfs nfs, _) => nfs.writeOPS ?? 0,
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
            xValueMapper: (Nfs nfs, index) => index,
            yValueMapper: (Nfs nfs, _) => nfs.readOPS ?? 0,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: '读取',
            markerSettings: const MarkerSettings(isVisible: false),
            // color: Colors.lightBlue,
            borderWidth: 2,
            borderColor: Colors.deepPurpleAccent,
            gradient: LinearGradient(colors: [Colors.deepPurpleAccent.withOpacity(0.1), Colors.deepPurpleAccent.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
          if (showTotal)
            AreaSeries<Nfs, num>(
              onRendererCreated: onReadRendererCreated,
              animationDuration: 1000,
              dataSource: nfs,
              xValueMapper: (Nfs nfs, index) => index,
              yValueMapper: (Nfs nfs, _) => nfs.totalOPS ?? 0,
              // dataLabelSettings: DataLabelSettings(),
              // width: 2,
              name: '总计',
              markerSettings: const MarkerSettings(isVisible: false),
              // color: Colors.lightBlue,
              borderWidth: 2,
              borderColor: AppTheme.of(context)?.primaryColor,
              gradient: LinearGradient(colors: [AppTheme.of(context)!.primaryColor!.withOpacity(0.1), AppTheme.of(context)!.primaryColor!.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            ),
        ],
      ),
    );
  }
}
