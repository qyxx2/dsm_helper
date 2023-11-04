import 'package:dsm_helper/models/Syno/Core/CurrentConnection.dart';
import 'package:dsm_helper/models/Syno/Core/FileHandle.dart';
import 'package:dsm_helper/pages/dashboard/dialogs/kick_connection_dialog.dart';
import 'package:dsm_helper/providers/setting_provider.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/empty_widget.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectedUserTab extends StatefulWidget {
  const ConnectedUserTab({super.key});

  @override
  State<ConnectedUserTab> createState() => _ConnectedUserTabState();
}

class _ConnectedUserTabState extends State<ConnectedUserTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CurrentConnection connectedUsers = CurrentConnection();
  FileHandle openedFiles = FileHandle();
  late TabController _tabController;
  bool loadingUsers = true;
  bool loadingFiles = true;
  bool userError = false;
  bool fileError = false;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    getConnectedUsers();
    super.initState();
  }

  getConnectedUsers() async {
    setState(() {
      loadingUsers = true;
    });
    try {
      connectedUsers = await CurrentConnection.get();
      setState(() {
        loadingUsers = false;
      });
    } catch (e) {
      setState(() {
        userError = true;
      });
    }
  }

  getConnectedFiles() async {
    setState(() {
      loadingFiles = true;
    });
    try {
      openedFiles = await FileHandle.get();
      setState(() {
        loadingFiles = false;
      });
    } catch (e) {
      setState(() {
        fileError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(
                text: "已连接用户",
              ),
              Tab(
                text: "访问的文件",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                if (loadingUsers)
                  SizedBox(height: 100, child: Center(child: LoadingWidget(size: 30)))
                else if (userError)
                  EmptyWidget(
                    text: "获取已连接客户失败",
                    size: 100,
                  )
                else if (connectedUsers.items != null && connectedUsers.items!.isNotEmpty)
                  ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, i) {
                      return _buildUserItem(connectedUsers.items![i]);
                    },
                    itemCount: connectedUsers.items!.length,
                  )
                else
                  EmptyWidget(
                    text: "暂无已连接用户",
                    size: 100,
                  ),
                if (loadingFiles)
                  SizedBox(height: 100, child: Center(child: LoadingWidget(size: 30)))
                else if (fileError)
                  EmptyWidget(
                    text: "获取访问的文件失败",
                    size: 100,
                  )
                else if (openedFiles.openedFiles != null && openedFiles.openedFiles!.isNotEmpty)
                  ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, i) {
                      return _buildOpenedFileItem(openedFiles.openedFiles![i]);
                    },
                    itemCount: openedFiles.openedFiles!.length,
                  )
                else
                  EmptyWidget(
                    text: "暂无访问的文件",
                    size: 100,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedFileItem(OpenedFiles file) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context)?.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${file.filename}",
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  "${file.user}（${file.host}）",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                ),
                SizedBox(height: 5),
                Text(
                  "${file.service}",
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          CupertinoButton(
            onPressed: file.running
                ? null
                : () async {
                    // bool? res = await KickConnectDialog.show(context: context, user: file);
                    // if (res == true) {
                    //   setState(() {
                    //     file.running = true;
                    //   });
                    //   bool? result = await file.kickConnection();
                    //   if (result == true) {
                    //     getConnectedUsers();
                    //   }
                    // }
                  },
            padding: EdgeInsets.zero,
            child: file.running
                ? LoadingWidget(
                    size: 24,
                  )
                : Image.asset(
                    "assets/icons/remove_circle_fill.png",
                    width: 24,
                    height: 24,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserItems user) {
    DateTime loginTime = DateTime.parse(user.time!.replaceAll("/", "-"));
    DateTime currentTime = DateTime.now();
    var timeLong = Utils.timeLong(currentTime.difference(loginTime).inSeconds);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context)?.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${user.who}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "（${user.descr}）",
                        style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                      )
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  "${user.type}（${user.from}）",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                ),
                SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${timeLong.hours.toString().padLeft(2, "0")}:${timeLong.minutes.toString().padLeft(2, "0")}:${timeLong.seconds.toString().padLeft(2, "0")}",
                        style: TextStyle(fontSize: 14, color: AppTheme.of(context)?.primaryColor),
                      ),
                      TextSpan(
                        text: "（${user.time}）",
                        style: TextStyle(fontSize: 12, color: AppTheme.of(context)?.placeholderColor),
                      )
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          CupertinoButton(
            onPressed: user.running || user.canBeKicked == false
                ? null
                : () async {
                    bool? res = await KickConnectDialog.show(context: context, user: user);
                    if (res == true) {
                      setState(() {
                        user.running = true;
                      });
                      bool? result = await user.kickConnection();
                      if (result == true) {
                        getConnectedUsers();
                      }
                    }
                  },
            padding: EdgeInsets.zero,
            child: user.running
                ? LoadingWidget(
                    size: 24,
                  )
                : Image.asset(
                    "assets/icons/remove_circle_fill.png",
                    width: 24,
                    height: 24,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
