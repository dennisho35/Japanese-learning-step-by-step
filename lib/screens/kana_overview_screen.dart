import 'package:flutter/material.dart';
import '../data/curriculum_repository.dart';
import '../models/curriculum_models.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';
import 'kana_detail_screen.dart';
import 'pronunciation_practice_screen.dart';

/// 頁面 5：五十音總覽表（含平假名、片假名、清音、濁音、半濁音、拗音、外來語、易混淆比較與促音長音）
class KanaOverviewScreen extends StatefulWidget {
  final CurriculumRepository repository;
  final StudyProgressService progress;
  final ISpeechService speechService;

  const KanaOverviewScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speechService,
  });

  @override
  State<KanaOverviewScreen> createState() => _KanaOverviewScreenState();
}

class _KanaOverviewScreenState extends State<KanaOverviewScreen> {
  bool _showKatakana = false;
  String _selectedCategory = 'seion';

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'seion', 'label': '清音 (46)'},
      {'id': 'dakuon', 'label': '濁音 (20)'},
      {'id': 'handakuon', 'label': '半濁音 (5)'},
      {'id': 'yoon', 'label': '拗音 (33)'},
      {'id': 'foreign_katakana', 'label': '外來語片假名'},
      {'id': 'confusable', 'label': '易混淆 & 促音長音'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('平假名 (あ)')),
                  ButtonSegment(value: true, label: Text('片假名 (ア)')),
                ],
                selected: {_showKatakana},
                onSelectionChanged: (v) => setState(() => _showKatakana = v.first),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PronunciationPracticeScreen(
                        kanaList: widget.repository.kanaList,
                        speechService: widget.speechService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.hearing, size: 18),
                label: const Text('A5 發音訓練'),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat['id']!),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _selectedCategory == 'confusable'
              ? _buildConfusableAndSpecialRulesView()
              : _buildKanaGrid(widget.repository.getKanaByCategory(_selectedCategory)),
        ),
      ],
    );
  }

  Widget _buildKanaGrid(List<KanaItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = widget.progress.kanaStatus[item.id] ?? 'unlearned';
        final mainChar = _showKatakana ? item.katakana : item.hiragana;
        final subChar = _showKatakana ? item.hiragana : item.katakana;
        Color statusColor = Colors.grey.shade300;
        if (status == 'learned') statusColor = AppTheme.bambooGreen;
        if (status == 'review') statusColor = AppTheme.amberGold;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            final globalIdx = widget.repository.kanaList.indexOf(item);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => KanaDetailScreen(
                  kanaList: widget.repository.kanaList,
                  initialIndex: globalIdx,
                  progress: widget.progress,
                  speechService: widget.speechService,
                ),
              ),
            );
          },
          child: Card(
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: InkWell(
                    onTap: () => widget.speechService.speakJapanese(item.hiragana),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.volume_up, size: 14),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        mainChar,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.progress.showRomaji ? '$subChar · ${item.romaji}' : subChar,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfusableAndSpecialRulesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🔍 易混淆假名比較（シ/ツ、ソ/ン、ぬ/め 等）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.repository.confusablePairs.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.pair} (${c.script})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('關鍵差異：${c.keyDifference}',
                        style: const TextStyle(color: AppTheme.accentVermilion, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(c.explanation),
                    const SizedBox(height: 4),
                    Text('🎯 口訣：${c.quizTip}',
                        style: const TextStyle(color: AppTheme.bambooGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        const Text(
          '⚡ 促音「っ」與長音「ー」發音規則',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.repository.specialPhonetics.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(r.summary, style: const TextStyle(color: AppTheme.accentVermilion)),
                    const SizedBox(height: 4),
                    Text(r.explanation),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
