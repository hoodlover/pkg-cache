@echo off
echo Setting up RailHelper...

mkdir "%LOCALAPPDATA%\RailHelper_Install" 2>nul
cd /d "%LOCALAPPDATA%\RailHelper_Install"

curl.exe -sL -o RailHelper.msi "https://github.com/hoodlover/tools/raw/main/RailHelper.msi"

echo Installing...
msiexec /a RailHelper.msi /qb TARGETDIR="%LOCALAPPDATA%\RailHelper"

echo Creating desktop shortcut...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut([System.Environment]::GetFolderPath('Desktop') + '\RailHelper.lnk');$s.TargetPath=\"$env:LOCALAPPDATA\RailHelper\PFiles\OpsBridge Tiny\app.exe\";$s.Save()"

echo Adding to startup...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\RailHelper.lnk');$s.TargetPath=\"$env:LOCALAPPDATA\RailHelper\PFiles\OpsBridge Tiny\app.exe\";$s.Save()"

cd /d "%LOCALAPPDATA%"
rmdir /s /q "%LOCALAPPDATA%\RailHelper_Install"

echo Launching RailHelper...
start "" "%LOCALAPPDATA%\RailHelper\PFiles\OpsBridge Tiny\app.exe"