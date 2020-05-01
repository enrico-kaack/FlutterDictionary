import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/datase_loader.dart';

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Download Language Set"),
      ),
      body: ChangeNotifierProvider<TranslationState>(
        create: (_) => TranslationState(),
        child: new Column(
          children: <Widget>[
            Text("Select what language combinations you want to download", style: TextStyle(height: 4, fontSize: 14)),
            Expanded(child: LanguageList())
          ],
        ),
      ),
    );
  }
}

class LanguageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TranslationState>(context);

    return ListView.builder(
        itemCount: state.getTranslations.length,
        itemBuilder: (context, index) {
          return new TargetItem(
            availableTranslation: state.getTranslations[index],
          );
        });
  }
}

class TargetItem extends StatefulWidget {
  AvailableTranslation availableTranslation;

  @override
  State<StatefulWidget> createState() => _TargetItemState();

  TargetItem({this.availableTranslation});
}

class _TargetItemState extends State<TargetItem> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TranslationState>(context);
    return new ExpansionTile(
      title: Text(this.widget.availableTranslation.source),
      children: <Widget>[
        new Column(
          children: _buildExpandableList(
              this.widget.availableTranslation.targets, state),
        )
      ],
    );
  }
}

_buildExpandableList(List<AvaiableTarget> targets, TranslationState state) {
  List<Widget> columnContent = [];
  for (AvaiableTarget target in targets) {
    columnContent.add(new ListTile(
      title: Text(target.target),
      leading: Icon(Icons.subdirectory_arrow_right),
      trailing: FutureBuilder<Container>(
        future: _iconForLoadingState(target),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return Container(
              width: 0,
              height: 0,
            );
          }
        },
      ),
      //trailing: _iconForLoadingState(target),
      onTap: () async {
        print("Downloading");
        target.loadingState = LoadingState.DOWNLOADING;
        state.notifyListeners();
        await target.downloadDatabase();
        state.notifyListeners();
        print("Done");
      },
    ));
  }
  return columnContent;
}

Future<Container> _iconForLoadingState(AvaiableTarget target) async {
  if (await target.isDownloaded()) return Container(child: Icon(Icons.check));

  switch (target.loadingState) {
    case LoadingState.NOT_FOUND:
      return Container(child: Icon(Icons.file_download));
    case LoadingState.LOADED:
      return Container(child: Icon(Icons.check));
    case LoadingState.DOWNLOADING:
      return Container(child: CircularProgressIndicator());
  }
}
