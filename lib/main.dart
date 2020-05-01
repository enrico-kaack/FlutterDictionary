import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:translator/translation_service.dart';
import 'package:translator/download_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<List<TranslationEntry>> newTranslationNotifier =
      new ValueNotifier([]);
  var db = TranslationService();

  void _updateList(List<TranslationEntry> translations) {
    setState(() {
      newTranslationNotifier.value = translations;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Translator"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (ctxt) => new DownloadPage())).then((value) => this.db = TranslationService());
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(5.0),
            child: TextField(
              onChanged: (String value) async {
                var result = await db.searchInAll(value);
                _updateList(result);
              },
            ),
          ),
          Divider(),
          Expanded(child: ResultList(newTranslationNotifier))
        ],
      ),
    );
  }
}

class ResultList extends StatelessWidget {
  final ValueListenable<List<TranslationEntry>> translationListener;

  ResultList(this.translationListener);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: this.translationListener.value.length,
      itemBuilder: (context, index) {
        return ListTile(
          title:
              Text(this.translationListener.value[index].source_representation),
          subtitle: Text(this
              .translationListener
              .value[index]
              .bestTranslation()
              .translation),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (ctxt) =>
                      new SecondScreen(this.translationListener.value[index])),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }
}

_renderVariations(List<TranslationSenseEntry> variations) {
  return Column(
    children: variations
        .map((e) => Row(
              children: <Widget>[
                Expanded(child: Text(e.sense)),
                Expanded(child: Text(e.translation)),
                Divider(
                  thickness: 1,
                ),
              ],
            ))
        .toList(),
  );
}

class SecondScreen extends StatefulWidget {
  TranslationEntry translationEntry;

  SecondScreen(TranslationEntry translationEntry) {
    this.translationEntry = translationEntry;
  }


  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.translationEntry.source_representation),
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.translationEntry.variations.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        widget.translationEntry.variations[index].translation),
                    subtitle:
                        Text(widget.translationEntry.variations[index].sense),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
