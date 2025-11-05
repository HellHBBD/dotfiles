# ===============================
# 建立三個批次檔 (.bat)
# ===============================

Write-Host "🔧 開始建立三個批次檔..." -ForegroundColor Cyan

# --- Script 1 ---
@'
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
powershell -Command "irm get.scoop.sh -outfile 'install.ps1'"
powershell -Command ".\install.ps1 -RunAsAdmin"
pause
'@ | Out-File -Encoding UTF8 -FilePath "script1.bat"

Write-Host "✅ 已建立 script1.bat" -ForegroundColor Green

# --- Script 2 ---
@'
scoop install git nodejs neovim fd fzf ripgrep gcc luarocks
pause
'@ | Out-File -Encoding UTF8 -FilePath "script2.bat"

Write-Host "✅ 已建立 script2.bat" -ForegroundColor Green

# --- Script 3 ---
@'
cd %USERPROFILE%
git clone https://github.com/HellHBBD/dotfiles.git
cd dotfiles
git checkout exam

if exist "%USERPROFILE%\AppData\Local\nvim" rmdir /s /q "%USERPROFILE%\AppData\Local\nvim"

mklink /D "%USERPROFILE%\AppData\Local\nvim" "%USERPROFILE%\dotfiles\nvim\.config\nvim"

npm -g install live-server
pause
'@ | Out-File -Encoding UTF8 -FilePath "script3.bat"

Write-Host "✅ 已建立 script3.bat" -ForegroundColor Green

Write-Host "`n🎉 全部建立完成！" -ForegroundColor Yellow
