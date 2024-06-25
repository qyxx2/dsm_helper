import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CpuChartWidget extends StatelessWidget {
  const CpuChartWidget(this.cpus, {this.onRendererCreated, super.key});
  final List<Cpu> cpus;
  final Function(ChartSeriesController)? onRendererCreated;

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
          interval: 10,
          maximum: 100,
          axisLabelFormatter: (args) {
            return ChartAxisLabel("${args.value}%", TextStyle());
          },
        ),
        enableAxisAnimation: true,
        series: <AreaSeries<Cpu, num>>[
          AreaSeries<Cpu, num>(
            onRendererCreated: onRendererCreated,
            animationDuration: 1000,
            dataSource: cpus,
            xValueMapper: (Cpu cpu, index) => index,
            yValueMapper: (Cpu cpu, _) => cpu.totalLoad,
            // dataLabelSettings: DataLabelSettings(),
            // width: 2,
            name: 'CPU使用率',
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
