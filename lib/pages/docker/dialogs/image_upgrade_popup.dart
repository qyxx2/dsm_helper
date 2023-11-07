import 'dart:ui';

import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/Docker/DockerContainer.dart' hide State;
import 'package:dsm_helper/models/Syno/Docker/DockerImage.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/media_query_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/dot_widget.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageUpgrade extends StatefulWidget {
  final Images image;
  const ImageUpgrade(this.image, {super.key});

  @override
  State<ImageUpgrade> createState() => _ImageUpgradeState();
}

class _ImageUpgradeState extends State<ImageUpgrade> {
  bool loading = true;
  List<Containers> containers = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    List<DsmResponse> batchRes = await Api.dsm.batch(apis: [DockerContainer()]);
    batchRes.forEach((element) {
      switch (element.data.runtimeType.toString()) {
        case "DockerContainer":
          containers = (element.data as DockerContainer).containers?.where((element) => element.image == "${widget.image.repository}:${widget.image.tags?.join(",")}").toList() ?? [];
          break;
      }
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "更新${widget.image.repository}",
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "目前标签",
                      style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${widget.image.tags?.join(",")}(${widget.image.digest?.replaceAll("sha256:", "")})",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(indent: 0, endIndent: 0, height: 20),
                    Text(
                      "新标签",
                      style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "${widget.image.tags?.join(",")}(${widget.image.remoteDigest?.replaceAll("sha256:", "")})",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(indent: 0, endIndent: 0, height: 20),
                    Text(
                      "注意事项",
                      style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                    ),
                    Text(
                      "相关容器的服务可能停止；容器数据可能被清除。",
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(indent: 0, endIndent: 0, height: 20),
                    Text(
                      "使用该镜像的容器",
                      style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                    ),
                    Container(
                      // height: context.height * 0.4,
                      child: loading
                          ? LoadingWidget(size: 30)
                          : containers.isNotEmpty
                              ? Column(
                                  children: containers.map(_buildContainerItem).toList(),
                                )
                              : Text(
                                  "无",
                                  style: TextStyle(fontSize: 16),
                                ),
                    ),
                    Text(
                      "为了避免数据丢失，请确保您更新前已遵循本映像的 Dockerhub 页面备注。您确定要更新映像吗？",
                      style: TextStyle(color: AppTheme.of(context)?.errorColor, fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        onPressed: () async {
                          context.pop();
                        },
                        color: Theme.of(context).disabledColor,
                        borderRadius: 15,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "关闭",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Button(
                        onPressed: () async {
                          context.pop(true);
                        },
                        color: AppTheme.of(context)?.primaryColor,
                        borderRadius: 15,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "更新",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainerItem(Containers container) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 6),
            child: DotWidget(
              color: container.statusEnum.color,
            ),
          ),
          Text(
            container.statusEnum.label,
            style: TextStyle(color: container.statusEnum.color, fontSize: 13),
          ),
          SizedBox(width: 5),
          Text(
            container.name!,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class ImageUpgradePopup {
  static Future<bool?> show({required BuildContext context, required Images image}) async {
    return await showCupertinoModalPopup(
      context: context,
      // barrierColor: Colors.black12,
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) {
        return ImageUpgrade(image);
      },
    );
  }
}
