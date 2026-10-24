import 'package:flutter/material.dart';
import '../data/curriculum_repository.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';

/// 整合頁面 12（8大題型測驗頁）、頁面 13（SRS 錯題複習頁）、頁面 14（收藏生字頁）與頁面 15（學習進度統計頁）
class QuizAndReviewScreen extends StatefulWidget {
  final CurriculumRepository repository;
  final StudyProgressService progress;
  final ISpeechService speechService;

  const QuizAndReviewScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speechService,
  });

  @override
  State<QuizAndReviewScreen> createState() => _QuizAndReviewScreenState();
}

class _QuizAndReviewScreenState extends State<QuizAndReviewScreen> {
  int _subTab = 0; // 0: 測驗頁, 1: 錯題複習頁, 2: 收藏生字頁, 3: 學習進度頁
  final Map<int, int> _selectedAnswers = {};
  bool _submitted = false;

  void _submitQuiz() {
    final questions = widget.repository.quizQuestions;
    if (_selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('還有 ${questions.length - _selectedAnswers.length} 題未作答！')),
      );
      return;
    }

    int correct = 0;
    final List<String> wrongIds = [];
    final List<String> correctIds = [];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      if (_selectedAnswers[i] == q.correctIndex) {
        correct++;
        correctIds.add(q.id);
      } else {
        wrongIds.add(q.id);
      }
    }

    widget.progress.recordQuizSubmission(
      totalQuestions: questions.length,
      correctCount: correct,
      wrongQuestionIds: wrongIds,
      correctQuestionIds: correctIds,
    );

    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('📝 8大題型測驗'),
                selected: _subTab == 0,
                onSelected: (_) => setState(() => _subTab = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('🔄 錯題本 (${widget.progress.mistakeBook.length})'),
                selected: _subTab == 1,
                onSelected: (_) => setState(() => _subTab = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('⭐ 收藏生字 (${widget.progress.favorites.length})'),
                selected: _subTab == 2,
                onSelected: (_) => setState(() => _subTab = 2),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('📊 學習統計'),
                selected: _subTab == 3,
                onSelected: (_) => setState(() => _subTab = 3),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _subTab,
            children: [
              _buildQuizTab(),
              _buildMistakeReviewTab(),
              _buildFavoritesTab(),
              _buildStatisticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  // 頁面 12：測驗頁
  Widget _buildQuizTab() {
    final questions = widget.repository.quizQuestions;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_submitted)
          Card(
            color: Colors.green.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '測驗完成！最新平均正確率：${widget.progress.averageQuizAccuracy.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAnswers.clear();
                        _submitted = false;
                      });
                    },
                    child: const Text('重新測驗'),
                  ),
                ],
              ),
            ),
          ),
        ...List.generate(questions.length, (qIdx) {
          final q = questions[qIdx];
          final chosen = _selectedAnswers[qIdx];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('第 ${qIdx + 1} 題 [${q.typeName}]',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo)),
                      IconButton(
                        onPressed: () =>
                            widget.speechService.speakJapanese(q.targetAudio),
                        icon: const Icon(Icons.volume_up),
                      ),
                    ],
                  ),
                  Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...List.generate(q.options.length, (optIdx) {
                    return RadioListTile<int>(
                      dense: true,
                      value: optIdx,
                      groupValue: chosen,
                      title: Text(q.options[optIdx]),
                      onChanged: _submitted
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() => _selectedAnswers[qIdx] = val);
                              }
                            },
                    );
                  }),
                  if (_submitted) ...[
                    const Divider(),
                    Text(
                      chosen == q.correctIndex
                          ? '✅ 答對了！${q.explanation}'
                          : '❌ 答錯了（正解：${q.options[q.correctIndex]}）。${q.explanation}\n建議重溫：${q.reviewCourse}',
                      style: TextStyle(
                        color: chosen == q.correctIndex
                            ? AppTheme.bambooGreen
                            : AppTheme.accentVermilion,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        if (!_submitted)
          ElevatedButton(
            onPressed: _submitQuiz,
            child: const Text('提交測驗並查看詳解'),
          ),
      ],
    );
  }

  // 頁面 13：錯題複習頁 (SRS)
  Widget _buildMistakeReviewTab() {
    final records = widget.progress.mistakeBook.values.toList()
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
    if (records.isEmpty) {
      return const Center(child: Text('🎉 目前錯題本是空的！答錯的測驗題目會自動記錄於此。'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final rec = records[index];
        final q = widget.repository.quizQuestions
            .firstWhere((item) => item.id == rec.questionId);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '累計答錯：${rec.wrongCount} 次 ｜ SRS 複習間隔：${rec.intervalDays} 天\n正解：${q.options[q.correctIndex]}\n詳解：${q.explanation}',
            ),
            trailing: IconButton(
              tooltip: '標記已熟練並移除',
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.bambooGreen),
              onPressed: () => widget.progress.removeMistake(rec.questionId),
            ),
          ),
        );
      },
    );
  }

  // 頁面 14：收藏生字頁
  Widget _buildFavoritesTab() {
    final favs = widget.progress.favorites;
    if (favs.isEmpty) {
      return const Center(child: Text('⭐ 尚未收藏任何生字或句子，可於日常會話頁點擊星號新增。'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favs.length,
      itemBuilder: (context, index) {
        final item = favs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text('${item.jp} (${item.reading})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.zh} ｜ 來源：${item.sourceLesson}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => widget.speechService.speakJapanese(item.jp),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => widget.progress.toggleFavorite(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 頁面 15：學習進度統計頁
  Widget _buildStatisticsTab() {
    final p = widget.progress;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('📊 真實本機學習統計（100% 來自實際操作紀錄）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('已掌握五十音數量'),
            trailing: Text('${p.learnedKanaCount} / ${widget.repository.kanaList.length}'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('需重溫五十音數量'),
            trailing: Text('${p.reviewKanaCount} 字'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('手寫描紅累計練習次數'),
            trailing: Text('${p.totalHandwritingCount} 次'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('測驗平均正確率'),
            trailing: Text('${p.averageQuizAccuracy.toStringAsFixed(1)}%'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('已完成課程數量'),
            trailing: Text('${p.completedLessonIds.length} 課'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('累計學習時間'),
            trailing: Text('${(p.totalStudySeconds / 60.0).toStringAsFixed(1)} 分鐘'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('連續學習日數'),
            trailing: Text('${p.streakDays} 天'),
          ),
        ),
      ],
    );
  }
}
