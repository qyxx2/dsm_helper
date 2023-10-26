import 'package:dsm_helper/apis/api.dart';

/// dates : ["2023-10-07","2023-09-27","2023-09-26","2023-09-24","2023-09-23","2023-09-22","2023-09-21","2023-09-20","2023-09-19","2023-09-18","2023-09-17","2023-09-16","2023-09-15","2023-09-14","2023-09-13","2023-09-12","2023-09-11","2023-09-10","2023-09-09","2023-09-08","2023-09-07","2023-09-06","2023-09-05","2023-09-04","2023-09-01","2023-08-31","2023-08-30","2023-08-29","2023-08-28","2023-08-27","2023-08-26","2023-08-25","2023-08-24","2023-08-23"]

class ContainerLogDates {
  ContainerLogDates({
    this.dates,
  });

  static Future getDateList(String name) async {
    DsmResponse res = await Api.dsm.entry(
      "SYNO.Docker.Container.Log",
      "get_date_list",
      version: 1,
      parser: ContainerLogDates.fromJson,
      data: {
        "name": name,
      },
    );
    return res.data;
  }

  ContainerLogDates.fromJson(dynamic json) {
    if (json['dates'] != null) {
      dates = [];
      json['dates'].forEach((date) {
        dates!.add(DateTime.parse(date));
      });
    }
  }
  List<DateTime>? dates;
  ContainerLogDates copyWith({
    List<DateTime>? dates,
  }) =>
      ContainerLogDates(
        dates: dates ?? this.dates,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dates'] = dates;
    return map;
  }
}
