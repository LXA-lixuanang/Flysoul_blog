@echo off
chcp 65001 >nul
title Hexo Auto Deploy Tool
color 0A

echo ==========================================
echo    Hexo Blog One-Click Deploy Script
echo ==========================================
echo.

:: 1. 清理旧缓存
echo [1/4] Cleaning old files...
call hexo clean
if errorlevel 1 (
    echo ERROR: Hexo clean failed! Please check your environment.
    pause
    exit /b
)

:: 2. 生成静态网页
echo [2/4] Generating static files...
call hexo generate
if errorlevel 1 (
    echo ERROR: Hexo generate failed! Check your markdown syntax.
    pause
    exit /b
)

:: 3. Git 操作 (添加、提交、推送)
echo [3/4] Committing changes to Git...
git add .

:: 检查是否有文件被修改，如果没有修改则跳过提交和推送
git diff --cached --quiet
if errorlevel 1 (
    :: 有文件变动，获取当前时间作为提交信息
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
    set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
    set "timestamp=%YYYY%-%MM%-%DD% %HH%:%Min%"

    git commit -m "Auto deploy: %timestamp%"
    
    echo [4/4] Pushing to remote repository...
    git push origin main
    if errorlevel 1 (
        echo ERROR: Push failed! You might need to pull first or check network.
        pause
        exit /b
    )
) else (
    echo WARNING: No changes detected. Skipping commit and push.
)

echo.
echo ==========================================
echo    Deployment Finished Successfully!
echo ==========================================
echo.
pause