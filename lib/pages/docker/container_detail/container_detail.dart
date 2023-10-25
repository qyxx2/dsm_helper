import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerContainerDetail.dart';
import 'package:dsm_helper/pages/docker/container_detail/overview_tab.dart';
import 'package:dsm_helper/pages/docker/container_detail/process_tab.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerDetail extends StatefulWidget {
  final String name;
  ContainerDetail(this.name);
  @override
  _ContainerDetailState createState() => _ContainerDetailState();
}

class _ContainerDetailState extends State<ContainerDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScrollController _scrollController = ScrollController();
  DockerContainerDetail detail = DockerContainerDetail();
  List logDates = [];
  List logs = [];
  String selectedDate = "";
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  getLogDates() async {
    var res = await Api.dockerLog(widget.name, "get_date_list");
    if (res['success']) {
      setState(() {
        logDates = res['data']['dates'];
        if (logDates.length > 0) {
          selectedDate = logDates[0];
        }
      });

      getLog();
    }
  }

  getLog() async {
    var log = await Api.dockerLog(widget.name, "get", date: selectedDate);
    if (log['success']) {
      setState(() {
        logs = log['data']['logs'];
      });
    }
  }

  Widget _buildLogItem(log) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Label("${log['stream']}", Colors.lightGreen),
                Spacer(),
                Text(
                  "${log['created']}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(log['text']),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(date) {
    String str = date;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
        getLog();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              Text(
                "${str.substring(5)}",
              ),
              Text(
                "${str.substring(0, 4)}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(widget.name),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(
              text: "总览",
            ),
            Tab(
              text: "进程",
            ),
            Tab(
              text: "日志",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(widget.name),
          ProcessTab(widget.name),
          Row(
            children: [
              Expanded(
                child: CupertinoScrollbar(
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 20, right: 10, top: 20),
                    itemBuilder: (context, i) {
                      return _buildDateItem(logDates[i]);
                    },
                    separatorBuilder: (context, i) {
                      return SizedBox(
                        height: 20,
                      );
                    },
                    itemCount: logDates.length,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: DraggableScrollbar.semicircle(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  scrollbarTimeToFade: Duration(seconds: 1),
                  controller: _scrollController,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.only(left: 10, right: 20, top: 20),
                    itemBuilder: (context, i) {
                      return _buildLogItem(logs.reversed.toList()[i]);
                    },
                    separatorBuilder: (context, i) {
                      return SizedBox(
                        height: 20,
                      );
                    },
                    itemCount: logs.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
