import '../components/word.dart';

List<Word> createWordsByArticle(String article) {
  var words = article.split(" ");
  return words.map((word) => Word(word)).toList();
}
