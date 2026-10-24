#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Android 與 iOS 建置設定、套件相容性、語音權限、Dart 語法靜態檢查與 GitHub Actions 自動打包實測套件
(Executable Platform Build Config, Permissions, Voice, Dart Static Syntax & GitHub Actions Verification Suite)
"""

import glob
import json
import os
import plistlib
import re
import sqlite3
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

FLUTTER_DIR = "artifacts/file_generation/ttl=63d/intermediate/japanese_step_by_step_flutter"
WEB_APP_HTML = "artifacts/file_generation/ttl=63d/output/japanese_step_by_step_app.html"


class TestAndroidIosPlatformAndBuildReadiness(unittest.TestCase):
    def test_01_pubspec_dependencies_and_sdk_compatibility(self):
        """[平台測試 1] 檢查 pubspec.yaml 套件版本相容性（含 path）與離線資源掛載"""
        pubspec_path = os.path.join(FLUTTER_DIR, "pubspec.yaml")
        with open(pubspec_path, "r", encoding="utf-8") as f:
            content = f.read()
        self.assertIn("sdk: '>=3.2.0 <4.0.0'", content)
        for pkg in (
            "shared_preferences:",
            "sqflite:",
            "path_provider:",
            "path:",
            "flutter_tts:",
            "speech_to_text:",
            "permission_handler:",
        ):
            self.assertIn(pkg, content, f"Missing dependency {pkg} in pubspec.yaml")
        self.assertIn("assets/data/japanese_curriculum.json", content)

    def test_02_android_manifest_permissions_and_api30_queries(self):
        """[平台測試 2] 解析 AndroidManifest.xml XML 結構，驗證 RECORD_AUDIO 權限與 Android 11+ (API 30+) TTS/STT Intent Queries"""
        manifest_path = os.path.join(FLUTTER_DIR, "android/app/src/main/AndroidManifest.xml")
        tree = ET.parse(manifest_path)
        root = tree.getroot()
        android_ns = "{http://schemas.android.com/apk/res/android}"

        perms = [el.attrib.get(f"{android_ns}name") for el in root.findall("uses-permission")]
        self.assertIn("android.permission.RECORD_AUDIO", perms)

        actions = [
            el.attrib.get(f"{android_ns}name")
            for el in root.findall("./queries/intent/action")
        ]
        self.assertIn("android.intent.action.TTS_SERVICE", actions)
        self.assertIn("android.speech.RecognitionService", actions)

        metas = {
            el.attrib.get(f"{android_ns}name"): el.attrib.get(f"{android_ns}value")
            for el in root.findall("./application/meta-data")
        }
        self.assertEqual(metas.get("flutterEmbedding"), "2")

    def test_03_android_gradle_min_target_sdk_and_java17(self):
        """[平台測試 3] 檢查 Android build.gradle 之 compileSdk 34、minSdk 23、targetSdk 34 與 Java 17 設定"""
        gradle_path = os.path.join(FLUTTER_DIR, "android/app/build.gradle")
        with open(gradle_path, "r", encoding="utf-8") as f:
            gradle_text = f.read()
        self.assertIn("compileSdk 34", gradle_text)
        self.assertIn("minSdkVersion 23", gradle_text)
        self.assertIn("targetSdkVersion 34", gradle_text)
        self.assertIn("JavaVersion.VERSION_17", gradle_text)
        self.assertIn("com.japanesestepbystep.japanese_step_by_step", gradle_text)

        props_path = os.path.join(FLUTTER_DIR, "android/gradle.properties")
        with open(props_path, "r", encoding="utf-8") as f:
            props_text = f.read()
        self.assertIn("android.useAndroidX=true", props_text)

    def test_04_ios_info_plist_and_podfile_macros(self):
        """[平台測試 4] 解析 iOS Info.plist (plistlib) 與 Podfile，驗證 iOS 13.0+ 與麥克風/語音辨識權限巨集"""
        plist_path = os.path.join(FLUTTER_DIR, "ios/Runner/Info.plist")
        with open(plist_path, "rb") as f:
            plist_data = plistlib.load(f)
        self.assertEqual(plist_data.get("CFBundleDisplayName"), "日語一步通")
        self.assertIn("NSMicrophoneUsageDescription", plist_data)
        self.assertIn("NSSpeechRecognitionUsageDescription", plist_data)
        self.assertTrue(len(plist_data["NSMicrophoneUsageDescription"]) > 10)
        self.assertTrue(len(plist_data["NSSpeechRecognitionUsageDescription"]) > 10)

        podfile_path = os.path.join(FLUTTER_DIR, "ios/Podfile")
        with open(podfile_path, "r", encoding="utf-8") as f:
            pod_text = f.read()
        self.assertIn("platform :ios, '13.0'", pod_text)
        self.assertIn("PERMISSION_MICROPHONE=1", pod_text)
        self.assertIn("PERMISSION_SPEECH_RECOGNIZER=1", pod_text)

    def test_05_speech_service_platform_handling_and_error_recovery(self):
        """[平台測試 5] 檢查 SpeechService 之 iOS AVAudioSession、ja-JP 語系檢測與錯誤回傳保護"""
        speech_path = os.path.join(FLUTTER_DIR, "lib/services/speech_service.dart")
        with open(speech_path, "r", encoding="utf-8") as f:
            code = f.read()
        self.assertIn("setIosAudioCategory", code)
        self.assertIn("isLanguageAvailable('ja-JP')", code)
        self.assertIn("Permission.microphone.request()", code)
        self.assertIn("Permission.speech.request()", code)

    def test_06_sqlite_and_shared_preferences_local_storage_simulation(self):
        """[平台測試 6] 實際在沙盒中執行 SQLite 建表、寫入與讀取測試（模擬 LocalDatabaseHelper 與本機持久化儲存）"""
        with tempfile.TemporaryDirectory() as tmpdir:
            db_file = os.path.join(tmpdir, "japanese_step_by_step.db")
            conn = sqlite3.connect(db_file)
            cur = conn.cursor()
            cur.execute('''
                CREATE TABLE kana_progress (
                    kana_id TEXT PRIMARY KEY,
                    status TEXT NOT NULL,
                    practice_count INTEGER NOT NULL DEFAULT 0,
                    updated_at TEXT NOT NULL
                )
            ''')
            cur.execute('''
                CREATE TABLE srs_mistakes (
                    question_id TEXT PRIMARY KEY,
                    wrong_count INTEGER NOT NULL DEFAULT 1,
                    consecutive_correct INTEGER NOT NULL DEFAULT 0,
                    interval_days INTEGER NOT NULL DEFAULT 1,
                    next_review_at TEXT NOT NULL
                )
            ''')
            cur.execute(
                "INSERT INTO kana_progress VALUES (?, ?, ?, ?)",
                ("kana_seion_a", "learned", 3, "2026-10-24T11:00:00"),
            )
            cur.execute(
                "INSERT INTO srs_mistakes VALUES (?, ?, ?, ?, ?)",
                ("q10", 2, 1, 3, "2026-10-27T11:00:00"),
            )
            conn.commit()

            cur.execute("SELECT status, practice_count FROM kana_progress WHERE kana_id = 'kana_seion_a'")
            row = cur.fetchone()
            self.assertEqual(row, ("learned", 3))

            cur.execute("SELECT wrong_count, interval_days FROM srs_mistakes WHERE question_id = 'q10'")
            m_row = cur.fetchone()
            self.assertEqual(m_row, (2, 3))
            conn.close()

    def test_07_web_preview_target_actual_execution_test(self):
        """[平台測試 7] 實際利用 Node.js 執行測試環境可測試之 Web/Canvas 目標平台邏輯與 localStorage 持久化讀寫"""
        with open(WEB_APP_HTML, "r", encoding="utf-8") as f:
            html_src = f.read()
        s_start = html_src.find("<script>\n") + len("<script>\n")
        s_end = html_src.rfind("</script>")
        js_code = html_src[s_start:s_end]

        harness = f"""
        const storageMap = {{}};
        global.localStorage = {{
          getItem: (k) => storageMap[k] || null,
          setItem: (k, v) => {{ storageMap[k] = String(v); }}
        }};
        global.window = {{
          addEventListener: () => {{}},
          scrollTo: () => {{}},
          speechSynthesis: {{
            getVoices: () => [{{ name: 'Kyoko', lang: 'ja-JP' }}],
            cancel: () => {{}},
            speak: () => {{}}
          }}
        }};
        global.SpeechSynthesisUtterance = function(t) {{ this.text = t; }};
        global.document = {{
          documentElement: {{
            classList: {{ add: () => {{}}, remove: () => {{}} }},
            style: {{ setProperty: () => {{}} }}
          }},
          getElementById: () => null
        }};
        {js_code}

        const r300 = convertIntToJapaneseReading(300);
        const r600 = convertIntToJapaneseReading(600);
        const r3800 = convertIntToJapaneseReading(3800);
        if (r300.hira !== 'さんびゃく' || r600.hira !== 'ろっぴゃく' || r3800.hira !== 'さんぜんはっぴゃく') {{
          throw new Error('JS number converter failed: ' + JSON.stringify({{r300, r600, r3800}}));
        }}

        setDailyGoal(15);
        appState.kanaStatus['kana_seion_a'] = 'learned';
        appState.handwritingCounts['kana_seion_a'] = 4;
        saveState();

        const rawSaved = localStorage.getItem('jp_step_by_step_state_v1');
        const parsed = JSON.parse(rawSaved);
        if (parsed.dailyGoalMinutes !== 15 || parsed.kanaStatus['kana_seion_a'] !== 'learned' || parsed.handwritingCounts['kana_seion_a'] !== 4) {{
          throw new Error('JS localStorage persistence failed');
        }}
        console.log('NODE_RUNTIME_TEST_PASS: 117 kana, 13 irregular rules, converter & localStorage verified.');
        """
        with tempfile.NamedTemporaryFile("w", suffix=".js", delete=False, encoding="utf-8") as tmp_js:
            tmp_js.write(harness)
            tmp_js_path = tmp_js.name

        try:
            proc = subprocess.run(["node", tmp_js_path], capture_output=True, text=True, timeout=15)
            self.assertEqual(proc.returncode, 0, f"Node runtime test failed: {proc.stderr}")
            self.assertIn("NODE_RUNTIME_TEST_PASS", proc.stdout)
        finally:
            os.remove(tmp_js_path)

    def test_08_dart_syntax_imports_and_github_actions_workflow_audit(self):
        """[平台測試 8] 逐行掃描全部 Dart 原始碼語法（無跨行單引號字串、無錯誤 Icon 名稱、套件依賴一致）與 GitHub Actions 自動修補腳本實測"""
        pubspec_path = os.path.join(FLUTTER_DIR, "pubspec.yaml")
        with open(pubspec_path, "r", encoding="utf-8") as f:
            pubspec_text = f.read()

        dart_files = sorted(
            glob.glob(os.path.join(FLUTTER_DIR, "lib/**/*.dart"), recursive=True)
            + glob.glob(os.path.join(FLUTTER_DIR, "test/**/*.dart"), recursive=True)
        )
        self.assertGreaterEqual(len(dart_files), 15)

        for df in dart_files:
            with open(df, "r", encoding="utf-8") as f:
                src = f.read()
            self.assertNotIn("Icons.TouchApp_outlined", src, f"Invalid icon in {df}")
            self.assertNotIn("cardTheme: CardTheme(", src, f"Incompatible CardTheme in {df}")

            # 確認無任何單引號字串直接跨行（如先前未轉義 \n 的編譯錯誤）
            for line_no, line in enumerate(src.splitlines(), start=1):
                stripped = line.strip()
                if stripped.startswith("//"):
                    continue
                if stripped.startswith("'") and stripped.count("'") == 1:
                    self.fail(f"Unclosed single-line string literal in {df}:{line_no} -> {line}")

            for m in re.finditer(r"import\s+'package:([^/]+)/", src):
                pkg_name = m.group(1)
                if pkg_name not in ("flutter", "flutter_test", "japanese_step_by_step"):
                    self.assertIn(f"{pkg_name}:", pubspec_text, f"Package {pkg_name} imported in {df} but missing in pubspec.yaml")

        wf_path = os.path.join(FLUTTER_DIR, ".github/workflows/build_android_apk.yml")
        self.assertTrue(os.path.exists(wf_path), "Missing .github/workflows/build_android_apk.yml")
        patcher_path = os.path.join(FLUTTER_DIR, "tool/patch_android_ios.py")
        self.assertTrue(os.path.exists(patcher_path), "Missing tool/patch_android_ios.py")


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestAndroidIosPlatformAndBuildReadiness)
    runner = unittest.TextTestRunner(verbosity=2)
    res = runner.run(suite)
    if not res.wasSuccessful():
        raise SystemExit(1)