setlocal
cd %~dp0

Get OpenSSH 9.0p1-1 installer source files from www.mls-software.com
curl -LO https://www.mls-software.com/files/installer_source_files.90p1-1.zip
tar -xvf installer_source_files.90p1-1.zip -C ..

REM Add tar.exe to bin32, bin64 folders
curl -L https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/i18n-zh/libarchine-3.1.2-win32.7z -o libarchine-win32.7z
tar -xvf libarchine-win32.7z -C bin32 --strip-components=1
curl -L https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/i18n-zh/libarchine-3.1.2-win64.7z -o libarchine-win64.7z
tar -xvf libarchine-win64.7z -C bin64 --strip-components=1

REM Add curl.exe to bin32, bin64 folders
curl -L https://github.com/fcharlie/wincurl/releases/download/8.18.0.1/wincurl-win64-8.18.0.1.zip -o wincurl-win64.zip
tar -xvf wincurl-win64.zip -C bin64 curl.exe
curl -L https://github.com/fcharlie/wincurl/releases/download/7.83.1.1/wincurl-win32-7.83.1.1.zip -o wincurl-win32.zip
tar -xvf wincurl-win32.zip -C bin32 --strip-components=1 bin/curl.exe bin/curl-ca-bundle.crt

"%ProgramFiles(x86)%\NSIS\makensis.exe" setupssh.nsi setupssh-extras.nsi
