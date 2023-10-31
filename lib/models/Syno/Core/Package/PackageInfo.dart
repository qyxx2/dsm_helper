import 'package:dsm_helper/apis/api.dart';

/// config : {"blBetaChannel":true,"blOtherServer":true,"def_void":"/volume4","ds_build":"42962","ds_major":"7","ds_minor":"1","ds_timezone":"Beijing","ds_unique":"synology_apollolake_918+","myPayBaseURL":"https://payment.synology.com","myds_id":"","success":true}
/// prerelease : {"agreed":false,"success":true}
/// term : {"agreed_term_version":"0003","curr_term_version":"0003","success":true}

class PackageInfo {
  PackageInfo({
    this.config,
    this.prerelease,
    this.term,
  });

  static Future<PackageInfo> get() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.Package.Info",
      "get",
      parser: PackageInfo.fromJson,
      version: 1,
    );
    return res.data;
  }

  PackageInfo.fromJson(dynamic json) {
    config = json['config'] != null ? Config.fromJson(json['config']) : null;
    prerelease = json['prerelease'] != null ? Prerelease.fromJson(json['prerelease']) : null;
    term = json['term'] != null ? Term.fromJson(json['term']) : null;
  }
  Config? config;
  Prerelease? prerelease;
  Term? term;
  PackageInfo copyWith({
    Config? config,
    Prerelease? prerelease,
    Term? term,
  }) =>
      PackageInfo(
        config: config ?? this.config,
        prerelease: prerelease ?? this.prerelease,
        term: term ?? this.term,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (config != null) {
      map['config'] = config?.toJson();
    }
    if (prerelease != null) {
      map['prerelease'] = prerelease?.toJson();
    }
    if (term != null) {
      map['term'] = term?.toJson();
    }
    return map;
  }
}

/// agreed_term_version : "0003"
/// curr_term_version : "0003"
/// success : true

class Term {
  Term({
    this.agreedTermVersion,
    this.currTermVersion,
    this.success,
  });

  Term.fromJson(dynamic json) {
    agreedTermVersion = json['agreed_term_version'];
    currTermVersion = json['curr_term_version'];
    success = json['success'];
  }
  String? agreedTermVersion;
  String? currTermVersion;
  bool? success;
  Term copyWith({
    String? agreedTermVersion,
    String? currTermVersion,
    bool? success,
  }) =>
      Term(
        agreedTermVersion: agreedTermVersion ?? this.agreedTermVersion,
        currTermVersion: currTermVersion ?? this.currTermVersion,
        success: success ?? this.success,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['agreed_term_version'] = agreedTermVersion;
    map['curr_term_version'] = currTermVersion;
    map['success'] = success;
    return map;
  }
}

/// agreed : false
/// success : true

class Prerelease {
  Prerelease({
    this.agreed,
    this.success,
  });

  Prerelease.fromJson(dynamic json) {
    agreed = json['agreed'];
    success = json['success'];
  }
  bool? agreed;
  bool? success;
  Prerelease copyWith({
    bool? agreed,
    bool? success,
  }) =>
      Prerelease(
        agreed: agreed ?? this.agreed,
        success: success ?? this.success,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['agreed'] = agreed;
    map['success'] = success;
    return map;
  }
}

/// blBetaChannel : true
/// blOtherServer : true
/// def_void : "/volume4"
/// ds_build : "42962"
/// ds_major : "7"
/// ds_minor : "1"
/// ds_timezone : "Beijing"
/// ds_unique : "synology_apollolake_918+"
/// myPayBaseURL : "https://payment.synology.com"
/// myds_id : ""
/// success : true

class Config {
  Config({
    this.blBetaChannel,
    this.blOtherServer,
    this.defVoid,
    this.dsBuild,
    this.dsMajor,
    this.dsMinor,
    this.dsTimezone,
    this.dsUnique,
    this.myPayBaseURL,
    this.mydsId,
    this.success,
  });

  Config.fromJson(dynamic json) {
    blBetaChannel = json['blBetaChannel'];
    blOtherServer = json['blOtherServer'];
    defVoid = json['def_void'];
    dsBuild = json['ds_build'];
    dsMajor = json['ds_major'];
    dsMinor = json['ds_minor'];
    dsTimezone = json['ds_timezone'];
    dsUnique = json['ds_unique'];
    myPayBaseURL = json['myPayBaseURL'];
    mydsId = json['myds_id'];
    success = json['success'];
  }
  bool? blBetaChannel;
  bool? blOtherServer;
  String? defVoid;
  String? dsBuild;
  String? dsMajor;
  String? dsMinor;
  String? dsTimezone;
  String? dsUnique;
  String? myPayBaseURL;
  String? mydsId;
  bool? success;
  Config copyWith({
    bool? blBetaChannel,
    bool? blOtherServer,
    String? defVoid,
    String? dsBuild,
    String? dsMajor,
    String? dsMinor,
    String? dsTimezone,
    String? dsUnique,
    String? myPayBaseURL,
    String? mydsId,
    bool? success,
  }) =>
      Config(
        blBetaChannel: blBetaChannel ?? this.blBetaChannel,
        blOtherServer: blOtherServer ?? this.blOtherServer,
        defVoid: defVoid ?? this.defVoid,
        dsBuild: dsBuild ?? this.dsBuild,
        dsMajor: dsMajor ?? this.dsMajor,
        dsMinor: dsMinor ?? this.dsMinor,
        dsTimezone: dsTimezone ?? this.dsTimezone,
        dsUnique: dsUnique ?? this.dsUnique,
        myPayBaseURL: myPayBaseURL ?? this.myPayBaseURL,
        mydsId: mydsId ?? this.mydsId,
        success: success ?? this.success,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['blBetaChannel'] = blBetaChannel;
    map['blOtherServer'] = blOtherServer;
    map['def_void'] = defVoid;
    map['ds_build'] = dsBuild;
    map['ds_major'] = dsMajor;
    map['ds_minor'] = dsMinor;
    map['ds_timezone'] = dsTimezone;
    map['ds_unique'] = dsUnique;
    map['myPayBaseURL'] = myPayBaseURL;
    map['myds_id'] = mydsId;
    map['success'] = success;
    return map;
  }
}
