@echo off
chcp 65001 >nul
echo ========================================================
echo   日語一步通 (Japanese Step-by-Step) 一鍵打包 APK 工具
echo ========================================================
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [錯誤] 找不到 Flutter SDK，請先安裝 Flutter 並加入 PATH，或使用 GitHub Actions 免安裝雲端打包。
    pause
    exit /b 1
)
echo [1/4] 重新產生完整 Android 原生 Gradle 結構...
if exist android rmdir /s /q android
if exist ios rmdir /s /q ios
call flutter create --platforms=android,ios --project-name japanese_step_by_step --org com.japanesestepbystep .
echo [2/4] 注入語音權限、Android 11+ TTS/STT Queries 與 minSdk 23...
python tool/patch_android_ios.py
echo [3/4] 下載離線儲存與語音套件...
call flutter pub get
echo [4/4] 正在編譯 Android Release APK...
call flutter build apk --release --no-tree-shake-icons
echo.
echo ========================================================
echo   編譯完成！請將以下 APK 檔案傳至手機安裝：
echo   build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
pause
