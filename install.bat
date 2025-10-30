:: install scoop
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
powershell -Command "irm get.scoop.sh -outfile 'install.ps1'"
powershell -Command ".\install.ps1 -RunAsAdmin"

:: install apps
scoop install git neovim powertoys fd fzf ripgrep gcc nodejs luarocks

cd %USERPROFILE%
git clone https://github.com/HellHBBD/dotfiles.git
cd dotfiles
git checkout exam

:: 刪掉舊設定
if exist "%USERPROFILE%\AppData\Local\nvim" rmdir /s /q "%USERPROFILE%\AppData\Local\nvim"

mklink /D "%USERPROFILE%\AppData\Local\nvim" "%USERPROFILE%\dotfiles\nvim\.config\nvim"

npm -g install live-server
