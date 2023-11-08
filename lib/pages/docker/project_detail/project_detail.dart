import 'package:dsm_helper/models/Syno/Docker/DockerProject.dart';
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
    return const Placeholder();
  }
}
