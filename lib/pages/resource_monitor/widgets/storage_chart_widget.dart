import 'dart:math';

import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpaceChartWidget extends StatelessWidget {
  const SpaceChartWidget(this.spaces, {this.onReadRendererCreated, this.onWriteRendererCreated, super.key});

  final List<Space> spaces;
  final Function(ChartSeriesController)? onReadRendererCreated;
  final Function(ChartSeriesController)? onWriteRendererCreated;

  num get maxNetworkSpeed {
    num maxSpeed = 0;
    for (var space in spaces) {
      num maxVal = max(space.total?.readByte ?? 0, space.total?.writeByte ?? 0);
      if (maxSpeed < maxVal) {
        maxSpeed = maxVal;
      }
    }
    return maxSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
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
            series: <AreaSeries<Space, num>>[
              AreaSeries<Space, num>(
                onRendererCreated: onWriteRendererCreated,
                animationDuration: 1000,
                dataSource: spaces,
                xValueMapper: (Space lun, index) => index,
                yValueMapper: (Space lun, _) => lun.total?.readByte ?? 0,
                // dataLabelSettings: DataLabelSettings(),
                // width: 2,
                name: '读取',
                markerSettings: const MarkerSettings(isVisible: false),
                // color: Colors.lightBlue,
                borderWidth: 2,
                borderColor: Colors.orange,
                gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
              AreaSeries<Space, num>(
                onRendererCreated: onReadRendererCreated,
                animationDuration: 1000,
                dataSource: spaces,
                xValueMapper: (Space lun, index) => index,
                yValueMapper: (Space lun, _) => lun.total?.writeByte ?? 0,
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
        ),
      ],
    );
  }
}
