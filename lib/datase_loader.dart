import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http2;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;


class TranslationState with ChangeNotifier {
  TranslationState() {
    fetchDate();
  }

  List<AvailableTranslation> _translations = [];

  List<AvailableTranslation> get getTranslations => _translations;

  void setTranslations(List<AvailableTranslation> translations) {
    _translations = translations;
    notifyListeners();
  }

  void fetchDate() async {
    setTranslations(await loadAvailableTranslations());
  }
}

class AvailableTranslation {
  String source;
  List<AvaiableTarget> targets = [];

  AvailableTranslation({this.source, this.targets});

  factory AvailableTranslation.fromJson(Map<String, dynamic> json) {
    var targetList = json["targets"] as List;
    var source = json['source'] as String;
    List<AvaiableTarget> availableTagetsList =
        targetList.map((i) => AvaiableTarget.fromJson(i, source)).toList();

    return AvailableTranslation(source: source, targets: availableTagetsList);
  }
}

class AvaiableTarget {
  String source;
  String target;
  String uri;

  String get key => '${source}_$target';

  LoadingState loadingState = LoadingState.NOT_FOUND;

  Future<bool> isDownloaded() async {
    var suppoertDirectory = await getApplicationSupportDirectory();
    return File(suppoertDirectory.path + "/" + key + ".sqlite3").exists();
  }

  AvaiableTarget({this.source, this.target, this.uri});

  factory AvaiableTarget.fromJson(Map<String, dynamic> json, String source) {
    return AvaiableTarget(
        source: source,
        target: json['target'] as String,
        uri: json['uri'] as String);
  }

  Future<void> downloadDatabase() async {
    await createApplicationDirectory();
    loadingState = LoadingState.DOWNLOADING;
    HttpClient client = new HttpClient();
    await client.getUrl(Uri.parse(uri)).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      await getApplicationSupportDirectory().then((dir) async {
        await response
            .pipe(
                new File('${dir.path}/${source}_${target}.sqlite3').openWrite())
            .then((value) async {
          loadingState = LoadingState.LOADED;
        });
      });
    });
  }
}

enum LoadingState { NOT_FOUND, DOWNLOADING, LOADED }

List<AvailableTranslation> _parseAvailableTranslations(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<AvailableTranslation>((json) => AvailableTranslation.fromJson(json))
      .toList();
}

Future<List<AvailableTranslation>> loadAvailableTranslations() async {
  /*final response = await http2.Client()
      //.get("http://10.0.2.2:8080/available_translations.json");
      .get("http://localhost:8080/available_translations.json");
*/
  var availableTranslationsString = await rootBundle.loadString('assets/available_translations.json');
  return compute(_parseAvailableTranslations, availableTranslationsString);
}


void createApplicationDirectory() async {
  var dir = await getApplicationSupportDirectory();
  dir.create(recursive: true);
}