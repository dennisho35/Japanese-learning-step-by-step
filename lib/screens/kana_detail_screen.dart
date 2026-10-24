import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../widgets/handwriting_canvas_widget.dart';

/// 頁面 6：單個假名獨立教學頁 ＆ 頁面 7：五十音手寫練習與描紅畫布頁 (A3 & A4)
class KanaDetailScreen extends StatefulWidget {
  final List<KanaItem> kanaList;
  final int initialIndex;
  final StudyProgressService progress;
  final ISpeechService speechService;

  const KanaDetailScreen({
    super.key,
    required this.kanaList,
    required this.initialIndex,
    required this.progress,
    required this.speechService,
  });

  @override
  State<KanaDetailScreen> createState() => _KanaDetailScreenState();
}

class _KanaDetailScreenState extends State<KanaDetailScreen> {
  late int _currentIndex;
  bool _practiceKatakana = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.kanaList.length - 1);
  }

  void _navigate(int delta) {
    setState(() {
      _currentIndex = (_currentIndex + delta + widget.kanaList.length) % widget.kanaList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.kanaList[_currentIndex];
    final currentStatus = widget.progress.kanaStatus[item.id] ?? 'unlearned';
    final practiceCount = widget.progress.handwritingPracticeCount[item.id] ?? 0;
    final directions = _practiceKatakana ? item.katakanaDirections : item.hiraganaDirections;
    final strokes = _practiceKatakana ? item.katakanaStrokes : item.hiraganaStrokes;

    return Scaffold(
      appBar: AppBar(
        title: Text('${item.row} — ${item.hiragana} / ${item.katakana}'),
        actions: [
          IconButton(
            tooltip: '上一個假名',
            onPressed: () => _navigate(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: '下一個假名',
            onPressed: () => _navigate(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. 字形、羅馬拼音與正常/慢速發音播放
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(item.hiragana,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text(item.katakana,
                          style: const TextStyle(fontSize: 38, color: Colors.blueGrey)),
                      const SizedBox(width: 12),
                      if (widget.progress.showRomaji)
                        Text(item.romaji,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD64045))),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => widget.speechService.speakJapanese(item.hiragana),
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('正常發音'),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () =>
                            widget.speechService.speakJapanese(item.hiragana, slow: true),
                        icon: const Icon(Icons.slow_motion_video, size: 18),
                        label: const Text('慢速 0.6x'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. 學習狀態切換按鈕（未學／已掌握／需重溫）
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('學習狀態：', style: TextStyle(fontWeight: FontWeight.bold)),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'unlearned', label: Text('未學習')),
                      ButtonSegment(value: 'learned', label: Text('已掌握')),
                      ButtonSegment(value: 'review', label: Text('需重溫')),
                    ],
                    selected: {currentStatus},
                    onSelectionChanged: (val) {
                      widget.progress.markKanaStatus(item.id, val.first);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. 繁體中文記憶聯想、筆順方向與代表單字
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 字源與記憶聯想（${item.origin}）',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.mnemonic),
                  const Divider(height: 20),
                  const Text('🗣️ 發音要訣與代表單字',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.pronunciationTip),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('代表詞：${item.exampleWord}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () => widget.speechService
                            .speakJapanese(item.exampleWord.split('(').first),
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('讀單字'),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('✍️ 正確筆順與書寫方向（共 $strokes 筆）',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...List.generate(
                    directions.length,
                    (idx) => Text('${idx + 1}. ${directions[idx]}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. A4 五十音觸控手寫練習畫布
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('A4. 觸控手寫練習（已練習 $practiceCount 次）',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ChoiceChip(
                        label: Text(_practiceKatakana ? '切換至平假名' : '切換至片假名'),
                        selected: _practiceKatakana,
                        onSelected: (v) => setState(() => _practiceKatakana = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  HandwritingCanvasWidget(
                    key: ValueKey('${item.id}_$_practiceKatakana'),
                    targetCharacter: _practiceKatakana ? item.katakana : item.hiragana,
                    expectedStrokes: strokes,
                    strokeDirections: directions,
                    onPracticeCompleted: () {
                      widget.progress.recordHandwritingPractice(item.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
