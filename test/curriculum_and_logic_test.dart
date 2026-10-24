import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:japanese_step_by_step/data/curriculum_repository.dart';
import 'package:japanese_step_by_step/services/handwriting_evaluator.dart';
import 'package:japanese_step_by_step/services/number_converter_service.dart';
import 'package:japanese_step_by_step/services/study_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CurriculumRepository repo;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    final jsonStr = File('assets/data/japanese_curriculum.json').readAsStringSync();
    repo = CurriculumRepository()..loadFromJsonString(jsonStr);
  });

  group('模組 A：五十音與發音規則完整性測試', () {
    test('包含 117 個假名項目（清音46、濁音20、半濁音5、拗音33、外來語13）', () {
      expect(repo.kanaList.length, 117);
      expect(repo.getKanaByCategory('seion').length, 46);
      expect(repo.getKanaByCategory('dakuon').length, 20);
      expect(repo.getKanaByCategory('handakuon').length, 5);
      expect(repo.getKanaByCategory('yoon').length, 33);
      expect(repo.getKanaByCategory('foreign_katakana').length, 13);
    });
  });

  group('模組 B & C：數字轉換器與 14 大量詞音變測試', () {
    test('NumberConverterService 正確處理 300, 600, 800, 3000, 8000, 3800 特殊音變', () {
      expect(NumberConverterService.convert(300).hiragana, 'さんびゃく');
      expect(NumberConverterService.convert(600).hiragana, 'ろっぴゃく');
      expect(NumberConverterService.convert(800).hiragana, 'はっぴゃく');
      expect(NumberConverterService.convert(3000).hiragana, 'さんぜん');
      expect(NumberConverterService.convert(8000).hiragana, 'はっせん');
      expect(NumberConverterService.convert(3800).hiragana, 'さんぜんはっぴゃく');
    });

    test('量詞包含 14 類別且會話包含 13 課', () {
      expect(repo.counters.length, 14);
      expect(repo.conversations.length, 13);
    });
  });

  group('模組 4：本機學習進度儲存讀取與 SRS 錯題邏輯測試', () {
    test('StudyProgressService 序列化與反序列化保持資料一致', () {
      final service = StudyProgressService();
      service.setDailyGoal(15);
      service.markKanaStatus('kana_seion_a', 'learned');
      service.recordHandwritingPractice('kana_seion_a');
      service.recordQuizSubmission(
        totalQuestions: 5,
        correctCount: 4,
        wrongQuestionIds: ['q01'],
        correctQuestionIds: ['q02', 'q03', 'q04', 'q05'],
      );

      final exported = service.toJsonMap();
      final restored = StudyProgressService()..loadFromJsonMap(exported);

      expect(restored.dailyGoalMinutes, 15);
      expect(restored.learnedKanaCount, 1);
      expect(restored.totalHandwritingCount, 1);
      expect(restored.averageQuizAccuracy, 80.0);
      expect(restored.mistakeBook.containsKey('q01'), true);
    });

    test('HandwritingEvaluator 評分與自我練習標示檢查', () {
      final res = HandwritingEvaluator.evaluate(
        strokes: [
          [const Offset(40, 60), const Offset(220, 60)],
          [const Offset(130, 30), const Offset(130, 230)],
          [const Offset(180, 100), const Offset(70, 210), const Offset(210, 200)],
        ],
        expectedStrokes: 3,
        canvasSize: const Size(280, 280),
      );
      expect(res.strokeCountMatched, true);
      expect(res.coverageScore > 0.5, true);
      expect(res.modeDisclosure.contains('自我練習'), true);
    });
  });
}
