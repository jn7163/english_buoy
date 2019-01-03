// 还没法使用
class Word {
  final String text;
  final int level;
  bool learned;

  Word(this.text, [this.level, this.learned = false]);
  Word.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        learned = json['learned'],
        level = json['level'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'learned': learned,
        'level': level,
      };
}
