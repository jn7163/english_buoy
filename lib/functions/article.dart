// check is word need learn
import "../models/word.dart";

// no need learn and no need add blank
final noNeedBlank = <String>[
  "'ll",
  "'s",
  "'re",
  "'m",
  "'d",
  "'ve",
  "n't",
  ".",
  "!",
  ",",
  ":",
  "?",
  "…",
];
// 字符串是否包含字母
bool hasLetter(String str) {
  RegExp regHasLetter = new RegExp(r"[a-zA-Z]+");
  return regHasLetter.hasMatch(str);
}

bool consecutiveLetter(String str) {
  RegExp regHasLetter = new RegExp(r"[a-zA-Z]{2}");
  return regHasLetter.hasMatch(str);
}

bool isNeedLearn(Word word) {
  // 无需前置空格的单词
  if (noNeedBlank.contains(word.text.toLowerCase())) return false;
  // 只有一个字符
  //if (word.text.length == 1) return false;
  // 没有连续的字母
  if (!consecutiveLetter(word.text)) return false;
  return true;
}
