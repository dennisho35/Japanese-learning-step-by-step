# 日語一步通 (Japanese Step-by-Step) — 完整產品架構、設計規範與 Android / iOS 建置發佈指南

## 一、環境檢查與實作方案誠實說明

在開始開發前，我們首先檢測了目前雲端執行沙盒環境的工具鏈狀態：
- **已支援工具**：Python 3、Node.js、HTML5/Canvas/Web Speech API 驗證工具、ZIP 封裝工具。
- **目前環境限制**：沙盒容器無對外網際網路連線，且未預載 Flutter SDK、Dart SDK、Android SDK / Gradle 及 macOS Xcode 編譯器，因此**無法在容器內直接編譯產生二進位 `.apk`、`.aab` 或 `.ipa` 安裝檔**。
- **雙軌完整交付方案**（不以單純網頁冒充原生 App，亦不虛構安裝檔連結）：
  1. **完整可建置之 Flutter 跨平台專案原始碼包 (`japanese_step_by_step_flutter_project.zip`)**：採用標準 Flutter + Dart 模組化架構，內建完整離線 JSON 教材資料庫 (`assets/data/japanese_curriculum.json`)、本機儲存服務 (`SharedPreferences` / `sqflite`)、系統原生語音服務 (`flutter_tts` + `speech_to_text`)、自訂手寫描紅畫布 (`CustomPainter` + `GestureDetector`) 及單元測試 (`test/curriculum_and_logic_test.dart`)。下載至開發機後執行 `flutter build apk` / `flutter build ipa` 即可正式部署至 Android 與 iOS。
  2. **立即可在目前畫面互動操作的完整功能 App 預覽版 (`japanese_step_by_step_app.html`)**：與 Flutter 專案共用同一份 100% 校對之日語教學資料庫，實作全部 16 個畫面、觸控手寫描紅畫布、系統日語 TTS 正常/慢速發音、互動數字轉換器、8 大題型測驗與 SRS 間隔重複錯題本。

## 二、Phase 1：產品規劃與系統架構

### 2.1 功能架構與四大核心模組
| 模組代碼 | 模組名稱 | 核心教學內容與互動功能 |
| :--- | :--- | :--- |
| **模組 A** | **日語五十音學習中心** | • **A1 平假名 & A2 片假名**：清音 46 字、濁音 20 字、半濁音 5 字、拗音 33 組、外來語常用組合 13 組（ファ、ティ、チェ、ディ等）、促音「っ」與長音「ー」規則、7 組易混淆假名對比（シ/ツ、ソ/ン、ぬ/め、は/ほ、る/ろ、わ/れ/ね、さ/ち）。<br>• **A3 獨立假名教學頁**：顯示平片假名、羅馬拼音（可一鍵隱藏以防依賴）、正常 1.0x 與慢速 0.6x 發音、筆順數與方向、筆順示範動畫、字源記憶聯想及學習狀態標記。<br>• **A4 手寫練習畫布**：支援手指觸控與滑鼠書寫、淡色描紅參考與自由書寫切換、復原/清除/提交、筆畫數與九宮格空間覆蓋率近似評分（誠實標示為「自我練習與軌跡近似比對模式」）。<br>• **A5 發音與聽音訓練**：正常/慢速播放、隨機聽音辨字挑戰、麥克風跟讀辨識（需明確授權）。 |
| **模組 B** | **日語數字教學** | • 涵蓋 0–10、11–99、百千萬億、日常購物金額（円 えん）、月份日期星期、時間分鐘、年齡（20歲 はたち）及電話號碼（「-」讀作 の）。<br>• **重點音變獨立標示**：4（よん/し）、7（なな/しち）、9（きゅう/く）、300（さんびゃく）、600（ろっぴゃく）、800（はっぴゃく）、3000（さんぜん）、8000（はっせん）、10000（いちまん）。<br>• **互動數字轉換器與報價聽力挑戰**：輸入任意 0〜99,999,999 阿拉伯數字即時轉換日文漢字、假名與發音。 |
| **模組 C** | **日語量詞及數目單位** | • 完整涵蓋 14 大生活情境量詞：1. 小型通用物（つ）、2. 一般物件（個・件）、3. 人數（人：ひとり、ふたり、よにん）、4. 細長物（本）、5. 薄片物（枚）、6. 書籍（冊）、7. 動物（匹・頭・羽）、8. 杯裝飲品（杯：いっぱい、さんばい、ろっぱい）、9. 車輛電器（台）、10. 樓層（階：さんがい）、11. 年齡（歳：はたち）、12. 次數（回）、13. 日期與住宿天數（日・日間・泊）、14. 鞋襪衣物與餐點份數（足・着・人前）。<br>• 每個量詞均附 1〜10＋疑問詞完整讀音變化表、情境例句、發音播放與常見錯誤提醒。 |
| **模組 D** | **日語日常生活會話** | • 完整 13 課旅遊與生活情境：1. 打招呼、2. 自我介紹、3. 初次見面、4. 感謝及道歉、5. 餐廳點餐、6. 購物及詢問價格/免稅、7. 問路及搭車、8. 酒店入住及退房、9. 機場入境常用語、10. 詢問時間及營業日期、11. 表達喜好與飲食禁忌（わさび抜き等）、12. 聽不懂時請對方慢說或寫漢字、13. 緊急求助（護照錢包遺失、交番、病院）。<br>• 每課含多輪對話、逐句正常/慢速發音、生字收藏、文法與正式/非正式對比及隨堂練習。 |
| **模組四** | **學習計劃・測驗・SRS錯題・統計** | • **4.1 每日學習計劃**：支援每日 5 / 10 / 15 / 30 分鐘目標設定、每日提醒時間設定與智慧推薦任務。<br>• **4.2 測驗模式**：涵蓋全部 8 大題型（看字選讀音、聽音選假名、假名配羅馬拼音、平片假名配對、數字音變、量詞選擇、會話填空、中日文互譯）。<br>• **4.3 錯題及 SRS 複習系統**：自動記錄答錯題目，依錯誤次數排序，並採用間隔重複（1天 → 3天 → 7天 → 14天）動態調整複習排程；支援自訂生字與句子收藏夾。<br>• **4.4 真實學習統計**：所有統計數據 100% 來自本機實際操作紀錄（初始為 0，無虛構數據）。 |

### 2.2 UI/UX 設計規範 (Design System)
- **視覺美學**：現代和風極簡設計，採用米白和紙底色 (`#FAF8F5`)、深藍靛色主色 (`#1B365D`) 與朱紅鳥居強調色 (`#D64045`)，支援一鍵切換深色模式 (`#0F172A`)。
- **字體與無障礙**：繁體中文採用 `Noto Sans TC`，日文採用 `Noto Sans JP`，支援 100% / 112% / 122% 三段無障礙字體放大，所有觸控按鈕高度均 $\ge 44	ext{--}48	ext{dp}$。

### 2.3 專案目錄結構 (`japanese_step_by_step_flutter_project.zip`)
```text
japanese_step_by_step_flutter/
├── pubspec.yaml                          # Flutter 依賴設定 (flutter_tts, shared_preferences, sqflite 等)
├── analysis_options.yaml                 # Dart Lint 靜態檢查規則
├── README.md                             # 專案架構與快速建置說明
├── assets/
│   └── data/
│       └── japanese_curriculum.json      # 完整獨立教學資料庫 (117假名、6大數字、14量詞、13會話、20測驗)
├── android/
│   └── app/src/main/AndroidManifest.xml  # Android 權限與 TTS Intent 設定
├── ios/
│   └── Runner/Info.plist                 # iOS 麥克風與語音辨識權限說明
├── lib/
│   ├── main.dart                         # App 入口、底部導覽與核心頁面路由
│   ├── theme/
│   │   └── app_theme.dart                # 淺色／深色模式與無障礙字體 Design System
│   ├── models/
│   │   └── curriculum_models.dart        # 假名、數字、量詞、會話、測驗與 SRS 資料模型
│   ├── services/
│   │   ├── speech_service.dart           # 系統原生 TTS 與 STT 語音服務封裝與錯誤處理
│   │   ├── handwriting_evaluator.dart    # 手寫筆畫數與九宮格空間覆蓋率近似評估器
│   │   └── study_progress_service.dart   # 本機持久化學習紀錄、每日目標與 SRS 錯題管理
│   └── widgets/
│       └── handwriting_canvas_widget.dart# 觸控描紅與自由書寫畫布元件
└── test/
    └── curriculum_and_logic_test.dart    # Flutter 資料完整性、音變規則與計分邏輯單元測試
```

## 三、Phase 4：測試執行結果與品質保證報告

| 測試項目 | 測試內容 | 執行狀態 | 執行結果說明 |
| :--- | :--- | :--- | :--- |
| 1. 五十音資料完整性測試 | 驗證清音 46、濁音 20、半濁音 5、拗音 33、外來語 13 共 117 項 | **已執行 (通過)** | Python 自動化測試 `test_01` 驗證 100% 通過 |
| 2. 羅馬拼音與讀音資料檢查 | 驗證所有假名具備非空羅馬拼音、筆順數、方向與繁中記憶法 | **已執行 (通過)** | Python 自動化測試 `test_02` 驗證 100% 通過 |
| 3. 易混淆假名與促音長音檢查 | 驗證 シ/ツ、ソ/ン、ぬ/め 等 7 組比較與促音/長音例句 | **已執行 (通過)** | Python 自動化測試 `test_03` 驗證 100% 通過 |
| 4. 數字與量詞特殊讀法測試 | 驗證 300/600/800/3000/8000 及 14 大量詞（ひとり、さんばい等） | **已執行 (通過)** | Python 自動化測試 `test_04` & `test_05` 驗證通過 |
| 5. 會話與測驗計分邏輯測試 | 驗證 13 課多輪會話與 8 大測驗題型、SRS 間隔計算邏輯 | **已執行 (通過)** | Python 自動化測試 `test_06` & `test_07` 驗證通過 |
| 6. 互動預覽版靜態與語法檢查 | 驗證 HTML/JS 語法、按鈕綁定、無死連結、手寫畫布與 TTS 錯誤處理 | **已執行 (通過)** | `check_web_app.py` 檢測結果：`OK: no issues found.` |
| 7. Android / iOS 實機二進位編譯測試 | 執行 `flutter test`、`flutter build apk`、`flutter build ipa` | **尚未執行（需本機 SDK）** | 因沙盒環境無 Flutter SDK / Android Studio / Xcode，已提供完整原始碼與下方標準建置指南 |

## 四、Android (APK / AAB) 與 iOS (IPA) 正式建置與上架指南

### 4.1 開發環境準備
1. 安裝 **Flutter SDK (3.19 或以上穩定版)**，執行 `flutter doctor` 確認環境正常。
2. 解壓縮本專案交付之 `japanese_step_by_step_flutter_project.zip`：
   ```bash
   unzip japanese_step_by_step_flutter_project.zip -d japanese_step_by_step
   cd japanese_step_by_step
   ```
3. 若首次建立平台底層目錄，請在專案根目錄執行：
   ```bash
   flutter create . --org com.japanesestepbystep --project-name japanese_step_by_step
   flutter pub get
   ```
4. 執行單元測試驗證：
   ```bash
   flutter test test/curriculum_and_logic_test.dart
   ```

### 4.2 Android 建置及安裝指南（產生 APK 與 Google Play AAB）
1. **需求環境**：Android Studio (含 Android SDK API 34+、Command-line Tools、JDK 17)。
2. **連接 Android 手機實機測試**：
   ```bash
   flutter run -d android
   ```
3. **產生可安裝的正式版 APK 檔案**：
   ```bash
   flutter build apk --release
   # 產出路徑：build/app/outputs/flutter-apk/app-release.apk
   ```
4. **產生上架 Google Play 所需的 App Bundle (AAB)**：
   - 先建立簽章金鑰：`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   - 於 `android/key.properties` 設定金鑰路徑後執行：
   ```bash
   flutter build appbundle --release
   # 產出路徑：build/app/outputs/bundle/release/app-release.aab
   ```

### 4.3 iOS 建置及安裝指南（產生 IPA 與 App Store 發佈）
1. **需求環境**：macOS 電腦、Xcode 15+、CocoaPods (`sudo gem install cocoapods`) 及 Apple Developer Program 帳號。
2. **安裝 iOS Pods 依賴並開啟 Xcode 設定簽章 (Signing & Capabilities)**：
   ```bash
   cd ios && pod install && cd ..
   open ios/Runner.xcworkspace
   ```
   在 Xcode 中選擇 `Runner` Target → `Signing & Capabilities` → 勾選 `Automatically manage signing` 並選擇您的 Apple Developer Team。
3. **產生正式版 iOS IPA 檔案**：
   ```bash
   flutter build ipa --release
   # 產出路徑：build/ios/archive/Runner.xcarchive（可透過 Xcode Organizer 直接上傳至 App Store Connect / TestFlight）
   ```

### 4.4 Google Play 及 Apple App Store 發佈前檢查清單
- [x] **離線可用性與免註冊體驗**：首次打開 App 無須註冊登入即可完整學習五十音、數字、量詞與會話。
- [x] **權限最小化與隱私聲明**：僅在使用者主動點擊跟讀時請求麥克風權限 (`RECORD_AUDIO` / `NSMicrophoneUsageDescription`)，無背景錄音或第三方追蹤 SDK。
- [x] **無硬編碼 API 金鑰**：完全採用本機離線資料庫與系統原生 TTS，原始碼內不含任何外洩風險之 API Key。
- [ ] **商店素材準備（上架前由發行者配置）**：準備 1024x1024 應用程式圖示、手機螢幕截圖及隱私權政策網址。
