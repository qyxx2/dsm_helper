import 'package:dsm_helper/apis/api.dart';

/// beta : false
/// blqinst : false
/// finished : false
/// id : "StorageAnalyzer"
/// installing : false
/// name : "StorageAnalyzer"
/// pid : 27457
/// progress : 0.29299265497070903
/// remote_link : "https://cndl.synology.cn/download/Package/spk/StorageAnalyzer/2.1.0-0421/StorageAnalyzer-x86_64-2.1.0-0421.spk"
/// size : "1828039"
/// success : true
/// taskid : "@SYNOPKG_DOWNLOAD_StorageAnalyzer"
/// tmp_folder : "/volume1/@tmp/synopkg/download.1TFy9J"

class PackageInstallTask {
  PackageInstallTask({
    this.beta,
    this.blqinst,
    this.finished,
    this.id,
    this.installing,
    this.name,
    this.pid,
    this.progress,
    this.remoteLink,
    this.size,
    this.success,
    this.taskid,
    this.tmpFolder,
  });

  Future<PackageInstallTask> status() async {
    DsmResponse res = await Api.dsm.entry("SYNO.Core.Package.Installation", "status", version: 1, parser: PackageInstallTask.fromJson, data: {
      "taskid": taskid,
    });
    return res.data;
  }

  Future<bool?> cancel() async {
    DsmResponse res = await Api.dsm.entry("SYNO.Core.Package.Installation", "cancel", version: 1, data: {
      "taskid": taskid,
    });
    return res.success;
  }

  PackageInstallTask.fromJson(dynamic json) {
    beta = json['beta'];
    blqinst = json['blqinst'];
    finished = json['finished'];
    id = json['id'];
    installing = json['installing'];
    name = json['name'];
    pid = json['pid'];
    progress = num.parse("${json['progress']}");
    remoteLink = json['remote_link'];
    size = json['size'];
    success = json['success'];
    taskid = json['taskid'];
    tmpFolder = json['tmp_folder'];
  }
  bool? beta;
  bool? blqinst;
  bool? finished;
  String? id;
  bool? installing;
  String? name;
  num? pid;
  num? progress;
  String? remoteLink;
  String? size;
  bool? success;
  String? taskid;
  String? tmpFolder;
  PackageInstallTask copyWith({
    bool? beta,
    bool? blqinst,
    bool? finished,
    String? id,
    bool? installing,
    String? name,
    num? pid,
    num? progress,
    String? remoteLink,
    String? size,
    bool? success,
    String? taskid,
    String? tmpFolder,
  }) =>
      PackageInstallTask(
        beta: beta ?? this.beta,
        blqinst: blqinst ?? this.blqinst,
        finished: finished ?? this.finished,
        id: id ?? this.id,
        installing: installing ?? this.installing,
        name: name ?? this.name,
        pid: pid ?? this.pid,
        progress: progress ?? this.progress,
        remoteLink: remoteLink ?? this.remoteLink,
        size: size ?? this.size,
        success: success ?? this.success,
        taskid: taskid ?? this.taskid,
        tmpFolder: tmpFolder ?? this.tmpFolder,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['beta'] = beta;
    map['blqinst'] = blqinst;
    map['finished'] = finished;
    map['id'] = id;
    map['installing'] = installing;
    map['name'] = name;
    map['pid'] = pid;
    map['progress'] = progress;
    map['remote_link'] = remoteLink;
    map['size'] = size;
    map['success'] = success;
    map['taskid'] = taskid;
    map['tmp_folder'] = tmpFolder;
    return map;
  }
}
