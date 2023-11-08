import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/pages/docker/enums/container_status_enum.dart';

/// details : {"AppArmorProfile":"docker-unconfined","Args":[],"Config":{"AttachStderr":false,"AttachStdin":false,"AttachStdout":false,"Cmd":null,"DDSM":false,"Domainname":"","Entrypoint":["/jellyfin/jellyfin"],"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"],"ExposedPorts":{"8096/tcp":{}},"Healthcheck":{"Interval":30000000000,"Retries":3,"StartPeriod":10000000000,"Test":["CMD-SHELL","curl -Lk \"${HEALTHCHECK_URL}\" || exit 1"],"Timeout":30000000000},"Hostname":"jellyfin","Image":"jellyfin/jellyfin:latest","Labels":{},"OnBuild":null,"OpenStdin":true,"StdinOnce":false,"Tty":true,"User":"","Volumes":{"/cache":{},"/config":{}},"WorkingDir":""},"Created":"2023-04-29T08:22:31.229681668Z","Driver":"btrfs","ExecIDs":null,"GraphDriver":{"Data":null,"Name":"btrfs"},"HostConfig":{"AutoRemove":false,"Binds":["/volume3/docker/jellyfin/config:/config:rw","/volume4/视频:/japan:rw"],"BlkioDeviceReadBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceWriteIOps":null,"BlkioWeight":0,"BlkioWeightDevice":null,"CapAdd":[],"CapDrop":[],"Cgroup":"","CgroupParent":"","CgroupnsMode":"host","ConsoleSize":[0,0],"ContainerIDFile":"","CpuCount":0,"CpuPercent":0,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpuShares":50,"CpusetCpus":"","CpusetMems":"","DeviceCgroupRules":null,"DeviceRequests":null,"Devices":null,"Dns":[],"DnsOptions":[],"DnsSearch":[],"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"],"ExtraHosts":null,"GroupAdd":null,"IOMaximumBandwidth":0,"IOMaximumIOps":0,"IpcMode":"private","Isolation":"","KernelMemory":0,"KernelMemoryTCP":0,"Links":null,"LogConfig":{"Config":{},"Type":"db"},"MaskedPaths":null,"Memory":0,"MemoryReservation":0,"MemorySwap":0,"MemorySwappiness":null,"NanoCpus":0,"NetworkMode":"bridge","OomKillDisable":false,"OomScoreAdj":0,"PidMode":"","PidsLimit":null,"PortBindings":{"8096/tcp":[{"HostIp":"","HostPort":"9096"}],"8920/tcp":[{"HostIp":"","HostPort":"9920"}]},"Privileged":true,"PublishAllPorts":false,"ReadonlyPaths":null,"ReadonlyRootfs":false,"RestartPolicy":{"MaximumRetryCount":0,"Name":"always"},"Runtime":"runc","SecurityOpt":["label=disable"],"ShmSize":67108864,"UTSMode":"","Ulimits":null,"UsernsMode":"","VolumeDriver":"","VolumesFrom":null},"HostnamePath":"/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/hostname","HostsPath":"/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/hosts","Id":"e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75","Image":"sha256:b27de364af61892a0d4f2d51bd3f84d13a43a640854dc534cb33b14110529c8d","LogPath":"/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/log.db","MountLabel":"","Mounts":[{"Destination":"/cache","Driver":"local","Mode":"","Name":"ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f","Propagation":"","RW":true,"Source":"/volume4/@docker/volumes/ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f/_data","Type":"volume"},{"Destination":"/config","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume3/docker/jellyfin/config","Type":"bind"},{"Destination":"/japan","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume4/视频","Type":"bind"}],"Name":"/jellyfin","NetworkSettings":{"Bridge":"","EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"HairpinMode":false,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:03","Networks":{"bridge":{"Aliases":null,"DriverOpts":null,"EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:03","NetworkID":"7704822a81028c4895beddea948c465444ab4ea429311938c02a463994dfb170"}},"Ports":{"8096/tcp":[{"HostIp":"0.0.0.0","HostPort":"9096"}],"8920/tcp":[{"HostIp":"0.0.0.0","HostPort":"9920"}]},"SandboxID":"d80b50eef099193ab1020b9fa6eebb9aa8def4a6469e4cfac724f5eb75504ac4","SandboxKey":"/var/run/docker/netns/d80b50eef099","SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null},"Path":"/jellyfin/jellyfin","Platform":"linux","ProcessLabel":"","ResolvConfPath":"/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/resolv.conf","RestartCount":0,"State":{"Dead":false,"Error":"","ExitCode":0,"FinishedAt":"2023-10-15T16:25:24.53874477Z","FinishedTs":1697387124,"Health":{"FailingStreak":0,"Log":[{"End":"2023-10-25T19:37:28.10207135+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:27.94285115+08:00"},{"End":"2023-10-25T19:37:58.324027368+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:58.164724751+08:00"},{"End":"2023-10-25T19:38:28.551192841+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-Healthy- --:--:-- --:--:--  1750\n","Start":"2023-10-25T19:38:28.381346278+08:00"},{"End":"2023-10-25T19:38:58.828731347+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Healthy\r100     7    0     7    0     0    777      0 --:--:-- --:--:-- --:--:--   777\n","Start":"2023-10-25T19:38:58.599435174+08:00"},{"End":"2023-10-25T19:39:29.11796881+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   2333      0 --:--:-- --:--:-- --:--:--  2333\nHealthy","Start":"2023-10-25T19:39:28.944010624+08:00"}],"Status":"healthy"},"OOMKilled":false,"Paused":false,"Pid":7100,"Restarting":false,"Running":true,"StartedAt":"2023-10-15T16:25:28.058628347Z","StartedTs":1697387128,"Status":"running"},"exe_cmd":"/jellyfin/jellyfin","finish_time":1697387124,"memory":360964096,"memoryPercent":4.392551422119141,"status":"running","up_time":1697387128}
/// profile : {"CapAdd":[],"CapDrop":[],"cmd":"","cpu_priority":50,"enable_publish_all_ports":false,"enable_restart_policy":true,"enable_service_portal":null,"enabled":true,"env_variables":[{"key":"PATH","value":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"},{"key":"HEALTHCHECK_URL","value":"http://localhost:8096/health"},{"key":"DOTNET_SYSTEM_GLOBALIZATION_INVARIANT","value":"1"},{"key":"LC_ALL","value":"en_US.UTF-8"},{"key":"LANG","value":"en_US.UTF-8"},{"key":"LANGUAGE","value":"en_US:en"},{"key":"JELLYFIN_DATA_DIR","value":"/config"},{"key":"JELLYFIN_CACHE_DIR","value":"/cache"},{"key":"JELLYFIN_CONFIG_DIR","value":"/config/config"},{"key":"JELLYFIN_LOG_DIR","value":"/config/log"},{"key":"JELLYFIN_WEB_DIR","value":"/jellyfin/jellyfin-web"},{"key":"JELLYFIN_FFMPEG","value":"/usr/lib/jellyfin-ffmpeg/ffmpeg"},{"key":"NVIDIA_VISIBLE_DEVICES","value":"all"},{"key":"NVIDIA_DRIVER_CAPABILITIES","value":"compute,video,utility"}],"exporting":false,"id":"e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75","image":"jellyfin/jellyfin:latest","is_ddsm":false,"is_package":false,"links":[],"memory_limit":0,"name":"jellyfin","network":[{"driver":"bridge","name":"bridge"}],"network_mode":"bridge","port_bindings":[{"container_port":8096,"host_port":9096,"type":"tcp"},{"container_port":8920,"host_port":9920,"type":"tcp"}],"privileged":true,"shortcut":{"enable_shortcut":false,"enable_status_page":false,"enable_web_page":false,"web_page_url":""},"use_host_network":false,"volume_bindings":[{"host_volume_file":"/docker/jellyfin/config","mount_point":"/config","type":"rw"},{"host_volume_file":"/视频","mount_point":"/japan","type":"rw"}]}

class DockerContainerDetail {
  DockerContainerDetail({
    this.details,
    this.profile,
  });

  static Future<DockerContainerDetail> get(String name) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Container",
      "get",
      version: 1,
      parser: DockerContainerDetail.fromJson,
      data: {
        "name": name,
      },
    );
    return res.data;
  }

  DockerContainerDetail.fromJson(dynamic json) {
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }
  Details? details;
  Profile? profile;
  DockerContainerDetail copyWith({
    Details? details,
    Profile? profile,
  }) =>
      DockerContainerDetail(
        details: details ?? this.details,
        profile: profile ?? this.profile,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (details != null) {
      map['details'] = details?.toJson();
    }
    if (profile != null) {
      map['profile'] = profile?.toJson();
    }
    return map;
  }
}

/// CapAdd : []
/// CapDrop : []
/// cmd : ""
/// cpu_priority : 50
/// enable_publish_all_ports : false
/// enable_restart_policy : true
/// enable_service_portal : null
/// enabled : true
/// env_variables : [{"key":"PATH","value":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"},{"key":"HEALTHCHECK_URL","value":"http://localhost:8096/health"},{"key":"DOTNET_SYSTEM_GLOBALIZATION_INVARIANT","value":"1"},{"key":"LC_ALL","value":"en_US.UTF-8"},{"key":"LANG","value":"en_US.UTF-8"},{"key":"LANGUAGE","value":"en_US:en"},{"key":"JELLYFIN_DATA_DIR","value":"/config"},{"key":"JELLYFIN_CACHE_DIR","value":"/cache"},{"key":"JELLYFIN_CONFIG_DIR","value":"/config/config"},{"key":"JELLYFIN_LOG_DIR","value":"/config/log"},{"key":"JELLYFIN_WEB_DIR","value":"/jellyfin/jellyfin-web"},{"key":"JELLYFIN_FFMPEG","value":"/usr/lib/jellyfin-ffmpeg/ffmpeg"},{"key":"NVIDIA_VISIBLE_DEVICES","value":"all"},{"key":"NVIDIA_DRIVER_CAPABILITIES","value":"compute,video,utility"}]
/// exporting : false
/// id : "e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75"
/// image : "jellyfin/jellyfin:latest"
/// is_ddsm : false
/// is_package : false
/// links : []
/// memory_limit : 0
/// name : "jellyfin"
/// network : [{"driver":"bridge","name":"bridge"}]
/// network_mode : "bridge"
/// port_bindings : [{"container_port":8096,"host_port":9096,"type":"tcp"},{"container_port":8920,"host_port":9920,"type":"tcp"}]
/// privileged : true
/// shortcut : {"enable_shortcut":false,"enable_status_page":false,"enable_web_page":false,"web_page_url":""}
/// use_host_network : false
/// volume_bindings : [{"host_volume_file":"/docker/jellyfin/config","mount_point":"/config","type":"rw"},{"host_volume_file":"/视频","mount_point":"/japan","type":"rw"}]

class Profile {
  Profile({
    this.capAdd,
    this.capDrop,
    this.cmd,
    this.cpuPriority,
    this.enablePublishAllPorts,
    this.enableRestartPolicy,
    this.enableServicePortal,
    this.enabled,
    this.envVariables,
    this.exporting,
    this.id,
    this.image,
    this.isDdsm,
    this.isPackage,
    this.links,
    this.memoryLimit,
    this.name,
    this.network,
    this.networkMode,
    this.portBindings,
    this.privileged,
    this.shortcut,
    this.useHostNetwork,
    this.volumeBindings,
  });

  Profile.fromJson(dynamic json) {
    if (json['CapAdd'] != null) {
      capAdd = [];
      // json['CapAdd'].forEach((v) {
      //   capAdd?.add(Dynamic.fromJson(v));
      // });
    }
    if (json['CapDrop'] != null) {
      capDrop = [];
      // json['CapDrop'].forEach((v) {
      //   capDrop?.add(Dynamic.fromJson(v));
      // });
    }
    cmd = json['cmd'];
    cpuPriority = json['cpu_priority'];
    enablePublishAllPorts = json['enable_publish_all_ports'];
    enableRestartPolicy = json['enable_restart_policy'];
    enableServicePortal = json['enable_service_portal'];
    enabled = json['enabled'];
    if (json['env_variables'] != null) {
      envVariables = [];
      json['env_variables'].forEach((v) {
        envVariables?.add(EnvVariables.fromJson(v));
      });
    }
    exporting = json['exporting'];
    id = json['id'];
    image = json['image'];
    isDdsm = json['is_ddsm'];
    isPackage = json['is_package'];
    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links?.add(Links.fromJson(v));
      });
    }
    memoryLimit = json['memory_limit'];
    name = json['name'];
    if (json['network'] != null) {
      network = [];
      json['network'].forEach((v) {
        network?.add(Network.fromJson(v));
      });
    }
    networkMode = json['network_mode'];
    if (json['port_bindings'] != null) {
      portBindings = [];
      json['port_bindings'].forEach((v) {
        portBindings?.add(PortBindings.fromJson(v));
      });
    }
    privileged = json['privileged'];
    shortcut = json['shortcut'] != null ? Shortcut.fromJson(json['shortcut']) : null;
    useHostNetwork = json['use_host_network'];
    if (json['volume_bindings'] != null) {
      volumeBindings = [];
      json['volume_bindings'].forEach((v) {
        volumeBindings?.add(VolumeBindings.fromJson(v));
      });
    }
  }
  List<dynamic>? capAdd;
  List<dynamic>? capDrop;
  String? cmd;
  num? cpuPriority;
  bool? enablePublishAllPorts;
  bool? enableRestartPolicy;
  dynamic enableServicePortal;
  bool? enabled;
  List<EnvVariables>? envVariables;
  bool? exporting;
  String? id;
  String? image;
  bool? isDdsm;
  bool? isPackage;
  List<Links>? links;
  num? memoryLimit;
  String? name;
  List<Network>? network;
  String? networkMode;
  List<PortBindings>? portBindings;
  bool? privileged;
  Shortcut? shortcut;
  bool? useHostNetwork;
  List<VolumeBindings>? volumeBindings;
  Profile copyWith({
    List<dynamic>? capAdd,
    List<dynamic>? capDrop,
    String? cmd,
    num? cpuPriority,
    bool? enablePublishAllPorts,
    bool? enableRestartPolicy,
    dynamic enableServicePortal,
    bool? enabled,
    List<EnvVariables>? envVariables,
    bool? exporting,
    String? id,
    String? image,
    bool? isDdsm,
    bool? isPackage,
    List<Links>? links,
    num? memoryLimit,
    String? name,
    List<Network>? network,
    String? networkMode,
    List<PortBindings>? portBindings,
    bool? privileged,
    Shortcut? shortcut,
    bool? useHostNetwork,
    List<VolumeBindings>? volumeBindings,
  }) =>
      Profile(
        capAdd: capAdd ?? this.capAdd,
        capDrop: capDrop ?? this.capDrop,
        cmd: cmd ?? this.cmd,
        cpuPriority: cpuPriority ?? this.cpuPriority,
        enablePublishAllPorts: enablePublishAllPorts ?? this.enablePublishAllPorts,
        enableRestartPolicy: enableRestartPolicy ?? this.enableRestartPolicy,
        enableServicePortal: enableServicePortal ?? this.enableServicePortal,
        enabled: enabled ?? this.enabled,
        envVariables: envVariables ?? this.envVariables,
        exporting: exporting ?? this.exporting,
        id: id ?? this.id,
        image: image ?? this.image,
        isDdsm: isDdsm ?? this.isDdsm,
        isPackage: isPackage ?? this.isPackage,
        links: links ?? this.links,
        memoryLimit: memoryLimit ?? this.memoryLimit,
        name: name ?? this.name,
        network: network ?? this.network,
        networkMode: networkMode ?? this.networkMode,
        portBindings: portBindings ?? this.portBindings,
        privileged: privileged ?? this.privileged,
        shortcut: shortcut ?? this.shortcut,
        useHostNetwork: useHostNetwork ?? this.useHostNetwork,
        volumeBindings: volumeBindings ?? this.volumeBindings,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (capAdd != null) {
      map['CapAdd'] = capAdd?.map((v) => v.toJson()).toList();
    }
    if (capDrop != null) {
      map['CapDrop'] = capDrop?.map((v) => v.toJson()).toList();
    }
    map['cmd'] = cmd;
    map['cpu_priority'] = cpuPriority;
    map['enable_publish_all_ports'] = enablePublishAllPorts;
    map['enable_restart_policy'] = enableRestartPolicy;
    map['enable_service_portal'] = enableServicePortal;
    map['enabled'] = enabled;
    if (envVariables != null) {
      map['env_variables'] = envVariables?.map((v) => v.toJson()).toList();
    }
    map['exporting'] = exporting;
    map['id'] = id;
    map['image'] = image;
    map['is_ddsm'] = isDdsm;
    map['is_package'] = isPackage;
    if (links != null) {
      map['links'] = links?.map((v) => v.toJson()).toList();
    }
    map['memory_limit'] = memoryLimit;
    map['name'] = name;
    if (network != null) {
      map['network'] = network?.map((v) => v.toJson()).toList();
    }
    map['network_mode'] = networkMode;
    if (portBindings != null) {
      map['port_bindings'] = portBindings?.map((v) => v.toJson()).toList();
    }
    map['privileged'] = privileged;
    if (shortcut != null) {
      map['shortcut'] = shortcut?.toJson();
    }
    map['use_host_network'] = useHostNetwork;
    if (volumeBindings != null) {
      map['volume_bindings'] = volumeBindings?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// link_container : ""
/// alias : ""

class Links {
  Links({
    this.linkContainer,
    this.alias,
  });

  Links.fromJson(dynamic json) {
    linkContainer = json['link_container'];
    alias = json['alias'];
  }
  String? linkContainer;
  String? alias;
  Links copyWith({
    String? linkContainer,
    String? alias,
  }) =>
      Links(
        linkContainer: linkContainer ?? this.linkContainer,
        alias: alias ?? this.alias,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['link_container'] = linkContainer;
    map['alias'] = alias;
    return map;
  }
}

/// host_volume_file : "/docker/jellyfin/config"
/// mount_point : "/config"
/// type : "rw"

class VolumeBindings {
  VolumeBindings({
    this.hostVolumeFile,
    this.mountPoint,
    this.type,
  });

  VolumeBindings.fromJson(dynamic json) {
    hostVolumeFile = json['host_volume_file'];
    mountPoint = json['mount_point'];
    type = json['type'];
  }
  String? hostVolumeFile;
  String? mountPoint;
  String? type;
  VolumeBindings copyWith({
    String? hostVolumeFile,
    String? mountPoint,
    String? type,
  }) =>
      VolumeBindings(
        hostVolumeFile: hostVolumeFile ?? this.hostVolumeFile,
        mountPoint: mountPoint ?? this.mountPoint,
        type: type ?? this.type,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['host_volume_file'] = hostVolumeFile;
    map['mount_point'] = mountPoint;
    map['type'] = type;
    return map;
  }
}

/// enable_shortcut : false
/// enable_status_page : false
/// enable_web_page : false
/// web_page_url : ""

class Shortcut {
  Shortcut({
    this.enableShortcut,
    this.enableStatusPage,
    this.enableWebPage,
    this.webPageUrl,
  });

  Shortcut.fromJson(dynamic json) {
    enableShortcut = json['enable_shortcut'];
    enableStatusPage = json['enable_status_page'];
    enableWebPage = json['enable_web_page'];
    webPageUrl = json['web_page_url'];
  }
  bool? enableShortcut;
  bool? enableStatusPage;
  bool? enableWebPage;
  String? webPageUrl;
  Shortcut copyWith({
    bool? enableShortcut,
    bool? enableStatusPage,
    bool? enableWebPage,
    String? webPageUrl,
  }) =>
      Shortcut(
        enableShortcut: enableShortcut ?? this.enableShortcut,
        enableStatusPage: enableStatusPage ?? this.enableStatusPage,
        enableWebPage: enableWebPage ?? this.enableWebPage,
        webPageUrl: webPageUrl ?? this.webPageUrl,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['enable_shortcut'] = enableShortcut;
    map['enable_status_page'] = enableStatusPage;
    map['enable_web_page'] = enableWebPage;
    map['web_page_url'] = webPageUrl;
    return map;
  }
}

/// container_port : 8096
/// host_port : 9096
/// type : "tcp"

class PortBindings {
  PortBindings({
    this.containerPort,
    this.hostPort,
    this.type,
  });

  PortBindings.fromJson(dynamic json) {
    containerPort = json['container_port'];
    hostPort = json['host_port'];
    type = json['type'];
  }
  num? containerPort;
  num? hostPort;
  String? type;
  PortBindings copyWith({
    num? containerPort,
    num? hostPort,
    String? type,
  }) =>
      PortBindings(
        containerPort: containerPort ?? this.containerPort,
        hostPort: hostPort ?? this.hostPort,
        type: type ?? this.type,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['container_port'] = containerPort;
    map['host_port'] = hostPort;
    map['type'] = type;
    return map;
  }
}

/// driver : "bridge"
/// name : "bridge"

class Network {
  Network({
    this.driver,
    this.name,
  });

  Network.fromJson(dynamic json) {
    driver = json['driver'];
    name = json['name'];
  }
  String? driver;
  String? name;
  Network copyWith({
    String? driver,
    String? name,
  }) =>
      Network(
        driver: driver ?? this.driver,
        name: name ?? this.name,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['driver'] = driver;
    map['name'] = name;
    return map;
  }
}

/// key : "PATH"
/// value : "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

class EnvVariables {
  EnvVariables({
    this.key,
    this.value,
  });

  EnvVariables.fromJson(dynamic json) {
    key = json['key'];
    value = json['value'];
  }
  String? key;
  String? value;
  EnvVariables copyWith({
    String? key,
    String? value,
  }) =>
      EnvVariables(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['key'] = key;
    map['value'] = value;
    return map;
  }
}

/// AppArmorProfile : "docker-unconfined"
/// Args : []
/// Config : {"AttachStderr":false,"AttachStdin":false,"AttachStdout":false,"Cmd":null,"DDSM":false,"Domainname":"","Entrypoint":["/jellyfin/jellyfin"],"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"],"ExposedPorts":{"8096/tcp":{}},"Healthcheck":{"Interval":30000000000,"Retries":3,"StartPeriod":10000000000,"Test":["CMD-SHELL","curl -Lk \"${HEALTHCHECK_URL}\" || exit 1"],"Timeout":30000000000},"Hostname":"jellyfin","Image":"jellyfin/jellyfin:latest","Labels":{},"OnBuild":null,"OpenStdin":true,"StdinOnce":false,"Tty":true,"User":"","Volumes":{"/cache":{},"/config":{}},"WorkingDir":""}
/// Created : "2023-04-29T08:22:31.229681668Z"
/// Driver : "btrfs"
/// ExecIDs : null
/// GraphDriver : {"Data":null,"Name":"btrfs"}
/// HostConfig : {"AutoRemove":false,"Binds":["/volume3/docker/jellyfin/config:/config:rw","/volume4/视频:/japan:rw"],"BlkioDeviceReadBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceWriteIOps":null,"BlkioWeight":0,"BlkioWeightDevice":null,"CapAdd":[],"CapDrop":[],"Cgroup":"","CgroupParent":"","CgroupnsMode":"host","ConsoleSize":[0,0],"ContainerIDFile":"","CpuCount":0,"CpuPercent":0,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpuShares":50,"CpusetCpus":"","CpusetMems":"","DeviceCgroupRules":null,"DeviceRequests":null,"Devices":null,"Dns":[],"DnsOptions":[],"DnsSearch":[],"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"],"ExtraHosts":null,"GroupAdd":null,"IOMaximumBandwidth":0,"IOMaximumIOps":0,"IpcMode":"private","Isolation":"","KernelMemory":0,"KernelMemoryTCP":0,"Links":null,"LogConfig":{"Config":{},"Type":"db"},"MaskedPaths":null,"Memory":0,"MemoryReservation":0,"MemorySwap":0,"MemorySwappiness":null,"NanoCpus":0,"NetworkMode":"bridge","OomKillDisable":false,"OomScoreAdj":0,"PidMode":"","PidsLimit":null,"PortBindings":{"8096/tcp":[{"HostIp":"","HostPort":"9096"}],"8920/tcp":[{"HostIp":"","HostPort":"9920"}]},"Privileged":true,"PublishAllPorts":false,"ReadonlyPaths":null,"ReadonlyRootfs":false,"RestartPolicy":{"MaximumRetryCount":0,"Name":"always"},"Runtime":"runc","SecurityOpt":["label=disable"],"ShmSize":67108864,"UTSMode":"","Ulimits":null,"UsernsMode":"","VolumeDriver":"","VolumesFrom":null}
/// HostnamePath : "/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/hostname"
/// HostsPath : "/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/hosts"
/// Id : "e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75"
/// Image : "sha256:b27de364af61892a0d4f2d51bd3f84d13a43a640854dc534cb33b14110529c8d"
/// LogPath : "/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/log.db"
/// MountLabel : ""
/// Mounts : [{"Destination":"/cache","Driver":"local","Mode":"","Name":"ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f","Propagation":"","RW":true,"Source":"/volume4/@docker/volumes/ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f/_data","Type":"volume"},{"Destination":"/config","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume3/docker/jellyfin/config","Type":"bind"},{"Destination":"/japan","Mode":"rw","Propagation":"rprivate","RW":true,"Source":"/volume4/视频","Type":"bind"}]
/// Name : "/jellyfin"
/// NetworkSettings : {"Bridge":"","EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"HairpinMode":false,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:03","Networks":{"bridge":{"Aliases":null,"DriverOpts":null,"EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:03","NetworkID":"7704822a81028c4895beddea948c465444ab4ea429311938c02a463994dfb170"}},"Ports":{"8096/tcp":[{"HostIp":"0.0.0.0","HostPort":"9096"}],"8920/tcp":[{"HostIp":"0.0.0.0","HostPort":"9920"}]},"SandboxID":"d80b50eef099193ab1020b9fa6eebb9aa8def4a6469e4cfac724f5eb75504ac4","SandboxKey":"/var/run/docker/netns/d80b50eef099","SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null}
/// Path : "/jellyfin/jellyfin"
/// Platform : "linux"
/// ProcessLabel : ""
/// ResolvConfPath : "/volume4/@docker/containers/e4ffccaabc86190aa11939e8b96c3c342e8b6df53698eacc9f72b51e253bac75/resolv.conf"
/// RestartCount : 0
/// State : {"Dead":false,"Error":"","ExitCode":0,"FinishedAt":"2023-10-15T16:25:24.53874477Z","FinishedTs":1697387124,"Health":{"FailingStreak":0,"Log":[{"End":"2023-10-25T19:37:28.10207135+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:27.94285115+08:00"},{"End":"2023-10-25T19:37:58.324027368+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:58.164724751+08:00"},{"End":"2023-10-25T19:38:28.551192841+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-Healthy- --:--:-- --:--:--  1750\n","Start":"2023-10-25T19:38:28.381346278+08:00"},{"End":"2023-10-25T19:38:58.828731347+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Healthy\r100     7    0     7    0     0    777      0 --:--:-- --:--:-- --:--:--   777\n","Start":"2023-10-25T19:38:58.599435174+08:00"},{"End":"2023-10-25T19:39:29.11796881+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   2333      0 --:--:-- --:--:-- --:--:--  2333\nHealthy","Start":"2023-10-25T19:39:28.944010624+08:00"}],"Status":"healthy"},"OOMKilled":false,"Paused":false,"Pid":7100,"Restarting":false,"Running":true,"StartedAt":"2023-10-15T16:25:28.058628347Z","StartedTs":1697387128,"Status":"running"}
/// exe_cmd : "/jellyfin/jellyfin"
/// finish_time : 1697387124
/// memory : 360964096
/// memoryPercent : 4.392551422119141
/// status : "running"
/// up_time : 1697387128

class Details {
  Details({
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
    this.state,
    this.exeCmd,
    this.finishTime,
    this.memory,
    this.memoryPercent,
    this.status,
    this.upTime,
  });

  Details.fromJson(dynamic json) {
    appArmorProfile = json['AppArmorProfile'];
    if (json['Args'] != null) {
      args = [];
      // json['Args'].forEach((v) {
      //   args?.add(Dynamic.fromJson(v));
      // });
    }
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
    state = json['State'] != null ? DockerState.fromJson(json['State']) : null;
    exeCmd = json['exe_cmd'];
    finishTime = json['finish_time'];
    memory = json['memory'];
    memoryPercent = json['memoryPercent'];
    status = json['status'];
    upTime = json['up_time'];
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
  DockerState? state;
  String? exeCmd;
  num? finishTime;
  num? memory;
  num? memoryPercent;
  String? status;
  ContainerStatusEnum get statusEnum => ContainerStatusEnum.fromValue(status ?? 'unknown');
  int? upTime;
  Details copyWith({
    String? appArmorProfile,
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
    DockerState? state,
    String? exeCmd,
    num? finishTime,
    num? memory,
    num? memoryPercent,
    String? status,
    int? upTime,
  }) =>
      Details(
        appArmorProfile: appArmorProfile ?? this.appArmorProfile,
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
        exeCmd: exeCmd ?? this.exeCmd,
        finishTime: finishTime ?? this.finishTime,
        memory: memory ?? this.memory,
        memoryPercent: memoryPercent ?? this.memoryPercent,
        status: status ?? this.status,
        upTime: upTime ?? this.upTime,
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
    map['exe_cmd'] = exeCmd;
    map['finish_time'] = finishTime;
    map['memory'] = memory;
    map['memoryPercent'] = memoryPercent;
    map['status'] = status;
    map['up_time'] = upTime;
    return map;
  }
}

/// Dead : false
/// Error : ""
/// ExitCode : 0
/// FinishedAt : "2023-10-15T16:25:24.53874477Z"
/// FinishedTs : 1697387124
/// Health : {"FailingStreak":0,"Log":[{"End":"2023-10-25T19:37:28.10207135+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:27.94285115+08:00"},{"End":"2023-10-25T19:37:58.324027368+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:58.164724751+08:00"},{"End":"2023-10-25T19:38:28.551192841+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-Healthy- --:--:-- --:--:--  1750\n","Start":"2023-10-25T19:38:28.381346278+08:00"},{"End":"2023-10-25T19:38:58.828731347+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Healthy\r100     7    0     7    0     0    777      0 --:--:-- --:--:-- --:--:--   777\n","Start":"2023-10-25T19:38:58.599435174+08:00"},{"End":"2023-10-25T19:39:29.11796881+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   2333      0 --:--:-- --:--:-- --:--:--  2333\nHealthy","Start":"2023-10-25T19:39:28.944010624+08:00"}],"Status":"healthy"}
/// OOMKilled : false
/// Paused : false
/// Pid : 7100
/// Restarting : false
/// Running : true
/// StartedAt : "2023-10-15T16:25:28.058628347Z"
/// StartedTs : 1697387128
/// Status : "running"

class DockerState {
  DockerState({
    this.dead,
    this.error,
    this.exitCode,
    this.finishedAt,
    this.finishedTs,
    this.health,
    this.oOMKilled,
    this.paused,
    this.pid,
    this.restarting,
    this.running,
    this.startedAt,
    this.startedTs,
    this.status,
  });

  DockerState.fromJson(dynamic json) {
    dead = json['Dead'];
    error = json['Error'];
    exitCode = json['ExitCode'];
    finishedAt = json['FinishedAt'];
    finishedTs = json['FinishedTs'];
    health = json['Health'] != null ? Health.fromJson(json['Health']) : null;
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
  Health? health;
  bool? oOMKilled;
  bool? paused;
  num? pid;
  bool? restarting;
  bool? running;
  String? startedAt;
  num? startedTs;
  String? status;
  DockerState copyWith({
    bool? dead,
    String? error,
    num? exitCode,
    String? finishedAt,
    num? finishedTs,
    Health? health,
    bool? oOMKilled,
    bool? paused,
    num? pid,
    bool? restarting,
    bool? running,
    String? startedAt,
    num? startedTs,
    String? status,
  }) =>
      DockerState(
        dead: dead ?? this.dead,
        error: error ?? this.error,
        exitCode: exitCode ?? this.exitCode,
        finishedAt: finishedAt ?? this.finishedAt,
        finishedTs: finishedTs ?? this.finishedTs,
        health: health ?? this.health,
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
    if (health != null) {
      map['Health'] = health?.toJson();
    }
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

/// FailingStreak : 0
/// Log : [{"End":"2023-10-25T19:37:28.10207135+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:27.94285115+08:00"},{"End":"2023-10-25T19:37:58.324027368+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy","Start":"2023-10-25T19:37:58.164724751+08:00"},{"End":"2023-10-25T19:38:28.551192841+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-Healthy- --:--:-- --:--:--  1750\n","Start":"2023-10-25T19:38:28.381346278+08:00"},{"End":"2023-10-25T19:38:58.828731347+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Healthy\r100     7    0     7    0     0    777      0 --:--:-- --:--:-- --:--:--   777\n","Start":"2023-10-25T19:38:58.599435174+08:00"},{"End":"2023-10-25T19:39:29.11796881+08:00","ExitCode":0,"Output":"  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   2333      0 --:--:-- --:--:-- --:--:--  2333\nHealthy","Start":"2023-10-25T19:39:28.944010624+08:00"}]
/// Status : "healthy"

class Health {
  Health({
    this.failingStreak,
    this.log,
    this.status,
  });

  Health.fromJson(dynamic json) {
    failingStreak = json['FailingStreak'];
    if (json['Log'] != null) {
      log = [];
      json['Log'].forEach((v) {
        log?.add(Log.fromJson(v));
      });
    }
    status = json['Status'];
  }
  num? failingStreak;
  List<Log>? log;
  String? status;
  Health copyWith({
    num? failingStreak,
    List<Log>? log,
    String? status,
  }) =>
      Health(
        failingStreak: failingStreak ?? this.failingStreak,
        log: log ?? this.log,
        status: status ?? this.status,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FailingStreak'] = failingStreak;
    if (log != null) {
      map['Log'] = log?.map((v) => v.toJson()).toList();
    }
    map['Status'] = status;
    return map;
  }
}

/// End : "2023-10-25T19:37:28.10207135+08:00"
/// ExitCode : 0
/// Output : "  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0\r100     7    0     7    0     0   1750      0 --:--:-- --:--:-- --:--:--  1750\nHealthy"
/// Start : "2023-10-25T19:37:27.94285115+08:00"

class Log {
  Log({
    this.end,
    this.exitCode,
    this.output,
    this.start,
  });

  Log.fromJson(dynamic json) {
    end = json['End'];
    exitCode = json['ExitCode'];
    output = json['Output'];
    start = json['Start'];
  }
  String? end;
  num? exitCode;
  String? output;
  String? start;
  Log copyWith({
    String? end,
    num? exitCode,
    String? output,
    String? start,
  }) =>
      Log(
        end: end ?? this.end,
        exitCode: exitCode ?? this.exitCode,
        output: output ?? this.output,
        start: start ?? this.start,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['End'] = end;
    map['ExitCode'] = exitCode;
    map['Output'] = output;
    map['Start'] = start;
    return map;
  }
}

/// Bridge : ""
/// EndpointID : "0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa"
/// Gateway : "172.17.0.1"
/// GlobalIPv6Address : ""
/// GlobalIPv6PrefixLen : 0
/// HairpinMode : false
/// IPAddress : "172.17.0.3"
/// IPPrefixLen : 16
/// IPv6Gateway : ""
/// LinkLocalIPv6Address : ""
/// LinkLocalIPv6PrefixLen : 0
/// MacAddress : "02:42:ac:11:00:03"
/// Networks : {"bridge":{"Aliases":null,"DriverOpts":null,"EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:03","NetworkID":"7704822a81028c4895beddea948c465444ab4ea429311938c02a463994dfb170"}}
/// Ports : {"8096/tcp":[{"HostIp":"0.0.0.0","HostPort":"9096"}],"8920/tcp":[{"HostIp":"0.0.0.0","HostPort":"9920"}]}
/// SandboxID : "d80b50eef099193ab1020b9fa6eebb9aa8def4a6469e4cfac724f5eb75504ac4"
/// SandboxKey : "/var/run/docker/netns/d80b50eef099"
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
    this.sandboxID,
    this.sandboxKey,
    this.secondaryIPAddresses,
    this.secondaryIPv6Addresses,
  });

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
  String? sandboxID;
  String? sandboxKey;
  dynamic secondaryIPAddresses;
  dynamic secondaryIPv6Addresses;
  NetworkSettings copyWith({
    String? bridge,
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
    String? sandboxID,
    String? sandboxKey,
    dynamic secondaryIPAddresses,
    dynamic secondaryIPv6Addresses,
  }) =>
      NetworkSettings(
        bridge: bridge ?? this.bridge,
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
    map['SandboxID'] = sandboxID;
    map['SandboxKey'] = sandboxKey;
    map['SecondaryIPAddresses'] = secondaryIPAddresses;
    map['SecondaryIPv6Addresses'] = secondaryIPv6Addresses;
    return map;
  }
}

/// bridge : {"Aliases":null,"DriverOpts":null,"EndpointID":"0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa","Gateway":"172.17.0.1","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"172.17.0.3","IPPrefixLen":16,"IPv6Gateway":"","Links":null,"MacAddress":"02:42:ac:11:00:03","NetworkID":"7704822a81028c4895beddea948c465444ab4ea429311938c02a463994dfb170"}

class Networks {
  Networks({
    this.bridge,
  });

  Networks.fromJson(dynamic json) {
    bridge = json['bridge'] != null ? Bridge.fromJson(json['bridge']) : null;
  }
  Bridge? bridge;
  Networks copyWith({
    Bridge? bridge,
  }) =>
      Networks(
        bridge: bridge ?? this.bridge,
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
/// EndpointID : "0f7f38cc8a2b24c91feb33abfd43047ae0337f2b684c1755f5066ef70c6b69fa"
/// Gateway : "172.17.0.1"
/// GlobalIPv6Address : ""
/// GlobalIPv6PrefixLen : 0
/// IPAMConfig : null
/// IPAddress : "172.17.0.3"
/// IPPrefixLen : 16
/// IPv6Gateway : ""
/// Links : null
/// MacAddress : "02:42:ac:11:00:03"
/// NetworkID : "7704822a81028c4895beddea948c465444ab4ea429311938c02a463994dfb170"

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
    this.networkID,
  });

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
  Bridge copyWith({
    dynamic aliases,
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
  }) =>
      Bridge(
        aliases: aliases ?? this.aliases,
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

/// Destination : "/cache"
/// Driver : "local"
/// Mode : ""
/// Name : "ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f"
/// Propagation : ""
/// RW : true
/// Source : "/volume4/@docker/volumes/ea7e5c3e8b71f53f10c65b00770f7bfcd24d380eb53341ab3a462575c32f292f/_data"
/// Type : "volume"

class Mounts {
  Mounts({
    this.destination,
    this.driver,
    this.mode,
    this.name,
    this.propagation,
    this.rw,
    this.source,
    this.type,
  });

  Mounts.fromJson(dynamic json) {
    destination = json['Destination'];
    driver = json['Driver'];
    mode = json['Mode'];
    name = json['Name'];
    propagation = json['Propagation'];
    rw = json['RW'];
    source = json['Source'];
    type = json['Type'];
  }
  String? destination;
  String? driver;
  String? mode;
  String? name;
  String? propagation;
  bool? rw;
  String? source;
  String? type;
  Mounts copyWith({
    String? destination,
    String? driver,
    String? mode,
    String? name,
    String? propagation,
    bool? rw,
    String? source,
    String? type,
  }) =>
      Mounts(
        destination: destination ?? this.destination,
        driver: driver ?? this.driver,
        mode: mode ?? this.mode,
        name: name ?? this.name,
        propagation: propagation ?? this.propagation,
        rw: rw ?? this.rw,
        source: source ?? this.source,
        type: type ?? this.type,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Destination'] = destination;
    map['Driver'] = driver;
    map['Mode'] = mode;
    map['Name'] = name;
    map['Propagation'] = propagation;
    map['RW'] = rw;
    map['Source'] = source;
    map['Type'] = type;
    return map;
  }
}

/// AutoRemove : false
/// Binds : ["/volume3/docker/jellyfin/config:/config:rw","/volume4/视频:/japan:rw"]
/// BlkioDeviceReadBps : null
/// BlkioDeviceReadIOps : null
/// BlkioDeviceWriteBps : null
/// BlkioDeviceWriteIOps : null
/// BlkioWeight : 0
/// BlkioWeightDevice : null
/// CapAdd : []
/// CapDrop : []
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
/// Env : ["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"]
/// ExtraHosts : null
/// GroupAdd : null
/// IOMaximumBandwidth : 0
/// IOMaximumIOps : 0
/// IpcMode : "private"
/// Isolation : ""
/// KernelMemory : 0
/// KernelMemoryTCP : 0
/// Links : null
/// LogConfig : {"Config":{},"Type":"db"}
/// MaskedPaths : null
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
/// PortBindings : {"8096/tcp":[{"HostIp":"","HostPort":"9096"}],"8920/tcp":[{"HostIp":"","HostPort":"9920"}]}
/// Privileged : true
/// PublishAllPorts : false
/// ReadonlyPaths : null
/// ReadonlyRootfs : false
/// RestartPolicy : {"MaximumRetryCount":0,"Name":"always"}
/// Runtime : "runc"
/// SecurityOpt : ["label=disable"]
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
    this.volumesFrom,
  });

  HostConfig.fromJson(dynamic json) {
    autoRemove = json['AutoRemove'];
    binds = json['Binds'] != null ? json['Binds'].cast<String>() : [];
    blkioDeviceReadBps = json['BlkioDeviceReadBps'];
    blkioDeviceReadIOps = json['BlkioDeviceReadIOps'];
    blkioDeviceWriteBps = json['BlkioDeviceWriteBps'];
    blkioDeviceWriteIOps = json['BlkioDeviceWriteIOps'];
    blkioWeight = json['BlkioWeight'];
    blkioWeightDevice = json['BlkioWeightDevice'];
    if (json['CapAdd'] != null) {
      capAdd = [];
      // json['CapAdd'].forEach((v) {
      //   capAdd?.add(Dynamic.fromJson(v));
      // });
    }
    if (json['CapDrop'] != null) {
      capDrop = [];
      // json['CapDrop'].forEach((v) {
      //   capDrop?.add(Dynamic.fromJson(v));
      // });
    }
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
    if (json['Dns'] != null) {
      dns = [];
      // json['Dns'].forEach((v) {
      //   dns?.add(Dynamic.fromJson(v));
      // });
    }
    if (json['DnsOptions'] != null) {
      dnsOptions = [];
      // json['DnsOptions'].forEach((v) {
      //   dnsOptions?.add(Dynamic.fromJson(v));
      // });
    }
    if (json['DnsSearch'] != null) {
      dnsSearch = [];
      // json['DnsSearch'].forEach((v) {
      //   dnsSearch?.add(Dynamic.fromJson(v));
      // });
    }
    env = json['Env'] != null ? json['Env'].cast<String>() : [];
    extraHosts = json['ExtraHosts'];
    groupAdd = json['GroupAdd'];
    iOMaximumBandwidth = json['IOMaximumBandwidth'];
    iOMaximumIOps = json['IOMaximumIOps'];
    ipcMode = json['IpcMode'];
    isolation = json['Isolation'];
    kernelMemory = json['KernelMemory'];
    kernelMemoryTCP = json['KernelMemoryTCP'];
    links = json['Links'];
    logConfig = json['LogConfig'] != null ? LogConfig.fromJson(json['LogConfig']) : null;
    maskedPaths = json['MaskedPaths'];
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
    privileged = json['Privileged'];
    publishAllPorts = json['PublishAllPorts'];
    readonlyPaths = json['ReadonlyPaths'];
    readonlyRootfs = json['ReadonlyRootfs'];
    restartPolicy = json['RestartPolicy'] != null ? RestartPolicy.fromJson(json['RestartPolicy']) : null;
    runtime = json['Runtime'];
    securityOpt = json['SecurityOpt'] != null ? json['SecurityOpt'].cast<String>() : [];
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
  List<dynamic>? capAdd;
  List<dynamic>? capDrop;
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
  dynamic extraHosts;
  dynamic groupAdd;
  num? iOMaximumBandwidth;
  num? iOMaximumIOps;
  String? ipcMode;
  String? isolation;
  num? kernelMemory;
  num? kernelMemoryTCP;
  dynamic links;
  LogConfig? logConfig;
  dynamic maskedPaths;
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
  PortBindings? portBindings;
  bool? privileged;
  bool? publishAllPorts;
  dynamic readonlyPaths;
  bool? readonlyRootfs;
  RestartPolicy? restartPolicy;
  String? runtime;
  List<String>? securityOpt;
  num? shmSize;
  String? uTSMode;
  dynamic ulimits;
  String? usernsMode;
  String? volumeDriver;
  dynamic volumesFrom;
  HostConfig copyWith({
    bool? autoRemove,
    List<String>? binds,
    dynamic blkioDeviceReadBps,
    dynamic blkioDeviceReadIOps,
    dynamic blkioDeviceWriteBps,
    dynamic blkioDeviceWriteIOps,
    num? blkioWeight,
    dynamic blkioWeightDevice,
    List<dynamic>? capAdd,
    List<dynamic>? capDrop,
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
    dynamic extraHosts,
    dynamic groupAdd,
    num? iOMaximumBandwidth,
    num? iOMaximumIOps,
    String? ipcMode,
    String? isolation,
    num? kernelMemory,
    num? kernelMemoryTCP,
    dynamic links,
    LogConfig? logConfig,
    dynamic maskedPaths,
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
    PortBindings? portBindings,
    bool? privileged,
    bool? publishAllPorts,
    dynamic readonlyPaths,
    bool? readonlyRootfs,
    RestartPolicy? restartPolicy,
    String? runtime,
    List<String>? securityOpt,
    num? shmSize,
    String? uTSMode,
    dynamic ulimits,
    String? usernsMode,
    String? volumeDriver,
    dynamic volumesFrom,
  }) =>
      HostConfig(
        autoRemove: autoRemove ?? this.autoRemove,
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
    if (capAdd != null) {
      map['CapAdd'] = capAdd?.map((v) => v.toJson()).toList();
    }
    if (capDrop != null) {
      map['CapDrop'] = capDrop?.map((v) => v.toJson()).toList();
    }
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
    map['ExtraHosts'] = extraHosts;
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
    if (portBindings != null) {
      map['PortBindings'] = portBindings?.toJson();
    }
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
/// Name : "always"

class RestartPolicy {
  RestartPolicy({
    this.maximumRetryCount,
    this.name,
  });

  RestartPolicy.fromJson(dynamic json) {
    maximumRetryCount = json['MaximumRetryCount'];
    name = json['Name'];
  }
  num? maximumRetryCount;
  String? name;
  RestartPolicy copyWith({
    num? maximumRetryCount,
    String? name,
  }) =>
      RestartPolicy(
        maximumRetryCount: maximumRetryCount ?? this.maximumRetryCount,
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
    this.type,
  });

  LogConfig.fromJson(dynamic json) {
    config = json['Config'];
    type = json['Type'];
  }
  dynamic config;
  String? type;
  LogConfig copyWith({
    dynamic config,
    String? type,
  }) =>
      LogConfig(
        config: config ?? this.config,
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
    this.name,
  });

  GraphDriver.fromJson(dynamic json) {
    data = json['Data'];
    name = json['Name'];
  }
  dynamic data;
  String? name;
  GraphDriver copyWith({
    dynamic data,
    String? name,
  }) =>
      GraphDriver(
        data: data ?? this.data,
        name: name ?? this.name,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Data'] = data;
    map['Name'] = name;
    return map;
  }
}

/// AttachStderr : false
/// AttachStdin : false
/// AttachStdout : false
/// Cmd : null
/// DDSM : false
/// Domainname : ""
/// Entrypoint : ["/jellyfin/jellyfin"]
/// Env : ["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HEALTHCHECK_URL=http://localhost:8096/health","DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1","LC_ALL=en_US.UTF-8","LANG=en_US.UTF-8","LANGUAGE=en_US:en","JELLYFIN_DATA_DIR=/config","JELLYFIN_CACHE_DIR=/cache","JELLYFIN_CONFIG_DIR=/config/config","JELLYFIN_LOG_DIR=/config/log","JELLYFIN_WEB_DIR=/jellyfin/jellyfin-web","JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg","NVIDIA_VISIBLE_DEVICES=all","NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"]
/// ExposedPorts : {"8096/tcp":{}}
/// Healthcheck : {"Interval":30000000000,"Retries":3,"StartPeriod":10000000000,"Test":["CMD-SHELL","curl -Lk \"${HEALTHCHECK_URL}\" || exit 1"],"Timeout":30000000000}
/// Hostname : "jellyfin"
/// Image : "jellyfin/jellyfin:latest"
/// Labels : {}
/// OnBuild : null
/// OpenStdin : true
/// StdinOnce : false
/// Tty : true
/// User : ""
/// Volumes : {"/cache":{},"/config":{}}
/// WorkingDir : ""

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
    this.healthcheck,
    this.hostname,
    this.image,
    this.labels,
    this.onBuild,
    this.openStdin,
    this.stdinOnce,
    this.tty,
    this.user,
    this.volumes,
    this.workingDir,
  });

  Config.fromJson(dynamic json) {
    attachStderr = json['AttachStderr'];
    attachStdin = json['AttachStdin'];
    attachStdout = json['AttachStdout'];
    cmd = json['Cmd'];
    ddsm = json['DDSM'];
    domainname = json['Domainname'];
    entrypoint = json['Entrypoint'] != null ? json['Entrypoint'].cast<String>() : [];
    env = json['Env'] != null ? json['Env'].cast<String>() : [];
    exposedPorts = json['ExposedPorts'] != null ? ExposedPorts.fromJson(json['ExposedPorts']) : null;
    healthcheck = json['Healthcheck'] != null ? Healthcheck.fromJson(json['Healthcheck']) : null;
    hostname = json['Hostname'];
    image = json['Image'];
    labels = json['Labels'];
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
  ExposedPorts? exposedPorts;
  Healthcheck? healthcheck;
  String? hostname;
  String? image;
  dynamic labels;
  dynamic onBuild;
  bool? openStdin;
  bool? stdinOnce;
  bool? tty;
  String? user;
  Volumes? volumes;
  String? workingDir;
  Config copyWith({
    bool? attachStderr,
    bool? attachStdin,
    bool? attachStdout,
    dynamic cmd,
    bool? ddsm,
    String? domainname,
    List<String>? entrypoint,
    List<String>? env,
    ExposedPorts? exposedPorts,
    Healthcheck? healthcheck,
    String? hostname,
    String? image,
    dynamic labels,
    dynamic onBuild,
    bool? openStdin,
    bool? stdinOnce,
    bool? tty,
    String? user,
    Volumes? volumes,
    String? workingDir,
  }) =>
      Config(
        attachStderr: attachStderr ?? this.attachStderr,
        attachStdin: attachStdin ?? this.attachStdin,
        attachStdout: attachStdout ?? this.attachStdout,
        cmd: cmd ?? this.cmd,
        ddsm: ddsm ?? this.ddsm,
        domainname: domainname ?? this.domainname,
        entrypoint: entrypoint ?? this.entrypoint,
        env: env ?? this.env,
        exposedPorts: exposedPorts ?? this.exposedPorts,
        healthcheck: healthcheck ?? this.healthcheck,
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
    if (exposedPorts != null) {
      map['ExposedPorts'] = exposedPorts?.toJson();
    }
    if (healthcheck != null) {
      map['Healthcheck'] = healthcheck?.toJson();
    }
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

/// /cache : {}
/// /config : {}

class Volumes {
  Volumes({
    this.cache,
    this.config,
  });

  Volumes.fromJson(dynamic json) {
    cache = json['/cache'];
    config = json['/config'];
  }
  dynamic cache;
  dynamic config;
  Volumes copyWith({
    dynamic cache,
    dynamic config,
  }) =>
      Volumes(
        cache: cache ?? this.cache,
        config: config ?? this.config,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['/cache'] = cache;
    map['/config'] = config;
    return map;
  }
}

/// Interval : 30000000000
/// Retries : 3
/// StartPeriod : 10000000000
/// Test : ["CMD-SHELL","curl -Lk \"${HEALTHCHECK_URL}\" || exit 1"]
/// Timeout : 30000000000

class Healthcheck {
  Healthcheck({
    this.interval,
    this.retries,
    this.startPeriod,
    this.test,
    this.timeout,
  });

  Healthcheck.fromJson(dynamic json) {
    interval = json['Interval'];
    retries = json['Retries'];
    startPeriod = json['StartPeriod'];
    test = json['Test'] != null ? json['Test'].cast<String>() : [];
    timeout = json['Timeout'];
  }
  num? interval;
  num? retries;
  num? startPeriod;
  List<String>? test;
  num? timeout;
  Healthcheck copyWith({
    num? interval,
    num? retries,
    num? startPeriod,
    List<String>? test,
    num? timeout,
  }) =>
      Healthcheck(
        interval: interval ?? this.interval,
        retries: retries ?? this.retries,
        startPeriod: startPeriod ?? this.startPeriod,
        test: test ?? this.test,
        timeout: timeout ?? this.timeout,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Interval'] = interval;
    map['Retries'] = retries;
    map['StartPeriod'] = startPeriod;
    map['Test'] = test;
    map['Timeout'] = timeout;
    return map;
  }
}

/// 8096/tcp : {}

class ExposedPorts {
  ExposedPorts({
    this.tcp,
  });

  ExposedPorts.fromJson(dynamic json) {
    tcp = json['8096/tcp'];
  }
  dynamic tcp;
  ExposedPorts copyWith({
    dynamic tcp,
  }) =>
      ExposedPorts(
        tcp: tcp ?? this.tcp,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['8096/tcp'] = tcp;
    return map;
  }
}
