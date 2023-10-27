import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MemoryChartWidget extends StatelessWidget {
  const MemoryChartWidget(this.memories, {this.onRendererCreated, super.key});

  final List<Memory> memories;

  final Function(ChartSeriesController)? onRendererCreated;

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
              interval: 10,
              maximum: 100,
              axisLabelFormatter: (args) {
                return ChartAxisLabel("${args.value}%", TextStyle());
              },
            ),
            enableAxisAnimation: true,
            series: <AreaSeries<Memory, num>>[
              AreaSeries<Memory, num>(
                onRendererCreated: onRendererCreated,
                animationDuration: 1000,
                dataSource: memories,
                xValueMapper: (Memory memory, index) => index,
                yValueMapper: (Memory memory, _) => memory.realUsage ?? 0,
                // dataLabelSettings: DataLabelSettings(),
                // width: 2,
                name: '内存使用率',
                markerSettings: const MarkerSettings(isVisible: false),
                // color: Colors.lightBlue,
                borderWidth: 2,
                borderColor: AppTheme.of(context)?.warningColor,
                gradient: LinearGradient(colors: [AppTheme.of(context)!.warningColor!.withOpacity(0.1), AppTheme.of(context)!.warningColor!.withOpacity(0.4)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
