import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ProjectTab extends StatefulWidget {
  const ProjectTab({super.key});

  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  Map<String, DockerProject> projects = {};
  bool loading = true;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    await DockerProject.list();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingWidget()
        : ListView.builder(
            itemBuilder: (context, i) {},
            itemCount: projects.length,
          );
  }
}
