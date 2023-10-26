import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/extensions/datetime.dart';

/// limit : 3
/// logs : [{"created":"2023-09-27T01:59:49.751324430Z","docid":"29169","stream":"stdout","text":"\u001b[32m2023-09-27 01:59:49.727\u001b[0m | \u001b[31m\u001b[1mERROR   \u001b[0m | \u001b[36mpandora.bots.server\u001b[0m:\u001b[36m__handle_error\u001b[0m:\u001b[36m99\u001b[0m - \u001b[31m\u001b[1m404 Not Found: The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.\u001b[0m\r\n"},{"created":"2023-09-27T01:59:49.788956377Z","docid":"29170","stream":"stdout","text":"\u001b[32m2023-09-27 01:59:49.778\u001b[0m | \u001b[31m\u001b[1mERROR   \u001b[0m | \u001b[36mpandora.bots.server\u001b[0m:\u001b[36m__handle_error\u001b[0m:\u001b[36m99\u001b[0m - \u001b[31m\u001b[1m405 Method Not Allowed: The method is not allowed for the requested URL.\u001b[0m\r\n"},{"created":"2023-09-27T01:59:49.789165254Z","docid":"29171","stream":"stdout","text":"\u001b[32m2023-09-27 01:59:49.783\u001b[0m | \u001b[31m\u001b[1mERROR   \u001b[0m | \u001b[36mpandora.bots.server\u001b[0m:\u001b[36m__handle_error\u001b[0m:\u001b[36m99\u001b[0m - \u001b[31m\u001b[1m405 Method Not Allowed: The method is not allowed for the requested URL.\u001b[0m\r\n"}]
/// offset : 0
/// total : 3

class ContainerLog {
  ContainerLog({
    this.limit,
    this.logs,
    this.offset,
    this.total,
  });

  static Future<ContainerLog> get(String name, DateTime date) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Container.Log",
      "get",
      version: 1,
      parser: ContainerLog.fromJson,
      data: {
        "name": name,
        "offset": 0,
        "limit": 1000,
        "date": '"${date.format("Y-m-d")}"',
        "sort_dir": "ASC",
      },
    );
    return res.data;
  }

  ContainerLog.fromJson(dynamic json) {
    limit = json['limit'];
    if (json['logs'] != null) {
      logs = [];
      json['logs'].forEach((v) {
        logs?.add(Logs.fromJson(v));
      });
    }
    offset = json['offset'];
    total = json['total'];
  }
  num? limit;
  List<Logs>? logs;
  num? offset;
  num? total;
  ContainerLog copyWith({
    num? limit,
    List<Logs>? logs,
    num? offset,
    num? total,
  }) =>
      ContainerLog(
        limit: limit ?? this.limit,
        logs: logs ?? this.logs,
        offset: offset ?? this.offset,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['limit'] = limit;
    if (logs != null) {
      map['logs'] = logs?.map((v) => v.toJson()).toList();
    }
    map['offset'] = offset;
    map['total'] = total;
    return map;
  }
}

/// created : "2023-09-27T01:59:49.751324430Z"
/// docid : "29169"
/// stream : "stdout"
/// text : "\u001b[32m2023-09-27 01:59:49.727\u001b[0m | \u001b[31m\u001b[1mERROR   \u001b[0m | \u001b[36mpandora.bots.server\u001b[0m:\u001b[36m__handle_error\u001b[0m:\u001b[36m99\u001b[0m - \u001b[31m\u001b[1m404 Not Found: The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.\u001b[0m\r\n"

class Logs {
  Logs({
    this.created,
    this.docid,
    this.stream,
    this.text,
  });

  Logs.fromJson(dynamic json) {
    created = json['created'] == null ? null : DateTime.parse(json['created']);
    docid = json['docid'];
    stream = json['stream'];
    text = json['text'];
  }
  DateTime? created;
  String? docid;
  String? stream;
  String? text;
  Logs copyWith({
    DateTime? created,
    String? docid,
    String? stream,
    String? text,
  }) =>
      Logs(
        created: created ?? this.created,
        docid: docid ?? this.docid,
        stream: stream ?? this.stream,
        text: text ?? this.text,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created'] = created;
    map['docid'] = docid;
    map['stream'] = stream;
    map['text'] = text;
    return map;
  }
}
