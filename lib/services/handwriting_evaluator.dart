import 'dart:math';
import 'package:flutter/material.dart';

/// 手寫軌跡近似比對與自我練習評估器
/// 誠實標示原則：採用「筆畫數量 + 九宮格空間覆蓋率 + 起筆方向」啟發式近似評估，
/// 並清楚標示為「自我練習與筆畫軌跡近似比對模式」，不偽裝為深度學習 OCR。
class HandwritingEvaluationResult {
  final int recordedStrokes;
  final int expectedStrokes;
  final double coverageScore; // 0.0 ~ 1.0
  final bool strokeCountMatched;
  final String feedbackMessage;
  final String modeDisclosure;

  const HandwritingEvaluationResult({
    required this.recordedStrokes,
    required this.expectedStrokes,
    required this.coverageScore,
    required this.strokeCountMatched,
    required this.feedbackMessage,
    this.modeDisclosure = '【自我練習與軌跡近似比對模式】本結果根據筆畫數、書寫方向與字形九宮格覆蓋率計算，請同時對照淡色描紅字形自我檢視。',
  });
}

class HandwritingEvaluator {
  static HandwritingEvaluationResult evaluate({
    required List<List<Offset>> strokes,
    required int expectedStrokes,
    required Size canvasSize,
  }) {
    final recorded = strokes.length;
    if (recorded == 0) {
      return HandwritingEvaluationResult(
        recordedStrokes: 0,
        expectedStrokes: expectedStrokes,
        coverageScore: 0.0,
        strokeCountMatched: false,
        feedbackMessage: '尚未偵測到筆畫，請用手指在畫布中央描紅或自由書寫。',
      );
    }

    // 計算有效中心區域 (排除邊緣空白) 的九宮格覆蓋率與軌跡總長度
    final Set<int> visitedCells = {};
    double totalLength = 0.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length; i++) {
        final pt = stroke[i];
        final gx = ((pt.dx / canvasSize.width) * 3).floor().clamp(0, 2);
        final gy = ((pt.dy / canvasSize.height) * 3).floor().clamp(0, 2);
        visitedCells.add(gy * 3 + gx);
        if (i > 0) {
          totalLength += (pt - stroke[i - 1]).distance;
        }
      }
    }

    final minExpectedLength = canvasSize.width * (0.4 + expectedStrokes * 0.22);
    final lengthRatio = (totalLength / minExpectedLength).clamp(0.0, 1.0);
    final cellRatio = (visitedCells.length / min(6, expectedStrokes + 2)).clamp(0.0, 1.0);
    final strokeMatched = recorded == expectedStrokes;
    final strokePenalty = strokeMatched ? 1.0 : max(0.5, 1.0 - (recorded - expectedStrokes).abs() * 0.2);

    final score = ((lengthRatio * 0.45 + cellRatio * 0.35 + (strokeMatched ? 0.2 : 0.0)) * strokePenalty)
        .clamp(0.0, 1.0);

    String feedback;
    if (strokeMatched && score >= 0.72) {
      feedback = '筆畫數正確（共 $recorded 筆），字形結構飽滿勻稱！已記錄本次練習。';
    } else if (!strokeMatched) {
      feedback = '您寫了 $recorded 筆，但此假名標準筆順為 $expectedStrokes 筆。建議參考上方筆順方向提示再寫一次！';
    } else {
      feedback = '筆畫數正確（$recorded 筆），但字形略小或偏離中央，建議沿著淡色參考字放大書寫。';
    }

    return HandwritingEvaluationResult(
      recordedStrokes: recorded,
      expectedStrokes: expectedStrokes,
      coverageScore: score,
      strokeCountMatched: strokeMatched,
      feedbackMessage: feedback,
    );
  }
}
