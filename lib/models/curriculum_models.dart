/// 學習狀態枚舉
enum StudyStatus { unlearned, learned, reviewNeeded }

/// 假名學習資料模型（含平假名、片假名、筆順、記憶法與發音提示）
class KanaItem {
  final String id;
  final int order;
  final String category; // seion, dakuon, handakuon, yoon, foreign_katakana
  final String row;
  final String romaji;
  final String hiragana;
  final String katakana;
  final int hiraganaStrokes;
  final int katakanaStrokes;
  final String origin;
  final String mnemonic;
  final String pronunciationTip;
  final String exampleWord;
  final List<String> hiraganaDirections;
  final List<String> katakanaDirections;

  const KanaItem({
    required this.id,
    required this.order,
    required this.category,
    required this.row,
    required this.romaji,
    required this.hiragana,
    required this.katakana,
    required this.hiraganaStrokes,
    required this.katakanaStrokes,
    required this.origin,
    required this.mnemonic,
    required this.pronunciationTip,
    required this.exampleWord,
    required this.hiraganaDirections,
    required this.katakanaDirections,
  });

  factory KanaItem.fromJson(Map<String, dynamic> json) {
    return KanaItem(
      id: json['id'] as String,
      order: json['order'] as int,
      category: json['category'] as String,
      row: json['row'] as String,
      romaji: json['romaji'] as String,
      hiragana: json['hiragana'] as String,
      katakana: json['katakana'] as String,
      hiraganaStrokes: json['hiraganaStrokes'] as int,
      katakanaStrokes: json['katakanaStrokes'] as int,
      origin: json['origin'] as String,
      mnemonic: json['mnemonic'] as String,
      pronunciationTip: json['pronunciationTip'] as String,
      exampleWord: json['exampleWord'] as String,
      hiraganaDirections: List<String>.from(json['hiraganaDirections'] as List),
      katakanaDirections: List<String>.from(json['katakanaDirections'] as List),
    );
  }
}

/// 易混淆假名比較模型
class ConfusablePair {
  final String id;
  final String pair;
  final String script;
  final String keyDifference;
  final String explanation;
  final String quizTip;

  const ConfusablePair({
    required this.id,
    required this.pair,
    required this.script,
    required this.keyDifference,
    required this.explanation,
    required this.quizTip,
  });

  factory ConfusablePair.fromJson(Map<String, dynamic> json) {
    return ConfusablePair(
      id: json['id'] as String,
      pair: json['pair'] as String,
      script: json['script'] as String,
      keyDifference: json['keyDifference'] as String,
      explanation: json['explanation'] as String,
      quizTip: json['quizTip'] as String,
    );
  }
}

/// 促音與長音特殊發音規則模型
class SpecialPhoneticRule {
  final String id;
  final String title;
  final String summary;
  final String explanation;
  final List<Map<String, String>> examples;

  const SpecialPhoneticRule({
    required this.id,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.examples,
  });

  factory SpecialPhoneticRule.fromJson(Map<String, dynamic> json) {
    return SpecialPhoneticRule(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      explanation: json['explanation'] as String,
      examples: (json['examples'] as List)
          .map((e) => {
                'jp': (e as Map<String, dynamic>)['jp'] as String,
                'zh': e['zh'] as String,
              })
          .toList(),
    );
  }
}

/// 數字項目模型
class NumberItem {
  final String numStr;
  final String kanji;
  final String hiragana;
  final String romaji;
  final bool irregular;
  final String note;
  final String exampleJp;
  final String exampleZh;

  const NumberItem({
    required this.numStr,
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.irregular,
    required this.note,
    required this.exampleJp,
    required this.exampleZh,
  });

  factory NumberItem.fromJson(Map<String, dynamic> json) {
    return NumberItem(
      numStr: json['num'] as String,
      kanji: json['kanji'] as String,
      hiragana: json['hiragana'] as String,
      romaji: json['romaji'] as String,
      irregular: json['irregular'] as bool,
      note: json['note'] as String,
      exampleJp: json['exampleJp'] as String,
      exampleZh: json['exampleZh'] as String,
    );
  }
}

/// 數字分類單元模型
class NumberCategory {
  final String id;
  final String title;
  final String description;
  final List<NumberItem> items;

  const NumberCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  factory NumberCategory.fromJson(Map<String, dynamic> json) {
    return NumberCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      items: (json['items'] as List)
          .map((e) => NumberItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 量詞讀音變化列模型
class CounterRow {
  final String numberLabel;
  final String kanji;
  final String hiragana;
  final String romaji;
  final bool irregular;

  const CounterRow({
    required this.numberLabel,
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.irregular,
  });

  factory CounterRow.fromJson(Map<String, dynamic> json) {
    return CounterRow(
      numberLabel: json['n'] as String,
      kanji: json['k'] as String,
      hiragana: json['h'] as String,
      romaji: json['r'] as String,
      irregular: json['irr'] as bool,
    );
  }
}

/// 量詞分類模型
class CounterCategory {
  final String id;
  final String name;
  final String kanji;
  final String hiragana;
  final String romaji;
  final String meaning;
  final String appliesTo;
  final String phoneticRule;
  final String commonMistake;
  final List<CounterRow> countTable;
  final String scenario;
  final String exampleJp;
  final String exampleHira;
  final String exampleRomaji;
  final String exampleZh;

  const CounterCategory({
    required this.id,
    required this.name,
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.meaning,
    required this.appliesTo,
    required this.phoneticRule,
    required this.commonMistake,
    required this.countTable,
    required this.scenario,
    required this.exampleJp,
    required this.exampleHira,
    required this.exampleRomaji,
    required this.exampleZh,
  });

  factory CounterCategory.fromJson(Map<String, dynamic> json) {
    return CounterCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      kanji: json['kanji'] as String,
      hiragana: json['hiragana'] as String,
      romaji: json['romaji'] as String,
      meaning: json['meaning'] as String,
      appliesTo: json['appliesTo'] as String,
      phoneticRule: json['phoneticRule'] as String,
      commonMistake: json['commonMistake'] as String,
      countTable: (json['countTable'] as List)
          .map((e) => CounterRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      scenario: json['scenario'] as String,
      exampleJp: json['exampleJp'] as String,
      exampleHira: json['exampleHira'] as String,
      exampleRomaji: json['exampleRomaji'] as String,
      exampleZh: json['exampleZh'] as String,
    );
  }
}

/// 會話單句模型
class DialogueLine {
  final String id;
  final String speaker;
  final String jp;
  final String hira;
  final String romaji;
  final String zh;
  final String note;

  const DialogueLine({
    required this.id,
    required this.speaker,
    required this.jp,
    required this.hira,
    required this.romaji,
    required this.zh,
    required this.note,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      jp: json['jp'] as String,
      hira: json['hira'] as String,
      romaji: json['romaji'] as String,
      zh: json['zh'] as String,
      note: json['note'] as String,
    );
  }
}

/// 會話隨堂練習模型
class ConversationPractice {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ConversationPractice({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory ConversationPractice.fromJson(Map<String, dynamic> json) {
    return ConversationPractice(
      prompt: json['prompt'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }
}

/// 會話單元模型
class ConversationTopic {
  final String id;
  final int order;
  final String title;
  final String category;
  final String level;
  final String situation;
  final String grammarNote;
  final String formalVsInformal;
  final List<Map<String, String>> vocab;
  final List<DialogueLine> lines;
  final ConversationPractice practiceQuestion;

  const ConversationTopic({
    required this.id,
    required this.order,
    required this.title,
    required this.category,
    required this.level,
    required this.situation,
    required this.grammarNote,
    required this.formalVsInformal,
    required this.vocab,
    required this.lines,
    required this.practiceQuestion,
  });

  factory ConversationTopic.fromJson(Map<String, dynamic> json) {
    return ConversationTopic(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      situation: json['situation'] as String,
      grammarNote: json['grammarNote'] as String,
      formalVsInformal: json['formalVsInformal'] as String,
      vocab: (json['vocab'] as List)
          .map((e) => {
                'jp': (e as Map<String, dynamic>)['jp'] as String,
                'romaji': e['romaji'] as String,
                'zh': e['zh'] as String,
              })
          .toList(),
      lines: (json['lines'] as List)
          .map((e) => DialogueLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      practiceQuestion: ConversationPractice.fromJson(
          json['practiceQuestion'] as Map<String, dynamic>),
    );
  }
}

/// 測驗題目模型
class QuizQuestion {
  final String id;
  final String type;
  final String typeName;
  final String module;
  final String prompt;
  final String targetDisplay;
  final String targetAudio;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String reviewCourse;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.typeName,
    required this.module,
    required this.prompt,
    required this.targetDisplay,
    required this.targetAudio,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.reviewCourse,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      typeName: json['typeName'] as String,
      module: json['module'] as String,
      prompt: json['prompt'] as String,
      targetDisplay: json['targetDisplay'] as String,
      targetAudio: json['targetAudio'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      reviewCourse: json['reviewCourse'] as String,
    );
  }
}

/// 自訂收藏生字與句子模型
class FavoriteItem {
  final String id;
  final String jp;
  final String reading;
  final String romaji;
  final String zh;
  final String sourceLesson;

  const FavoriteItem({
    required this.id,
    required this.jp,
    required this.reading,
    required this.romaji,
    required this.zh,
    required this.sourceLesson,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jp': jp,
        'reading': reading,
        'romaji': romaji,
        'zh': zh,
        'sourceLesson': sourceLesson,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        id: json['id'] as String,
        jp: json['jp'] as String,
        reading: json['reading'] as String,
        romaji: json['romaji'] as String,
        zh: json['zh'] as String,
        sourceLesson: json['sourceLesson'] as String,
      );
}

/// 間隔重複 (Spaced Repetition System) 錯題紀錄模型
class MistakeRecord {
  final String questionId;
  int wrongCount;
  int consecutiveCorrect;
  int intervalDays;
  DateTime nextReviewAt;

  MistakeRecord({
    required this.questionId,
    this.wrongCount = 1,
    this.consecutiveCorrect = 0,
    this.intervalDays = 1,
    required this.nextReviewAt,
  });

  /// 根據使用者答題表現動態調整複習間隔 (SRS)
  void recordAttempt({required bool isCorrect, DateTime? now}) {
    final current = now ?? DateTime.now();
    if (isCorrect) {
      consecutiveCorrect += 1;
      if (consecutiveCorrect == 1) {
        intervalDays = 1;
      } else if (consecutiveCorrect == 2) {
        intervalDays = 3;
      } else if (consecutiveCorrect == 3) {
        intervalDays = 7;
      } else {
        intervalDays = intervalDays * 2;
      }
      nextReviewAt = current.add(Duration(days: intervalDays));
    } else {
      wrongCount += 1;
      consecutiveCorrect = 0;
      intervalDays = 1;
      nextReviewAt = current;
    }
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'wrongCount': wrongCount,
        'consecutiveCorrect': consecutiveCorrect,
        'intervalDays': intervalDays,
        'nextReviewAt': nextReviewAt.toIso8601String(),
      };

  factory MistakeRecord.fromJson(Map<String, dynamic> json) => MistakeRecord(
        questionId: json['questionId'] as String,
        wrongCount: json['wrongCount'] as int,
        consecutiveCorrect: json['consecutiveCorrect'] as int,
        intervalDays: json['intervalDays'] as int,
        nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      );
}
