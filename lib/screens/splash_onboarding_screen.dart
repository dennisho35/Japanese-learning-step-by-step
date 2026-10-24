import 'package:flutter/material.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';

/// 頁面 1：啟動畫面 (Splash Screen) 與 頁面 2：新手導覽頁 (Onboarding Screen)
class OnboardingScreen extends StatefulWidget {
  final StudyProgressService progressService;
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.progressService,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedGoal = 10;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.progressService.dailyGoalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.accentVermilion,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'あ',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '日語一步通 Japanese Step-by-Step',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '專為零基礎繁體中文學習者設計，從五十音、發音、數字量詞到日本旅遊日常會話，循序漸進掌握溝通能力。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.gesture, color: AppTheme.primaryIndigo),
                      title: Text('步驟 1：五十音與觸控手寫描紅'),
                      subtitle: Text('包含清音、濁音、半濁音、拗音、外來語片假名與筆順方向指引。'),
                    ),
                    ListTile(
                      leading: Icon(Icons.onetwothree, color: AppTheme.primaryIndigo),
                      title: Text('步驟 2：數字音變與 14 大情境量詞'),
                      subtitle: Text('徹底掌握 300/600/800 音變，以及ひとり、さんばい等生活量詞。'),
                    ),
                    ListTile(
                      leading: Icon(Icons.forum_outlined, color: AppTheme.primaryIndigo),
                      title: Text('步驟 3：13 課旅遊情境會話與慢速跟讀'),
                      subtitle: Text('點餐、問路、免稅購物、飯店入住與緊急求助一應俱全。'),
                    ),
                    ListTile(
                      leading: Icon(Icons.psychology_outlined, color: AppTheme.primaryIndigo),
                      title: Text('步驟 4：8 大題型測驗與 SRS 間隔重複錯題本'),
                      subtitle: Text('所有學習進度儲存在本機，免註冊即可離線學習。'),
                    ),
                  ],
                ),
              ),
              const Text(
                '請選擇您的每日學習目標時間：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 30].map((min) {
                  return ChoiceChip(
                    label: Text('每日 $min 分鐘'),
                    selected: _selectedGoal == min,
                    onSelected: (_) => setState(() => _selectedGoal = min),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.progressService.setDailyGoal(_selectedGoal);
                  widget.progressService.completeOnboarding();
                  widget.onFinish();
                },
                child: const Text('開始學習日語！'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
