// ignore: implementation_imports
import 'package:flutter/material.dart';
// ignore: implementation_imports

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Calculator"),
      ),
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 2,
              children: const [
                Card(
                  margin: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 20,
                  child: Text("Monthly SIP"),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 20,
                  child: Text("Lumpsum SIP"),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 20,
                  child: Text("Target SIP"),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 20,
                  child: Text("EMI Calculator"),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
