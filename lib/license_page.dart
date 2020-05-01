import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LicensePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("License"),
      ),
      body: Column(
        children: <Widget>[
          Container(
              child: Text("""
This apps translation data is based on the Wiktionary Project (https://www.wiktionary.org/). 
All data is licensed under the Creative Commons Attribution-Share-Alike 3.0 License (https://creativecommons.org/licenses/by-sa/3.0/).
The databases were downloaded from The WikDict Project (https://www.wikdict.com/page/about), which extracted the data from Wiktionary by the DBmary project(https://kaiko.getalp.org/about-dbnary).""",
                  style:
                      TextStyle(color: ThemeData().textTheme.bodyText1.color)))
        ],
      ),
    );
  }
}
