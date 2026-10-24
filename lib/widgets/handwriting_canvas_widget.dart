import 'package:flutter/material.dart';
import '../services/handwriting_evaluator.dart';

/// 五十音觸控手寫練習畫布元件（支援描紅參考、自由書寫、清除、重寫與軌跡近似評分）
class HandwritingCanvasWidget extends StatefulWidget {
  final String targetCharacter;
  final int expectedStrokes;
  final List<String> strokeDirections;
  final VoidCallback onPracticeCompleted;

  const HandwritingCanvasWidget({
    super.key,
    required this.targetCharacter,
    required this.expectedStrokes,
    required this.strokeDirections,
    required this.onPracticeCompleted,
  });

  @override
  State<HandwritingCanvasWidget> createState() => _HandwritingCanvasWidgetState();
}

class _HandwritingCanvasWidgetState extends State<HandwritingCanvasWidget> {
  final List<List<Offset>> _strokes = [];
  bool _showTracingGuide = true; // true: 描紅模式, false: 自由書寫模式
  HandwritingEvaluationResult? _lastResult;

  void _startStroke(DragStartDetails details) {
    setState(() {
      _strokes.add([details.localPosition]);
      _lastResult = null;
    });
  }

  void _appendStroke(DragUpdateDetails details) {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.last.add(details.localPosition);
    });
  }

  void _undoLastStroke() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _lastResult = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _lastResult = null;
    });
  }

  void _submitPractice(Size canvasSize) {
    final result = HandwritingEvaluator.evaluate(
      strokes: _strokes,
      expectedStrokes: widget.expectedStrokes,
      canvasSize: canvasSize,
    );
    setState(() {
      _lastResult = result;
    });
    if (result.recordedStrokes > 0) {
      widget.onPracticeCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    const canvasSize = Size(280, 280);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '標準筆順：共 ${widget.expectedStrokes} 筆（已寫 ${_strokes.length} 筆）',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('描紅參考')),
                ButtonSegment(value: false, label: Text('自由書寫')),
              ],
              selected: {_showTracingGuide},
              onSelectionChanged: (val) {
                setState(() => _showTracingGuide = val.first);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: canvasSize.width,
            height: canvasSize.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1B365D), width: 2),
            ),
            child: GestureDetector(
              onPanStart: _startStroke,
              onPanUpdate: _appendStroke,
              child: CustomPaint(
                size: canvasSize,
                painter: _KanaCanvasPainter(
                  character: widget.targetCharacter,
                  strokes: _strokes,
                  showGuide: _showTracingGuide,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _undoLastStroke,
              icon: const Icon(Icons.undo),
              label: const Text('復原上一筆'),
            ),
            OutlinedButton.icon(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.delete_outline),
              label: const Text('清除重寫'),
            ),
            ElevatedButton.icon(
              onPressed: () => _submitPractice(canvasSize),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('提交練習'),
            ),
          ],
        ),
        if (_lastResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _lastResult!.strokeCountMatched
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lastResult!.feedbackMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastResult!.modeDisclosure,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KanaCanvasPainter extends CustomPainter {
  final String character;
  final List<List<Offset>> strokes;
  final bool showGuide;

  _KanaCanvasPainter({
    required this.character,
    required this.strokes,
    required this.showGuide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    // 繪製米字格輔助線
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);

    // 繪製淡色假名描紅底字
    if (showGuide) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: character,
          style: const TextStyle(
            fontSize: 190,
            color: Color(0x221B365D),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
      );
    }

    // 繪製使用者手指筆畫軌跡
    final strokePaint = Paint()
      ..color = const Color(0xFF1B365D)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 4.5, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
      } else if (stroke.length > 1) {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KanaCanvasPainter oldDelegate) => true;
}
