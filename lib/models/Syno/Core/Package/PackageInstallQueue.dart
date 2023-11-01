/// broken_pkgs : []
/// cause_pausing_pkgs : []
/// conflicted_pkgs : []
/// non_exist_pkgs : []
/// paused_pkgs : []
/// queue : [{"beta":false,"pkg":"Node.js_v16","volume":""}]
/// replaced_pkgs : []

class PackageInstallQueue {
  PackageInstallQueue({
    this.brokenPkgs,
    this.causePausingPkgs,
    this.conflictedPkgs,
    this.nonExistPkgs,
    this.pausedPkgs,
    this.queue,
    this.replacedPkgs,
  });

  PackageInstallQueue.fromJson(dynamic json) {
    if (json['broken_pkgs'] != null) {
      brokenPkgs = [];
      // json['broken_pkgs'].forEach((v) {
      //   brokenPkgs?.add(Dynamic.fromJson(v));
      // });
    }
    causePausingPkgs = json['cause_pausing_pkgs'] != null ? json['cause_pausing_pkgs'].cast<String>() : null;

    if (json['conflicted_pkgs'] != null) {
      conflictedPkgs = [];
      // json['conflicted_pkgs'].forEach((v) {
      //   conflictedPkgs?.add(Dynamic.fromJson(v));
      // });
    }
    if (json['non_exist_pkgs'] != null) {
      nonExistPkgs = [];
      // json['non_exist_pkgs'].forEach((v) {
      //   nonExistPkgs?.add(Dynamic.fromJson(v));
      // });
    }
    pausedPkgs = json['paused_pkgs'] != null ? json['paused_pkgs'].cast<String>() : null;

    if (json['queue'] != null) {
      queue = [];
      json['queue'].forEach((v) {
        queue?.add(Queue.fromJson(v));
      });
    }
    if (json['replaced_pkgs'] != null) {
      replacedPkgs = [];
      // json['replaced_pkgs'].forEach((v) {
      //   replacedPkgs?.add(Dynamic.fromJson(v));
      // });
    }
  }
  List<dynamic>? brokenPkgs;
  List<dynamic>? causePausingPkgs;
  List<dynamic>? conflictedPkgs;
  List<dynamic>? nonExistPkgs;
  List<dynamic>? pausedPkgs;
  List<Queue>? queue;
  List<dynamic>? replacedPkgs;
  PackageInstallQueue copyWith({
    List<dynamic>? brokenPkgs,
    List<dynamic>? causePausingPkgs,
    List<dynamic>? conflictedPkgs,
    List<dynamic>? nonExistPkgs,
    List<dynamic>? pausedPkgs,
    List<Queue>? queue,
    List<dynamic>? replacedPkgs,
  }) =>
      PackageInstallQueue(
        brokenPkgs: brokenPkgs ?? this.brokenPkgs,
        causePausingPkgs: causePausingPkgs ?? this.causePausingPkgs,
        conflictedPkgs: conflictedPkgs ?? this.conflictedPkgs,
        nonExistPkgs: nonExistPkgs ?? this.nonExistPkgs,
        pausedPkgs: pausedPkgs ?? this.pausedPkgs,
        queue: queue ?? this.queue,
        replacedPkgs: replacedPkgs ?? this.replacedPkgs,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (brokenPkgs != null) {
      map['broken_pkgs'] = brokenPkgs?.map((v) => v.toJson()).toList();
    }
    if (causePausingPkgs != null) {
      map['cause_pausing_pkgs'] = causePausingPkgs?.map((v) => v.toJson()).toList();
    }
    if (conflictedPkgs != null) {
      map['conflicted_pkgs'] = conflictedPkgs?.map((v) => v.toJson()).toList();
    }
    if (nonExistPkgs != null) {
      map['non_exist_pkgs'] = nonExistPkgs?.map((v) => v.toJson()).toList();
    }
    if (pausedPkgs != null) {
      map['paused_pkgs'] = pausedPkgs?.map((v) => v.toJson()).toList();
    }
    if (queue != null) {
      map['queue'] = queue?.map((v) => v.toJson()).toList();
    }
    if (replacedPkgs != null) {
      map['replaced_pkgs'] = replacedPkgs?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// beta : false
/// pkg : "Node.js_v16"
/// volume : ""

class Queue {
  Queue({
    this.beta,
    this.pkg,
    this.volume,
  });

  Queue.fromJson(dynamic json) {
    beta = json['beta'];
    pkg = json['pkg'];
    volume = json['volume'];
  }
  bool? beta;
  String? pkg;
  String? volume;
  Queue copyWith({
    bool? beta,
    String? pkg,
    String? volume,
  }) =>
      Queue(
        beta: beta ?? this.beta,
        pkg: pkg ?? this.pkg,
        volume: volume ?? this.volume,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['beta'] = beta;
    map['pkg'] = pkg;
    map['volume'] = volume;
    return map;
  }
}
