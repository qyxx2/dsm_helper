import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/Docker/Container/ContainerResource.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart' hide State;
import 'package:dsm_helper/pages/docker/widgets/container_item_widget.dart';
import 'package:dsm_helper/pages/docker/widgets/docker_host_info_widget.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerTab extends StatefulWidget {
  const ContainerTab({super.key});

  @override
  State<ContainerTab> createState() => _ContainerTabState();
}

class _ContainerTabState extends State<ContainerTab> with AutomaticKeepAliveClientMixin {
  DockerContainer containers = DockerContainer();
  ContainerResource resource = ContainerResource();
  bool loading = true;
  Map<Containers, bool> containerLoading = {};
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData({bool loop = true}) async {
    List<DsmResponse> batchRes = await Api.dsm.batch(apis: [DockerContainer(), ContainerResource()]);
    batchRes.forEach((element) {
      switch (element.data.runtimeType.toString()) {
        case "DockerContainer":
          containers = element.data;
          containers.containers!.sort((a, b) => a.name!.compareTo(b.name!));
          break;
        case "ContainerResource":
          resource = element.data;
      }
    });
    if (mounted) {
      setState(() {
        containers.containers!.forEach((container) {
          container.resource = resource.resources!.firstWhere((element) => element.name == container.name);
        });
        loading = false;
      });
    }
    if (loop) {
      await Future.delayed(Duration(seconds: 10));
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? LoadingWidget(
            size: 30,
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(height: 14),
                DockerHostInfoWidget(),
                SizedBox(height: 20),
                if (containers.containers != null && containers.containers!.isNotEmpty)
                  ...containers.containers!.map((container) {
                    return ContainerItemWidget(
                      container,
                      loading: containerLoading[container] == true,
                      startLoading: () {
                        setState(() {
                          containerLoading[container] = true;
                        });
                      },
                      endLoading: () {
                        setState(() {
                          containerLoading[container] = false;
                        });
                      },
                    );
                  }).toList()
                else
                  EmptyWidget(text: "未添加容器"),
                SizedBox(height: 10),
              ],
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
