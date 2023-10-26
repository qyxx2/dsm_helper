import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/glass/glass_dialog.dart';
import 'package:flutter/material.dart';

class OtpCodeDialog {
  static Future<String?> show(BuildContext context, {required String message}) async {
    String otpCode = '';
    return await showGlassDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "验证您的身份",
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (v) {
                  otpCode = v;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "输入验证码",
                  // suffixIconColor: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Button(
                    child: Text("取消"),
                    onPressed: () {
                      context.pop();
                    },
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Button(
                    child: Text("登录"),
                    onPressed: () {
                      print(otpCode);
                      context.pop(otpCode);
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
