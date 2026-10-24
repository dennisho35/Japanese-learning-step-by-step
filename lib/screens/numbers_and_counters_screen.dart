import 'package:flutter/material.dart';
import '../data/curriculum_repository.dart';
import '../services/number_converter_service.dart';
import '../services/speech_service.dart';
import '../services/study_progress_service.dart';
import '../theme/app_theme.dart';

/// 頁面 9：日語數字課程頁 (模組 B) ＆ 頁面 10：日語量詞課程及情境例句頁 (模組 C)
class NumbersAndCountersScreen extends StatefulWidget {
  final CurriculumRepository repository;
  final StudyProgressService progress;
  final ISpeechService speechService;

  const NumbersAndCountersScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speechService,
  });

  @override
  State<NumbersAndCountersScreen> createState() =>
      _NumbersAndCountersScreenState();
}

class _NumbersAndCountersScreenState extends State<NumbersAndCountersScreen> {
  bool _showCounters = false;
  int _customNumber = 3800;

  @override
  Widget build(BuildContext context) {
    final converted = NumberConverterService.convert(_customNumber);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('模組 B：數字教學')),
                  ButtonSegment(value: true, label: Text('模組 C：14大類量詞')),
                ],
                selected: {_showCounters},
                onSelectionChanged: (v) => setState(() => _showCounters = v.first),
              ),
            ],
          ),
        ),
        // 互動數字與價格轉換器
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧮 互動數字／金額即時音變轉換器 (0〜99,999,999)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          initialValue: '3800',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            labelText: '輸入數字',
                          ),
                          onChanged: (val) {
                            setState(() {
                              _customNumber = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('漢字：${converted.kanji}（¥$_customNumber 円）',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('假名：${converted.hiragana} えん',
                                style: const TextStyle(color: AppTheme.accentVermilion)),
                            if (widget.progress.showRomaji)
                              Text('Romaji: ${converted.romaji} en',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '播放金額讀音',
                        onPressed: () => widget.speechService
                            .speakJapanese('${converted.hiragana}えん'),
                        icon: const Icon(Icons.volume_up),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _showCounters ? _buildCountersList() : _buildNumbersList(),
        ),
      ],
    );
  }

  Widget _buildNumbersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.repository.numberCategories.length,
      itemBuilder: (context, index) {
        final cat = widget.repository.numberCategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(cat.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 18),
                ...cat.items.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${item.numStr} ｜ ${item.kanji} 【${item.hiragana}】',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.irregular ? AppTheme.accentVermilion : null,
                        ),
                      ),
                      subtitle: Text(
                        '${widget.progress.showRomaji ? "[${item.romaji}] " : ""}${item.note}\n例句：${item.exampleJp} (${item.exampleZh})',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => widget.speechService
                            .speakJapanese(item.hiragana.split('/').first),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.repository.counters.length,
      itemBuilder: (context, index) {
        final cnt = widget.repository.counters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${cnt.name} (${cnt.kanji})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      tooltip: '播放例句',
                      onPressed: () => widget.speechService.speakJapanese(cnt.exampleJp),
                      icon: const Icon(Icons.volume_up),
                    ),
                  ],
                ),
                Text('適用物件：${cnt.appliesTo}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('📌 音變規則：${cnt.phoneticRule}'),
                const SizedBox(height: 4),
                Text('⚠️ 常見錯誤提醒：${cnt.commonMistake}',
                    style: const TextStyle(color: AppTheme.accentVermilion)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cnt.countTable.map((r) {
                    return ActionChip(
                      label: Text('${r.kanji}: ${r.hiragana}'),
                      backgroundColor: r.irregular
                          ? AppTheme.accentVermilion.withOpacity(0.12)
                          : null,
                      onPressed: () => widget.speechService
                          .speakJapanese(r.hiragana.split('/').first),
                    );
                  }).toList(),
                ),
                const Divider(height: 18),
                Text('情境（${cnt.scenario}）：${cnt.exampleJp}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('平假名：${cnt.exampleHira}'),
                Text('中文：${cnt.exampleZh}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
