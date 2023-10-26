import 'package:dsm_helper/pages/docker/image_tab.dart';
import 'package:dsm_helper/pages/docker/log_tab.dart';
import 'package:dsm_helper/pages/docker/network_tab.dart';
import 'package:dsm_helper/pages/docker/repository_tab.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container_tab.dart';

class Docker extends StatefulWidget {
  final String title;
  Docker({this.title = 'Docker'});
  @override
  _DockerState createState() => _DockerState();
}

class _DockerState extends State<Docker> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    // getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(widget.title),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(
              child: Text("容器"),
            ),
            Tab(
              child: Text("镜像"),
            ),
            Tab(
              child: Text("注册表"),
            ),
            Tab(
              child: Text("网络"),
            ),
            Tab(
              child: Text("日志"),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
