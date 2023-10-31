import 'dart:async';

import 'package:dsm_helper/models/Syno/Core/Package/PackageServer.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/pages/packages/uninstall.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/media_query_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:dsm_helper/widgets/label.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class PackageDetail extends StatefulWidget {
  final PackageItem package;
  final bool beta;
  final String? method;
  PackageDetail(this.package, {this.beta = false, this.method});
  @override
  _PackageDetailState createState() => _PackageDetailState();
}

class _PackageDetailState extends State<PackageDetail> {
  String thumbnailUrl = "";
  String installVolume = "";
  String installPath = "";
  List volumes = [];
  double installProgress = 0;
  bool installing = false;
  Timer? timer;
  String taskId = "";
  @override
  void initState() {
    if (widget.package.installed) {
      setState(() {
        installPath = widget.package.installedPackageItem?.additional?.installedInfo?.path?.split("/@appstore")[0] ?? '';
        if (widget.package.installedPackageItem?.additional?.installedInfo?.path?.contains("volume") ?? false) {
          List<String> paths = widget.package.installedPackageItem?.additional?.installedInfo?.path?.split("/") ?? [];
          installVolume = paths[1];
        } else {
          installVolume = "系统分区";
        }
      });
    }
    thumbnailUrl = widget.package.thumbnail!.last;
    if (!thumbnailUrl.startsWith("http")) {
      thumbnailUrl = Utils.baseUrl + thumbnailUrl;
    }
    getVolumes();
    super.initState();
  }

  getVolumes() async {
    var res = await Api.volumes();
    if (res['success']) {
      setState(() {
        volumes = res['data']['volumes'];
      });
      if (widget.method == "install") {
        selectVolume();
      } else if (widget.method == "update") {
        update();
      }
    }
  }

  Widget _buildSwiperItem(String url) {
    if (!url.startsWith("http")) {
      url = Utils.baseUrl + url;
    }
    return CupertinoExtendedImage(
      url,
      height: 210,
      fit: BoxFit.contain,
    );
  }

  uninstall() {
    if (widget.package.installedPackageItem?.additional?.isUninstallPages == true) {
      context.push(UninstallPackage(widget.package), name: "uninstall_package");
    } else {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "卸载套件",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "确认要卸载此套件？",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              uninstallPackage();
                            },
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(25),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "卸载",
                              style: TextStyle(fontSize: 18, color: Colors.redAccent),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: CupertinoButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(25),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "取消",
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
          );
        },
      );
    }
  }

  selectVolume() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "选择套件安装位置",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ...volumes.map((volume) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: CupertinoButton(
                          onPressed: () async {
                            install(volume['volume_path']);
                            Navigator.of(context).pop();
                          },
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            padding: EdgeInsets.only(left: 20),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${volume['display_name']}(可用容量：${Utils.formatSize(int.parse(volume['size_free_byte']))}) - ${volume['fs_type']}"),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${volume['description']}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    CupertinoButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "取消",
                        style: TextStyle(fontSize: 18),
                      ),
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
      },
    );
  }

  getLaunchedPackages() async {
    // widget.package['launched'] = true;
    // widget.package['can_update'] = false;
  }

  update() async {
    setState(() {
      // installButtonText = "请稍后";
    });
    var res = await Api.installPackageQueue(widget.package.id!, widget.package.version!, beta: widget.beta);
    if (res['success']) {
      if (res['data']['paused_pkgs'].length > 0) {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "确认更新",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          '更新${res['data']['cause_pausing_pkgs'].join(",")}时，${res['data']['paused_pkgs'].join("，")}将被停用。',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                onPressed: () async {
                                  install(installPath);
                                  Navigator.of(context).pop();
                                },
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(25),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "继续更新",
                                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: CupertinoButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(25),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "取消",
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
          },
        ).then((value) {
          setState(() {
            // installButtonText = "更新";
          });
        });
      } else {
        install(installPath);
      }
    }
  }

  uninstallPackage() async {
    var res = await Api.uninstallPackageTask(widget.package.id!);
    if (res['success']) {
      Utils.toast("卸载成功");
      Navigator.of(context).pop();
    } else {
      Utils.toast("套件卸载失败，错误代码：${res['error']['code']}");
    }
  }

  install(path) async {
    var res = await Api.installPackageTask(widget.package.id!, path);
    print(res);
    if (res['success']) {
      Utils.toast("已开始安装");
      setState(() {
        installing = true;
        // installButtonText = "准备安装…";
        installProgress = double.parse(res['data']['progress']);
      });
      //进度
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        Api.installPackageStatus(res['data']['taskid']).then((value) {
          print(value);
          setState(() {
            installing = !value['data']['finished'];
            if (value['data']['finished']) {
              widget.package.installed = true;
              getLaunchedPackages();
              timer.cancel();
            } else if (value['data']['progress'] != null) {
              if (value['data']['progress'] is double) {
                installProgress = value['data']['progress'];
              } else {
                installProgress = double.parse(value['data']['progress']);
              }
              // installButtonText = "下载中:${installProgress.toStringAsFixed(2)}%";
            } else if (value['data']['status'] == "installing") {
              // installButtonText = "安装中…";
            } else if (value['data']['status'] == 'upgrading') {
              // installButtonText = "更新中…";
            }
          });
        });
      });
    } else if (res['error']['code'] == 4501) {
      Utils.toast("此套件需配置信息，当前暂不支持，请在WEB端安装");
    } else {
      Utils.toast("安装套件失败，代码${res['error']['code']}");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text("${widget.package.dname}"),
        actions: [
          if (widget.package.installed)
            CupertinoButton(
              onPressed: () async {},
              child: Image.asset(
                "assets/icons/delete.png",
                width: 24,
                height: 24,
              ),
            ),
          if (widget.package.installedPackageItem?.canUpdate == true)
            CupertinoButton(
              onPressed: update,
              child: Icon(
                Icons.tips_and_updates_outlined,
                size: 24,
                color: AppTheme.of(context)?.warningColor,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 14, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context)?.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CupertinoExtendedImage(
                          thumbnailUrl,
                          width: 60,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.package.dname}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (widget.package.installed)
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: widget.package.installedPackageItem?.additional?.status == 'running' ? Label("已启动", Colors.green) : Label("已停用", Colors.red),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (widget.package.snapshot != null && widget.package.snapshot!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 14, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context)?.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 210,
                            child: Swiper(
                              autoplay: true,
                              autoplayDelay: 5000,
                              pagination: SwiperPagination(alignment: Alignment.bottomCenter, builder: DotSwiperPaginationBuilder(activeColor: AppTheme.of(context)?.primaryColor, size: 7, activeSize: 7)),
                              itemCount: widget.package.snapshot!.length,
                              itemBuilder: (context, i) {
                                return _buildSwiperItem(widget.package.snapshot![i]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                WidgetCard(
                  title: "描述",
                  body: Text("${widget.package.desc}"),
                ),
                if (widget.package.changelog != null && widget.package.changelog != "")
                  WidgetCard(
                    title: "${widget.package.version}新增功能",
                    body: Html(
                      data: widget.package.changelog!,
                      onLinkTap: (link, _, __) {
                        if (link != null) {
                          context.push(Browser(url: link));
                        }
                      },
                      style: {
                        "ol": Style(
                          padding: HtmlPaddings.zero,
                          margin: Margins.zero,
                        ),
                        "li": Style(),
                      },
                    ),
                  ),
                WidgetCard(
                  title: "其他信息",
                  body: Wrap(
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: (context.width - 84) / 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "开发者",
                              style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                            ),
                            if (widget.package.maintainerUrl != null && widget.package.maintainerUrl != "")
                              GestureDetector(
                                child: Text(
                                  "${widget.package.maintainer}",
                                  style: TextStyle(color: AppTheme.of(context)?.primaryColor, fontSize: 16),
                                ),
                                onTap: () {
                                  context.push(Browser(url: widget.package.maintainerUrl!));
                                },
                              )
                            else
                              Text(
                                "${widget.package.maintainer}",
                                style: TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                      if (widget.package.distributor != null && widget.package.distributor != "")
                        SizedBox(
                          width: (context.width - 84) / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "发布人员",
                                style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                              ),
                              if (widget.package.distributorUrl != null && widget.package.distributorUrl != "")
                                GestureDetector(
                                  child: Text(
                                    "${widget.package.distributor}",
                                    style: TextStyle(color: AppTheme.of(context)?.primaryColor, fontSize: 16),
                                  ),
                                  onTap: () {
                                    context.push(Browser(url: widget.package.distributorUrl!));
                                  },
                                )
                              else
                                Text(
                                  "${widget.package.distributor}",
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: (context.width - 84) / 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "下载次数",
                              style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                            ),
                            Text(
                              "${widget.package.downloadCount}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      if (widget.package.installed) ...[
                        SizedBox(
                          width: (context.width - 84) / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "已安装版本",
                                style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                              ),
                              Text(
                                "${widget.package.installedPackageItem?.version}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: (context.width - 84) / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "安装位置",
                                style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                              ),
                              Text(
                                "${installVolume.replaceAll("volume", "存储空间 ")}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(
                        width: (context.width - 84) / 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "最新版本",
                              style: TextStyle(color: AppTheme.of(context)?.placeholderColor, fontSize: 13),
                            ),
                            Text(
                              "${widget.package.version}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              if (widget.package.installed) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: widget.package.installedPackageItem?.additional?.status == 'running'
                        ? CupertinoButton(
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(22),
                                      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                      child: SafeArea(
                                        top: false,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "停用套件",
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Text(
                                              "确认要停用此套件？",
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                                            ),
                                            SizedBox(
                                              height: 22,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CupertinoButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      var res = await Api.launchPackage(widget.package.id!, widget.package.installedPackageItem!.additional!.dsmApps!, "stop");
                                                      if (res['success']) {
                                                        Utils.toast("已停用");
                                                        setState(() {
                                                          // widget.package['launched'] = false;
                                                        });
                                                      }
                                                    },
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(25),
                                                    padding: EdgeInsets.symmetric(vertical: 10),
                                                    child: Text(
                                                      "停用",
                                                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  child: CupertinoButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                    },
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(25),
                                                    padding: EdgeInsets.symmetric(vertical: 10),
                                                    child: Text(
                                                      "取消",
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
                                  );
                                },
                              );
                            },
                            padding: EdgeInsets.symmetric(vertical: 15),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(50),
                            child: Text("停用"),
                          )
                        : CupertinoButton(
                            onPressed: () async {
                              var res = await Api.launchPackage(widget.package.id!, widget.package.installedPackageItem!.additional!.dsmApps!, "start");
                              print(res);
                              if (res['success']) {
                                Utils.toast("已启动");
                                setState(() {
                                  // widget.package.installedPackageItem = true;
                                });
                              }
                            },
                            padding: EdgeInsets.symmetric(vertical: 15),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(50),
                            child: Text("启动"),
                          ),
                  ),
                ),
              ] else
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CupertinoButton(
                      onPressed: () {
                        selectVolume();
                      },
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(50),
                      child: Text("安装"),
                    ),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
