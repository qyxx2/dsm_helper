import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/FileStation/BackgroundTaskStatus.dart';

/// offset : 0
/// tasks : [{"api":"SYNO.FileStation.CopyMove","background":{"cancel":{"api":"SYNO.FileStation.CopyMove","method":"stop","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3},"id":"FileStation_1698197793C6F74541","query":{"api":"SYNO.FileStation.CopyMove","method":"status","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3},"title":["{0}: {1}","filebrowser:filetable_move","视频_2.mp4"]},"crtime":1698197974,"finished":false,"method":"start","params":{"accurate_progress":true,"dest_folder_path":"/T14/短视频","overwrite":true,"path":["/photo/污神映画/污神映画&猫性少女 (150P+2V)/视频/视频_2.mp4"],"remove_src":true,"search_taskid":"16981967833BA8C3B1"},"path":"/photo/JK邪魔暖暖/（特）KTV+电影院合集 159P+29视频/VID_20170825_214418.mp4","processed_size":4892834676,"processing_path":"/photo/JK邪魔暖暖/（特）KTV+电影院合集 159P+29视频/VID_20170825_214418.mp4","progress":0.034842077642679214,"taskid":"FileStation_1698197793C6F74541","total":140428898828,"version":3}]
/// total : 1

class BackgroundTask {
  BackgroundTask({
    this.offset,
    this.tasks,
    this.total,
  });

  static Future<BackgroundTask> list() async {
    DsmResponse res = await Api.dsm.entry("SYNO.FileStation.BackgroundTask", "list",
        version: 3,
        data: {
          "is_list_sharemove": true,
          "is_vfs": true,
          "bkg_info": true,
        },
        parser: BackgroundTask.fromJson);
    return res.data;
  }

  BackgroundTask.fromJson(dynamic json) {
    offset = json['offset'];
    if (json['tasks'] != null) {
      tasks = [];
      json['tasks'].forEach((v) {
        tasks?.add(Tasks.fromJson(v));
      });
    }
    total = json['total'];
  }
  num? offset;
  List<Tasks>? tasks;
  num? total;
  BackgroundTask copyWith({
    num? offset,
    List<Tasks>? tasks,
    num? total,
  }) =>
      BackgroundTask(
        offset: offset ?? this.offset,
        tasks: tasks ?? this.tasks,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['offset'] = offset;
    if (tasks != null) {
      map['tasks'] = tasks?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }
}

/// api : "SYNO.FileStation.CopyMove"
/// background : {"cancel":{"api":"SYNO.FileStation.CopyMove","method":"stop","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3},"id":"FileStation_1698197793C6F74541","query":{"api":"SYNO.FileStation.CopyMove","method":"status","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3},"title":["{0}: {1}","filebrowser:filetable_move","视频_2.mp4"]}
/// crtime : 1698197974
/// finished : false
/// method : "start"
/// params : {"accurate_progress":true,"dest_folder_path":"/T14/短视频","overwrite":true,"path":["/photo/污神映画/污神映画&猫性少女 (150P+2V)/视频/视频_2.mp4"],"remove_src":true,"search_taskid":"16981967833BA8C3B1"}
/// path : "/photo/JK邪魔暖暖/（特）KTV+电影院合集 159P+29视频/VID_20170825_214418.mp4"
/// processed_size : 4892834676
/// processing_path : "/photo/JK邪魔暖暖/（特）KTV+电影院合集 159P+29视频/VID_20170825_214418.mp4"
/// progress : 0.034842077642679214
/// taskid : "FileStation_1698197793C6F74541"
/// total : 140428898828
/// version : 3

class Tasks {
  Tasks({
    this.api,
    this.background,
    this.crtime,
    this.finished,
    this.method,
    this.params,
    this.path,
    this.processedSize,
    this.processingPath,
    this.progress,
    this.taskid,
    this.total,
    this.version,
  });

  Future<BackgroundTaskStatus> status() async {
    DsmResponse res = await Api.dsm.entry(background!.query!.api!, background!.query!.method!, version: background!.query!.version!.toInt(), data: background!.query!.params!.toJson(), parser: BackgroundTaskStatus.fromJson);
    return res.data;
  }

  Future<bool?> cancel() async {
    DsmResponse res = await Api.dsm.entry(background!.cancel!.api!, background!.cancel!.method!, version: background!.cancel!.version!.toInt(), data: background!.cancel!.params!.toJson());
    return res.success;
  }

  Tasks.fromJson(dynamic json) {
    api = json['api'];
    background = json['background'] != null ? Background.fromJson(json['background']) : null;
    crtime = json['crtime'];
    finished = json['finished'];
    method = json['method'];
    params = json['params'] != null ? TaskParams.fromJson(json['params']) : null;
    path = json['path'];
    processedSize = json['processed_size'];
    processingPath = json['processing_path'];
    progress = json['progress'];
    taskid = json['taskid'];
    total = json['total'];
    version = json['version'];
  }
  String? api;
  Background? background;
  num? crtime;
  bool? finished;
  String? method;
  TaskParams? params;
  String? path;
  num? processedSize;
  String? processingPath;
  num? progress;
  String? taskid;
  num? total;
  num? version;
  BackgroundTaskStatus? taskStatus;
  Tasks copyWith({
    String? api,
    Background? background,
    num? crtime,
    bool? finished,
    String? method,
    TaskParams? params,
    String? path,
    num? processedSize,
    String? processingPath,
    num? progress,
    String? taskid,
    num? total,
    num? version,
  }) =>
      Tasks(
        api: api ?? this.api,
        background: background ?? this.background,
        crtime: crtime ?? this.crtime,
        finished: finished ?? this.finished,
        method: method ?? this.method,
        params: params ?? this.params,
        path: path ?? this.path,
        processedSize: processedSize ?? this.processedSize,
        processingPath: processingPath ?? this.processingPath,
        progress: progress ?? this.progress,
        taskid: taskid ?? this.taskid,
        total: total ?? this.total,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api'] = api;
    if (background != null) {
      map['background'] = background?.toJson();
    }
    map['crtime'] = crtime;
    map['finished'] = finished;
    map['method'] = method;
    if (params != null) {
      map['params'] = params?.toJson();
    }
    map['path'] = path;
    map['processed_size'] = processedSize;
    map['processing_path'] = processingPath;
    map['progress'] = progress;
    map['taskid'] = taskid;
    map['total'] = total;
    map['version'] = version;
    return map;
  }
}

/// accurate_progress : true
/// dest_folder_path : "/T14/短视频"
/// overwrite : true
/// path : ["/photo/污神映画/污神映画&猫性少女 (150P+2V)/视频/视频_2.mp4"]
/// remove_src : true
/// search_taskid : "16981967833BA8C3B1"

class TaskParams {
  TaskParams({
    this.accurateProgress,
    this.destFolderPath,
    this.overwrite,
    this.path,
    this.removeSrc,
    this.searchTaskid,
  });

  TaskParams.fromJson(dynamic json) {
    accurateProgress = json['accurate_progress'];
    destFolderPath = json['dest_folder_path'];
    overwrite = json['overwrite'];
    path = json['path'] != null ? json['path'].cast<String>() : [];
    removeSrc = json['remove_src'];
    searchTaskid = json['search_taskid'];
  }
  bool? accurateProgress;
  String? destFolderPath;
  bool? overwrite;
  List<String>? path;
  bool? removeSrc;
  String? searchTaskid;
  TaskParams copyWith({
    bool? accurateProgress,
    String? destFolderPath,
    bool? overwrite,
    List<String>? path,
    bool? removeSrc,
    String? searchTaskid,
  }) =>
      TaskParams(
        accurateProgress: accurateProgress ?? this.accurateProgress,
        destFolderPath: destFolderPath ?? this.destFolderPath,
        overwrite: overwrite ?? this.overwrite,
        path: path ?? this.path,
        removeSrc: removeSrc ?? this.removeSrc,
        searchTaskid: searchTaskid ?? this.searchTaskid,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accurate_progress'] = accurateProgress;
    map['dest_folder_path'] = destFolderPath;
    map['overwrite'] = overwrite;
    map['path'] = path;
    map['remove_src'] = removeSrc;
    map['search_taskid'] = searchTaskid;
    return map;
  }
}

/// cancel : {"api":"SYNO.FileStation.CopyMove","method":"stop","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3}
/// id : "FileStation_1698197793C6F74541"
/// query : {"api":"SYNO.FileStation.CopyMove","method":"status","params":{"taskid":"FileStation_1698197793C6F74541"},"version":3}
/// title : ["{0}: {1}","filebrowser:filetable_move","视频_2.mp4"]

class Background {
  Background({
    this.cancel,
    this.id,
    this.query,
    this.title,
  });

  Background.fromJson(dynamic json) {
    cancel = json['cancel'] != null ? Cancel.fromJson(json['cancel']) : null;
    id = json['id'];
    query = json['query'] != null ? Query.fromJson(json['query']) : null;
    title = json['title'] != null ? json['title'].cast<String>() : [];
  }
  Cancel? cancel;
  String? id;
  Query? query;
  List<String>? title;
  Background copyWith({
    Cancel? cancel,
    String? id,
    Query? query,
    List<String>? title,
  }) =>
      Background(
        cancel: cancel ?? this.cancel,
        id: id ?? this.id,
        query: query ?? this.query,
        title: title ?? this.title,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (cancel != null) {
      map['cancel'] = cancel?.toJson();
    }
    map['id'] = id;
    if (query != null) {
      map['query'] = query?.toJson();
    }
    map['title'] = title;
    return map;
  }
}

/// api : "SYNO.FileStation.CopyMove"
/// method : "status"
/// params : {"taskid":"FileStation_1698197793C6F74541"}
/// version : 3

class Query {
  Query({
    this.api,
    this.method,
    this.params,
    this.version,
  });

  Query.fromJson(dynamic json) {
    api = json['api'];
    method = json['method'];
    params = json['params'] != null ? Params.fromJson(json['params']) : null;
    version = json['version'];
  }
  String? api;
  String? method;
  Params? params;
  num? version;
  Query copyWith({
    String? api,
    String? method,
    Params? params,
    num? version,
  }) =>
      Query(
        api: api ?? this.api,
        method: method ?? this.method,
        params: params ?? this.params,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api'] = api;
    map['method'] = method;
    if (params != null) {
      map['params'] = params?.toJson();
    }
    map['version'] = version;
    return map;
  }
}

/// taskid : "FileStation_1698197793C6F74541"

class Params {
  Params({
    this.taskid,
  });

  Params.fromJson(dynamic json) {
    taskid = json['taskid'];
  }
  String? taskid;
  Params copyWith({
    String? taskid,
  }) =>
      Params(
        taskid: taskid ?? this.taskid,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['taskid'] = taskid;
    return map;
  }
}

/// api : "SYNO.FileStation.CopyMove"
/// method : "stop"
/// params : {"taskid":"FileStation_1698197793C6F74541"}
/// version : 3

class Cancel {
  Cancel({
    this.api,
    this.method,
    this.params,
    this.version,
  });

  Cancel.fromJson(dynamic json) {
    api = json['api'];
    method = json['method'];
    params = json['params'] != null ? Params.fromJson(json['params']) : null;
    version = json['version'];
  }
  String? api;
  String? method;
  Params? params;
  num? version;
  Cancel copyWith({
    String? api,
    String? method,
    Params? params,
    num? version,
  }) =>
      Cancel(
        api: api ?? this.api,
        method: method ?? this.method,
        params: params ?? this.params,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api'] = api;
    map['method'] = method;
    if (params != null) {
      map['params'] = params?.toJson();
    }
    map['version'] = version;
    return map;
  }
}
