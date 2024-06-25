import 'package:dsm_helper/models/Syno/Docker/DockerContainerDetail.dart';
import 'package:dsm_helper/pages/docker/container_detail/container_log_tab.dart';
import 'package:dsm_helper/pages/docker/container_detail/overview_tab.dart';
import 'package:dsm_helper/pages/docker/container_detail/process_tab.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';

class ContainerDetail extends StatefulWidget {
  final String name;
  ContainerDetail(this.name);
  @override
  _ContainerDetailState createState() => _ContainerDetailState();
}

class _ContainerDetailState extends State<ContainerDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DockerContainerDetail detail = DockerContainerDetail();
  List logDates = [];
  List logs = [];
  String selectedDate = "";
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
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
            Tab(text: "总览"),
            Tab(text: "进程"),
            Tab(text: "日志"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(widget.name),
          ProcessTab(widget.name),
          ContainerLogTab(widget.name),
        ],
      ),
    );
  }
}
