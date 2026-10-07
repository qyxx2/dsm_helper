import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:dsm_helper/apis/api.dart';
import 'package:dsm_helper/apis/dsm_api/dsm_api.dart';
import 'package:dsm_helper/database/table_extension.dart';
import 'package:dsm_helper/database/tables.dart';
import 'package:dsm_helper/models/Syno/Api/auth.dart';
import 'package:dsm_helper/models/Syno/SDS/Session/SessionData.dart';
import 'package:dsm_helper/new_ui/session/active_context_coordinator.dart';
import 'package:dsm_helper/new_ui/session/active_context_mapping.dart';
import 'package:dsm_helper/new_ui/shell/new_ui_shell.dart';
import 'package:dsm_helper/pages/login/dialogs/otp_code_dialog.dart';
import 'package:dsm_helper/pages/server/select_server.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/utils/db_utils.dart';
import 'package:dsm_helper/utils/extensions/media_query_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/utils/utils.dart' hide Api;
import 'package:dsm_helper/widgets/button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  const Login(this.server, {super.key});
  final Server server;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String account = '';
  String password = '';
  bool rememberDevice = true;
  bool loading = false;
  bool showPassword = false;
  bool isDefault = false;
  String cipherStr = "";
  SessionDataModel? sessionDataModel;

  @override
  void initState() {
    getSessionData();
    super.initState();
  }

  getSessionData() async {
    var res = await Api.dsm.get("/webapi/query.cgi", parameters: {
      "api": "SYNO.Core.Desktop.SessionData",
      "version": 1,
      "method": "getjs",
      "SynoToken": "",
    });
    final regex = RegExp(r'SYNO\.SDS\.Session\s*=\s*([\s\S]*?);');

    try {
      final match = regex.firstMatch(res);
      final sessionDataString = match?.group(1);
      setState(() {
        sessionDataModel = SessionDataModel.fromJson(jsonDecode(sessionDataString!));
      });
      // 将hostname和backgroundImage存入Servers
      DbUtils.db.updateServer(
        widget.server.copyWith(
          backgroundImage: drift.Value(sessionDataModel?.loginBackgroundEnable == true ? "${widget.server.url}/webman/login_background${sessionDataModel?.loginBackgroundExt}" : null),
          hostname: drift.Value(sessionDataModel?.hostname),
        ),
      );
    } catch (e) {}
  }

  login({String? otpCode}) async {
    setState(() {
      loading = true;
    });

    try {
      Auth authModel = await Auth.login(account: account, password: password, optCode: otpCode);
      setState(() {
        loading = false;
      });
      final savedAccount =
          await DbUtils.db.into(DbUtils.db.accounts).insertReturning(
                AccountsCompanion.insert(
                  account: account,
                  serverId: widget.server.id,
                  password: password,
                  remark: "",
                  createTime: DateTime.now().secondsSinceEpoch,
                  lastLoginTime: DateTime.now().secondsSinceEpoch,
                  isDefault: isDefault,
                  deviceId: authModel.deviceId!,
                  ikMessage: authModel.ikMessage!,
                  sid: authModel.sid!,
                  synoToken: authModel.synotoken!,
                ),
              );
      final target =
          ActiveContextMapping.savedAccount(widget.server, savedAccount);
      final result = await ActiveContextCoordinator().restore(target);
      if (!mounted) {
        return;
      }
      if (result.status == ActiveContextStatus.reauthenticationRequired) {
        setState(() {
          loading = false;
        });
        Utils.toast("登录状态无效，请重新登录");
        return;
      }
      context.push(
        NewUiShell(contextLabel: target.label),
        replace: true,
      );
    } on DsmException catch (e) {
      if (e.code == 400) {
        setState(() {
          loading = false;
        });
        Utils.toast("用户名/密码有误");
      } else if ([403, 404, 414].contains(e.code)) {
        setState(() {
          loading = false;
        });
        String message = e.code == 403
            ? "您已开启双重验证，请输入验证码"
            : e.code == 404
                ? "错误的验证码。请再试一次"
                : "为确认这是您本人登录，系统已将验证码发送到${e.source?['errors']['email']}，请查看您的邮箱，并在5分钟内输入验证码";
        String? code = await OtpCodeDialog.show(context, message: message);
        if (code != null) {
          login(otpCode: code);
        }
      } else {
        setState(() {
          loading = false;
        });
        Utils.toast("登录失败，代码：${e.code}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).cardColor,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Container(
              height: context.height,
            ),
            if (sessionDataModel?.loginBackgroundEnable == true)
              ExtendedImage.network(
                "${widget.server.url}/webman/login_background${sessionDataModel?.loginBackgroundExt}",
                cache: false,
                height: context.width / 16 * 9,
                width: context.width,
                fit: BoxFit.cover,
              )
            else
              Image.asset(
                "assets/default_login_background.jpg",
                height: context.width / 16 * 9,
                width: context.width,
                fit: BoxFit.cover,
              ),
            if ((sessionDataModel?.loginLogoEnable ?? false) && (sessionDataModel?.loginLogoExt != null))
              Positioned(
                left: 20,
                top: context.padding.top - 10,
                child: ExtendedImage.network(
                  "${widget.server.url}/webman/login_logo${sessionDataModel?.loginLogoExt}",
                  cache: false,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            if (sessionDataModel?.loginWelcomeTitle != null || sessionDataModel?.loginWelcomeMsg != null)
              Positioned(
                left: 20,
                top: context.width / 16 * 9 / 2 - 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sessionDataModel?.loginWelcomeTitle != null)
                      Text(
                        "${sessionDataModel?.loginWelcomeTitle}",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                    if (sessionDataModel?.loginWelcomeMsg != null)
                      Text(
                        "${sessionDataModel?.loginWelcomeMsg}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                  ],
                ),
              ),
            if (sessionDataModel?.loginFooterMsg != null && sessionDataModel?.loginFooterEnableHtml == false)
              Positioned(
                top: context.width / 16 * 9 - 70,
                child: SizedBox(
                  width: context.width,
                  child: Center(
                    child: Text(
                      "${sessionDataModel?.loginFooterMsg}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (ModalRoute.of(context)?.canPop ?? false) {
                          context.pop();
                        } else {
                          context.push(SelectServer(), replace: true);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                          Text("选择服务器"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      sessionDataModel?.hostname ?? '账号登录',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${widget.server.url}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: (v) => setState(() {
                        account = v;
                      }),
                      controller: _accountController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: "账号",
                        suffixIcon: account.isNotEmpty
                            ? CupertinoButton(
                                child: Image.asset(
                                  "assets/icons/close_circle.png",
                                  width: 20,
                                ),
                                padding: EdgeInsets.all(5),
                                onPressed: () {
                                  setState(() {
                                    account = '';
                                    _accountController.clear();
                                  });
                                },
                              )
                            : null,
                        // suffixIconColor: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _passwordController,
                      onChanged: (v) => setState(() {
                        password = v;
                      }),
                      obscureText: !showPassword,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: "密码",
                        suffixIcon: password.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    child: Image.asset(
                                      "assets/icons/eye${showPassword ? '' : '_slash'}.png",
                                      width: 20,
                                    ),
                                    padding: EdgeInsets.all(5),
                                    minSize: 0,
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  CupertinoButton(
                                    child: Image.asset(
                                      "assets/icons/close_circle.png",
                                      width: 20,
                                    ),
                                    padding: EdgeInsets.all(5),
                                    onPressed: () {
                                      _passwordController.clear();
                                      setState(() {
                                        password = '';
                                      });
                                    },
                                  ),
                                ],
                              )
                            : null,
                        // suffixIconColor: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Button(
                          width: 150,
                          child: Text(
                            "设为默认",
                            strutStyle: StrutStyle(
                              forceStrutHeight: true,
                            ),
                          ),
                          color: isDefault ? AppTheme.of(context).successColor : AppTheme.of(context).placeholderColor,
                          fill: isDefault,
                          borderColor: isDefault ? AppTheme.of(context).successColor : AppTheme.of(context).placeholderColor,
                          icon: Icon(
                            Icons.check,
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              isDefault = !isDefault;
                            });
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Button(
                            child: Text("登录"),
                            loading: loading,
                            onPressed: login,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
