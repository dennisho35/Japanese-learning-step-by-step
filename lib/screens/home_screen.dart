import 'package:flutter/material.dart';
import '../data/curriculum_repository.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';
import 'kana_detail_screen.dart';
import 'pronunciation_practice_screen.dart';

/// 頁面 3：首頁及每日學習任務 ＆ 頁面 4：課程分類總覽入口
class HomeScreen extends StatelessWidget {
  final CurriculumRepository repository;
  final StudyProgressService progress;
  final ISpeechService speechService;
  final ValueChanged<int> onNavigateTab;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speechService,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final todayMinutes = (progress.todayStudySeconds / 60.0);
    final goalRatio = (todayMinutes / progress.dailyGoalMinutes).clamp(0.0, 1.0);
    final nextKana = repository.kanaList.firstWhere(
      (k) => progress.kanaStatus[k.id] != 'learned',
      orElse: () => repository.kanaList.first,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 每日學習計劃卡片
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryIndigo, Color(0xFF264B80)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎯 每日學習計劃',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '連續學習：${progress.streakDays} 天',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '今日進度：${todayMinutes.toStringAsFixed(1)} / ${progress.dailyGoalMinutes} 分鐘',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: goalRatio,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 30].map((min) {
                  final selected = progress.dailyGoalMinutes == min;
                  return ChoiceChip(
                    label: Text('$min 分鐘'),
                    selected: selected,
                    onSelected: (_) => progress.setDailyGoal(min),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 四大核心課程分類入口（首頁清楚顯示四個主要入口）
        const Text(
          '四大核心課程分類',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            _PortalCard(
              iconText: 'あア',
              title: '1. 五十音中心',
              subtitle: '已掌握 ${progress.learnedKanaCount}/${repository.kanaList.length}',
              accentColor: AppTheme.primaryIndigo,
              onTap: () => onNavigateTab(1),
            ),
            _PortalCard(
              iconText: '百杯',
              title: '2. 數字與量詞',
              subtitle: '6大數字 + 14類量詞',
              accentColor: AppTheme.amberGold,
              onTap: () => onNavigateTab(2),
            ),
            _PortalCard(
              iconText: '💬',
              title: '3. 日常會話',
              subtitle: '全 ${repository.conversations.length} 課旅遊情境',
              accentColor: AppTheme.bambooGreen,
              onTap: () => onNavigateTab(3),
            ),
            _PortalCard(
              iconText: '🎯',
              title: '4. 測驗與複習',
              subtitle: '正確率 ${progress.averageQuizAccuracy.toStringAsFixed(0)}%',
              accentColor: AppTheme.accentVermilion,
              onTap: () => onNavigateTab(4),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 今日推薦學習任務
        const Text(
          '📋 今日智慧推薦任務',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryIndigo,
              foregroundColor: Colors.white,
              child: Text(nextKana.hiragana),
            ),
            title: Text('五十音手寫與發音：${nextKana.hiragana} / ${nextKana.katakana} (${nextKana.romaji})'),
            subtitle: Text('${nextKana.row} ｜ ${nextKana.exampleWord}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => KanaDetailScreen(
                      kanaList: repository.kanaList,
                      initialIndex: repository.kanaList.indexOf(nextKana),
                      progress: progress,
                      speechService: speechService,
                    ),
                  ),
                );
              },
              child: const Text('立即練習'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.accentVermilion,
              foregroundColor: Colors.white,
              child: Icon(Icons.record_voice_over),
            ),
            title: const Text('五十音聽音辨字與發音跟讀訓練'),
            subtitle: const Text('正常速度 1.0x / 慢速 0.6x 發音與隨機聽力挑戰'),
            trailing: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PronunciationPracticeScreen(
                      kanaList: repository.kanaList,
                      speechService: speechService,
                    ),
                  ),
                );
              },
              child: const Text('進入訓練'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String iconText;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _PortalCard({
    required this.iconText,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  iconText,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
