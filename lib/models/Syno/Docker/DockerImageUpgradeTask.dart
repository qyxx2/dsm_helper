import 'package:dsm_helper/apis/api.dart';

/// current : 0
/// finished : false
/// image : "shellngn/pro:latest"
/// state : "PULLING_IMAGE"
/// total : 0

class DockerImageUpgradeTask {
  DockerImageUpgradeTask({
    this.current,
    this.finished,
    this.image,
    this.state,
    this.total,
  });

  static Future<DockerImageUpgradeTask> upgradeStatus(String taskId) async {
    print("11111111111111${taskId}");
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Image",
      "upgrade_status",
      version: 1,
      parser: DockerImageUpgradeTask.fromJson,
      data: {
        "task_id": taskId,
      },
    );
    return res.data;
  }

  DockerImageUpgradeTask.fromJson(dynamic json) {
    print(json);
    current = json['current'];
    finished = json['finished'];
    image = json['image'];
    state = json['state'];
    total = json['total'];
  }
  num? current;
  bool? finished;
  String? image;
  String? state;
  num? total;
  num? get percent => current != null && total != null && total! > 0 ? current! / total! * 100 : null;
  DockerImageUpgradeTask copyWith({
    num? current,
    bool? finished,
    String? image,
    String? state,
    num? total,
  }) =>
      DockerImageUpgradeTask(
        current: current ?? this.current,
        finished: finished ?? this.finished,
        image: image ?? this.image,
        state: state ?? this.state,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current'] = current;
    map['finished'] = finished;
    map['image'] = image;
    map['state'] = state;
    map['total'] = total;
    return map;
  }
}
