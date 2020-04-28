import 'dart:io';

import 'package:edit_distance/edit_distance.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class TranslationService {
  Database db;



  Future<void> openDatabaseOrCopyIfNotExists() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "de-en.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "de-en.sqlite3"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }
    // open the database
    db = await openDatabase(path, readOnly: true);
  }


/*
SELECT * FROM translation WHERE lexentry IN (

SELECT lexentry  FROM translation WHERE written_rep LIKE '%Haus%'  GROUP BY lexentry ORDER BY MAX(score) DESC LIMIT 20
  )
 */


  Future<List<TranslationEntry>> search(String searchQuery) async {
    List<Map> maps = await db.rawQuery("""SELECT * FROM translation WHERE lexentry IN (

SELECT lexentry  FROM translation WHERE written_rep LIKE ?  GROUP BY lexentry ORDER BY MAX(score) DESC LIMIT 20
  )""", ['%$searchQuery%']);

    Map<String, TranslationEntry> groupMap = {};
    for (var row in maps) {
      if (groupMap.containsKey(row['lexentry'])){
        groupMap[row['lexentry']].variations.add(TranslationSenseEntry.fromMap(row));
      }else {
        groupMap[row['lexentry']] = TranslationEntry.fromMap(row);
        groupMap[row['lexentry']].variations.add(TranslationSenseEntry.fromMap(row));
      }
    }

    /*List<Map> maps = await db.query(
        "simple_translation",
    columns: ['Written_rep', 'Trans_list', 'max_score'],
    where: 'Written_rep LIKE ?',
    whereArgs: ['%$searchQuery%'],
    orderBy: 'max_score DESC',
    limit: 20);*/

    List<TranslationEntry> returnList = groupMap.values.toList();
    returnList.sort();
    return returnList;
  }
}

class TranslationEntry extends Comparable{

  String source_representation;

  List<TranslationSenseEntry> variations = [];

  TranslationSenseEntry bestTranslation() {
    TranslationSenseEntry response = TranslationSenseEntry();
    for (var value in variations) {
      if (response.score < value.score){
        response = value;
      }
    }
    return response;
  }

  num score() {
    return variations.fold(0.0, (value, element)  => value + element.score );
  }

  TranslationEntry(source){
    this.source_representation = source;
  }



  TranslationEntry.fromMap(Map<String, dynamic> map){
    this.source_representation = map['written_rep'];

  }

  @override
  int compareTo(other) {
    TranslationEntry otherTyped = other;
    return (otherTyped.score() - score()).round();
  }




}
class TranslationSenseEntry{
  String sense = "";
  String translation = "";
  num score = 0;

  TranslationSenseEntry.fromMap(Map<String, dynamic> map) {
    this.sense = map['sense'];
    this.translation = map['trans_list'];
    this.score = map['score'];

  }
  TranslationSenseEntry(){}



}