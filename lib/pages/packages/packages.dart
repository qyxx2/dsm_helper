import 'package:dsm_helper/models/Syno/Core/Package/InstalledPackage.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageInfo.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageServer.dart';
import 'package:dsm_helper/pages/packages/detail.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/cupertino_image.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Packages extends StatefulWidget {
  // final String version;
  Packages();
  @override
  _PackagesState createState() => _PackagesState();
}

class _PackagesState extends State<Packages> with TickerProviderStateMixin {
  int packagesVersion = 1;
  int installedVersion = 1;
  late TabController _tabController;
  PackageInfo packageInfo = PackageInfo();
  PackageServer packages = PackageServer();
  PackageServer others = PackageServer();

  List<PackageItem> get installedPackages => allPackages.where((element) => element.installed).toList();
  List<PackageItem> canUpdatePackages = [];
  List<PackageItem> launchedPackages = [];

  InstalledPackage installedPackageList = InstalledPackage();

  List volumes = [];
  bool loading = false;
  bool loadingAll = true;
  bool loadingInstalled = true;
  bool loadingOthers = true;
  List<PackageItem> get allPackages {
    return (packages.packages ?? []) + (packages.betaPackages ?? []) + (others.packages ?? []);
  }

  @override
  void initState() {
    String ver = "7.2";
    // int end = ver.indexOf("-");
    // var dsmVersion = ver.substring(4, end);
    List v = ver.split(".");
    if (v[0] == "6" && v[1] == "1") {
      installedVersion = 1;
      packagesVersion = 1;
    } else if (v[0] == "5") {
      packagesVersion = 1;
      installedVersion = 1;
    } else if (v[0] == "6" && v[1] == "2" && v.length == 2) {
      installedVersion = 1;
      packagesVersion = 2;
    } else {
      packagesVersion = 2;
      installedVersion = 2;
    }
    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    // try {
    packageInfo = await PackageInfo.get();
    int tabLength = 2;
    if (packageInfo.config?.blBetaChannel == true) {
      tabLength++;
    }
    if (packageInfo.config?.blOtherServer == true) {
      tabLength++;
    }
    if (tabLength != 2) {
      _tabController = TabController(initialIndex: 1, length: tabLength, vsync: this);
    }
    // } catch (e) {}
    // try {
    packages = await PackageServer.list(version: packagesVersion);
    setState(() {
      loadingAll = false;
    });
    // } catch (e) {
    //   print(e);
    //   Utils.toast("数据加载失败");
    //   // Navigator.of(context).pop();
    //   return;
    // }
    getOthers();
    // getLaunchedPackages();
    getInstalledPackages();
    // getVolumes();
  }

  getVolumes() async {
    var res = await Api.volumes();
    if (res['success']) {
      setState(() {
        volumes = res['data']['volumes'];
      });
    }
  }

  getOthers() async {
    print("获取第三方套件");
    others = await PackageServer.list(version: packagesVersion, others: true);
    print("获取第三方套件end");
    setState(() {
      loadingOthers = false;
    });
    // if (res['success']) {
    //   setState(() {
    //     if (res['data']['packages'] != null) {
    //       others = res['data']['packages'];
    //     } else {
    //       others = res['data']['data'];
    //     }
    //     //
    //     loadingOthers = false;
    //   });
    //   calcInstalledPackage();
    // }
  }

  // getLaunchedPackages() async {
  //   return;
  //   launchedPackages = [];
  //   print("获取运行中套件");
  //   var res = await Api.launchedPackages();
  //   print(res);
  //   print("获取运行中套件end");
  //   if (res['success']) {
  //     Map packages = res['data']['packages'];
  //     packages.forEach((key, value) {
  //       launchedPackages.add(key);
  //       setState(() {});
  //     });
  //     calcInstalledPackage();
  //   }
  // }

  getInstalledPackages() async {
    try {
      installedPackageList = await InstalledPackage.list();
      setState(() {
        loadingInstalled = false;
      });
      calcInstalledPackage();
    } catch (e) {
      print("获取已安装套件失败");
    }
  }

  calcInstalledPackage() {
    canUpdatePackages = [];
    installedPackageList.packages?.forEach((installedPackageInfo) {
      try {
        PackageItem find = allPackages.firstWhere((element) => element.id == installedPackageInfo.id);

        if (Utils.versionCompare(installedPackageInfo.version!, find.version!) < 0) {
          canUpdatePackages.add(find);
          installedPackageInfo.canUpdate = true;
        }
        find.installed = true;
        find.installedPackageItem = installedPackageInfo;
      } catch (e) {}

      // allPackages.forEach((package) {
      //   package['installed'] = package['installed'] ?? false;
      //   package['installed_version'] = package['installed_version'] ?? "";
      //   package['can_update'] = package['can_update'] ?? false;
      //   package['launched'] = package['launched'] ?? false;
      //   if (installedPackageInfo.id == package.id) {
      //     package['installed'] = true;
      //     package['installed_version'] = installedPackageInfo['version'];
      //     package['can_update'] = Utils.versionCompare(package['installed_version'], package['version']) < 0;
      //     package['additional'] = installedPackageInfo['additional'];
      //     if (package['installed']) {
      //       installedPackages.add(package);
      //     }
      //     if (package['can_update']) {
      //       canUpdatePackages.add(package);
      //     }
      //     if (package['additional'] != null && package['additional']['status'] == "running") {
      //       package['launched'] = true;
      //     } else if (launchedPackages.contains(package['id'])) {
      //       package['launched'] = true;
      //     }
      //   }
      //   setState(() {});
      // });
    });
  }

  List<String> getCategoryName(List<String>? categoryIds) {
    List<String> name = [];
    if (categoryIds == null) {
      return [];
    }
    for (int i = 0; i < categoryIds.length; i++) {
      packages.categories?.forEach((category) {
        if (category.id == categoryIds[i]) {
          name.add(category.dname!);
        }
      });
    }
    return name;
  }

  Widget _buildButton(PackageItem package, {bool beta = false}) {
    Widget button;
    if (loadingInstalled) {
      button = Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text("获取中"),
      );
    } else if (package.installedPackageItem != null && package.installedPackageItem!.canUpdate) {
      button = Button(
        onPressed: () {
          context.push(PackageDetail(package, beta: beta, method: "update"), name: "package_detail").then((_) async {
            // await getLaunchedPackages();
            await getInstalledPackages();
            setState(() {
              loading = false;
            });
          });
        },
        width: 60,
        padding: EdgeInsets.symmetric(vertical: 6),
        color: AppTheme.of(context)?.warningColor,
        borderRadius: 20,
        child: Text(
          "更新",
          style: TextStyle(fontSize: 14),
        ),
      );
    } else if (package.installed) {
      String text = "";
      if (package.installedPackageItem?.additional?.startable == true) {
        if (package.installedPackageItem?.additional?.status == 'running') {
          text = "停用";
        } else if (package.installedPackageItem?.additional?.status == 'stop') {
          text = "启动";
        } else {
          text = package.installedPackageItem?.additional?.status ?? '未知';
        }
      } else {
        text = "已安装";
      }
      button = Button(
        onPressed: () async {
          if (text == "启动") {
            setState(() {
              loading = true;
            });
            var res = await Api.launchPackage(package.id!, package.installedPackageItem!.additional!.dsmApps!, "start");
            if (res['success']) {
              Utils.toast("已启动");
              // await getLaunchedPackages();
              await getInstalledPackages();
              setState(() {
                loading = false;
              });
            }
          } else if (text == "停用") {
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
                                    setState(() {
                                      loading = true;
                                    });
                                    var res = await Api.launchPackage(package.id!, package.installedPackageItem!.additional!.dsmApps!, "stop");
                                    if (res['success']) {
                                      Utils.toast("已停用");
                                      // await getLaunchedPackages();
                                      await getInstalledPackages();
                                      setState(() {
                                        loading = false;
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
          }
        },
        padding: EdgeInsets.symmetric(vertical: 6),
        width: 60,
        color: text == "启动"
            ? AppTheme.of(context)?.successColor
            : text == "停用"
                ? AppTheme.of(context)?.errorColor
                : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: 20,
        child: Text(
          "$text",
          style: TextStyle(fontSize: 14, color: text == '已安装' ? Theme.of(context).primaryColor : null),
        ),
      );
    } else {
      button = Button(
        onPressed: () {
          context.push(PackageDetail(package, beta: beta, method: "install"), name: "package_detail").then((_) async {
            // await getLaunchedPackages();
            await getInstalledPackages();
            setState(() {
              loading = false;
            });
          });
        },
        width: 60,
        padding: EdgeInsets.symmetric(vertical: 6),
        color: AppTheme.of(context)?.primaryColor,
        borderRadius: 20,
        child: Text(
          "安装",
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    return button;
  }

  Widget _buildUpdateItem(PackageItem update) {
    String thumbnailUrl = update.thumbnail!.last;
    if (!thumbnailUrl.startsWith("http")) {
      thumbnailUrl = Utils.baseUrl + thumbnailUrl;
    }
    return GestureDetector(
      onTap: () {
        context.push(PackageDetail(update), name: "package_detail").then((_) async {
          // await getLaunchedPackages();
          await getInstalledPackages();
          setState(() {
            loading = false;
          });
        });
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                alignment: Alignment.center,
                child: CupertinoExtendedImage(
                  thumbnailUrl,
                  width: 80,
                  height: 80,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${update.dname}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${update.version}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // _buildButton(update),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageItem(PackageItem package, bool installed, {bool isBeta = false}) {
    String thumbnailUrl = "";
    if (package.thumbnail != null && package.thumbnail!.isNotEmpty) {
      thumbnailUrl = package.thumbnail!.last;
      if (!thumbnailUrl.startsWith("http")) {
        thumbnailUrl = Utils.baseUrl + thumbnailUrl;
      }
    }

    return GestureDetector(
      onTap: () {
        context.push(PackageDetail(package, beta: isBeta), name: "package_detail").then((_) async {
          // await getLaunchedPackages();
          await getInstalledPackages();
          setState(() {
            loading = false;
          });
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context)?.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(top: 14),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 40,
                    child: CupertinoExtendedImage(
                      thumbnailUrl,
                      width: 40,
                    ),
                  ),
                ),
                if (isBeta)
                  Align(
                    alignment: Alignment.topRight,
                    child: Label(
                      "Beta",
                      Colors.lightBlueAccent,
                      fill: true,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${package.dname}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (package.category != null)
                    Text(
                      // "${package['category']}",
                      // "${installed && package['additional']['updated_at'] != null ? package['additional']['updated_at'] : package['category'] is List && getCategoryName(package['category']).length > 0 ? getCategoryName(package['category']).join(",") : package['maintainer']}",
                      "${package.category is List && getCategoryName(package.category!).length > 0 ? getCategoryName(package.category!).join(",") : package.maintainer}",
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                    ),
                ],
              ),
            ),
            _buildButton(package, beta: isBeta),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: getData,
      ),
      appBar: GlassAppBar(
        leadingWidth: 50,
        title: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: [
            Tab(text: "已安装"),
            Tab(text: "全部套件"),
            if (packageInfo.config?.blBetaChannel == true) Tab(text: "Beta套件"),
            if (packageInfo.config?.blOtherServer == true) Tab(text: "社群"),
          ],
        ),
      ),
      body: loading
          ? Center(child: LoadingWidget(size: 30))
          : TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: loadingInstalled
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.all(50),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CupertinoActivityIndicator(radius: 14),
                          ),
                        )
                      : installedPackageList.packages != null && installedPackageList.packages!.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                itemBuilder: (context, i) {
                                  return _buildPackageItem(installedPackages[i], true);
                                },
                                itemCount: installedPackages.length,
                              ),
                            )
                          : EmptyWidget(
                              text: "暂无已安装套件",
                            ),
                  // : ListView(
                  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  //     children: [
                  //       if (canUpdatePackages.length > 0)
                  //         ListView.builder(
                  //           itemBuilder: (content, i) {
                  //             return _buildUpdateItem(canUpdatePackages[i]);
                  //           },
                  //           itemCount: canUpdatePackages.length,
                  //           shrinkWrap: true,
                  //           physics: NeverScrollableScrollPhysics(),
                  //         ),
                  //       Wrap(
                  //         runSpacing: 20,
                  //         spacing: 20,
                  //         children: installedPackages.map((package) {
                  //           return _buildPackageItem(package, true);
                  //         }).toList(),
                  //       ),
                  //     ],
                  //   ),
                ),
                Container(
                  child: loadingAll
                      ? Center(
                          child: LoadingWidget(size: 30),
                        )
                      : packages.packages != null && packages.packages!.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.builder(
                                itemCount: packages.packages!.length,
                                itemBuilder: (context, i) {
                                  return _buildPackageItem(packages.packages![i], false);
                                },
                              ),
                            )
                          : EmptyWidget(
                              text: "暂无套件",
                            ),
                ),
                if (packageInfo.config?.blBetaChannel == true)
                  Container(
                    child: loadingAll
                        ? LoadingWidget(size: 30)
                        : packages.betaPackages != null && packages.betaPackages!.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: ListView.builder(
                                  itemCount: packages.betaPackages!.length,
                                  itemBuilder: (context, i) {
                                    return _buildPackageItem(packages.betaPackages![i], false);
                                  },
                                ),
                              )
                            : EmptyWidget(
                                text: "暂无Beta套件",
                              ),
                  ),
                if (packageInfo.config?.blOtherServer == true)
                  Container(
                    child: loadingOthers
                        ? Center(
                            child: LoadingWidget(size: 30),
                          )
                        : others.packages != null && others.packages!.isNotEmpty
                            ? ListView.builder(
                                itemCount: others.betaPackages!.length,
                                itemBuilder: (context, i) {
                                  return _buildPackageItem(others.betaPackages![i], false);
                                },
                              )
                            : EmptyWidget(
                                text: "暂无社群套件",
                              ),
                  ),
              ],
            ),
    );
  }
}
