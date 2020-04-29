import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:translator/database.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Translator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<List<TranslationEntry>> newTranslationNotifier = new ValueNotifier([]);

  void _updateList(List<TranslationEntry> translations) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      newTranslationNotifier.value = translations;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            onChanged: (String value) async {
              var db = TranslationService();
              await db.openDatabaseOrCopyIfNotExists();
              var result = await db.search(value);
              _updateList(result);
            },
          ),
          Expanded(child: ResultList(newTranslationNotifier))
        ],
      ),
    );
  }
}



class ResultList extends StatelessWidget{
  final ValueListenable<List<TranslationEntry>> translationListener;

  ResultList(this.translationListener);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: this.translationListener.value.length,
      itemBuilder: (context, index)
      {
        return ListTile(
          title: Text(this.translationListener.value[index].source_representation),
          subtitle: Text(this.translationListener.value[index].bestTranslation().translation),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (ctxt) => new SecondScreen(this.translationListener.value[index])),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );}

}

_renderVariations(List<TranslationSenseEntry> variations){
  return Column(
    children: variations.map((e) =>
      Row(
        children: <Widget>[
          Expanded(child: Text(e.sense)),
          Expanded(child: Text(e.translation)),
          Divider(
            thickness: 1,
          )
        ],
      )
    ).toList(),
  );
}


class SecondScreen extends StatefulWidget {
  TranslationEntry translationEntry;


  SecondScreen(TranslationEntry translationEntry){
    this.translationEntry = translationEntry;
  }



  @override
  State<StatefulWidget> createState()=> _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen>{

  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.translationEntry.source_representation),
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: widget.translationEntry.variations.length,
                itemBuilder: (context, index){
                  return Card(
                    child: ListTile(
                      title: Text(widget.translationEntry.variations[index].translation),
                      subtitle: Text(widget.translationEntry.variations[index].sense),
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
