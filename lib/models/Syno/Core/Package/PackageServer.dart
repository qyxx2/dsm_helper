import 'dart:convert';

import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/Core/Package/InstalledPackage.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageInstallQueue.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageInstallTask.dart';

class PackageServer {
  PackageServer({
    this.banners,
    this.betaPackages,
    this.categories,
    this.packages,
  });

  static Future<PackageServer> list({bool others = false, int version = 1}) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.Package.Server",
      "list",
      parser: PackageServer.fromJson,
      version: version,
      data: {
        "updateSprite": true,
        "blforcereload": false,
        "blloadothers": others,
      },
    );
    return res.data;
  }

  PackageServer.fromJson(dynamic json) {
    if (json['banners'] != null) {
      banners = [];
      json['banners'].forEach((v) {
        banners?.add(Banners.fromJson(v));
      });
    }
    if (json['beta_packages'] != null) {
      betaPackages = [];
      json['beta_packages'].forEach((v) {
        betaPackages?.add(PackageItem.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories?.add(Categories.fromJson(v));
      });
    }
    if (json['packages'] != null) {
      packages = [];
      json['packages'].forEach((v) {
        packages?.add(PackageItem.fromJson(v));
      });
    }
    if (json['data'] != null) {
      packages = [];
      json['packages'].forEach((v) {
        packages?.add(PackageItem.fromJson(v));
      });
    }
  }
  List<Banners>? banners;
  List<PackageItem>? betaPackages;
  List<Categories>? categories;
  List<PackageItem>? packages;
  PackageServer copyWith({
    List<Banners>? banners,
    List<PackageItem>? betaPackages,
    List<Categories>? categories,
    List<PackageItem>? packages,
  }) =>
      PackageServer(
        banners: banners ?? this.banners,
        betaPackages: betaPackages ?? this.betaPackages,
        categories: categories ?? this.categories,
        packages: packages ?? this.packages,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (banners != null) {
      map['banners'] = banners?.map((v) => v.toJson()).toList();
    }
    if (betaPackages != null) {
      map['beta_packages'] = betaPackages?.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      map['categories'] = categories?.map((v) => v.toJson()).toList();
    }
    if (packages != null) {
      map['packages'] = packages?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// beta : false
/// breakpkgs : null
/// category : ["backup","business"]
/// changelog : "<p><strong>问题修正（一般问题）</strong></p><ol style=\"list-style: decimal; padding-left: 30px;\"><li>修正了启用带宽使用限制时，Windows 设备上的增量备份速度减慢的问题。</li><li>修正了备份代理程序在备份系统卷时，同时备份其他包含系统数据的卷的问题。</li><li>修正了因夏令时调整，而导致备份任务无法依照计划执行的问题。</li></ol><p><strong>问题修正（Mac）</strong></p><ol style=\"list-style: decimal; padding-left: 30px;\"><li>改善备份代理程序的错误处理行为，以避免备份失败。</li><li>修正了备份本机系统卷时，备份代理程序同时备份其他卷的问题。</li></ol><p><strong>问题修正（虚拟机）</strong></p><ol style=\"list-style: decimal; padding-left: 30px;\"><li>修正了 Hypervisor 包含超过 1,000 台虚拟设备时，无法备份及还原的问题。</li><li>修正了取消选择不存在的虚拟机时，无法编辑已启用自动探索功能的备份任务的问题。</li><li>修正了虚拟机包含 Btrfs 文件系统时，还原入口无法于相同设备浏览两个以上版本的问题。</li><li>修正了因无法重新信任凭证，而导致凭证更新后无法编辑 Hypervisor 的问题。</li><li>修正了还原入口无法浏览两个以上包含 LDM 卷的虚拟机的问题。</li><li>修正了因备份服务器重复选择相同虚拟机，而导致无法建立备份任务的问题。</li></ol><p><strong>问题修正（文件服务器）</strong></p><ol style=\"list-style: decimal; padding-left: 30px;\"><li>修正了文件服务器备份任务无法取消的问题。</li><li>修正了当备份服务超时，文件服务器备份任务可能失败的问题。</li></ol>"
/// conflictpkgs : null
/// deppkgs : {"SMBService":""}
/// desc : "Active Backup for Business 旨在提供全面但集中化的数据保护解决方案，帮助您备份企业计算机、虚拟机、物理服务器和文件服务器等。"
/// distributor_url : "http://www.synology.com/"
/// dname : "Active Backup for Business"
/// download_count : 3589255
/// id : "ActiveBackup"
/// ignore_rolling : false
/// install_on_cold_storage : true
/// is_security_version : false
/// link : "https://cndl.synology.cn/download/Package/spk/ActiveBackup/2.6.1-13052/ActiveBackup-x86_64-2.6.1-13052.spk"
/// maintainer : "Synology Inc."
/// maintainer_url : "http://www.synology.com/"
/// md5 : "211faf13296fd8ebd817048214a595a4"
/// package : "ActiveBackup"
/// price : null
/// qinst : true
/// qstart : true
/// qupgrade : true
/// recent_download_count : 1303
/// replace_message : "<p>Compatibility &amp; Installation</p><ol style=\"list-style: decimal; padding-left: 30px;\"><li>Updated to be compatible with DSM 7.0 Preview.</li></ol>"
/// replaceforcepkgs : null
/// replacepkgs : null
/// silent_install : true
/// silent_uninstall : true
/// silent_upgrade : true
/// size : 103884344
/// snapshot : ["https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/activebackup_1607392921_1.png","https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/activebackup_1606734768_1.png","https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/activebackup_1606732047_1.png","https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/activebackup_1606734863_1.png"]
/// source : "syno"
/// start : true
/// thumbnail : ["https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/thumb_72.png","https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/thumb_256.png"]
/// thumbnail_retina : ["https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/thumb_256.png","https://cndl.synology.cn/download/Package/img/ActiveBackup/2.6.1-13052/thumb_256.png"]
/// type : 0
/// version : "2.6.1-13052"

class PackageItem {
  PackageItem({
    this.beta,
    this.breakpkgs,
    this.category,
    this.changelog,
    this.conflictpkgs,
    this.desc,
    this.distributor,
    this.distributorUrl,
    this.dname,
    this.downloadCount,
    this.id,
    this.ignoreRolling,
    this.installOnColdStorage,
    this.isSecurityVersion,
    this.link,
    this.maintainer,
    this.maintainerUrl,
    this.md5,
    this.package,
    this.price,
    this.qinst,
    this.qstart,
    this.qupgrade,
    this.recentDownloadCount,
    this.replaceMessage,
    this.replaceforcepkgs,
    this.replacepkgs,
    this.silentInstall,
    this.silentUninstall,
    this.silentUpgrade,
    this.size,
    this.snapshot,
    this.source,
    this.start,
    this.thumbnail,
    this.thumbnailRetina,
    this.type,
    this.version,
  });

  Future<bool?> feasibilityCheck() async {
    DsmResponse res = await Api.dsm.entry("SYNO.Core.Package", "feasibility_check", version: 1, data: {
      "type": "install_check",
      "packages": jsonEncode([id]),
    });
    return res.success;
  }

  Future<PackageInstallQueue> getInstallQueue() async {
    DsmResponse res = await Api.dsm.entry("SYNO.Core.Package.Installation", "get_queue", version: 1, parser: PackageInstallQueue.fromJson, data: {
      "pkgs": jsonEncode([
        {"pkg": "$id", "version": "$version", "beta": beta}
      ]),
    });
    return res.data;
  }

  Future<PackageInstallTask> install() async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Core.Package.Installation",
      "install",
      version: 1,
      parser: PackageInstallTask.fromJson,
      data: {
        "name": id,
        "url": link,
        "checksum": md5,
        "filesize": size,
        "type": type,
        "blqinst": false,
        "operation": "install",
      },
    );
    print(res.data);
    return res.data;
  }

  PackageItem.fromJson(dynamic json) {
    beta = json['beta'];
    breakpkgs = json['breakpkgs'];
    category = json['category'] != null && json['category'] is List ? json['category'].cast<String>() : [];
    changelog = json['changelog'];
    conflictpkgs = json['conflictpkgs'];
    desc = json['desc'];
    distributor = json['distributor'];
    distributorUrl = json['distributor_url'];
    dname = json['dname'];
    downloadCount = json['download_count'];
    id = json['id'];
    ignoreRolling = json['ignore_rolling'];
    installOnColdStorage = json['install_on_cold_storage'];
    isSecurityVersion = json['is_security_version'];
    link = json['link'];
    maintainer = json['maintainer'];
    maintainerUrl = json['maintainer_url'];
    md5 = json['md5'];
    package = json['package'];
    price = json['price'];
    qinst = json['qinst'];
    qstart = json['qstart'];
    qupgrade = json['qupgrade'];
    recentDownloadCount = json['recent_download_count'];
    replaceMessage = json['replace_message'];
    replaceforcepkgs = json['replaceforcepkgs'];
    replacepkgs = json['replacepkgs'];
    silentInstall = json['silent_install'];
    silentUninstall = json['silent_uninstall'];
    silentUpgrade = json['silent_upgrade'];
    size = json['size'];
    snapshot = json['snapshot'] != null ? json['snapshot'].cast<String>() : [];
    source = json['source'];
    start = json['start'];
    thumbnail = json['thumbnail'] != null ? json['thumbnail'].cast<String>() : [];
    thumbnailRetina = json['thumbnail_retina'] != null ? json['thumbnail_retina'].cast<String>() : [];
    type = json['type'];
    version = json['version'];
  }
  bool? beta;
  dynamic breakpkgs;
  List<String>? category;
  String? changelog;
  dynamic conflictpkgs;
  String? desc;
  String? distributor;
  String? distributorUrl;
  String? dname;
  num? downloadCount;
  String? id;
  bool? ignoreRolling;
  bool? installOnColdStorage;
  bool? isSecurityVersion;
  String? link;
  String? maintainer;
  String? maintainerUrl;
  String? md5;
  String? package;
  dynamic price;
  bool? qinst;
  bool? qstart;
  bool? qupgrade;
  num? recentDownloadCount;
  String? replaceMessage;
  dynamic replaceforcepkgs;
  dynamic replacepkgs;
  bool? silentInstall;
  bool? silentUninstall;
  bool? silentUpgrade;
  num? size;
  List<String>? snapshot;
  String? source;
  bool? start;
  List<String>? thumbnail;
  List<String>? thumbnailRetina;
  num? type;
  String? version;

  bool loading = false;
  bool installed = false;
  InstalledPackageItem? installedPackageItem;

  PackageItem copyWith({
    bool? beta,
    dynamic breakpkgs,
    List<String>? category,
    String? changelog,
    dynamic conflictpkgs,
    String? desc,
    String? distributorUrl,
    String? dname,
    num? downloadCount,
    String? id,
    bool? ignoreRolling,
    bool? installOnColdStorage,
    bool? isSecurityVersion,
    String? link,
    String? maintainer,
    String? maintainerUrl,
    String? md5,
    String? package,
    dynamic price,
    bool? qinst,
    bool? qstart,
    bool? qupgrade,
    num? recentDownloadCount,
    String? replaceMessage,
    dynamic replaceforcepkgs,
    dynamic replacepkgs,
    bool? silentInstall,
    bool? silentUninstall,
    bool? silentUpgrade,
    num? size,
    List<String>? snapshot,
    String? source,
    bool? start,
    List<String>? thumbnail,
    List<String>? thumbnailRetina,
    num? type,
    String? version,
  }) =>
      PackageItem(
        beta: beta ?? this.beta,
        breakpkgs: breakpkgs ?? this.breakpkgs,
        category: category ?? this.category,
        changelog: changelog ?? this.changelog,
        conflictpkgs: conflictpkgs ?? this.conflictpkgs,
        desc: desc ?? this.desc,
        distributorUrl: distributorUrl ?? this.distributorUrl,
        dname: dname ?? this.dname,
        downloadCount: downloadCount ?? this.downloadCount,
        id: id ?? this.id,
        ignoreRolling: ignoreRolling ?? this.ignoreRolling,
        installOnColdStorage: installOnColdStorage ?? this.installOnColdStorage,
        isSecurityVersion: isSecurityVersion ?? this.isSecurityVersion,
        link: link ?? this.link,
        maintainer: maintainer ?? this.maintainer,
        maintainerUrl: maintainerUrl ?? this.maintainerUrl,
        md5: md5 ?? this.md5,
        package: package ?? this.package,
        price: price ?? this.price,
        qinst: qinst ?? this.qinst,
        qstart: qstart ?? this.qstart,
        qupgrade: qupgrade ?? this.qupgrade,
        recentDownloadCount: recentDownloadCount ?? this.recentDownloadCount,
        replaceMessage: replaceMessage ?? this.replaceMessage,
        replaceforcepkgs: replaceforcepkgs ?? this.replaceforcepkgs,
        replacepkgs: replacepkgs ?? this.replacepkgs,
        silentInstall: silentInstall ?? this.silentInstall,
        silentUninstall: silentUninstall ?? this.silentUninstall,
        silentUpgrade: silentUpgrade ?? this.silentUpgrade,
        size: size ?? this.size,
        snapshot: snapshot ?? this.snapshot,
        source: source ?? this.source,
        start: start ?? this.start,
        thumbnail: thumbnail ?? this.thumbnail,
        thumbnailRetina: thumbnailRetina ?? this.thumbnailRetina,
        type: type ?? this.type,
        version: version ?? this.version,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['beta'] = beta;
    map['breakpkgs'] = breakpkgs;
    map['category'] = category;
    map['changelog'] = changelog;
    map['conflictpkgs'] = conflictpkgs;
    map['desc'] = desc;
    map['distributor_url'] = distributorUrl;
    map['dname'] = dname;
    map['download_count'] = downloadCount;
    map['id'] = id;
    map['ignore_rolling'] = ignoreRolling;
    map['install_on_cold_storage'] = installOnColdStorage;
    map['is_security_version'] = isSecurityVersion;
    map['link'] = link;
    map['maintainer'] = maintainer;
    map['maintainer_url'] = maintainerUrl;
    map['md5'] = md5;
    map['package'] = package;
    map['price'] = price;
    map['qinst'] = qinst;
    map['qstart'] = qstart;
    map['qupgrade'] = qupgrade;
    map['recent_download_count'] = recentDownloadCount;
    map['replace_message'] = replaceMessage;
    map['replaceforcepkgs'] = replaceforcepkgs;
    map['replacepkgs'] = replacepkgs;
    map['silent_install'] = silentInstall;
    map['silent_uninstall'] = silentUninstall;
    map['silent_upgrade'] = silentUpgrade;
    map['size'] = size;
    map['snapshot'] = snapshot;
    map['source'] = source;
    map['start'] = start;
    map['thumbnail'] = thumbnail;
    map['thumbnail_retina'] = thumbnailRetina;
    map['type'] = type;
    map['version'] = version;
    return map;
  }
}

/// descr : "通过强大的备份套件防范意外的数据丢失。可以为物理和虚拟环境备份数据、拍摄快照或还原文件。"
/// dname : "备份"
/// id : "backup"
/// isCompilation : false

class Categories {
  Categories({
    this.descr,
    this.dname,
    this.id,
    this.isCompilation,
  });

  Categories.fromJson(dynamic json) {
    descr = json['descr'];
    dname = json['dname'];
    id = json['id'];
    isCompilation = json['isCompilation'];
  }
  String? descr;
  String? dname;
  String? id;
  bool? isCompilation;
  Categories copyWith({
    String? descr,
    String? dname,
    String? id,
    bool? isCompilation,
  }) =>
      Categories(
        descr: descr ?? this.descr,
        dname: dname ?? this.dname,
        id: id ?? this.id,
        isCompilation: isCompilation ?? this.isCompilation,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['descr'] = descr;
    map['dname'] = dname;
    map['id'] = id;
    map['isCompilation'] = isCompilation;
    return map;
  }
}

/// background : "https://cndl.synology.cn/download/Package/banner/Collaboration/background.png"
/// beta : false
/// css : {"desc":"font-size: 13px; line-height: 20px; max-height: 120px; overflow-y: hidden; margin-bottom: 40px","icon":"width: 72px; height: 72px; margin-bottom: 4px; display:none;","string":"width: 45%; display: flex; display: -ms-flexbox; -ms-flex-align: center; align-items: center; padding: 0 0 0 5%; background-color: rgba(0, 180, 90, 0.9); height: 100%; position: relative","title":"max-height: 64px; font-size: 24px; line-height: 32px; margin-bottom: 8px; overflow-y: hidden","triangle":"position: absolute; top: 0; right: -92px; width: 0; height: 0; border-style: solid; border-width: 280px 0 0 92px; border-color: transparent transparent transparent rgba(0, 180, 90,0.9)"}
/// descr : "邀请外部用户加入 Chat 进行讨论<br>\r\n通过灵活的权限设置，在 Office 中共享文件<br>\r\n与团队成员共享 MailPlus 邮箱<br>\r\n在 Calendar 中整理每日待办任务<br>"
/// icon : ""
/// keyword : "collaboration_suite"
/// link : ""
/// sort : 0
/// title : "协作套件"
/// type : "compilation"

class Banners {
  Banners({
    this.background,
    this.beta,
    this.css,
    this.descr,
    this.icon,
    this.keyword,
    this.link,
    this.sort,
    this.title,
    this.type,
  });

  Banners.fromJson(dynamic json) {
    background = json['background'];
    beta = json['beta'];
    css = json['css'] != null ? Css.fromJson(json['css']) : null;
    descr = json['descr'];
    icon = json['icon'];
    keyword = json['keyword'];
    link = json['link'];
    sort = json['sort'];
    title = json['title'];
    type = json['type'];
  }
  String? background;
  bool? beta;
  Css? css;
  String? descr;
  String? icon;
  String? keyword;
  String? link;
  num? sort;
  String? title;
  String? type;
  Banners copyWith({
    String? background,
    bool? beta,
    Css? css,
    String? descr,
    String? icon,
    String? keyword,
    String? link,
    num? sort,
    String? title,
    String? type,
  }) =>
      Banners(
        background: background ?? this.background,
        beta: beta ?? this.beta,
        css: css ?? this.css,
        descr: descr ?? this.descr,
        icon: icon ?? this.icon,
        keyword: keyword ?? this.keyword,
        link: link ?? this.link,
        sort: sort ?? this.sort,
        title: title ?? this.title,
        type: type ?? this.type,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['background'] = background;
    map['beta'] = beta;
    if (css != null) {
      map['css'] = css?.toJson();
    }
    map['descr'] = descr;
    map['icon'] = icon;
    map['keyword'] = keyword;
    map['link'] = link;
    map['sort'] = sort;
    map['title'] = title;
    map['type'] = type;
    return map;
  }
}

/// desc : "font-size: 13px; line-height: 20px; max-height: 120px; overflow-y: hidden; margin-bottom: 40px"
/// icon : "width: 72px; height: 72px; margin-bottom: 4px; display:none;"
/// string : "width: 45%; display: flex; display: -ms-flexbox; -ms-flex-align: center; align-items: center; padding: 0 0 0 5%; background-color: rgba(0, 180, 90, 0.9); height: 100%; position: relative"
/// title : "max-height: 64px; font-size: 24px; line-height: 32px; margin-bottom: 8px; overflow-y: hidden"
/// triangle : "position: absolute; top: 0; right: -92px; width: 0; height: 0; border-style: solid; border-width: 280px 0 0 92px; border-color: transparent transparent transparent rgba(0, 180, 90,0.9)"

class Css {
  Css({
    this.desc,
    this.icon,
    this.string,
    this.title,
    this.triangle,
  });

  Css.fromJson(dynamic json) {
    desc = json['desc'];
    icon = json['icon'];
    string = json['string'];
    title = json['title'];
    triangle = json['triangle'];
  }
  String? desc;
  String? icon;
  String? string;
  String? title;
  String? triangle;
  Css copyWith({
    String? desc,
    String? icon,
    String? string,
    String? title,
    String? triangle,
  }) =>
      Css(
        desc: desc ?? this.desc,
        icon: icon ?? this.icon,
        string: string ?? this.string,
        title: title ?? this.title,
        triangle: triangle ?? this.triangle,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['desc'] = desc;
    map['icon'] = icon;
    map['string'] = string;
    map['title'] = title;
    map['triangle'] = triangle;
    return map;
  }
}
