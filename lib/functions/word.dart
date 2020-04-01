import '../models/word.dart';
import '../store/store.dart';

keepWordHasSameStat(Word word) {
  if (Store.wordStatus.containsKey(word.text.toLowerCase())) word.learned = Store.wordStatus[word.text.toLowerCase()].learned;
}
