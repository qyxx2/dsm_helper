import 'package:dsm_helper/models/Syno/Docker/ContainerProcess.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ProcessTab extends StatefulWidget {
  const ProcessTab(this.name, {super.key});

  final String name;

  @override
  State<ProcessTab> createState() => _ProcessTabState();
}

class _ProcessTabState extends State<ProcessTab> {
  bool loading = true;
  ContainerProcess process = ContainerProcess();
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    process = await ContainerProcess.getProcess(widget.name);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingWidget(size: 30)
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemBuilder: (context, i) {
                return _buildProcessItem(process.processes![i]);
              },
              itemCount: process.processes!.length,
            ),
          );
  }

  Widget _buildProcessItem(Processes processes) {
    return Container(
      margin: EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: AppTheme.of(context)?.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            processes.command!,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          DefaultTextStyle(
            style: TextStyle(fontSize: 13, color: AppTheme.of(context)?.placeholderColor),
            child: Row(
              children: [
                Expanded(child: Text("进程标识符：${processes.pid}")),
                SizedBox(width: 100, child: Text("CPU：${processes.cpu!.toStringAsFixed(2)}%")),
                SizedBox(width: 100, child: Text("RAM：${Utils.formatSize(processes.memory!, showByte: true)}")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
