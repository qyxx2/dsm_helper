import 'dart:convert';
import 'dart:math';

import 'package:dsm_helper/apis/api.dart';

/// OpenedFiles : [{"filename":".发票信息.txt.swp","hidden":0,"host":"192.168.0.76","path":"homes/yaoshuwei/工作文件/王炎/.发票信息.txt.swp","pid":"5251","service":"SSH","user":"yaoshuwei"}]
/// total : 1

class FileHandle {
  FileHandle({
    this.openedFiles,
    this.total,
  });

  static Future<FileHandle> get() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.FileHandle",
      "get",
      parser: FileHandle.fromJson,
      version: 1,
      data: {
        "offset": 0,
        "limit": 50,
        "sort_by": "service",
        "sort_direction": "ASC",
        "action": "enum",
        "forceReload": true,
      },
    );
    return res.data;
  }

  FileHandle.fromJson(dynamic json) {
    if (json['OpenedFiles'] != null) {
      openedFiles = [];
      json['OpenedFiles'].forEach((v) {
        openedFiles?.add(OpenedFiles.fromJson(v));
      });
    }
    total = json['total'];
  }
  List<OpenedFiles>? openedFiles;
  num? total;
  FileHandle copyWith({
    List<OpenedFiles>? openedFiles,
    num? total,
  }) =>
      FileHandle(
        openedFiles: openedFiles ?? this.openedFiles,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (openedFiles != null) {
      map['OpenedFiles'] = openedFiles?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }
}

/// filename : ".发票信息.txt.swp"
/// hidden : 0
/// host : "192.168.0.76"
/// path : "homes/yaoshuwei/工作文件/王炎/.发票信息.txt.swp"
/// pid : "5251"
/// service : "SSH"
/// user : "yaoshuwei"

class OpenedFiles {
  OpenedFiles({
    this.filename,
    this.hidden,
    this.host,
    this.path,
    this.pid,
    this.service,
    this.user,
  });

  Future<bool?> kick() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.FileHandle",
      "kick",
      version: 1,
      data: {
        "pids": jsonEncode([pid]),
      },
    );
    return res.success;
  }

  OpenedFiles.fromJson(dynamic json) {
    filename = json['filename'];
    hidden = json['hidden'];
    host = json['host'];
    path = json['path'];
    pid = json['pid'];
    service = json['service'];
    user = json['user'];
  }
  String? filename;
  num? hidden;
  String? host;
  String? path;
  String? pid;
  String? service;
  String? user;
  bool running = false;
  OpenedFiles copyWith({
    String? filename,
    num? hidden,
    String? host,
    String? path,
    String? pid,
    String? service,
    String? user,
  }) =>
      OpenedFiles(
        filename: filename ?? this.filename,
        hidden: hidden ?? this.hidden,
        host: host ?? this.host,
        path: path ?? this.path,
        pid: pid ?? this.pid,
        service: service ?? this.service,
        user: user ?? this.user,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['filename'] = filename;
    map['hidden'] = hidden;
    map['host'] = host;
    map['path'] = path;
    map['pid'] = pid;
    map['service'] = service;
    map['user'] = user;
    return map;
  }
}
