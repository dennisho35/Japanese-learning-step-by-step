import 'package:flutter/material.dart';
import 'data/curriculum_repository.dart';
import 'screens/conversation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/kana_overview_screen.dart';
import 'screens/numbers_and_counters_screen.dart';
import 'screens/quiz_and_review_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_onboarding_screen.dart';
import 'services/speech_service.dart';
import 'services/study_progress_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progressService = StudyProgressService();
  await progressService.loadFromLocal();
  final repository = CurriculumRepository();
  await repository.loadFromAssets();

  runApp(
    JapaneseStepByStepApp(
      repository: repository,
      progressService: progressService,
      speechService: NativeSpeechService(),
    ),
  );
}

class JapaneseStepByStepApp extends StatefulWidget {
  final CurriculumRepository repository;
  final StudyProgressService progressService;
  final ISpeechService speechService;

  const JapaneseStepByStepApp({
    super.key,
    required this.repository,
    required this.progressService,
    required this.speechService,
  });

  @override
  State<JapaneseStepByStepApp> createState() => _JapaneseStepByStepAppState();
}

class _JapaneseStepByStepAppState extends State<JapaneseStepByStepApp> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.progressService,
      builder: (context, _) {
        final p = widget.progressService;
        return MaterialApp(
          title: '日語一步通 Japanese Step-by-Step',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(p.fontScale),
          darkTheme: AppTheme.darkTheme(p.fontScale),
          themeMode: p.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(p.fontScale),
              ),
              child: child!,
            );
          },
          home: !p.hasCompletedOnboarding
              ? OnboardingScreen(
                  progressService: p,
                  onFinish: () => setState(() {}),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: const Text('日語一步通 Japanese Step-by-Step'),
                    actions: [
                      TextButton(
                        onPressed: p.toggleRomajiVisibility,
                        child: Text(
                          p.showRomaji ? '拼音：顯示' : '拼音：隱藏',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        tooltip: '切換深色／淺色模式',
                        icon: Icon(p.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                        onPressed: p.toggleDarkMode,
                      ),
                      IconButton(
                        tooltip: '開啟設定頁',
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(progress: p),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  body: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      HomeScreen(
                        repository: widget.repository,
                        progress: p,
                        speechService: widget.speechService,
                        onNavigateTab: (idx) => setState(() => _currentTabIndex = idx),
                      ),
                      KanaOverviewScreen(
                        repository: widget.repository,
                        progress: p,
                        speechService: widget.speechService,
                      ),
                      NumbersAndCountersScreen(
                        repository: widget.repository,
                        progress: p,
                        speechService: widget.speechService,
                      ),
                      ConversationScreen(
                        repository: widget.repository,
                        progress: p,
                        speechService: widget.speechService,
                      ),
                      QuizAndReviewScreen(
                        repository: widget.repository,
                        progress: p,
                        speechService: widget.speechService,
                      ),
                    ],
                  ),
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _currentTabIndex,
                    onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.home_outlined), label: '首頁任務'),
                      NavigationDestination(icon: Icon(Icons.translate), label: '五十音'),
                      NavigationDestination(icon: Icon(Icons.onetwothree), label: '數字量詞'),
                      NavigationDestination(icon: Icon(Icons.forum_outlined), label: '日常會話'),
                      NavigationDestination(icon: Icon(Icons.quiz_outlined), label: '測驗統計'),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
