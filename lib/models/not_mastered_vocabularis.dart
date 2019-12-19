import 'package:flutter/material.dart';
import './word.dart';

class NotMasteredVocabularies with ChangeNotifier {
  // 未掌握单词与其对应所处 sentences widget 的 key 的 map
  var notMasteredVocabularies = Map();
  set(Word word , Key key){
    notMasteredVocabularies[word.text]={"key":key, "word":word};
    notifyListeners();
  }
  unset(String word){
    notMasteredVocabularies.remove(word);
    notifyListeners();
  }
  clear() {
    notMasteredVocabularies=Map();
    notifyListeners();
  }
}