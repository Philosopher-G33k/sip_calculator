import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "GENERAL",
                style: TextStyle(color: Colors.black26),
              ),
            ),
            Spacer(),
          ],
        ),
        const Divider(),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Number Format"),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
              child: Text(
                "123456",
                style: TextStyle(color: Colors.black26),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
