import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tagger/tagger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? tags;
  TaggerController controller = TaggerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Tagger(
                  controller: controller,
                  onChanged: (s) {
                    if (tags == null) return;
                    tags = null;
                    setState(() {});
                  },
                ),
              ),
            ),
            if (tags != null)
              Container(
                color: Colors.blue,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Text(tags!, style: TextStyle(color: Colors.white)),
              ),
            TextButton(
              onPressed: () {
                // tags = controller.tags.join(", ");
                // setState(() {});
                controller.wholeText =
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
              },
              child: Text("Click here to show your tags"),
            ),
          ],
        ),
      ),
    );
  }
}
