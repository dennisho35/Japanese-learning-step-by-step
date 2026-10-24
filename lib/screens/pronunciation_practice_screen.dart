import 'dart:math';
import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/speech_service.dart';

/// 頁面 8：五十音發音訓練與聽音辨字頁 (A5)
class PronunciationPracticeScreen extends StatefulWidget {
  final List<KanaItem> kanaList;
  final ISpeechService speechService;

  const PronunciationPracticeScreen({
    super.key,
    required this.kanaList,
    required this.speechService,
  });

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> {
  final Random _random = Random();
  late KanaItem _targetKana;
  late List<KanaItem> _options;
  String? _listeningFeedback;
  String _recognizedSpeech = '';
  String _sttStatusMessage = '點擊下方「開始麥克風跟讀」以進行本機語音辨識比對（需先授權麥克風權限）。';

  @override
  void initState() {
    super.initState();
    _generateListeningRound();
  }

  void _generateListeningRound() {
    _targetKana = widget.kanaList[_random.nextInt(widget.kanaList.length)];
    final pool = widget.kanaList.where((k) => k.id != _targetKana.id).toList()
      ..shuffle(_random);
    _options = [_targetKana, ...pool.take(3)]..shuffle(_random);
    _listeningFeedback = null;
    setState(() {});
  }

  Future<void> _startFollowAlongRecording() async {
    try {
      setState(() {
        _sttStatusMessage = '🎙️ 正在聆聽中... 請對著麥克風念出「${_targetKana.hiragana} (${_targetKana.romaji})」';
      });
      await widget.speechService.startListening(
        onResult: (words) {
          setState(() {
            _recognizedSpeech = words;
            final matched = words.contains(_targetKana.hiragana) ||
                words.contains(_targetKana.katakana);
            _sttStatusMessage = matched
                ? '✅ 語音辨識結果：「$words」— 與目標假名吻合！'
                : '💡 語音辨識結果：「$words」— 建議慢速重聽標準音後再試一次。';
          });
        },
      );
    } catch (e) {
      setState(() {
        _sttStatusMessage = '⚠️ $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A5. 五十音發音訓練與聽音辨字')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. 聽音辨認假名挑戰',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            widget.speechService.speakJapanese(_targetKana.hiragana),
                        icon: const Icon(Icons.volume_up),
                        label: const Text('播放正常速度'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => widget.speechService
                            .speakJapanese(_targetKana.hiragana, slow: true),
                        icon: const Icon(Icons.slow_motion_video),
                        label: const Text('慢速 0.6x'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: '換下一題',
                        onPressed: _generateListeningRound,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                    children: _options.map((opt) {
                      return OutlinedButton(
                        onPressed: () {
                          final correct = opt.id == _targetKana.id;
                          setState(() {
                            _listeningFeedback = correct
                                ? '🎉 答對了！正確答案是 ${_targetKana.hiragana} (${_targetKana.romaji})'
                                : '❌ 答錯了，請再聽一次！（提示：${_targetKana.pronunciationTip}）';
                          });
                        },
                        child: Text(
                          '${opt.hiragana} (${opt.katakana})',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_listeningFeedback != null) ...[
                    const SizedBox(height: 10),
                    Text(_listeningFeedback!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2. 顯示假名跟讀與語音辨識比對',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '目標假名：${_targetKana.hiragana} / ${_targetKana.katakana} (${_targetKana.romaji}) — ${_targetKana.exampleWord}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _startFollowAlongRecording,
                    icon: const Icon(Icons.mic),
                    label: const Text('開始麥克風跟讀辨識'),
                  ),
                  const SizedBox(height: 10),
                  Text(_sttStatusMessage),
                  if (_recognizedSpeech.isNotEmpty)
                    Text('最新辨識文字：$_recognizedSpeech'),
                  const Divider(height: 20),
                  const Text(
                    '【誠實標示】本功能使用裝置系統原生 TTS 播放標準日語讀音，並透過裝置原生語音辨識 (STT) 比對文字結果，非真人預錄音檔或深度學習聲學評分。',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
