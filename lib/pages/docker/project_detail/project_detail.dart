import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/pages/docker/project_detail/project_container_tab.dart';
import 'package:dsm_helper/pages/docker/project_detail/project_setting_tab.dart';
import 'package:dsm_helper/pages/docker/project_detail/project_statistic_tab.dart';
import 'package:dsm_helper/pages/docker/project_detail/project_yaml_tab.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/widgets/dot_widget.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';

class ProjectDetail extends StatefulWidget {
  final DockerProject project;
  const ProjectDetail(this.project, {super.key});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loading = true;
  DockerProject project = DockerProject();
  @override
  void initState() {
    setState(() {
      project = widget.project;
    });
    _tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    project = await DockerProject.get(widget.project.id!);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: DotWidget(
                    color: widget.project.statusEnum.color,
                  ),
                ),
                Text(widget.project.name!),
              ],
            ),
            Text(
              widget.project.path!,
              style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
            ),
          ],
        ),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(text: "容器"),
            Tab(text: "统计数据"),
            Tab(text: "YAML配置"),
            Tab(text: "设置"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProjectContainerTab(project),
          ProjectStatisticTab(),
          ProjectYamlTab(),
          ProjectSettingTab(),
        ],
      ),
    );
  }
}
