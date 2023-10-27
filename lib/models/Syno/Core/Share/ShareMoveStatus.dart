import 'package:dsm_helper/apis/api.dart';

/// auto_remove : false
/// data : {"data_transfer_mode":true,"found_file_size":24662089728,"percent":69,"processed_size":17177818643,"progress":0.6965273022651672,"status":"progressing","total":24662089728,"transfer_rate":205894872.1215035}
/// finish : false
/// info : {"api":"SYNO.Core.Share","group":"admin","method":"set","param":{"name":"media","shareinfo":{"desc":"","enable_share_compress":false,"enable_share_cow":false,"enc_passwd":"","encryption":false,"name":"media","vol_path":"/volume2"}},"prefix":"sharemove","version":1}
/// success : true

class ShareMoveStatus {
  ShareMoveStatus({
    this.autoRemove,
    this.data,
    this.finish,
    this.info,
    this.success,
  });

  static Future<String?> getAllMoveTask() async {
    DsmResponse res = await Api.dsm.entry("SYNO.Core.Share", "get_all_move_task", version: 1);
    if (res.success == true) {
      return res.data?['task_id'];
    } else {
      return null;
    }
  }

  static Future<ShareMoveStatus> moveStatus() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.Share",
      "move_status",
      parser: ShareMoveStatus.fromJson,
      version: 1,
      data: {
        "task_id": 0,
      },
    );
    return res.data;
  }

  ShareMoveStatus.fromJson(dynamic json) {
    autoRemove = json['auto_remove'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    finish = json['finish'];
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    success = json['success'];
  }
  bool? autoRemove;
  Data? data;
  bool? finish;
  Info? info;
  bool? success;
  ShareMoveStatus copyWith({
    bool? autoRemove,
    Data? data,
    bool? finish,
    Info? info,
    bool? success,
  }) =>
      ShareMoveStatus(
        autoRemove: autoRemove ?? this.autoRemove,
        data: data ?? this.data,
        finish: finish ?? this.finish,
        info: info ?? this.info,
        success: success ?? this.success,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['auto_remove'] = autoRemove;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['finish'] = finish;
    if (info != null) {
      map['info'] = info?.toJson();
    }
    map['success'] = success;
    return map;
  }
}

/// api : "SYNO.Core.Share"
/// group : "admin"
/// method : "set"
/// param : {"name":"media","shareinfo":{"desc":"","enable_share_compress":false,"enable_share_cow":false,"enc_passwd":"","encryption":false,"name":"media","vol_path":"/volume2"}}
/// prefix : "sharemove"
/// version : 1

class Info {
  Info({
    this.api,
    this.group,
    this.method,
    this.param,
    this.prefix,
    this.version,
  });

  Info.fromJson(dynamic json) {
    api = json['api'];
    group = json['group'];
    method = json['method'];
    param = json['param'] != null ? Param.fromJson(json['param']) : null;
    prefix = json['prefix'];
    version = json['version'];
  }
  String? api;
  String? group;
  String? method;
  Param? param;
  String? prefix;
  num? version;
  Info copyWith({
    String? api,
    String? group,
    String? method,
    Param? param,
    String? prefix,
    num? version,
  }) =>
      Info(
        api: api ?? this.api,
        group: group ?? this.group,
        method: method ?? this.method,
        param: param ?? this.param,
        prefix: prefix ?? this.prefix,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api'] = api;
    map['group'] = group;
    map['method'] = method;
    if (param != null) {
      map['param'] = param?.toJson();
    }
    map['prefix'] = prefix;
    map['version'] = version;
    return map;
  }
}

/// name : "media"
/// shareinfo : {"desc":"","enable_share_compress":false,"enable_share_cow":false,"enc_passwd":"","encryption":false,"name":"media","vol_path":"/volume2"}

class Param {
  Param({
    this.name,
    this.shareinfo,
  });

  Param.fromJson(dynamic json) {
    name = json['name'];
    shareinfo = json['shareinfo'] != null ? Shareinfo.fromJson(json['shareinfo']) : null;
  }
  String? name;
  Shareinfo? shareinfo;
  Param copyWith({
    String? name,
    Shareinfo? shareinfo,
  }) =>
      Param(
        name: name ?? this.name,
        shareinfo: shareinfo ?? this.shareinfo,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    if (shareinfo != null) {
      map['shareinfo'] = shareinfo?.toJson();
    }
    return map;
  }
}

/// desc : ""
/// enable_share_compress : false
/// enable_share_cow : false
/// enc_passwd : ""
/// encryption : false
/// name : "media"
/// vol_path : "/volume2"

class Shareinfo {
  Shareinfo({
    this.desc,
    this.enableShareCompress,
    this.enableShareCow,
    this.encPasswd,
    this.encryption,
    this.name,
    this.volPath,
  });

  Shareinfo.fromJson(dynamic json) {
    desc = json['desc'];
    enableShareCompress = json['enable_share_compress'];
    enableShareCow = json['enable_share_cow'];
    encPasswd = json['enc_passwd'];
    encryption = json['encryption'];
    name = json['name'];
    volPath = json['vol_path'];
  }
  String? desc;
  bool? enableShareCompress;
  bool? enableShareCow;
  String? encPasswd;
  bool? encryption;
  String? name;
  String? volPath;
  Shareinfo copyWith({
    String? desc,
    bool? enableShareCompress,
    bool? enableShareCow,
    String? encPasswd,
    bool? encryption,
    String? name,
    String? volPath,
  }) =>
      Shareinfo(
        desc: desc ?? this.desc,
        enableShareCompress: enableShareCompress ?? this.enableShareCompress,
        enableShareCow: enableShareCow ?? this.enableShareCow,
        encPasswd: encPasswd ?? this.encPasswd,
        encryption: encryption ?? this.encryption,
        name: name ?? this.name,
        volPath: volPath ?? this.volPath,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['desc'] = desc;
    map['enable_share_compress'] = enableShareCompress;
    map['enable_share_cow'] = enableShareCow;
    map['enc_passwd'] = encPasswd;
    map['encryption'] = encryption;
    map['name'] = name;
    map['vol_path'] = volPath;
    return map;
  }
}

/// data_transfer_mode : true
/// found_file_size : 24662089728
/// percent : 69
/// processed_size : 17177818643
/// progress : 0.6965273022651672
/// status : "progressing"
/// total : 24662089728
/// transfer_rate : 205894872.1215035

class Data {
  Data({
    this.dataTransferMode,
    this.foundFileSize,
    this.percent,
    this.processedSize,
    this.progress,
    this.status,
    this.total,
    this.transferRate,
  });

  Data.fromJson(dynamic json) {
    dataTransferMode = json['data_transfer_mode'];
    foundFileSize = json['found_file_size'];
    percent = json['percent'];
    processedSize = json['processed_size'];
    progress = json['progress'];
    status = json['status'];
    total = json['total'];
    transferRate = json['transfer_rate'];
  }
  bool? dataTransferMode;
  num? foundFileSize;
  num? percent;
  num? processedSize;
  num? progress;
  String? status;
  num? total;
  num? transferRate;
  Data copyWith({
    bool? dataTransferMode,
    num? foundFileSize,
    num? percent,
    num? processedSize,
    num? progress,
    String? status,
    num? total,
    num? transferRate,
  }) =>
      Data(
        dataTransferMode: dataTransferMode ?? this.dataTransferMode,
        foundFileSize: foundFileSize ?? this.foundFileSize,
        percent: percent ?? this.percent,
        processedSize: processedSize ?? this.processedSize,
        progress: progress ?? this.progress,
        status: status ?? this.status,
        total: total ?? this.total,
        transferRate: transferRate ?? this.transferRate,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data_transfer_mode'] = dataTransferMode;
    map['found_file_size'] = foundFileSize;
    map['percent'] = percent;
    map['processed_size'] = processedSize;
    map['progress'] = progress;
    map['status'] = status;
    map['total'] = total;
    map['transfer_rate'] = transferRate;
    return map;
  }
}
