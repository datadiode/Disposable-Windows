@echo off

setlocal
cd %~dp0

:: Get OpenSSH 9.0p1-1 installer source files from www.mls-software.com
curl -LO https://www.mls-software.com/files/installer_source_files.90p1-1.zip
tar -xvf installer_source_files.90p1-1.zip -C ..

:: Get fixed InstallerSupport/UnInstallerProcess.nsi from www.mls-software.com
curl -LO https://www.mls-software.com/files/installer_source_files.100p1-1.7z
tar -xvf installer_source_files.100p1-1.7z -C .. openssh/InstallerSupport/UnInstallerProcess.nsi

echo none /cygdrive cygdrive binary,noacl,posix=0,user 0 0 > etc\fstab

:: Get the Mozilla CA bundle from https://github.com/bagder/ca-bundle
curl -LO https://raw.githubusercontent.com/bagder/ca-bundle/refs/heads/master/ca-bundle.crt

:: Add cygwin's bsdtar and curl to bin32, bin64 folders, assuming they exist
:: as installed through https://github.com/datadiode/cygwin-portable-installer

set "CYGWIN32=D:\cygwin32"
set "CYGWIN64=D:\cygwin64"

for %%u in ("%CYGWIN32%\bin\bsdtar.exe" "%CYGWIN32%\bin\curl.exe") do (
  pushd %CYGWIN32%\bin
  for /f "tokens=*" %%v in ('%CYGWIN32%\bin\cygcheck %%u') do if "%%~dpv" == "%%~dpu" xcopy /y %%v %~dp0bin32
  popd
)

for %%u in ("%CYGWIN64%\bin\bsdtar.exe" "%CYGWIN64%\bin\curl.exe") do (
  pushd %CYGWIN64%\bin
  for /f "tokens=*" %%v in ('%CYGWIN64%\bin\cygcheck %%u') do if "%%~dpv" == "%%~dpu" xcopy /y %%v %~dp0bin64
  popd
)

"%ProgramFiles(x86)%\NSIS\makensis.exe" setupssh.nsi setupssh-extras.nsi
