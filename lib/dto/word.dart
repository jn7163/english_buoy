// 还没法使用
class Word {
  final String text;
  final String label;
  final int level;

  Word(this.text, this.label, this.level);

  Word.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        label = json['lable'],
        level = json['level'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'label': label,
        'level': level,
      };
}
