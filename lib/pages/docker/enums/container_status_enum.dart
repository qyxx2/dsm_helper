import 'package:flutter/material.dart';

enum ContainerStatusEnum {
  running(label: "运行中", color: Color(0xFF25B85F)),
  stopped(label: "已停止", color: Color(0xFF7F7F7F)),
  unknown(label: "未知", color: Colors.orangeAccent);

  final String label;
  final Color color;

  const ContainerStatusEnum({
    required this.label,
    required this.color,
  });

  static ContainerStatusEnum fromValue(String value) {
    return ContainerStatusEnum.values.firstWhere((element) => element.name == value, orElse: () => ContainerStatusEnum.unknown);
  }
}
