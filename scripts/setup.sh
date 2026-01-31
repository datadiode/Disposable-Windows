#!/bin/sh

# Allow to suspend updates for up to 1 year
reg add HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings /v FlightSettingsMaxPauseDays /t REG_DWORD /d 365 /f

# Extend the evaluation period if it did not yet happen
if $WINDIR/System32/cscript $WINDIR/System32/slmgr.vbs -dlv | $WINDIR/System32/find "Remaining Windows rearm count: 2"; then
  $WINDIR/System32/cscript $WINDIR/System32/slmgr.vbs -rearm
fi

# Install stuff from here and there
###############################################################################

# Install rootsupd.exe
if [ ! -f rootsupd.zip ]; then
  curl -kLO https://github.com/Voronenko/winfiles/raw/refs/heads/master/bin/rootsupd.zip
  tar -xf rootsupd.zip -C $WINDIR
fi

# Update certificates
rootsupd.exe

# Install Visual C++ runtimes
if [ ! -f vc_redist.x64.exe ]; then
  curl -LO https://aka.ms/vc14/vc_redist.x64.exe
  ./vc_redist.x64.exe -passive
fi
if [ ! -f vc_redist.x86.exe ]; then
  curl -LO https://aka.ms/vc14/vc_redist.x86.exe
  ./vc_redist.x86.exe -passive
fi

# Install tuxliketimeout.exe
if [ ! -f $WINDIR/tuxliketimeout.exe ]; then
  curl -L https://github.com/cernoch/tuxliketimeout/releases/download/v1.0/tuxliketimeout.exe -o $WINDIR/tuxliketimeout.exe
fi

# Install PsExec.exe
if [ ! -f $WINDIR/PsExec.exe ]; then
  curl -L https://github.com/davehardy20/sysinternals/raw/refs/heads/master/PsExec.exe -o $WINDIR/PsExec.exe
fi

# Switch keyboard language
echo KEYBOARD_LANGUAGE=$KEYBOARD_LANGUAGE
PsExec -accepteula -nobanner -i 1 powershell -command "\$ProgressPreference = 'SilentlyContinue'; Set-WinUserLanguageList -Force '$KEYBOARD_LANGUAGE'"

# Install WebView2 runtime if none exists yet
if ! reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /ve; then
  if [ ! -f tis-webview2_*_PROD.wapt ]; then
    curl -LO https://wapt.tranquil.it/store/en/wapt/tis-webview2_143.0.3650.96-12_x64_windows_10.0_PROD.wapt
    tar -xf tis-webview2_*_PROD.wapt
    tuxliketimeout 180000 MicrosoftEdgeWebView2RuntimeInstallerX64.exe -silent -install
  fi
fi

. ${0%.*}.pp

$WINDIR/System32/shutdown /s
