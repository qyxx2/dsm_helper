import 'dart:ui';

import 'package:dsm_helper/pages/photos/album_tab.dart';
import 'package:dsm_helper/pages/photos/folder.dart';
import 'package:dsm_helper/pages/photos/photo_tab.dart';
import 'package:dsm_helper/pages/photos/timeline.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';

class Photos extends StatefulWidget {
  const Photos({super.key});

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos> with SingleTickerProviderStateMixin {
  GlobalKey actionButtonKey = GlobalKey();
  late TabController _tabController;
  int currentIndex = 0;
  bool isTeam = false;
  bool isTimeline = true;
  GlobalKey<TimelineState> timelineKey = GlobalKey();
  GlobalKey<FolderState> folderKey = GlobalKey();
  GlobalKey<AlbumTabState> albumTabKey = GlobalKey();
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    // 获取
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: "图片"),
            Tab(text: "相册"),
          ],
        ),
        actions: [
          CupertinoButton(
            key: actionButtonKey,
            onPressed: () {
              showPopupWindow(
                context,
                gravity: KumiPopupGravity.leftBottom,
                bgColor: Colors.transparent,
                clickOutDismiss: true,
                clickBackDismiss: true,
                customAnimation: false,
                customPop: false,
                customPage: false,
                underStatusBar: true,
                underAppBar: true,
                needSafeDisplay: true,
                offsetX: 30,
                offsetY: -80,
                // curve: Curves.easeInSine,
                duration: Duration(milliseconds: 200),
                targetRenderBox: actionButtonKey.currentContext!.findRenderObject() as RenderBox,
                childFun: (pop) {
                  return BackdropFilter(
                    key: GlobalKey(),
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: 220,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      margin: EdgeInsets.only(top: 50),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                isTeam = !isTeam;
                              });
                              if (isTimeline) {
                                timelineKey.currentState?.getData(isTeam: isTeam);
                              } else {
                                folderKey.currentState?.getData(isTeam: isTeam);
                              }
                              albumTabKey.currentState?.getData(isTeam: isTeam);
                              },
                            child: Text("切换到${isTeam ? '个人空间' : '共享空间'}"),
                          ),
                          PopupMenuItem(
                            onTap: () async {
                              setState(() {
                                isTimeline = !isTimeline;
                              });
                              if (isTimeline) {
                                timelineKey.currentState?.getData(isTeam: isTeam);
                              } else {
                                folderKey.currentState?.getData(isTeam: isTeam);
                              }
                            },
                            child: Text("切换到${isTimeline ? '文件夹' : '时间线'}视图"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            minSize: 0,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Image.asset(
              "assets/icons/more_vertical.png",
              width: 20,
              height: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PhotoTab(
            isTeam,
            isTimeline,
            timelineKey: timelineKey,
            folderKey: folderKey,
          ),
          AlbumTab(
            isTeam,
            key: albumTabKey,
          ),
        ],
      ),
    );
  }
}
