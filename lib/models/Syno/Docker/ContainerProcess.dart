import 'package:dsm_helper/apis/api.dart';

/// processes : [{"command":"/jellyfin/jellyfin","cpu":0.05000000074505806,"memory":331616256,"memoryPercent":4.035419138097754,"pid":"7100","start":"Oct16"}]
/// total : 1

class ContainerProcess {
  ContainerProcess({
    this.processes,
    this.total,
  });
  static Future<ContainerProcess> getProcess(String name) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Container",
      "get_process",
      version: 1,
      parser: ContainerProcess.fromJson,
      data: {
        "name": name,
      },
    );
    return res.data;
  }

  ContainerProcess.fromJson(dynamic json) {
    if (json['processes'] != null) {
      processes = [];
      json['processes'].forEach((v) {
        processes?.add(Processes.fromJson(v));
      });
    }
    total = json['total'];
  }
  List<Processes>? processes;
  num? total;
  ContainerProcess copyWith({
    List<Processes>? processes,
    num? total,
  }) =>
      ContainerProcess(
        processes: processes ?? this.processes,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (processes != null) {
      map['processes'] = processes?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }
}

/// command : "/jellyfin/jellyfin"
/// cpu : 0.05000000074505806
/// memory : 331616256
/// memoryPercent : 4.035419138097754
/// pid : "7100"
/// start : "Oct16"

class Processes {
  Processes({
    this.command,
    this.cpu,
    this.memory,
    this.memoryPercent,
    this.pid,
    this.start,
  });

  Processes.fromJson(dynamic json) {
    command = json['command'];
    cpu = json['cpu'];
    memory = json['memory'];
    memoryPercent = json['memoryPercent'];
    pid = json['pid'];
    start = json['start'];
  }
  String? command;
  num? cpu;
  num? memory;
  num? memoryPercent;
  String? pid;
  String? start;
  Processes copyWith({
    String? command,
    num? cpu,
    num? memory,
    num? memoryPercent,
    String? pid,
    String? start,
  }) =>
      Processes(
        command: command ?? this.command,
        cpu: cpu ?? this.cpu,
        memory: memory ?? this.memory,
        memoryPercent: memoryPercent ?? this.memoryPercent,
        pid: pid ?? this.pid,
        start: start ?? this.start,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['command'] = command;
    map['cpu'] = cpu;
    map['memory'] = memory;
    map['memoryPercent'] = memoryPercent;
    map['pid'] = pid;
    map['start'] = start;
    return map;
  }
}
