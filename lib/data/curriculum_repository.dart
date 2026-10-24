import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_models.dart';

/// 獨立教材資料存取層（將所有五十音、數字、量詞、會話與測驗題庫與 UI 程式碼分離）
class CurriculumRepository {
  List<KanaItem> kanaList = [];
  List<ConfusablePair> confusablePairs = [];
  List<SpecialPhoneticRule> specialPhonetics = [];
  List<NumberCategory> numberCategories = [];
  List<CounterCategory> counters = [];
  List<ConversationTopic> conversations = [];
  List<QuizQuestion> quizQuestions = [];

  bool isLoaded = false;

  Future<void> loadFromAssets() async {
    if (isLoaded) return;
    final jsonString =
        await rootBundle.loadString('assets/data/japanese_curriculum.json');
    loadFromJsonString(jsonString);
  }

  void loadFromJsonString(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    kanaList = (map['kana'] as List)
        .map((e) => KanaItem.fromJson(e as Map<String, dynamic>))
        .toList();
    confusablePairs = (map['confusableKana'] as List)
        .map((e) => ConfusablePair.fromJson(e as Map<String, dynamic>))
        .toList();
    specialPhonetics = (map['specialPhonetics'] as List)
        .map((e) => SpecialPhoneticRule.fromJson(e as Map<String, dynamic>))
        .toList();
    numberCategories = (map['numbersCategories'] as List)
        .map((e) => NumberCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    counters = (map['counters'] as List)
        .map((e) => CounterCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    conversations = (map['conversations'] as List)
        .map((e) => ConversationTopic.fromJson(e as Map<String, dynamic>))
        .toList();
    quizQuestions = (map['quizQuestions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    isLoaded = true;
  }

  List<KanaItem> getKanaByCategory(String category) {
    return kanaList.where((k) => k.category == category).toList();
  }
}
