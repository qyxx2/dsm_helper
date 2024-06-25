enum UpgradeStateEnum {
  PULLING_IMAGE(label: "拉取镜像"),
  UPGRADING_CONTAINERS(label: "更新容器"),
  unknown(label: "未知");

  final String label;
  const UpgradeStateEnum({
    required this.label,
  });

  static UpgradeStateEnum fromValue(String value) {
    return UpgradeStateEnum.values.firstWhere((element) => element.name == value, orElse: () => UpgradeStateEnum.unknown);
  }
}
