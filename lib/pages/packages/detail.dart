import 'dart:async';

import 'package:cool_ui/cool_ui.dart';
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageInstallTask.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageServer.dart';
import 'package:dsm_helper/pages/common/browser.dart';
import 'package:dsm_helper/pages/dashboard/widgets/widget_card.dart';
import 'package:dsm_helper/pages/packages/dialogs/stop_package_dialog.dart';
import 'package:dsm_helper/pages/packages/dialogs/uninstall_package_dialog.dart';
import 'package:dsm_helper/pages/packages/dialogs/update_pause_dialog.dart';
import 'package:dsm_helper/pages/packages/uninstall.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/media_query_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart' hide Api;
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

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
  bool installing = false;
  bool loading = false;
  Timer? timer;
  PackageInstallTask? packageInstallTask;
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
    super.initState();
  }

  Widget _buildSwiperItem(String url) {
    if (!url.startsWith("http")) {
      url = Api.dsm.baseUrl! + url;
    }
    return CupertinoExtendedImage(
      url,
      height: 210,
      fit: BoxFit.contain,
    );
  }

  uninstall() async {
    if (widget.package.installedPackageItem?.additional?.isUninstallPages == true) {
      context.push(UninstallPackage(widget.package), name: "uninstall_package");
    } else {
      bool? res = await UninstallPackageDialog.show(context: context, package: widget.package.installedPackageItem!);
      if (res == true) {
        uninstallPackage();
      }
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

  update() async {
    setState(() {
      // installButtonText = "请稍后";
    });
    bool? check = await widget.package.feasibilityCheck();
    if (check == true) {
      var queue = await widget.package.getInstallQueue();
      if (queue.pausedPkgs != null && queue.pausedPkgs!.isNotEmpty) {
        bool? confirm = await UpdatePauseDialog.show(context: context, queue: queue);
        if (confirm == true) {
          install(installPath);
        }
      } else {
        install(installPath);
      }
    }
    // var res = await Api.installPackageQueue(widget.package.id!, widget.package.version!, beta: widget.beta);
    // if (res['success']) {
    //   if (res['data']['paused_pkgs'].length > 0) {
    //     showCupertinoModalPopup(
    //       context: context,
    //       builder: (context) {
    //         return Material(
    //           color: Colors.transparent,
    //           child: Container(
    //             width: double.infinity,
    //             decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    //             child: SafeArea(
    //               top: false,
    //               child: Padding(
    //                 padding: EdgeInsets.all(20),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: <Widget>[
    //                     Text(
    //                       "确认更新",
    //                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    //                     ),
    //                     SizedBox(
    //                       height: 12,
    //                     ),
    //                     Text(
    //                       '更新${res['data']['cause_pausing_pkgs'].join(",")}时，${res['data']['paused_pkgs'].join("，")}将被停用。',
    //                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    //                     ),
    //                     SizedBox(
    //                       height: 22,
    //                     ),
    //                     Row(
    //                       children: [
    //                         Expanded(
    //                           child: CupertinoButton(
    //                             onPressed: () async {
    //                               install(installPath);
    //                               Navigator.of(context).pop();
    //                             },
    //                             color: Theme.of(context).scaffoldBackgroundColor,
    //                             borderRadius: BorderRadius.circular(25),
    //                             padding: EdgeInsets.symmetric(vertical: 10),
    //                             child: Text(
    //                               "继续更新",
    //                               style: TextStyle(fontSize: 18, color: Colors.redAccent),
    //                             ),
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           width: 16,
    //                         ),
    //                         Expanded(
    //                           child: CupertinoButton(
    //                             onPressed: () async {
    //                               Navigator.of(context).pop();
    //                             },
    //                             color: Theme.of(context).scaffoldBackgroundColor,
    //                             borderRadius: BorderRadius.circular(25),
    //                             padding: EdgeInsets.symmetric(vertical: 10),
    //                             child: Text(
    //                               "取消",
    //                               style: TextStyle(fontSize: 18),
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     SizedBox(
    //                       height: 8,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         );
    //       },
    //     ).then((value) {
    //       setState(() {
    //         // installButtonText = "更新";
    //       });
    //     });
    //   } else {
    //     install(installPath);
    //   }
    // }
  }

  uninstallPackage() async {
    var hide = showWeuiLoadingToast(context: context);
    try {
      bool? res = await widget.package.installedPackageItem!.uninstall();
      if (res == true) {
        Utils.vibrate(FeedbackType.success);
        Utils.toast("卸载成功");
        setState(() {
          widget.package.installed = false;
        });
      }
    } on DsmException catch (e) {
      Utils.toast("套件卸载失败，错误代码：${e.code}");
    } catch (e) {
      Utils.toast("套件卸载失败");
    }
    hide();
  }

  install(path) async {
    try {
      packageInstallTask = await widget.package.install();
      setState(() {
        installing = true;
      });
      print(packageInstallTask!.toJson());
    } on DsmException catch (e) {
      if (e.code == 4501) {
        Utils.toast("此套件需配置信息，当前暂不支持，请在WEB端安装");
      } else {
        Utils.toast("安装套件失败，代码${e.code}");
      }
    } catch (e) {
      Utils.toast("安装套件失败");
    }
    setState(() {
      installing = true;
    });
    //进度
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      packageInstallTask!.installStatus().then((value) {
        print(value.toJson());
        setState(() {
          if (value.finished == true) {
            installing = false;
            widget.package.installed = true;
            timer.cancel();
          } else {
            installing = true;
          }
        });
      });
    });
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
              onPressed: uninstall,
              child: Image.asset(
                "assets/icons/delete.png",
                width: 24,
                height: 24,
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        ),
                        if (widget.package.installed && widget.package.installedPackageItem?.additional?.startable == true) ...[
                          loading
                              ? LoadingWidget(size: 24)
                              : widget.package.installedPackageItem?.additional?.status == 'running'
                                  ? Button(
                                      width: 60,
                                      onPressed: () async {
                                        bool? confirm = await StopPackageDialog.show(context: context, package: widget.package.installedPackageItem!);
                                        if (confirm == true) {
                                          setState(() {
                                            loading = true;
                                          });
                                          bool? res = await widget.package.installedPackageItem!.stop();
                                          setState(() {
                                            loading = false;
                                          });
                                          if (res == true) {
                                            setState(() {
                                              widget.package.installedPackageItem!.additional!.status = 'stop';
                                            });
                                            Utils.vibrate(FeedbackType.success);
                                            Utils.toast("停用成功");
                                          } else {
                                            Utils.vibrate(FeedbackType.error);
                                            Utils.toast("停用失败");
                                          }
                                        }
                                      },
                                      padding: EdgeInsets.symmetric(vertical: 6),
                                      color: AppTheme.of(context)?.errorColor,
                                      borderRadius: 50,
                                      child: Text(
                                        "停用",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    )
                                  : Button(
                                      width: 60,
                                      onPressed: () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        bool? res = await widget.package.installedPackageItem!.start();
                                        setState(() {
                                          loading = false;
                                        });
                                        if (res == true) {
                                          Utils.vibrate(FeedbackType.success);
                                          Utils.toast("启动成功");
                                          setState(() {
                                            widget.package.installedPackageItem!.additional!.status = 'running';
                                          });
                                        } else {
                                          Utils.vibrate(FeedbackType.error);
                                          Utils.toast("启动失败");
                                        }
                                      },
                                      padding: EdgeInsets.symmetric(vertical: 6),
                                      color: AppTheme.of(context)?.successColor,
                                      borderRadius: 50,
                                      child: Text(
                                        "启动",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                        ]
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
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      persistentFooterButtons: packageInstallTask != null
          ? [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Button(
                        onPressed: () {
                          selectVolume();
                        },
                        padding: EdgeInsets.symmetric(vertical: 12),
                        color: AppTheme.of(context)?.primaryColor,
                        borderRadius: 50,
                        child: Text("${(packageInstallTask!.progress ?? 0) < 100 ? '下载中 ${packageInstallTask!.progress ?? 0}' : packageInstallTask!.installing == true ? '安装中' : ''}"),
                      ),
                    ),
                  ],
                ),
              )
            ]
          : !widget.package.installed
              ? [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Button(
                            onPressed: () {
                              install("/volume1");
                              // selectVolume();
                            },
                            loading: installing,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            color: AppTheme.of(context)?.primaryColor,
                            borderRadius: 50,
                            child: Text("安装"),
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              : widget.package.installedPackageItem?.canUpdate == true
                  ? [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Button(
                                onPressed: update,
                                loading: installing,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                color: AppTheme.of(context)?.warningColor,
                                borderRadius: 50,
                                child: Text("更新"),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  : null,
    );
  }
}
