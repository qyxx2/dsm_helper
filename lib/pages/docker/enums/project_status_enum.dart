import 'package:flutter/material.dart';

enum ProjectStatusEnum {
  RUNNING(label: "运行中", color: Color(0xFF25B85F)),
  STOPPED(label: "已停止", color: Color(0xFF7F7F7F)),
  unknown(label: "未知", color: Colors.orangeAccent);

  final String label;
  final Color color;

  const ProjectStatusEnum({
    required this.label,
    required this.color,
  });

  static ProjectStatusEnum fromValue(String value) {
    return ProjectStatusEnum.values.firstWhere((element) => element.name == value, orElse: () => ProjectStatusEnum.unknown);
  }
}
