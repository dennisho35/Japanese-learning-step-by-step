import 'package:flutter/material.dart';
import '../services/study_progress_service.dart';

/// 頁面 16：系統設定、深淺色模式、無障礙字體與隱私管理頁
class SettingsScreen extends StatelessWidget {
  final StudyProgressService progress;

  const SettingsScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ 設定與無障礙管理')),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('深色模式 (Dark Mode)'),
                subtitle: const Text('適合夜間或低光源環境閱讀'),
                value: progress.isDarkMode,
                onChanged: (_) => progress.toggleDarkMode(),
              ),
              SwitchListTile(
                title: const Text('顯示羅馬拼音輔助'),
                subtitle: const Text('建議熟悉五十音後關閉，避免長期依賴羅馬拼音'),
                value: progress.showRomaji,
                onChanged: (_) => progress.toggleRomajiVisibility(),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('無障礙文字大小設定', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('標準 (100%)'),
                    selected: progress.fontScale == 1.0,
                    onSelected: (_) => progress.setFontScale(1.0),
                  ),
                  ChoiceChip(
                    label: const Text('適中放大 (112%)'),
                    selected: progress.fontScale == 1.12,
                    onSelected: (_) => progress.setFontScale(1.12),
                  ),
                  ChoiceChip(
                    label: const Text('大字體 (122%)'),
                    selected: progress.fontScale == 1.22,
                    onSelected: (_) => progress.setFontScale(1.22),
                  ),
                ],
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('重置所有本機學習紀錄', style: TextStyle(color: Colors.red)),
                subtitle: const Text('清除五十音狀態、手寫次數、錯題本與統計資料'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('確定要重置所有學習紀錄嗎？'),
                      content: const Text('此操作將清除本機儲存的所有學習進度並恢復初始狀態。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('確定重置'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await progress.resetAllProgress();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
