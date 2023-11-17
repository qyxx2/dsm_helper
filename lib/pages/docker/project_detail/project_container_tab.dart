import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectContainerTab extends StatefulWidget {
  final DockerProject project;
  const ProjectContainerTab(this.project, {super.key});

  @override
  State<ProjectContainerTab> createState() => _ProjectContainerTabState();
}

class _ProjectContainerTabState extends State<ProjectContainerTab> {
  @override
  Widget build(BuildContext context) {
    return widget.project.containers != null && widget.project.containers!.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, i) {
              // return ContainerItemWidget(widget.project.containers![i]);
            },
          )
        : EmptyWidget(
            text: "暂无容器",
          );
  }
}
