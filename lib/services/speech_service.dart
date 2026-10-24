import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// 語音播放 (TTS) 與語音辨識 (STT) 抽象介面
/// 支援 Android (Google TTS Engine) 與 iOS (AVSpeechSynthesizer / AVAudioSession)
abstract class ISpeechService {
  Future<bool> speakJapanese(String text, {bool slow = false});
  Future<void> stopSpeaking();
  Future<bool> requestMicrophonePermission();
  Future<void> startListening({required Function(String recognizedText) onResult});
  Future<void> stopListening();
}

class NativeSpeechService implements ISpeechService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _ttsInitialized = false;
  String? lastError;

  Future<void> initTts() async {
    if (_ttsInitialized) return;
    try {
      // iOS 專屬設定：配置 AVAudioSession 讓靜音鍵模式下仍能播放教學語音並與其他音訊混音
      if (!kIsWeb && Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      // 檢查裝置是否支援 ja-JP 東京標準音語系
      final isAvailable = await _tts.isLanguageAvailable('ja-JP');
      if (isAvailable == true) {
        await _tts.setLanguage('ja-JP');
      } else {
        await _tts.setLanguage('ja');
      }
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _ttsInitialized = true;
      lastError = null;
    } catch (e) {
      lastError = '無法初始化日語系統語音 (ja-JP)，請確認裝置設定已下載日語語音包：$e';
    }
  }

  @override
  Future<bool> speakJapanese(String text, {bool slow = false}) async {
    try {
      await initTts();
      await _tts.stop();
      // 東京標準音語速設定：正常速度 0.50，慢速分解跟讀 0.28
      await _tts.setSpeechRate(slow ? 0.28 : 0.50);
      final result = await _tts.speak(text);
      return result == 1;
    } catch (e) {
      lastError = '語音播放失敗，請檢查裝置音量或離線日語語音設定：$e';
      return false;
    }
  }

  @override
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final micStatus = await Permission.microphone.request();
    if (!kIsWeb && Platform.isIOS) {
      final speechStatus = await Permission.speech.request();
      return micStatus.isGranted && speechStatus.isGranted;
    }
    return micStatus.isGranted;
  }

  @override
  Future<void> startListening({required Function(String recognizedText) onResult}) async {
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      throw Exception('尚未取得麥克風或語音辨識權限。本 App 絕不會在未經您同意下錄音。');
    }
    final available = await _stt.initialize();
    if (!available) {
      throw Exception('此裝置目前不支援日語語音辨識服務。');
    }
    await _stt.listen(
      localeId: 'ja_JP',
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  @override
  Future<void> stopListening() async {
    await _stt.stop();
  }
}
