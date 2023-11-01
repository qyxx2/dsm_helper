import 'package:flutter/material.dart';

enum PackageStatusEnum {
  running(label: "运行中", color: Color(0xFF25B85F)),
  stop(label: "已停用", color: Color(0xFFFF5733)),
  unknown(label: "未知", color: Color(0xFF7F7F7F));

  final String label;
  final Color color;
  const PackageStatusEnum({required this.label, required this.color});

  static PackageStatusEnum fromValue(String value) {
    return PackageStatusEnum.values.firstWhere((element) => element.name == value, orElse: () => PackageStatusEnum.unknown);
  }
}
