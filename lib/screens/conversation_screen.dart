import 'package:flutter/material.dart';
import '../data/curriculum_repository.dart';
import '../models/curriculum_models.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';

/// 頁面 11：日常生活會話情境頁（全 13 課多輪對話、慢速跟讀、生字收藏與隨堂測驗）
class ConversationScreen extends StatefulWidget {
  final CurriculumRepository repository;
  final StudyProgressService progress;
  final ISpeechService speechService;

  const ConversationScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speechService,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  int _selectedIndex = 0;
  String? _practiceFeedback;

  @override
  Widget build(BuildContext context) {
    final topics = widget.repository.conversations;
    final current = topics[_selectedIndex];
    final isCompleted = widget.progress.completedLessonIds.contains(current.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 課程選擇器與完成狀態按鈕
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedIndex,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: '選擇會話情境課程（共 13 課）',
                ),
                items: List.generate(topics.length, (idx) {
                  final t = topics[idx];
                  final done = widget.progress.completedLessonIds.contains(t.id);
                  return DropdownMenuItem(
                    value: idx,
                    child: Text('${t.title} ${done ? "✅" : ""}'),
                  );
                }),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedIndex = val;
                    _practiceFeedback = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => widget.progress.toggleLessonCompleted(current.id),
              icon: Icon(isCompleted ? Icons.check_circle : Icons.check_box_outline_blank),
              label: Text(isCompleted ? '已完成' : '標記完成'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 情境說明卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${current.category} ・ ${current.level}',
                    style: const TextStyle(color: AppTheme.accentVermilion, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('情境：${current.situation}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 多輪對話列表
        ...current.lines.map((line) {
          final favId = line.id;
          final isFav = widget.progress.isFavorite(favId);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(line.speaker,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo)),
                      Row(
                        children: [
                          IconButton(
                            tooltip: '正常發音',
                            onPressed: () => widget.speechService.speakJapanese(line.jp),
                            icon: const Icon(Icons.volume_up, size: 20),
                          ),
                          IconButton(
                            tooltip: '慢速 0.6x 跟讀',
                            onPressed: () =>
                                widget.speechService.speakJapanese(line.jp, slow: true),
                            icon: const Icon(Icons.slow_motion_video, size: 20),
                          ),
                          IconButton(
                            tooltip: '加入或移除收藏',
                            onPressed: () {
                              widget.progress.toggleFavorite(
                                FavoriteItem(
                                  id: favId,
                                  jp: line.jp,
                                  reading: line.hira,
                                  romaji: line.romaji,
                                  zh: line.zh,
                                  sourceLesson: current.title,
                                ),
                              );
                              setState(() {});
                            },
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: isFav ? AppTheme.amberGold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(line.jp,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('平假名：${line.hira}', style: const TextStyle(fontSize: 13)),
                  if (widget.progress.showRomaji)
                    Text('Romaji: ${line.romaji}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.accentVermilion)),
                  const SizedBox(height: 4),
                  Text('中文：${line.zh}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppTheme.bambooGreen)),
                  const SizedBox(height: 4),
                  Text('💡 解析：${line.note}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        }),

        // 文法與正式/非正式說法對比
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📐 文法重點與使用情境',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(current.grammarNote),
                const Divider(height: 18),
                const Text('🎩 正式與非正式說法差異',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(current.formalVsInformal),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 隨堂練習
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 隨堂情境練習',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(current.practiceQuestion.prompt),
                const SizedBox(height: 8),
                ...List.generate(current.practiceQuestion.options.length, (optIdx) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.touch_app_outlined, size: 18),
                    title: Text(current.practiceQuestion.options[optIdx]),
                    onTap: () {
                      final correct = optIdx == current.practiceQuestion.correctIndex;
                      setState(() {
                        _practiceFeedback = correct
                            ? '🎉 答對了！${current.practiceQuestion.explanation}'
                            : '❌ 再想一下！提示：${current.practiceQuestion.explanation}';
                      });
                    },
                  );
                }),
                if (_practiceFeedback != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_practiceFeedback!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
