import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/pages/docker/enums/container_status_enum.dart';
import 'package:dsm_helper/pages/docker/enums/project_status_enum.dart';

/// containerIds : ["82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3"]
/// created_at : "2023-11-03T02:17:53.782328Z"
/// enable_service_portal : false
/// id : "1d665a1d-2314-4d5b-afa6-2b60aa8f99b6"
/// is_package : false
/// name : "qbittorrent"
/// path : "/volume3/docker/qbittorrent"
/// service_portal_name : ""
/// service_portal_port : 0
/// service_portal_protocol : ""
/// services : null
/// share_path : "/docker/qbittorrent"
/// state : ""
/// status : "RUNNING"
/// updated_at : "2023-11-03T02:17:54.061941Z"
/// version : 2

class DockerProject {
  DockerProject({
    this.containerIds,
    this.createdAt,
    this.enableServicePortal,
    this.id,
    this.isPackage,
    this.name,
    this.path,
    this.servicePortalName,
    this.servicePortalPort,
    this.servicePortalProtocol,
    this.services,
    this.sharePath,
    this.state,
    this.status,
    this.updatedAt,
    this.version,
  });

  static Future<Map<String, DockerProject>> list({String logLevel = ""}) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Project",
      "list",
      version: 1,
    );
    Map<String, DockerProject> projects = {};
    if (res.success == true) {
      (res.data as Map).forEach((key, value) {
        projects[key] = DockerProject.fromJson(value);
      });
    } else {}
    return projects;
  }

  Future<bool?> start() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Project",
      "start_stream",
      version: 1,
      data: {
        "id": id,
      },
    );
    return res.success;
  }

  Future<bool?> stop() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Project",
      "stop_stream",
      version: 1,
      data: {
        "id": id,
      },
    );
    return res.success;
  }

  DockerProject.fromJson(dynamic json) {
    containerIds = json['containerIds'] != null ? json['containerIds'].cast<String>() : [];
    createdAt = json['created_at'];
    enableServicePortal = json['enable_service_portal'];
    id = json['id'];
    isPackage = json['is_package'];
    name = json['name'];
    path = json['path'];
    servicePortalName = json['service_portal_name'];
    servicePortalPort = json['service_portal_port'];
    servicePortalProtocol = json['service_portal_protocol'];
    services = json['services'];
    sharePath = json['share_path'];
    state = json['state'];
    status = json['status'];
    updatedAt = json['updated_at'];
    version = json['version'];
  }
  List<String>? containerIds;
  String? createdAt;
  bool? enableServicePortal;
  String? id;
  bool? isPackage;
  String? name;
  String? path;
  String? servicePortalName;
  num? servicePortalPort;
  String? servicePortalProtocol;
  dynamic services;
  String? sharePath;
  String? state;
  ProjectStatusEnum get statusEnum => ProjectStatusEnum.fromValue(status ?? 'unknown');
  String? status;
  String? updatedAt;
  num? version;
  DockerProject copyWith({
    List<String>? containerIds,
    String? createdAt,
    bool? enableServicePortal,
    String? id,
    bool? isPackage,
    String? name,
    String? path,
    String? servicePortalName,
    num? servicePortalPort,
    String? servicePortalProtocol,
    dynamic services,
    String? sharePath,
    String? state,
    String? status,
    String? updatedAt,
    num? version,
  }) =>
      DockerProject(
        containerIds: containerIds ?? this.containerIds,
        createdAt: createdAt ?? this.createdAt,
        enableServicePortal: enableServicePortal ?? this.enableServicePortal,
        id: id ?? this.id,
        isPackage: isPackage ?? this.isPackage,
        name: name ?? this.name,
        path: path ?? this.path,
        servicePortalName: servicePortalName ?? this.servicePortalName,
        servicePortalPort: servicePortalPort ?? this.servicePortalPort,
        servicePortalProtocol: servicePortalProtocol ?? this.servicePortalProtocol,
        services: services ?? this.services,
        sharePath: sharePath ?? this.sharePath,
        state: state ?? this.state,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['containerIds'] = containerIds;
    map['created_at'] = createdAt;
    map['enable_service_portal'] = enableServicePortal;
    map['id'] = id;
    map['is_package'] = isPackage;
    map['name'] = name;
    map['path'] = path;
    map['service_portal_name'] = servicePortalName;
    map['service_portal_port'] = servicePortalPort;
    map['service_portal_protocol'] = servicePortalProtocol;
    map['services'] = services;
    map['share_path'] = sharePath;
    map['state'] = state;
    map['status'] = status;
    map['updated_at'] = updatedAt;
    map['version'] = version;
    return map;
  }
}
