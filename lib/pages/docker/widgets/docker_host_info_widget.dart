import 'package:dsm_helper/models/Syno/Core/System/Utilization.dart';
import 'package:dsm_helper/providers/utilization_provider.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DockerHostInfoWidget extends StatelessWidget {
  const DockerHostInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    UtilizationProvider utilizationProvider = context.watch<UtilizationProvider>();
    Utilization utilization = utilizationProvider.utilization;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.of(context)?.cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SfRadialGauge(
              animationDuration: 1000,
              enableLoadingAnimation: true,
              axes: <RadialAxis>[
                RadialAxis(
                  showLabels: false,
                  showTicks: false,
                  // radiusFactor: 0.8,
                  maximum: 100,
                  axisLineStyle: AxisLineStyle(cornerStyle: CornerStyle.bothCurve, thickness: 8),
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.4,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            "assets/icons/cpu_line.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${utilization.cpu?.totalLoad ?? '-'}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                                TextSpan(
                                  text: '%',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.of(context)?.placeholderColor),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "CPU",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.of(context)?.placeholderColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      enableAnimation: true,
                      animationDuration: 1000,
                      value: (utilization.cpu?.totalLoad ?? 0).toDouble(),
                      width: 8,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(colors: (utilization.cpu?.totalLoad ?? 0) < 80 ? [Color(0xFF00BAAD), Color(0xFF4BD6CD)] : [AppTheme.of(context)!.errorColor!, AppTheme.of(context)!.warningColor!]),
                    ),
                    // MarkerPointer(
                    //   value: utilization.cpu!.totalLoad.toDouble() - 3,
                    //   color: Colors.white,
                    //   markerType: MarkerType.circle,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Container(
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.of(context)?.cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SfRadialGauge(
              animationDuration: 1000,
              enableLoadingAnimation: true,
              axes: <RadialAxis>[
                RadialAxis(
                  showLabels: false,
                  showTicks: false,
                  // radiusFactor: 0.8,
                  maximum: 100,
                  axisLineStyle: AxisLineStyle(cornerStyle: CornerStyle.bothCurve, thickness: 8),
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.4,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            "assets/icons/memory.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${utilization.memory?.realUsage ?? '-'}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                                TextSpan(
                                  text: '%',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.of(context)?.placeholderColor),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "RAM",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.of(context)?.placeholderColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      enableAnimation: true,
                      animationDuration: 1000,
                      value: (utilization.memory?.realUsage ?? 0).toDouble(),
                      width: 8,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(colors: (utilization.memory?.realUsage ?? 0) < 80 ? [AppTheme.of(context)!.primaryColor!, Color(0xFF75ACFF)] : [AppTheme.of(context)!.errorColor!, AppTheme.of(context)!.warningColor!]),
                    ),
                    // MarkerPointer(
                    //   value: utilization.cpu!.totalLoad.toDouble() - 3,
                    //   color: Colors.white,
                    //   markerType: MarkerType.circle,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Expanded(child: SizedBox()),
      ],
    );
  }
}
