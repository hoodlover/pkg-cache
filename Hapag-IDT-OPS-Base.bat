@echo off
echo Setting up OPS-BASE...

set "DEFAULT_DATA_DIR=%USERPROFILE%\Documents\OPS-BASE"
set "SETTINGS_DIR=%APPDATA%\OPS-BASE"
set "SETTINGS_FILE=%SETTINGS_DIR%\settings.json"

mkdir "%SETTINGS_DIR%" 2>nul

echo Please choose where OPS-BASE should save your data...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $default='%DEFAULT_DATA_DIR%'; New-Item -ItemType Directory -Force -Path $default | Out-Null; $dialog=New-Object System.Windows.Forms.FolderBrowserDialog; $dialog.Description='Choose where OPS-BASE should save your data'; $dialog.SelectedPath=$default; $dialog.ShowNewFolderButton=$true; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $dialog.SelectedPath } else { $default }" > "%TEMP%\opsbase_data_dir.txt"

set /p DATA_DIR=<"%TEMP%\opsbase_data_dir.txt"
del /q "%TEMP%\opsbase_data_dir.txt"

if "%DATA_DIR%"=="" set "DATA_DIR=%DEFAULT_DATA_DIR%"
mkdir "%DATA_DIR%" 2>nul

echo Saving settings...
powershell -Command "$settingsDir='%SETTINGS_DIR%'; $settingsFile='%SETTINGS_FILE%'; $dataDir='%DATA_DIR%'; [pscustomobject]@{ appName='OPS-BASE'; dataDir=$dataDir; createdAt=(Get-Date).ToString('o') } | ConvertTo-Json | Set-Content -Encoding UTF8 -Path $settingsFile"
setx OPSBRIDGE_DATA_DIR "%DATA_DIR%"

mkdir "%LOCALAPPDATA%\OPS-BASE_Install" 2>nul
cd /d "%LOCALAPPDATA%\OPS-BASE_Install"

echo Downloading OPS-BASE...
curl.exe -sL -o OPS-BASE.msi "https://github.com/hoodlover/pkg-cache/raw/main/Hapag-IDT-OPS-Base.msi"

echo Installing...
msiexec /a OPS-BASE.msi /qb TARGETDIR="%LOCALAPPDATA%\OPS-BASE"

echo Creating desktop shortcut...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut([System.Environment]::GetFolderPath('Desktop') + '\OPS-BASE.lnk');$s.TargetPath=\"$env:LOCALAPPDATA\OPS-BASE\PFiles\OPS-BASE Tiny\app.exe\";$s.Arguments='--data-dir \"%DATA_DIR%\"';$s.Save()"

echo Adding to startup...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\OPS-BASE.lnk');$s.TargetPath=\"$env:LOCALAPPDATA\OPS-BASE\PFiles\OPS-BASE Tiny\app.exe\";$s.Arguments='--data-dir \"%DATA_DIR%\"';$s.Save()"

cd /d "%LOCALAPPDATA%"
rmdir /s /q "%LOCALAPPDATA%\OPS-BASE_Install"

echo Launching OPS-BASE...
start "" "%LOCALAPPDATA%\OPS-BASE\PFiles\OPS-BASE Tiny\app.exe" --data-dir "%DATA_DIR%"
