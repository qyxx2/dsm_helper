import 'package:dsm_helper/pages/docker/image_tab.dart';
import 'package:dsm_helper/pages/docker/log_tab.dart';
import 'package:dsm_helper/pages/docker/network_tab.dart';
import 'package:dsm_helper/pages/docker/project_tab.dart';
import 'package:dsm_helper/pages/docker/repository_tab.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';

import 'container_tab.dart';

class Docker extends StatefulWidget {
  final bool isContainer;
  Docker({this.isContainer = false});
  @override
  _DockerState createState() => _DockerState();
}

class _DockerState extends State<Docker> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: widget.isContainer ? 6 : 5, vsync: this);
    // getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(widget.isContainer ? 'Container Manager' : 'Docker'),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            if (widget.isContainer) Tab(text: "项目"),
            Tab(text: "容器"),
            Tab(text: "镜像"),
            Tab(text: "注册表"),
            Tab(text: "网络"),
            Tab(text: "日志"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (widget.isContainer) ProjectTab(),
          ContainerTab(),
          ImageTab(),
          RepositoryTab(),
          NetworkTab(),
          LogTab(),
        ],
      ),
    );
  }
}
