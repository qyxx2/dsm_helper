import 'dart:convert';

import 'package:dsm_helper/models/Syno/Core/Package/InstalledPackage.dart';
import 'package:dsm_helper/models/Syno/Core/Package/PackageServer.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/glass/glass_app_bar.dart';
import 'package:dsm_helper/widgets/glass/glass_scaffold.dart';
import 'package:dsm_helper/widgets/loading_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UninstallPackage extends StatefulWidget {
  final PackageItem package;
  UninstallPackage(this.package);
  @override
  _UninstallPackageState createState() => _UninstallPackageState();
}

class _UninstallPackageState extends State<UninstallPackage> {
  bool loading = true;
  bool uninstalling = false;
  List pageData = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      var res = await InstalledPackageItem.get(widget.package.id!);
      pageData = jsonDecode(Uri.decodeComponent(res.additional!.uninstallPages!));
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      Utils.toast("获取卸载信息失败");
    }
  }

  Widget _buildSubItem(item) {
    item['checked'] = item['checked'] ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          item['checked'] = !item['checked'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(item['desc']),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: item['checked']
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Color(0xffff9813),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(item) {
    List subItems = item['subitems'] ?? [];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['desc'] != null) Text(item['desc']),
            if (item['desc'] != null && subItems.isNotEmpty)
              SizedBox(
                height: 20,
              ),
            ...subItems.map(_buildSubItem).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildData(data) {
    List items = data['items'];
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['step_title'] != null) ...[
            Text(
              data['step_title'],
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: 20,
            ),
          ],
          ...items.map(_buildItem).toList(),
        ],
      ),
    );
  }

  uninstall() async {
    //获取额外参数
    Map extra = {};
    for (int i = 0; i < pageData.length; i++) {
      for (int j = 0; j < pageData[i]['items'].length; j++) {
        for (int k = 0; k < pageData[i]['items'][j]['subitems'].length; k++) {
          if (pageData[i]['items'][j]['subitems'][k]['checked']) {
            extra[pageData[i]['items'][j]['subitems'][i]['key']] = pageData[i]['items'][j]['subitems'][i]['checked'];
          }
        }
      }
    }
    setState(() {
      uninstalling = true;
    });
    bool? res = await widget.package.installedPackageItem!.uninstall(extra: extra);
    if (res == true) {
      Utils.toast("卸载成功");
      context.popUntil((route) => route.settings.name == 'package_center');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          "卸载${widget.package.dname}",
        ),
      ),
      body: loading
          ? Center(
              child: LoadingWidget(size: 30),
            )
          : ListView.builder(
              itemBuilder: (context, i) {
                return _buildData(pageData[i]);
              },
              itemCount: pageData.length,
            ),
      persistentFooterButtons: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Button(
                  onPressed: uninstall,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  color: AppTheme.of(context).errorColor,
                  borderRadius: 50,
                  loading: uninstalling,
                  child: Text("卸载"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
