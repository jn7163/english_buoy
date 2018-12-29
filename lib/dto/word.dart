// 还没法使用
class Word {
  final String text;
  final String label;
  final int level;
  final bool learned;

  Word(this.text, [this.label, this.level, this.learned = false]);
  Word.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        label = json['label'],
        learned = json['learned'],
        level = json['level'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'label': label,
        'learned': learned,
        'level': level,
      };
}
