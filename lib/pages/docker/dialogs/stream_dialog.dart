import 'dart:async';

import 'package:dsm_helper/utils/extensions/media_query_ext.dart';
import 'package:dsm_helper/utils/extensions/navigator_ext.dart';
import 'package:dsm_helper/widgets/button.dart';
import 'package:dsm_helper/widgets/glass/glass_dialog.dart';
import 'package:flutter/material.dart';

class StreamDialogContent extends StatefulWidget {
  final String title;
  final Stream<String> stream;
  final Function()? onFinish;
  const StreamDialogContent(this.title, this.stream, {this.onFinish, super.key});

  @override
  State<StreamDialogContent> createState() => _StreamDialogContentState();
}

class _StreamDialogContentState extends State<StreamDialogContent> {
  List<String> messages = [];
  late StreamSubscription listener;
  @override
  void initState() {
    listener = widget.stream.listen((event) {
      print(event);
      setState(() {
        messages.add(event);
      });
      if (event == '\n') {
        widget.onFinish?.call();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "${widget.title}",
        textAlign: TextAlign.center,
      ),
      content: Container(
        width: context.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: 300,
          minHeight: 100,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .where((element) => element.isNotEmpty)
                .map(
                  (e) => Text(
                    e,
                    style: TextStyle(fontSize: 12, height: 1.1),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () async {
                  context.pop();
                  listener.cancel();
                },
                color: Theme.of(context).disabledColor,
                child: Text(
                  "关闭",
                  style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StreamDialog {
  static Future<bool?> show(BuildContext context, {required String title, required Stream<String> stream, Function()? onFinish}) async {
    return await showGlassDialog(
      context: context,
      builder: (context) {
        return StreamDialogContent(title, stream, onFinish: onFinish);
      },
    );
  }
}
