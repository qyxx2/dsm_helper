import 'package:dsm_helper/extensions/datetime.dart';
import 'package:dsm_helper/models/Syno/Docker/Container/ContainerLog.dart';
import 'package:dsm_helper/models/Syno/Docker/Container/ContainerLogDates.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/expansion_container.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ContainerLogTab extends StatefulWidget {
  const ContainerLogTab(this.name, {super.key});

  final String name;

  @override
  State<ContainerLogTab> createState() => _ContainerLogTabState();
}

class _ContainerLogTabState extends State<ContainerLogTab> {
  bool loading = true;
  bool logLoading = true;
  ContainerLogDates logDates = ContainerLogDates();
  DateTime? currentDate;
  ContainerLog log = ContainerLog();
  Map<DateTime, List<DateTime>> logMonths = {};
  RegExp exp = RegExp(r"(\x9B|\x1B\[)[0-?]*[ -/]*[@-~]");
  @override
  void initState() {
    getDateList();
    super.initState();
  }

  getDateList() async {
    logDates = await ContainerLogDates.getDateList(widget.name);
    setState(() {
      if (logDates.dates != null && logDates.dates!.isNotEmpty) {
        logDates.dates!.forEach((date) {
          DateTime month = DateTime(date.year, date.month);
          if (logMonths[month] == null) {
            logMonths[month] = [];
          }
          logMonths[month]!.add(date);
        });
        currentDate = logDates.dates!.first;
        getLog();
      }

      loading = false;
    });
  }

  getLog() async {
    setState(() {
      logLoading = true;
    });
    log = await ContainerLog.get(widget.name, currentDate!);
    setState(() {
      logLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingWidget(size: 30)
        : logDates.dates != null && logDates.dates!.isNotEmpty
            ? Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: ListView.builder(
                      itemBuilder: (context, i) {
                        DateTime month = logMonths.keys.toList()[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)?.cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.only(top: 10),
                          child: ExpansionContainer(
                            title: Text("${month.format("Y-m")}"),
                            childrenPadding: EdgeInsets.only(bottom: 10),
                            children: logMonths[month]!.map((date) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentDate = date;
                                  });
                                  getLog();
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                  child: Text(
                                    date.format("m-d"),
                                    style: TextStyle(
                                      color: date == currentDate ? AppTheme.of(context)?.primaryColor : null,
                                      fontWeight: date == currentDate ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      itemCount: logMonths.keys.length,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                      child: logLoading
                          ? LoadingWidget(size: 30)
                          : log.logs != null && log.logs!.isNotEmpty
                              ? ListView.builder(
                                  itemBuilder: (context, i) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context)?.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      margin: EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(log.logs![i].created!.format("H:i:s")),
                                              Spacer(),
                                              Text(
                                                log.logs![i].stream!,
                                                style: TextStyle(color: AppTheme.of(context)?.successColor),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "${log.logs![i].text!.replaceAll(exp, "").trim()}",
                                            style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  itemCount: log.logs!.length,
                                )
                              : EmptyWidget(
                                  text: "暂无日志",
                                )),
                ],
              )
            : EmptyWidget(text: "暂无日志");
  }
}
