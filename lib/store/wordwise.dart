import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Store {
  static const PATH = "assets/db/wordwise.db";
  static Database database;
  static Map wordwiseMap = Map<String, String>();
  static Map noWordwiseMap = Map<String, String>();
}

Future openDB() async {
// Construct the path to the app's writable database file:
  var dbDir = await getDatabasesPath();
  var dbPath = join(dbDir, "app.db");

// Delete any existing database:
  await deleteDatabase(dbPath);

// Create the writable database file from the bundled demo database file:
  ByteData data = await rootBundle.load(Store.PATH);
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(dbPath).writeAsBytes(bytes);

  Store.database = await openDatabase(dbPath, readOnly: true);
}

Future<String> getDefinitionByWord(String word) async {
  //get from https://github.com/xnohat/wordwise-dict
  if (Store.noWordwiseMap[word] == 'no') return null;
  if (Store.wordwiseMap[word] != null) return Store.wordwiseMap[word];
  String definition;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  if (Store.database == null) return null;
  List<Map> list = await Store.database.rawQuery('''
    SELECT short_def 
    FROM senses s, lemmas l
    where s.display_lemma_id=l.id
    and s.sense_number=1
    and lemma='$word' LIMIT 1
  ''');
  if (list != null) {
    if (list.length > 0) {
      definition = stringToBase64.decode(list[0]["short_def"]);
      Store.wordwiseMap[word] = definition;
    } else
      Store.noWordwiseMap[word] = 'no';
  } else {
    Store.noWordwiseMap[word] = 'no';
  }
  return definition;
}

