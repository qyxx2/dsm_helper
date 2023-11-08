import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:flutter/material.dart';

class ProjectDetail extends StatefulWidget {
  final DockerProject project;
  const ProjectDetail(this.project, {super.key});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Column(
          children: [
            Text(widget.project.name!),
            Text(
              widget.project.path!,
              style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
            ),
          ],
        ),
      ),
      body: Placeholder(),
    );
  }
}
