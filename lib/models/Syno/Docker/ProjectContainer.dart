import 'package:dsm_helper/pages/docker/enums/container_status_enum.dart';

/// AppArmorProfile : "docker-default"
/// Args : []
/// Config : {"AttachStderr":true,"AttachStdin":false,"AttachStdout":true,"Cmd":null,"DDSM":false,"Domainname":"","Entrypoint":["/init"],"Env":["PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","PS1=$(whoami)@$(hostname):$(pwd)\\$ ","HOME=/config","TERM=xterm","S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0","S6_VERBOSITY=1","S6_STAGE2_HOOK=/docker-mods","VIRTUAL_ENV=/lsiopy","LSIO_FIRST_PARTY=true","XDG_CONFIG_HOME=/config","XDG_DATA_HOME=/config","WEBUI_PORT=5581"],"ExposedPorts":{"52000/tcp":{},"5581/tcp":{},"6881/tcp":{},"6881/udp":{},"8080/tcp":{}},"Hostname":"1c337ea30de9","Image":"linuxserver/qbittorrent","Labels":{"build_version":"Linuxserver.io version:- 4.6.0-r0-ls294 Build-date:- 2023-10-29T06:54:01+00:00","com.docker.compose.config-hash":"04949dace87bab26ec25ebd415b293da880e2c3f075bce39d71dfc166bd63e80","com.docker.compose.container-number":"1","com.docker.compose.depends_on":"","com.docker.compose.image":"sha256:d17ec24707d5f5378e36ecabfe4670fde1d39d5105d9610d3a00513668b638ad","com.docker.compose.oneoff":"False","com.docker.compose.project":"qbittorrent","com.docker.compose.project.config_files":"/volume3/docker/qbittorrent/compose.yaml","com.docker.compose.project.working_dir":"/volume3/docker/qbittorrent","com.docker.compose.service":"emby","com.docker.compose.version":"2.9.0","maintainer":"thespad","org.opencontainers.image.authors":"linuxserver.io","org.opencontainers.image.created":"2023-10-29T06:54:01+00:00","org.opencontainers.image.description":"The [Qbittorrent](https://www.qbittorrent.org/) project aims to provide an open-source software alternative to µTorrent. qBittorrent is based on the Qt toolkit and libtorrent-rasterbar library.","org.opencontainers.image.documentation":"https://docs.linuxserver.io/images/docker-qbittorrent","org.opencontainers.image.licenses":"GPL-3.0-only","org.opencontainers.image.ref.name":"1d02eac543db6c970950fc71164db6dd578d1aa3","org.opencontainers.image.revision":"1d02eac543db6c970950fc71164db6dd578d1aa3","org.opencontainers.image.source":"https://github.com/linuxserver/docker-qbittorrent","org.opencontainers.image.title":"Qbittorrent","org.opencontainers.image.url":"https://github.com/linuxserver/docker-qbittorrent/packages","org.opencontainers.image.vendor":"linuxserver.io","org.opencontainers.image.version":"4.6.0-r0-ls294"},"OnBuild":null,"OpenStdin":false,"StdinOnce":false,"Tty":false,"User":"","Volumes":{"/config":{}},"WorkingDir":"/"}
/// Created : "2023-11-07T13:58:37.939644289Z"
/// Driver : "btrfs"
/// ExecIDs : null
/// GraphDriver : {"Data":null,"Name":"btrfs"}
/// HostConfig : {"AutoRemove":false,"Binds":["/volume3/docker/qbittorrent/config:/config:rw","/volume4/影视/下载/qbittorrent:/downloads:rw"],"BlkioDeviceReadBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceWriteIOps":null,"BlkioWeight":0,"BlkioWeightDevice":null,"CapAdd":null,"CapDrop":null,"Cgroup":"","CgroupParent":"","CgroupnsMode":"host","ConsoleSize":[0,0],"ContainerIDFile":"","CpuCount":0,"CpuPercent":0,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpuShares":50,"CpusetCpus":"","CpusetMems":"","DeviceCgroupRules":null,"DeviceRequests":null,"Devices":null,"Dns":[],"DnsOptions":[],"DnsSearch":[],"Env":["PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","PS1=$(whoami)@$(hostname):$(pwd)\\$ ","HOME=/config","TERM=xterm","S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0","S6_VERBOSITY=1","S6_STAGE2_HOOK=/docker-mods","VIRTUAL_ENV=/lsiopy","LSIO_FIRST_PARTY=true","XDG_CONFIG_HOME=/config","XDG_DATA_HOME=/config","WEBUI_PORT=5581"],"ExtraHosts":[],"GroupAdd":null,"IOMaximumBandwidth":0,"IOMaximumIOps":0,"IpcMode":"private","Isolation":"","KernelMemory":0,"KernelMemoryTCP":0,"Links":null,"LogConfig":{"Config":{},"Type":"db"},"MaskedPaths":["/proc/asound","/proc/acpi","/proc/kcore","/proc/keys","/proc/latency_stats","/proc/timer_list","/proc/timer_stats","/proc/sched_debug","/proc/scsi","/sys/firmware"],"Memory":0,"MemoryReservation":0,"MemorySwap":0,"MemorySwappiness":null,"NanoCpus":0,"NetworkMode":"bridge","OomKillDisable":false,"OomScoreAdj":0,"PidMode":"","PidsLimit":null,"PortBindings":{"52000/tcp":[{"HostIp":"","HostPort":"52000"}],"5581/tcp":[{"HostIp":"","HostPort":"5581"}]},"Privileged":false,"PublishAllPorts":false,"ReadonlyPaths":["/proc/bus","/proc/fs","/proc/irq","/proc/sys","/proc/sysrq-trigger"],"ReadonlyRootfs":false,"RestartPolicy":{"MaximumRetryCount":0,"Name":"no"},"Runtime":"runc","SecurityOpt":null,"ShmSize":67108864,"UTSMode":"","Ulimits":null,"UsernsMode":"","VolumeDriver":"","VolumesFrom":null}
/// HostnamePath : "/volume4/@docker/containers/82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3/hostname"
/// HostsPath : "/volume4/@docker/containers/82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3/hosts"
/// Id : "82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3"
/// Image : "sha256:0c7dbb6a6e647a36242a02e7a3303fd8b9463f4ef2b60313a12bdc39e00bbae7"
/// LogPath : "/volume4/@docker/containers/82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3/log.db"
/// MountLabel : ""
/// Mounts : [{"Destination":"/config","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume3/docker/qbittorrent/config","Type":"bind"},{"Destination":"/downloads","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume4/影视/下载/qbittorrent","Type":"bind"}]
/// Name : "/qbittorrent"
/// NetworkSettings : {"Bridge":"","EndpointID":"d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"HairpinMode":false,"IPAddress":"172.17.0.5","IPPrefixLen":16,"IPv6Gateway":"","LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:05","Networks":{"bridge":{"Aliases":null,"DriverOpts":null,"EndpointID":"d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.5","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:05","NetworkID":"360feba33caf38cce219eab2f910fa3def2d6a6cabc98d3bf2704d41752ec667"}},"Ports":{"52000/tcp":[{"HostIp":"0.0.0.0","HostPort":"52000"},{"HostIp":"::","HostPort":"52000"}],"5581/tcp":[{"HostIp":"0.0.0.0","HostPort":"5581"},{"HostIp":"::","HostPort":"5581"}],"6881/tcp":null,"6881/udp":null,"8080/tcp":null},"SandboxID":"9c6000cc9da274a2c3c9cbca594a9f52e56cd104b7749250bda043f67ced9d2b","SandboxKey":"/var/run/docker/netns/9c6000cc9da2","SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null}
/// Path : "/init"
/// Platform : "linux"
/// ProcessLabel : ""
/// ResolvConfPath : "/volume4/@docker/containers/82c220324beeabf83ef751af6b3261053ad2a220cecfd6c79f22d8cf652ebfa3/resolv.conf"
/// RestartCount : 0
/// State : {"Dead":false,"Error":"","ExitCode":0,"FinishedAt":"0001-01-01T00:00:00Z","FinishedTs":-62135596800,"OOMKilled":false,"Paused":false,"Pid":12284,"Restarting":false,"Running":true,"StartedAt":"2023-11-07T13:58:44.398801239Z","StartedTs":1699365524,"Status":"running"}

class ProjectContainer {
  ProjectContainer({
      this.appArmorProfile, 
      this.args, 
      this.config, 
      this.created, 
      this.driver, 
      this.execIDs, 
      this.graphDriver, 
      this.hostConfig, 
      this.hostnamePath, 
      this.hostsPath, 
      this.id, 
      this.image, 
      this.logPath, 
      this.mountLabel, 
      this.mounts, 
      this.name, 
      this.networkSettings, 
      this.path, 
      this.platform, 
      this.processLabel, 
      this.resolvConfPath, 
      this.restartCount, 
      this.state,});

  ProjectContainer.fromJson(dynamic json) {
    appArmorProfile = json['AppArmorProfile'];
    // if (json['Args'] != null) {
    //   args = [];
    //   json['Args'].forEach((v) {
    //     args?.add(Dynamic.fromJson(v));
    //   });
    // }
    args = json['Args'] != null ? json['Args'].cast<String>() : null;
    config = json['Config'] != null ? Config.fromJson(json['Config']) : null;
    created = json['Created'];
    driver = json['Driver'];
    execIDs = json['ExecIDs'];
    graphDriver = json['GraphDriver'] != null ? GraphDriver.fromJson(json['GraphDriver']) : null;
    hostConfig = json['HostConfig'] != null ? HostConfig.fromJson(json['HostConfig']) : null;
    hostnamePath = json['HostnamePath'];
    hostsPath = json['HostsPath'];
    id = json['Id'];
    image = json['Image'];
    logPath = json['LogPath'];
    mountLabel = json['MountLabel'];
    if (json['Mounts'] != null) {
      mounts = [];
      json['Mounts'].forEach((v) {
        mounts?.add(Mounts.fromJson(v));
      });
    }
    name = json['Name'];
    networkSettings = json['NetworkSettings'] != null ? NetworkSettings.fromJson(json['NetworkSettings']) : null;
    path = json['Path'];
    platform = json['Platform'];
    processLabel = json['ProcessLabel'];
    resolvConfPath = json['ResolvConfPath'];
    restartCount = json['RestartCount'];
    state = json['State'] != null ? State.fromJson(json['State']) : null;
  }
  String? appArmorProfile;
  List<dynamic>? args;
  Config? config;
  String? created;
  String? driver;
  dynamic execIDs;
  GraphDriver? graphDriver;
  HostConfig? hostConfig;
  String? hostnamePath;
  String? hostsPath;
  String? id;
  String? image;
  String? logPath;
  String? mountLabel;
  List<Mounts>? mounts;
  String? name;
  NetworkSettings? networkSettings;
  String? path;
  String? platform;
  String? processLabel;
  String? resolvConfPath;
  num? restartCount;
  State? state;
ProjectContainer copyWith({  String? appArmorProfile,
  List<dynamic>? args,
  Config? config,
  String? created,
  String? driver,
  dynamic execIDs,
  GraphDriver? graphDriver,
  HostConfig? hostConfig,
  String? hostnamePath,
  String? hostsPath,
  String? id,
  String? image,
  String? logPath,
  String? mountLabel,
  List<Mounts>? mounts,
  String? name,
  NetworkSettings? networkSettings,
  String? path,
  String? platform,
  String? processLabel,
  String? resolvConfPath,
  num? restartCount,
  State? state,
}) => ProjectContainer(  appArmorProfile: appArmorProfile ?? this.appArmorProfile,
  args: args ?? this.args,
  config: config ?? this.config,
  created: created ?? this.created,
  driver: driver ?? this.driver,
  execIDs: execIDs ?? this.execIDs,
  graphDriver: graphDriver ?? this.graphDriver,
  hostConfig: hostConfig ?? this.hostConfig,
  hostnamePath: hostnamePath ?? this.hostnamePath,
  hostsPath: hostsPath ?? this.hostsPath,
  id: id ?? this.id,
  image: image ?? this.image,
  logPath: logPath ?? this.logPath,
  mountLabel: mountLabel ?? this.mountLabel,
  mounts: mounts ?? this.mounts,
  name: name ?? this.name,
  networkSettings: networkSettings ?? this.networkSettings,
  path: path ?? this.path,
  platform: platform ?? this.platform,
  processLabel: processLabel ?? this.processLabel,
  resolvConfPath: resolvConfPath ?? this.resolvConfPath,
  restartCount: restartCount ?? this.restartCount,
  state: state ?? this.state,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AppArmorProfile'] = appArmorProfile;
    if (args != null) {
      map['Args'] = args?.map((v) => v.toJson()).toList();
    }
    if (config != null) {
      map['Config'] = config?.toJson();
    }
    map['Created'] = created;
    map['Driver'] = driver;
    map['ExecIDs'] = execIDs;
    if (graphDriver != null) {
      map['GraphDriver'] = graphDriver?.toJson();
    }
    if (hostConfig != null) {
      map['HostConfig'] = hostConfig?.toJson();
    }
    map['HostnamePath'] = hostnamePath;
    map['HostsPath'] = hostsPath;
    map['Id'] = id;
    map['Image'] = image;
    map['LogPath'] = logPath;
    map['MountLabel'] = mountLabel;
    if (mounts != null) {
      map['Mounts'] = mounts?.map((v) => v.toJson()).toList();
    }
    map['Name'] = name;
    if (networkSettings != null) {
      map['NetworkSettings'] = networkSettings?.toJson();
    }
    map['Path'] = path;
    map['Platform'] = platform;
    map['ProcessLabel'] = processLabel;
    map['ResolvConfPath'] = resolvConfPath;
    map['RestartCount'] = restartCount;
    if (state != null) {
      map['State'] = state?.toJson();
    }
    return map;
  }

}

/// Dead : false
/// Error : ""
/// ExitCode : 0
/// FinishedAt : "0001-01-01T00:00:00Z"
/// FinishedTs : -62135596800
/// OOMKilled : false
/// Paused : false
/// Pid : 12284
/// Restarting : false
/// Running : true
/// StartedAt : "2023-11-07T13:58:44.398801239Z"
/// StartedTs : 1699365524
/// Status : "running"

class State {
  State({
      this.dead, 
      this.error, 
      this.exitCode, 
      this.finishedAt, 
      this.finishedTs, 
      this.oOMKilled, 
      this.paused, 
      this.pid, 
      this.restarting, 
      this.running, 
      this.startedAt, 
      this.startedTs, 
      this.status,});

  State.fromJson(dynamic json) {
    dead = json['Dead'];
    error = json['Error'];
    exitCode = json['ExitCode'];
    finishedAt = json['FinishedAt'];
    finishedTs = json['FinishedTs'];
    oOMKilled = json['OOMKilled'];
    paused = json['Paused'];
    pid = json['Pid'];
    restarting = json['Restarting'];
    running = json['Running'];
    startedAt = json['StartedAt'];
    startedTs = json['StartedTs'];
    status = json['Status'];
  }
  bool? dead;
  String? error;
  num? exitCode;
  String? finishedAt;
  num? finishedTs;
  bool? oOMKilled;
  bool? paused;
  num? pid;
  bool? restarting;
  bool? running;
  String? startedAt;
  num? startedTs;
  String? status;
  ContainerStatusEnum get statusEnum=>ContainerStatusEnum.fromValue(status ?? 'unknown');
State copyWith({  bool? dead,
  String? error,
  num? exitCode,
  String? finishedAt,
  num? finishedTs,
  bool? oOMKilled,
  bool? paused,
  num? pid,
  bool? restarting,
  bool? running,
  String? startedAt,
  num? startedTs,
  String? status,
}) => State(  dead: dead ?? this.dead,
  error: error ?? this.error,
  exitCode: exitCode ?? this.exitCode,
  finishedAt: finishedAt ?? this.finishedAt,
  finishedTs: finishedTs ?? this.finishedTs,
  oOMKilled: oOMKilled ?? this.oOMKilled,
  paused: paused ?? this.paused,
  pid: pid ?? this.pid,
  restarting: restarting ?? this.restarting,
  running: running ?? this.running,
  startedAt: startedAt ?? this.startedAt,
  startedTs: startedTs ?? this.startedTs,
  status: status ?? this.status,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Dead'] = dead;
    map['Error'] = error;
    map['ExitCode'] = exitCode;
    map['FinishedAt'] = finishedAt;
    map['FinishedTs'] = finishedTs;
    map['OOMKilled'] = oOMKilled;
    map['Paused'] = paused;
    map['Pid'] = pid;
    map['Restarting'] = restarting;
    map['Running'] = running;
    map['StartedAt'] = startedAt;
    map['StartedTs'] = startedTs;
    map['Status'] = status;
    return map;
  }

}

/// Bridge : ""
/// EndpointID : "d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc"
/// Gateway : "172.17.0.1"
/// GlobalIPv6Address : ""
/// GlobalIPv6PrefixLen : 0
/// HairpinMode : false
/// IPAddress : "172.17.0.5"
/// IPPrefixLen : 16
/// IPv6Gateway : ""
/// LinkLocalIPv6Address : ""
/// LinkLocalIPv6PrefixLen : 0
/// MacAddress : "02:42:ac:11:00:05"
/// Networks : {"bridge":{"Aliases":null,"DriverOpts":null,"EndpointID":"d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.5","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:05","NetworkID":"360feba33caf38cce219eab2f910fa3def2d6a6cabc98d3bf2704d41752ec667"}}
/// Ports : {"52000/tcp":[{"HostIp":"0.0.0.0","HostPort":"52000"},{"HostIp":"::","HostPort":"52000"}],"5581/tcp":[{"HostIp":"0.0.0.0","HostPort":"5581"},{"HostIp":"::","HostPort":"5581"}],"6881/tcp":null,"6881/udp":null,"8080/tcp":null}
/// SandboxID : "9c6000cc9da274a2c3c9cbca594a9f52e56cd104b7749250bda043f67ced9d2b"
/// SandboxKey : "/var/run/docker/netns/9c6000cc9da2"
/// SecondaryIPAddresses : null
/// SecondaryIPv6Addresses : null

class NetworkSettings {
  NetworkSettings({
      this.bridge, 
      this.endpointID, 
      this.gateway, 
      this.globalIPv6Address, 
      this.globalIPv6PrefixLen, 
      this.hairpinMode, 
      this.iPAddress, 
      this.iPPrefixLen, 
      this.iPv6Gateway, 
      this.linkLocalIPv6Address, 
      this.linkLocalIPv6PrefixLen, 
      this.macAddress, 
      this.networks, 
      this.ports, 
      this.sandboxID, 
      this.sandboxKey, 
      this.secondaryIPAddresses, 
      this.secondaryIPv6Addresses,});

  NetworkSettings.fromJson(dynamic json) {
    bridge = json['Bridge'];
    endpointID = json['EndpointID'];
    gateway = json['Gateway'];
    globalIPv6Address = json['GlobalIPv6Address'];
    globalIPv6PrefixLen = json['GlobalIPv6PrefixLen'];
    hairpinMode = json['HairpinMode'];
    iPAddress = json['IPAddress'];
    iPPrefixLen = json['IPPrefixLen'];
    iPv6Gateway = json['IPv6Gateway'];
    linkLocalIPv6Address = json['LinkLocalIPv6Address'];
    linkLocalIPv6PrefixLen = json['LinkLocalIPv6PrefixLen'];
    macAddress = json['MacAddress'];
    networks = json['Networks'] != null ? Networks.fromJson(json['Networks']) : null;
    ports = json['Ports'];
    sandboxID = json['SandboxID'];
    sandboxKey = json['SandboxKey'];
    secondaryIPAddresses = json['SecondaryIPAddresses'];
    secondaryIPv6Addresses = json['SecondaryIPv6Addresses'];
  }
  String? bridge;
  String? endpointID;
  String? gateway;
  String? globalIPv6Address;
  num? globalIPv6PrefixLen;
  bool? hairpinMode;
  String? iPAddress;
  num? iPPrefixLen;
  String? iPv6Gateway;
  String? linkLocalIPv6Address;
  num? linkLocalIPv6PrefixLen;
  String? macAddress;
  Networks? networks;
  Map? ports;
  String? sandboxID;
  String? sandboxKey;
  dynamic secondaryIPAddresses;
  dynamic secondaryIPv6Addresses;
NetworkSettings copyWith({  String? bridge,
  String? endpointID,
  String? gateway,
  String? globalIPv6Address,
  num? globalIPv6PrefixLen,
  bool? hairpinMode,
  String? iPAddress,
  num? iPPrefixLen,
  String? iPv6Gateway,
  String? linkLocalIPv6Address,
  num? linkLocalIPv6PrefixLen,
  String? macAddress,
  Networks? networks,
  Map? ports,
  String? sandboxID,
  String? sandboxKey,
  dynamic secondaryIPAddresses,
  dynamic secondaryIPv6Addresses,
}) => NetworkSettings(  bridge: bridge ?? this.bridge,
  endpointID: endpointID ?? this.endpointID,
  gateway: gateway ?? this.gateway,
  globalIPv6Address: globalIPv6Address ?? this.globalIPv6Address,
  globalIPv6PrefixLen: globalIPv6PrefixLen ?? this.globalIPv6PrefixLen,
  hairpinMode: hairpinMode ?? this.hairpinMode,
  iPAddress: iPAddress ?? this.iPAddress,
  iPPrefixLen: iPPrefixLen ?? this.iPPrefixLen,
  iPv6Gateway: iPv6Gateway ?? this.iPv6Gateway,
  linkLocalIPv6Address: linkLocalIPv6Address ?? this.linkLocalIPv6Address,
  linkLocalIPv6PrefixLen: linkLocalIPv6PrefixLen ?? this.linkLocalIPv6PrefixLen,
  macAddress: macAddress ?? this.macAddress,
  networks: networks ?? this.networks,
  ports: ports ?? this.ports,
  sandboxID: sandboxID ?? this.sandboxID,
  sandboxKey: sandboxKey ?? this.sandboxKey,
  secondaryIPAddresses: secondaryIPAddresses ?? this.secondaryIPAddresses,
  secondaryIPv6Addresses: secondaryIPv6Addresses ?? this.secondaryIPv6Addresses,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Bridge'] = bridge;
    map['EndpointID'] = endpointID;
    map['Gateway'] = gateway;
    map['GlobalIPv6Address'] = globalIPv6Address;
    map['GlobalIPv6PrefixLen'] = globalIPv6PrefixLen;
    map['HairpinMode'] = hairpinMode;
    map['IPAddress'] = iPAddress;
    map['IPPrefixLen'] = iPPrefixLen;
    map['IPv6Gateway'] = iPv6Gateway;
    map['LinkLocalIPv6Address'] = linkLocalIPv6Address;
    map['LinkLocalIPv6PrefixLen'] = linkLocalIPv6PrefixLen;
    map['MacAddress'] = macAddress;
    if (networks != null) {
      map['Networks'] = networks?.toJson();
    }
    map['Ports'] = ports;
    map['SandboxID'] = sandboxID;
    map['SandboxKey'] = sandboxKey;
    map['SecondaryIPAddresses'] = secondaryIPAddresses;
    map['SecondaryIPv6Addresses'] = secondaryIPv6Addresses;
    return map;
  }

}


/// bridge : {"Aliases":null,"DriverOpts":null,"EndpointID":"d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.5","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:05","NetworkID":"360feba33caf38cce219eab2f910fa3def2d6a6cabc98d3bf2704d41752ec667"}

class Networks {
  Networks({
      this.bridge,});

  Networks.fromJson(dynamic json) {
    bridge = json['bridge'] != null ? Bridge.fromJson(json['bridge']) : null;
  }
  Bridge? bridge;
Networks copyWith({  Bridge? bridge,
}) => Networks(  bridge: bridge ?? this.bridge,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (bridge != null) {
      map['bridge'] = bridge?.toJson();
    }
    return map;
  }

}

/// Aliases : null
/// DriverOpts : null
/// EndpointID : "d34160abde450ccdb024dbde5481fcf9fab57c8c20a304c53f947fc07bb241fc"
/// Gateway : "172.17.0.1"
/// GlobalIPv6Address : ""
/// GlobalIPv6PrefixLen : 0
/// IPAMConfig : null
/// IPAddress : "172.17.0.5"
/// IPPrefixLen : 16
/// IPv6Gateway : ""
/// Links : null
/// MacAddress : "02:42:ac:11:00:05"
/// NetworkID : "360feba33caf38cce219eab2f910fa3def2d6a6cabc98d3bf2704d41752ec667"

class Bridge {
  Bridge({
      this.aliases, 
      this.driverOpts, 
      this.endpointID, 
      this.gateway, 
      this.globalIPv6Address, 
      this.globalIPv6PrefixLen, 
      this.iPAMConfig, 
      this.iPAddress, 
      this.iPPrefixLen, 
      this.iPv6Gateway, 
      this.links, 
      this.macAddress, 
      this.networkID,});

  Bridge.fromJson(dynamic json) {
    aliases = json['Aliases'];
    driverOpts = json['DriverOpts'];
    endpointID = json['EndpointID'];
    gateway = json['Gateway'];
    globalIPv6Address = json['GlobalIPv6Address'];
    globalIPv6PrefixLen = json['GlobalIPv6PrefixLen'];
    iPAMConfig = json['IPAMConfig'];
    iPAddress = json['IPAddress'];
    iPPrefixLen = json['IPPrefixLen'];
    iPv6Gateway = json['IPv6Gateway'];
    links = json['Links'];
    macAddress = json['MacAddress'];
    networkID = json['NetworkID'];
  }
  dynamic aliases;
  dynamic driverOpts;
  String? endpointID;
  String? gateway;
  String? globalIPv6Address;
  num? globalIPv6PrefixLen;
  dynamic iPAMConfig;
  String? iPAddress;
  num? iPPrefixLen;
  String? iPv6Gateway;
  dynamic links;
  String? macAddress;
  String? networkID;
Bridge copyWith({  dynamic aliases,
  dynamic driverOpts,
  String? endpointID,
  String? gateway,
  String? globalIPv6Address,
  num? globalIPv6PrefixLen,
  dynamic iPAMConfig,
  String? iPAddress,
  num? iPPrefixLen,
  String? iPv6Gateway,
  dynamic links,
  String? macAddress,
  String? networkID,
}) => Bridge(  aliases: aliases ?? this.aliases,
  driverOpts: driverOpts ?? this.driverOpts,
  endpointID: endpointID ?? this.endpointID,
  gateway: gateway ?? this.gateway,
  globalIPv6Address: globalIPv6Address ?? this.globalIPv6Address,
  globalIPv6PrefixLen: globalIPv6PrefixLen ?? this.globalIPv6PrefixLen,
  iPAMConfig: iPAMConfig ?? this.iPAMConfig,
  iPAddress: iPAddress ?? this.iPAddress,
  iPPrefixLen: iPPrefixLen ?? this.iPPrefixLen,
  iPv6Gateway: iPv6Gateway ?? this.iPv6Gateway,
  links: links ?? this.links,
  macAddress: macAddress ?? this.macAddress,
  networkID: networkID ?? this.networkID,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Aliases'] = aliases;
    map['DriverOpts'] = driverOpts;
    map['EndpointID'] = endpointID;
    map['Gateway'] = gateway;
    map['GlobalIPv6Address'] = globalIPv6Address;
    map['GlobalIPv6PrefixLen'] = globalIPv6PrefixLen;
    map['IPAMConfig'] = iPAMConfig;
    map['IPAddress'] = iPAddress;
    map['IPPrefixLen'] = iPPrefixLen;
    map['IPv6Gateway'] = iPv6Gateway;
    map['Links'] = links;
    map['MacAddress'] = macAddress;
    map['NetworkID'] = networkID;
    return map;
  }

}

/// Destination : "/config"
/// Mode : "rw"
/// Propagation : "rprivate"
/// RW : true
/// Source : "/volume3/docker/qbittorrent/config"
/// Type : "bind"

class Mounts {
  Mounts({
      this.destination, 
      this.mode, 
      this.propagation, 
      this.rw, 
      this.source, 
      this.type,});

  Mounts.fromJson(dynamic json) {
    destination = json['Destination'];
    mode = json['Mode'];
    propagation = json['Propagation'];
    rw = json['RW'];
    source = json['Source'];
    type = json['Type'];
  }
  String? destination;
  String? mode;
  String? propagation;
  bool? rw;
  String? source;
  String? type;
Mounts copyWith({  String? destination,
  String? mode,
  String? propagation,
  bool? rw,
  String? source,
  String? type,
}) => Mounts(  destination: destination ?? this.destination,
  mode: mode ?? this.mode,
  propagation: propagation ?? this.propagation,
  rw: rw ?? this.rw,
  source: source ?? this.source,
  type: type ?? this.type,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Destination'] = destination;
    map['Mode'] = mode;
    map['Propagation'] = propagation;
    map['RW'] = rw;
    map['Source'] = source;
    map['Type'] = type;
    return map;
  }

}

/// AutoRemove : false
/// Binds : ["/volume3/docker/qbittorrent/config:/config:rw","/volume4/影视/下载/qbittorrent:/downloads:rw"]
/// BlkioDeviceReadBps : null
/// BlkioDeviceReadIOps : null
/// BlkioDeviceWriteBps : null
/// BlkioDeviceWriteIOps : null
/// BlkioWeight : 0
/// BlkioWeightDevice : null
/// CapAdd : null
/// CapDrop : null
/// Cgroup : ""
/// CgroupParent : ""
/// CgroupnsMode : "host"
/// ConsoleSize : [0,0]
/// ContainerIDFile : ""
/// CpuCount : 0
/// CpuPercent : 0
/// CpuPeriod : 0
/// CpuQuota : 0
/// CpuRealtimePeriod : 0
/// CpuRealtimeRuntime : 0
/// CpuShares : 50
/// CpusetCpus : ""
/// CpusetMems : ""
/// DeviceCgroupRules : null
/// DeviceRequests : null
/// Devices : null
/// Dns : []
/// DnsOptions : []
/// DnsSearch : []
/// Env : ["PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","PS1=$(whoami)@$(hostname):$(pwd)\\$ ","HOME=/config","TERM=xterm","S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0","S6_VERBOSITY=1","S6_STAGE2_HOOK=/docker-mods","VIRTUAL_ENV=/lsiopy","LSIO_FIRST_PARTY=true","XDG_CONFIG_HOME=/config","XDG_DATA_HOME=/config","WEBUI_PORT=5581"]
/// ExtraHosts : []
/// GroupAdd : null
/// IOMaximumBandwidth : 0
/// IOMaximumIOps : 0
/// IpcMode : "private"
/// Isolation : ""
/// KernelMemory : 0
/// KernelMemoryTCP : 0
/// Links : null
/// LogConfig : {"Config":{},"Type":"db"}
/// MaskedPaths : ["/proc/asound","/proc/acpi","/proc/kcore","/proc/keys","/proc/latency_stats","/proc/timer_list","/proc/timer_stats","/proc/sched_debug","/proc/scsi","/sys/firmware"]
/// Memory : 0
/// MemoryReservation : 0
/// MemorySwap : 0
/// MemorySwappiness : null
/// NanoCpus : 0
/// NetworkMode : "bridge"
/// OomKillDisable : false
/// OomScoreAdj : 0
/// PidMode : ""
/// PidsLimit : null
/// PortBindings : {"52000/tcp":[{"HostIp":"","HostPort":"52000"}],"5581/tcp":[{"HostIp":"","HostPort":"5581"}]}
/// Privileged : false
/// PublishAllPorts : false
/// ReadonlyPaths : ["/proc/bus","/proc/fs","/proc/irq","/proc/sys","/proc/sysrq-trigger"]
/// ReadonlyRootfs : false
/// RestartPolicy : {"MaximumRetryCount":0,"Name":"no"}
/// Runtime : "runc"
/// SecurityOpt : null
/// ShmSize : 67108864
/// UTSMode : ""
/// Ulimits : null
/// UsernsMode : ""
/// VolumeDriver : ""
/// VolumesFrom : null

class HostConfig {
  HostConfig({
      this.autoRemove, 
      this.binds, 
      this.blkioDeviceReadBps, 
      this.blkioDeviceReadIOps, 
      this.blkioDeviceWriteBps, 
      this.blkioDeviceWriteIOps, 
      this.blkioWeight, 
      this.blkioWeightDevice, 
      this.capAdd, 
      this.capDrop, 
      this.cgroup, 
      this.cgroupParent, 
      this.cgroupnsMode, 
      this.consoleSize, 
      this.containerIDFile, 
      this.cpuCount, 
      this.cpuPercent, 
      this.cpuPeriod, 
      this.cpuQuota, 
      this.cpuRealtimePeriod, 
      this.cpuRealtimeRuntime, 
      this.cpuShares, 
      this.cpusetCpus, 
      this.cpusetMems, 
      this.deviceCgroupRules, 
      this.deviceRequests, 
      this.devices, 
      this.dns, 
      this.dnsOptions, 
      this.dnsSearch, 
      this.env, 
      this.extraHosts, 
      this.groupAdd, 
      this.iOMaximumBandwidth, 
      this.iOMaximumIOps, 
      this.ipcMode, 
      this.isolation, 
      this.kernelMemory, 
      this.kernelMemoryTCP, 
      this.links, 
      this.logConfig, 
      this.maskedPaths, 
      this.memory, 
      this.memoryReservation, 
      this.memorySwap, 
      this.memorySwappiness, 
      this.nanoCpus, 
      this.networkMode, 
      this.oomKillDisable, 
      this.oomScoreAdj, 
      this.pidMode, 
      this.pidsLimit, 
      this.portBindings, 
      this.privileged, 
      this.publishAllPorts, 
      this.readonlyPaths, 
      this.readonlyRootfs, 
      this.restartPolicy, 
      this.runtime, 
      this.securityOpt, 
      this.shmSize, 
      this.uTSMode, 
      this.ulimits, 
      this.usernsMode, 
      this.volumeDriver, 
      this.volumesFrom,});

  HostConfig.fromJson(dynamic json) {
    autoRemove = json['AutoRemove'];
    binds = json['Binds'] != null ? json['Binds'].cast<String>() : [];
    blkioDeviceReadBps = json['BlkioDeviceReadBps'];
    blkioDeviceReadIOps = json['BlkioDeviceReadIOps'];
    blkioDeviceWriteBps = json['BlkioDeviceWriteBps'];
    blkioDeviceWriteIOps = json['BlkioDeviceWriteIOps'];
    blkioWeight = json['BlkioWeight'];
    blkioWeightDevice = json['BlkioWeightDevice'];
    capAdd = json['CapAdd'];
    capDrop = json['CapDrop'];
    cgroup = json['Cgroup'];
    cgroupParent = json['CgroupParent'];
    cgroupnsMode = json['CgroupnsMode'];
    consoleSize = json['ConsoleSize'] != null ? json['ConsoleSize'].cast<num>() : [];
    containerIDFile = json['ContainerIDFile'];
    cpuCount = json['CpuCount'];
    cpuPercent = json['CpuPercent'];
    cpuPeriod = json['CpuPeriod'];
    cpuQuota = json['CpuQuota'];
    cpuRealtimePeriod = json['CpuRealtimePeriod'];
    cpuRealtimeRuntime = json['CpuRealtimeRuntime'];
    cpuShares = json['CpuShares'];
    cpusetCpus = json['CpusetCpus'];
    cpusetMems = json['CpusetMems'];
    deviceCgroupRules = json['DeviceCgroupRules'];
    deviceRequests = json['DeviceRequests'];
    devices = json['Devices'];
    // if (json['Dns'] != null) {
    //   dns = [];
    //   json['Dns'].forEach((v) {
    //     dns?.add(Dynamic.fromJson(v));
    //   });
    // }
    // if (json['DnsOptions'] != null) {
    //   dnsOptions = [];
    //   json['DnsOptions'].forEach((v) {
    //     dnsOptions?.add(Dynamic.fromJson(v));
    //   });
    // }
    // if (json['DnsSearch'] != null) {
    //   dnsSearch = [];
    //   json['DnsSearch'].forEach((v) {
    //     dnsSearch?.add(Dynamic.fromJson(v));
    //   });
    // }
    env = json['Env'] != null ? json['Env'].cast<String>() : [];
    // if (json['ExtraHosts'] != null) {
    //   extraHosts = [];
    //   json['ExtraHosts'].forEach((v) {
    //     extraHosts?.add(Dynamic.fromJson(v));
    //   });
    // }
    groupAdd = json['GroupAdd'];
    iOMaximumBandwidth = json['IOMaximumBandwidth'];
    iOMaximumIOps = json['IOMaximumIOps'];
    ipcMode = json['IpcMode'];
    isolation = json['Isolation'];
    kernelMemory = json['KernelMemory'];
    kernelMemoryTCP = json['KernelMemoryTCP'];
    links = json['Links'];
    logConfig = json['LogConfig'] != null ? LogConfig.fromJson(json['LogConfig']) : null;
    maskedPaths = json['MaskedPaths'] != null ? json['MaskedPaths'].cast<String>() : [];
    memory = json['Memory'];
    memoryReservation = json['MemoryReservation'];
    memorySwap = json['MemorySwap'];
    memorySwappiness = json['MemorySwappiness'];
    nanoCpus = json['NanoCpus'];
    networkMode = json['NetworkMode'];
    oomKillDisable = json['OomKillDisable'];
    oomScoreAdj = json['OomScoreAdj'];
    pidMode = json['PidMode'];
    pidsLimit = json['PidsLimit'];
    portBindings = json['PortBindings'];
    privileged = json['Privileged'];
    publishAllPorts = json['PublishAllPorts'];
    readonlyPaths = json['ReadonlyPaths'] != null ? json['ReadonlyPaths'].cast<String>() : [];
    readonlyRootfs = json['ReadonlyRootfs'];
    restartPolicy = json['RestartPolicy'] != null ? RestartPolicy.fromJson(json['RestartPolicy']) : null;
    runtime = json['Runtime'];
    securityOpt = json['SecurityOpt'];
    shmSize = json['ShmSize'];
    uTSMode = json['UTSMode'];
    ulimits = json['Ulimits'];
    usernsMode = json['UsernsMode'];
    volumeDriver = json['VolumeDriver'];
    volumesFrom = json['VolumesFrom'];
  }
  bool? autoRemove;
  List<String>? binds;
  dynamic blkioDeviceReadBps;
  dynamic blkioDeviceReadIOps;
  dynamic blkioDeviceWriteBps;
  dynamic blkioDeviceWriteIOps;
  num? blkioWeight;
  dynamic blkioWeightDevice;
  dynamic capAdd;
  dynamic capDrop;
  String? cgroup;
  String? cgroupParent;
  String? cgroupnsMode;
  List<num>? consoleSize;
  String? containerIDFile;
  num? cpuCount;
  num? cpuPercent;
  num? cpuPeriod;
  num? cpuQuota;
  num? cpuRealtimePeriod;
  num? cpuRealtimeRuntime;
  num? cpuShares;
  String? cpusetCpus;
  String? cpusetMems;
  dynamic deviceCgroupRules;
  dynamic deviceRequests;
  dynamic devices;
  List<dynamic>? dns;
  List<dynamic>? dnsOptions;
  List<dynamic>? dnsSearch;
  List<String>? env;
  List<dynamic>? extraHosts;
  dynamic groupAdd;
  num? iOMaximumBandwidth;
  num? iOMaximumIOps;
  String? ipcMode;
  String? isolation;
  num? kernelMemory;
  num? kernelMemoryTCP;
  dynamic links;
  LogConfig? logConfig;
  List<String>? maskedPaths;
  num? memory;
  num? memoryReservation;
  num? memorySwap;
  dynamic memorySwappiness;
  num? nanoCpus;
  String? networkMode;
  bool? oomKillDisable;
  num? oomScoreAdj;
  String? pidMode;
  dynamic pidsLimit;
  Map? portBindings;
  bool? privileged;
  bool? publishAllPorts;
  List<String>? readonlyPaths;
  bool? readonlyRootfs;
  RestartPolicy? restartPolicy;
  String? runtime;
  dynamic securityOpt;
  num? shmSize;
  String? uTSMode;
  dynamic ulimits;
  String? usernsMode;
  String? volumeDriver;
  dynamic volumesFrom;
HostConfig copyWith({  bool? autoRemove,
  List<String>? binds,
  dynamic blkioDeviceReadBps,
  dynamic blkioDeviceReadIOps,
  dynamic blkioDeviceWriteBps,
  dynamic blkioDeviceWriteIOps,
  num? blkioWeight,
  dynamic blkioWeightDevice,
  dynamic capAdd,
  dynamic capDrop,
  String? cgroup,
  String? cgroupParent,
  String? cgroupnsMode,
  List<num>? consoleSize,
  String? containerIDFile,
  num? cpuCount,
  num? cpuPercent,
  num? cpuPeriod,
  num? cpuQuota,
  num? cpuRealtimePeriod,
  num? cpuRealtimeRuntime,
  num? cpuShares,
  String? cpusetCpus,
  String? cpusetMems,
  dynamic deviceCgroupRules,
  dynamic deviceRequests,
  dynamic devices,
  List<dynamic>? dns,
  List<dynamic>? dnsOptions,
  List<dynamic>? dnsSearch,
  List<String>? env,
  List<dynamic>? extraHosts,
  dynamic groupAdd,
  num? iOMaximumBandwidth,
  num? iOMaximumIOps,
  String? ipcMode,
  String? isolation,
  num? kernelMemory,
  num? kernelMemoryTCP,
  dynamic links,
  LogConfig? logConfig,
  List<String>? maskedPaths,
  num? memory,
  num? memoryReservation,
  num? memorySwap,
  dynamic memorySwappiness,
  num? nanoCpus,
  String? networkMode,
  bool? oomKillDisable,
  num? oomScoreAdj,
  String? pidMode,
  dynamic pidsLimit,
  Map? portBindings,
  bool? privileged,
  bool? publishAllPorts,
  List<String>? readonlyPaths,
  bool? readonlyRootfs,
  RestartPolicy? restartPolicy,
  String? runtime,
  dynamic securityOpt,
  num? shmSize,
  String? uTSMode,
  dynamic ulimits,
  String? usernsMode,
  String? volumeDriver,
  dynamic volumesFrom,
}) => HostConfig(  autoRemove: autoRemove ?? this.autoRemove,
  binds: binds ?? this.binds,
  blkioDeviceReadBps: blkioDeviceReadBps ?? this.blkioDeviceReadBps,
  blkioDeviceReadIOps: blkioDeviceReadIOps ?? this.blkioDeviceReadIOps,
  blkioDeviceWriteBps: blkioDeviceWriteBps ?? this.blkioDeviceWriteBps,
  blkioDeviceWriteIOps: blkioDeviceWriteIOps ?? this.blkioDeviceWriteIOps,
  blkioWeight: blkioWeight ?? this.blkioWeight,
  blkioWeightDevice: blkioWeightDevice ?? this.blkioWeightDevice,
  capAdd: capAdd ?? this.capAdd,
  capDrop: capDrop ?? this.capDrop,
  cgroup: cgroup ?? this.cgroup,
  cgroupParent: cgroupParent ?? this.cgroupParent,
  cgroupnsMode: cgroupnsMode ?? this.cgroupnsMode,
  consoleSize: consoleSize ?? this.consoleSize,
  containerIDFile: containerIDFile ?? this.containerIDFile,
  cpuCount: cpuCount ?? this.cpuCount,
  cpuPercent: cpuPercent ?? this.cpuPercent,
  cpuPeriod: cpuPeriod ?? this.cpuPeriod,
  cpuQuota: cpuQuota ?? this.cpuQuota,
  cpuRealtimePeriod: cpuRealtimePeriod ?? this.cpuRealtimePeriod,
  cpuRealtimeRuntime: cpuRealtimeRuntime ?? this.cpuRealtimeRuntime,
  cpuShares: cpuShares ?? this.cpuShares,
  cpusetCpus: cpusetCpus ?? this.cpusetCpus,
  cpusetMems: cpusetMems ?? this.cpusetMems,
  deviceCgroupRules: deviceCgroupRules ?? this.deviceCgroupRules,
  deviceRequests: deviceRequests ?? this.deviceRequests,
  devices: devices ?? this.devices,
  dns: dns ?? this.dns,
  dnsOptions: dnsOptions ?? this.dnsOptions,
  dnsSearch: dnsSearch ?? this.dnsSearch,
  env: env ?? this.env,
  extraHosts: extraHosts ?? this.extraHosts,
  groupAdd: groupAdd ?? this.groupAdd,
  iOMaximumBandwidth: iOMaximumBandwidth ?? this.iOMaximumBandwidth,
  iOMaximumIOps: iOMaximumIOps ?? this.iOMaximumIOps,
  ipcMode: ipcMode ?? this.ipcMode,
  isolation: isolation ?? this.isolation,
  kernelMemory: kernelMemory ?? this.kernelMemory,
  kernelMemoryTCP: kernelMemoryTCP ?? this.kernelMemoryTCP,
  links: links ?? this.links,
  logConfig: logConfig ?? this.logConfig,
  maskedPaths: maskedPaths ?? this.maskedPaths,
  memory: memory ?? this.memory,
  memoryReservation: memoryReservation ?? this.memoryReservation,
  memorySwap: memorySwap ?? this.memorySwap,
  memorySwappiness: memorySwappiness ?? this.memorySwappiness,
  nanoCpus: nanoCpus ?? this.nanoCpus,
  networkMode: networkMode ?? this.networkMode,
  oomKillDisable: oomKillDisable ?? this.oomKillDisable,
  oomScoreAdj: oomScoreAdj ?? this.oomScoreAdj,
  pidMode: pidMode ?? this.pidMode,
  pidsLimit: pidsLimit ?? this.pidsLimit,
  portBindings: portBindings ?? this.portBindings,
  privileged: privileged ?? this.privileged,
  publishAllPorts: publishAllPorts ?? this.publishAllPorts,
  readonlyPaths: readonlyPaths ?? this.readonlyPaths,
  readonlyRootfs: readonlyRootfs ?? this.readonlyRootfs,
  restartPolicy: restartPolicy ?? this.restartPolicy,
  runtime: runtime ?? this.runtime,
  securityOpt: securityOpt ?? this.securityOpt,
  shmSize: shmSize ?? this.shmSize,
  uTSMode: uTSMode ?? this.uTSMode,
  ulimits: ulimits ?? this.ulimits,
  usernsMode: usernsMode ?? this.usernsMode,
  volumeDriver: volumeDriver ?? this.volumeDriver,
  volumesFrom: volumesFrom ?? this.volumesFrom,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AutoRemove'] = autoRemove;
    map['Binds'] = binds;
    map['BlkioDeviceReadBps'] = blkioDeviceReadBps;
    map['BlkioDeviceReadIOps'] = blkioDeviceReadIOps;
    map['BlkioDeviceWriteBps'] = blkioDeviceWriteBps;
    map['BlkioDeviceWriteIOps'] = blkioDeviceWriteIOps;
    map['BlkioWeight'] = blkioWeight;
    map['BlkioWeightDevice'] = blkioWeightDevice;
    map['CapAdd'] = capAdd;
    map['CapDrop'] = capDrop;
    map['Cgroup'] = cgroup;
    map['CgroupParent'] = cgroupParent;
    map['CgroupnsMode'] = cgroupnsMode;
    map['ConsoleSize'] = consoleSize;
    map['ContainerIDFile'] = containerIDFile;
    map['CpuCount'] = cpuCount;
    map['CpuPercent'] = cpuPercent;
    map['CpuPeriod'] = cpuPeriod;
    map['CpuQuota'] = cpuQuota;
    map['CpuRealtimePeriod'] = cpuRealtimePeriod;
    map['CpuRealtimeRuntime'] = cpuRealtimeRuntime;
    map['CpuShares'] = cpuShares;
    map['CpusetCpus'] = cpusetCpus;
    map['CpusetMems'] = cpusetMems;
    map['DeviceCgroupRules'] = deviceCgroupRules;
    map['DeviceRequests'] = deviceRequests;
    map['Devices'] = devices;
    if (dns != null) {
      map['Dns'] = dns?.map((v) => v.toJson()).toList();
    }
    if (dnsOptions != null) {
      map['DnsOptions'] = dnsOptions?.map((v) => v.toJson()).toList();
    }
    if (dnsSearch != null) {
      map['DnsSearch'] = dnsSearch?.map((v) => v.toJson()).toList();
    }
    map['Env'] = env;
    if (extraHosts != null) {
      map['ExtraHosts'] = extraHosts?.map((v) => v.toJson()).toList();
    }
    map['GroupAdd'] = groupAdd;
    map['IOMaximumBandwidth'] = iOMaximumBandwidth;
    map['IOMaximumIOps'] = iOMaximumIOps;
    map['IpcMode'] = ipcMode;
    map['Isolation'] = isolation;
    map['KernelMemory'] = kernelMemory;
    map['KernelMemoryTCP'] = kernelMemoryTCP;
    map['Links'] = links;
    if (logConfig != null) {
      map['LogConfig'] = logConfig?.toJson();
    }
    map['MaskedPaths'] = maskedPaths;
    map['Memory'] = memory;
    map['MemoryReservation'] = memoryReservation;
    map['MemorySwap'] = memorySwap;
    map['MemorySwappiness'] = memorySwappiness;
    map['NanoCpus'] = nanoCpus;
    map['NetworkMode'] = networkMode;
    map['OomKillDisable'] = oomKillDisable;
    map['OomScoreAdj'] = oomScoreAdj;
    map['PidMode'] = pidMode;
    map['PidsLimit'] = pidsLimit;
    map['PortBindings'] = portBindings;
    map['Privileged'] = privileged;
    map['PublishAllPorts'] = publishAllPorts;
    map['ReadonlyPaths'] = readonlyPaths;
    map['ReadonlyRootfs'] = readonlyRootfs;
    if (restartPolicy != null) {
      map['RestartPolicy'] = restartPolicy?.toJson();
    }
    map['Runtime'] = runtime;
    map['SecurityOpt'] = securityOpt;
    map['ShmSize'] = shmSize;
    map['UTSMode'] = uTSMode;
    map['Ulimits'] = ulimits;
    map['UsernsMode'] = usernsMode;
    map['VolumeDriver'] = volumeDriver;
    map['VolumesFrom'] = volumesFrom;
    return map;
  }

}

/// MaximumRetryCount : 0
/// Name : "no"

class RestartPolicy {
  RestartPolicy({
      this.maximumRetryCount, 
      this.name,});

  RestartPolicy.fromJson(dynamic json) {
    maximumRetryCount = json['MaximumRetryCount'];
    name = json['Name'];
  }
  num? maximumRetryCount;
  String? name;
RestartPolicy copyWith({  num? maximumRetryCount,
  String? name,
}) => RestartPolicy(  maximumRetryCount: maximumRetryCount ?? this.maximumRetryCount,
  name: name ?? this.name,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaximumRetryCount'] = maximumRetryCount;
    map['Name'] = name;
    return map;
  }

}

/// Config : {}
/// Type : "db"

class LogConfig {
  LogConfig({
      this.config, 
      this.type,});

  LogConfig.fromJson(dynamic json) {
    config = json['Config'];
    type = json['Type'];
  }
  dynamic config;
  String? type;
LogConfig copyWith({  dynamic config,
  String? type,
}) => LogConfig(  config: config ?? this.config,
  type: type ?? this.type,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Config'] = config;
    map['Type'] = type;
    return map;
  }

}

/// Data : null
/// Name : "btrfs"

class GraphDriver {
  GraphDriver({
      this.data, 
      this.name,});

  GraphDriver.fromJson(dynamic json) {
    data = json['Data'];
    name = json['Name'];
  }
  dynamic data;
  String? name;
GraphDriver copyWith({  dynamic data,
  String? name,
}) => GraphDriver(  data: data ?? this.data,
  name: name ?? this.name,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Data'] = data;
    map['Name'] = name;
    return map;
  }

}

/// AttachStderr : true
/// AttachStdin : false
/// AttachStdout : true
/// Cmd : null
/// DDSM : false
/// Domainname : ""
/// Entrypoint : ["/init"]
/// Env : ["PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","PS1=$(whoami)@$(hostname):$(pwd)\\$ ","HOME=/config","TERM=xterm","S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0","S6_VERBOSITY=1","S6_STAGE2_HOOK=/docker-mods","VIRTUAL_ENV=/lsiopy","LSIO_FIRST_PARTY=true","XDG_CONFIG_HOME=/config","XDG_DATA_HOME=/config","WEBUI_PORT=5581"]
/// ExposedPorts : {"52000/tcp":{},"5581/tcp":{},"6881/tcp":{},"6881/udp":{},"8080/tcp":{}}
/// Hostname : "1c337ea30de9"
/// Image : "linuxserver/qbittorrent"
/// Labels : {"build_version":"Linuxserver.io version:- 4.6.0-r0-ls294 Build-date:- 2023-10-29T06:54:01+00:00","com.docker.compose.config-hash":"04949dace87bab26ec25ebd415b293da880e2c3f075bce39d71dfc166bd63e80","com.docker.compose.container-number":"1","com.docker.compose.depends_on":"","com.docker.compose.image":"sha256:d17ec24707d5f5378e36ecabfe4670fde1d39d5105d9610d3a00513668b638ad","com.docker.compose.oneoff":"False","com.docker.compose.project":"qbittorrent","com.docker.compose.project.config_files":"/volume3/docker/qbittorrent/compose.yaml","com.docker.compose.project.working_dir":"/volume3/docker/qbittorrent","com.docker.compose.service":"emby","com.docker.compose.version":"2.9.0","maintainer":"thespad","org.opencontainers.image.authors":"linuxserver.io","org.opencontainers.image.created":"2023-10-29T06:54:01+00:00","org.opencontainers.image.description":"The [Qbittorrent](https://www.qbittorrent.org/) project aims to provide an open-source software alternative to µTorrent. qBittorrent is based on the Qt toolkit and libtorrent-rasterbar library.","org.opencontainers.image.documentation":"https://docs.linuxserver.io/images/docker-qbittorrent","org.opencontainers.image.licenses":"GPL-3.0-only","org.opencontainers.image.ref.name":"1d02eac543db6c970950fc71164db6dd578d1aa3","org.opencontainers.image.revision":"1d02eac543db6c970950fc71164db6dd578d1aa3","org.opencontainers.image.source":"https://github.com/linuxserver/docker-qbittorrent","org.opencontainers.image.title":"Qbittorrent","org.opencontainers.image.url":"https://github.com/linuxserver/docker-qbittorrent/packages","org.opencontainers.image.vendor":"linuxserver.io","org.opencontainers.image.version":"4.6.0-r0-ls294"}
/// OnBuild : null
/// OpenStdin : false
/// StdinOnce : false
/// Tty : false
/// User : ""
/// Volumes : {"/config":{}}
/// WorkingDir : "/"

class Config {
  Config({
      this.attachStderr, 
      this.attachStdin, 
      this.attachStdout, 
      this.cmd, 
      this.ddsm, 
      this.domainname, 
      this.entrypoint, 
      this.env, 
      this.exposedPorts, 
      this.hostname, 
      this.image,
      this.labels,
      this.onBuild, 
      this.openStdin, 
      this.stdinOnce, 
      this.tty, 
      this.user, 
      this.volumes, 
      this.workingDir,});

  Config.fromJson(dynamic json) {
    attachStderr = json['AttachStderr'];
    attachStdin = json['AttachStdin'];
    attachStdout = json['AttachStdout'];
    cmd = json['Cmd'];
    ddsm = json['DDSM'];
    domainname = json['Domainname'];
    entrypoint = json['Entrypoint'] != null ? json['Entrypoint'].cast<String>() : [];
    env = json['Env'] != null ? json['Env'].cast<String>() : [];
    exposedPorts = json['ExposedPorts'];
    labels = json['Labels'];
    hostname = json['Hostname'];
    image = json['Image'];
    onBuild = json['OnBuild'];
    openStdin = json['OpenStdin'];
    stdinOnce = json['StdinOnce'];
    tty = json['Tty'];
    user = json['User'];
    volumes = json['Volumes'] != null ? Volumes.fromJson(json['Volumes']) : null;
    workingDir = json['WorkingDir'];
  }
  bool? attachStderr;
  bool? attachStdin;
  bool? attachStdout;
  dynamic cmd;
  bool? ddsm;
  String? domainname;
  List<String>? entrypoint;
  List<String>? env;
  Map? exposedPorts;
  String? hostname;
  String? image;
  Map? labels;
  dynamic onBuild;
  bool? openStdin;
  bool? stdinOnce;
  bool? tty;
  String? user;
  Volumes? volumes;
  String? workingDir;
Config copyWith({  bool? attachStderr,
  bool? attachStdin,
  bool? attachStdout,
  dynamic cmd,
  bool? ddsm,
  String? domainname,
  List<String>? entrypoint,
  List<String>? env,
  Map? exposedPorts,
  String? hostname,
  String? image,
  Map? labels,
  dynamic onBuild,
  bool? openStdin,
  bool? stdinOnce,
  bool? tty,
  String? user,
  Volumes? volumes,
  String? workingDir,
}) => Config(  attachStderr: attachStderr ?? this.attachStderr,
  attachStdin: attachStdin ?? this.attachStdin,
  attachStdout: attachStdout ?? this.attachStdout,
  cmd: cmd ?? this.cmd,
  ddsm: ddsm ?? this.ddsm,
  domainname: domainname ?? this.domainname,
  entrypoint: entrypoint ?? this.entrypoint,
  env: env ?? this.env,
  exposedPorts: exposedPorts ?? this.exposedPorts,
  hostname: hostname ?? this.hostname,
  image: image ?? this.image,
  labels: labels ?? this.labels,
  onBuild: onBuild ?? this.onBuild,
  openStdin: openStdin ?? this.openStdin,
  stdinOnce: stdinOnce ?? this.stdinOnce,
  tty: tty ?? this.tty,
  user: user ?? this.user,
  volumes: volumes ?? this.volumes,
  workingDir: workingDir ?? this.workingDir,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AttachStderr'] = attachStderr;
    map['AttachStdin'] = attachStdin;
    map['AttachStdout'] = attachStdout;
    map['Cmd'] = cmd;
    map['DDSM'] = ddsm;
    map['Domainname'] = domainname;
    map['Entrypoint'] = entrypoint;
    map['Env'] = env;
    map['ExposedPorts'] = exposedPorts;
    map['Hostname'] = hostname;
    map['Image'] = image;
map['Labels'] = labels;
    map['OnBuild'] = onBuild;
    map['OpenStdin'] = openStdin;
    map['StdinOnce'] = stdinOnce;
    map['Tty'] = tty;
    map['User'] = user;
    if (volumes != null) {
      map['Volumes'] = volumes?.toJson();
    }
    map['WorkingDir'] = workingDir;
    return map;
  }

}

/// /config : {}

class Volumes {
  Volumes({
      this.config,});

  Volumes.fromJson(dynamic json) {
    config = json['/config'];
  }
  dynamic config;
Volumes copyWith({  dynamic config,
}) => Volumes(  config: config ?? this.config,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['/config'] = config;
    return map;
  }

}