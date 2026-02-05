#!/bin/sh

# Switch keyboard language
reg add "HKEY_CURRENT_USER\\Keyboard Layout\\Preload" -v 1 -t REG_SZ -d $KEYBOARD_LANGUAGE -f

# Allow to suspend updates for up to 1 year
reg add HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings -v FlightSettingsMaxPauseDays -t REG_DWORD -d 365 -f

# Extend the evaluation period if it did not yet happen
if $WINDIR/System32/cscript $WINDIR/System32/slmgr.vbs -dlv | findstr -BEC:"Remaining Windows rearm count: 4"; then
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

# Install Visual C++ runtimes (Win7 needs older ones)
if [ ! -f vc_redist.*.exe ]; then
  if reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion" -v CurrentVersion | findstr -EC:" 6.1"; then
    curl -LO https://aka.ms/vs/16/release/VC_redist.x64.exe
    curl -LO https://aka.ms/vs/16/release/VC_redist.x86.exe
  else
    curl -LO https://aka.ms/vc14/vc_redist.x64.exe
    curl -LO https://aka.ms/vc14/vc_redist.x86.exe
  fi
  ./vc_redist.x64.exe -passive
  ./vc_redist.x86.exe -passive
fi

# Install tuxliketimeout.exe
if [ ! -f $WINDIR/tuxliketimeout.exe ]; then
  curl -L https://github.com/cernoch/tuxliketimeout/releases/download/v1.0/tuxliketimeout.exe -o $WINDIR/tuxliketimeout.exe
fi

# Install WebView2 runtime if none exists yet (version chosen with Win7 in mind)
if ! reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -ve; then
  if [ ! -f MicrosoftEdgeWebView2RuntimeInstallerX64.exe ]; then
    curl -LO https://archive.org/download/microsoft-edge-web-view-2-runtime-installer-v109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe
    tuxliketimeout 90000 MicrosoftEdgeWebView2RuntimeInstallerX64.exe -silent -install
  fi
fi

. ${0%.*}.pp

$WINDIR/System32/shutdown /s
