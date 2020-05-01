import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:translator/languages.dart';

class TranslationService {
  List<DatabaseMetadata> translationDatabases = [];

  Future _doneInitialising;

  Future get initializationDone => _doneInitialising;

  Future<bool> get isNoDatabaseOfflineAvailable async {
    await _doneInitialising;
    return translationDatabases.isEmpty;
  }

  Future<void> rescan() {
    return _loadAllOfflineAvailableDatabases();
  }

  TranslationService() {
    _doneInitialising = _loadAllOfflineAvailableDatabases();
  }

  Future<void> _loadAllOfflineAvailableDatabases() async {
    List<DatabaseMetadata> availableDatabases = [];
    var databaseDirectory = await getApplicationSupportDirectory();
    var dirList = await databaseDirectory
        .list(recursive: false, followLinks: false)
        .toList();
    for (var dir in dirList) {
      var databaseObject = await extractDatabaseMetadata(dir.path);
      if (databaseObject != null) {
        availableDatabases.add(databaseObject);
      }
    }
    this.translationDatabases = availableDatabases;
  }

  Future<DatabaseMetadata> extractDatabaseMetadata(String path) async {
    try {
      if (p.extension(path) == ".sqlite3") {
        var basename = p.basenameWithoutExtension(path);
        var sourceLanguage =
            LanguageCodeHandler.parseLanguageCode(basename.split("_")[0]);
        var targetLanguage =
            LanguageCodeHandler.parseLanguageCode(basename.split("_")[1]);

        var database = await openDatabase(path);
        return DatabaseMetadata(
            source: sourceLanguage, target: targetLanguage, database: database);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<TranslationEntry>> searchInAll(String searchQuery) async {
    //wait for class to finish initialising
    await _doneInitialising;

    List<TranslationEntry> allTranslations = [];

    await Future.wait(translationDatabases.map((element) async {
      var translations = await searchInDatabase(searchQuery, element);
      allTranslations.addAll(translations);
    }));
    allTranslations.sort();
    return allTranslations;
  }

  Future<List<TranslationEntry>> searchInDatabase(
      String searchQuery, DatabaseMetadata databaseMetadata) async {
    List<Map> maps = await databaseMetadata.database
        .rawQuery("""SELECT * FROM translation WHERE lexentry IN (

SELECT lexentry  FROM translation WHERE written_rep LIKE ?  GROUP BY lexentry ORDER BY MAX(score) DESC LIMIT 20
  )""", ['%$searchQuery%']);

    Map<String, TranslationEntry> groupMap = {};
    for (var row in maps) {
      if (groupMap.containsKey(row['lexentry'])) {
        groupMap[row['lexentry']]
            .variations
            .add(TranslationSenseEntry.fromMap(row));
      } else {
        groupMap[row['lexentry']] = TranslationEntry.fromMap(row);
        groupMap[row['lexentry']]
            .variations
            .add(TranslationSenseEntry.fromMap(row));
      }
    }

    List<TranslationEntry> returnList = groupMap.values.toList();
    return returnList;
  }
}

class DatabaseMetadata {
  Language source;
  Language target;
  Database database;

  bool get isOpened => database.isOpen;

  DatabaseMetadata({this.source, this.target, this.database});
}

class TranslationEntry extends Comparable {
  String source_representation;

  Language sourceLanguage;
  Language targetLanguage;

  List<TranslationSenseEntry> variations = [];

  TranslationSenseEntry bestTranslation() {
    TranslationSenseEntry response = TranslationSenseEntry();
    for (var value in variations) {
      if (response.score < value.score) {
        response = value;
      }
    }
    return response;
  }

  num score() {
    return variations.fold(0.0, (value, element) => value + element.score);
  }

  TranslationEntry(source) {
    this.source_representation = source;
  }

  TranslationEntry.fromMap(Map<String, dynamic> map) {
    this.source_representation = map['written_rep'];
  }

  @override
  int compareTo(other) {
    TranslationEntry otherTyped = other;
    return (otherTyped.score() - score()).round();
  }
}

class TranslationSenseEntry {
  String sense = "";
  String translation = "";
  num score = 0;

  TranslationSenseEntry.fromMap(Map<String, dynamic> map) {
    this.sense = map['sense'];
    this.translation = map['trans_list'];
    this.score = map['score'];
  }

  TranslationSenseEntry() {}
}
