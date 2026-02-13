#!/bin/sh

# Switch keyboard language
reg add "HKEY_CURRENT_USER\\Keyboard Layout\\Preload" -v 1 -t REG_SZ -d $KEYBOARD_LANGUAGE -f

# Allow to suspend updates for up to 1 year
reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings" -v FlightSettingsMaxPauseDays -t REG_DWORD -d 365 -f

# Follow https://superuser.com/questions/1052763 to reduce the over-animating
reg add "HKEY_CURRENT_USER\\Control Panel\\Desktop\\WindowMetrics" -v MinAnimate -t REG_SZ -d 0 -f

# Extend the evaluation period if it did not yet happen
if $WINDIR/System32/cscript $WINDIR/System32/slmgr.vbs -dlv | findstr -BEC:"Remaining Windows rearm count: 4"; then
  $WINDIR/System32/cscript $WINDIR/System32/slmgr.vbs -rearm
fi

# Install stuff from here and there
###############################################################################

# Install rootsupd.exe
if [ ! -f rootsupd.zip ]; then
  /usr/bin/curl -kLO https://github.com/Voronenko/winfiles/raw/refs/heads/master/bin/rootsupd.zip
  /usr/bin/tar -xf rootsupd.zip -C $WINDIR
fi

# Update certificates
rootsupd.exe

# Install Visual C++ runtimes (Win7 needs older ones)
if [ ! -f vc_redist.*.exe ]; then
  if reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion" -v CurrentVersion | findstr -EC:" 6.1"; then
    /usr/bin/curl -LO https://aka.ms/vs/16/release/VC_redist.x64.exe
    /usr/bin/curl -LO https://aka.ms/vs/16/release/VC_redist.x86.exe
  else
    /usr/bin/curl -LO https://aka.ms/vc14/vc_redist.x64.exe
    /usr/bin/curl -LO https://aka.ms/vc14/vc_redist.x86.exe
  fi
  ./vc_redist.x64.exe -passive
  ./vc_redist.x86.exe -passive
fi

# Install tuxliketimeout.exe
if [ ! -f $WINDIR/tuxliketimeout.exe ]; then
  /usr/bin/curl -L https://github.com/cernoch/tuxliketimeout/releases/download/v1.0/tuxliketimeout.exe -o $WINDIR/tuxliketimeout.exe
fi

# Install mkshortcut.exe
if [ ! -f $WINDIR/mkshortcut.exe ]; then
  /usr/bin/curl -LO https://github.com/darealshinji/mkshortcut/releases/download/r4/mkshortcut.zip
  /usr/bin/tar -xf mkshortcut.zip -C $WINDIR
fi

# Install iridium browser
/usr/bin/curl -LO https://downloads.iridiumbrowser.de/windows/2022.04.100/iridiumbrowser-2022.04.100.0-x64.msi
msiexec -i iridiumbrowser-2022.04.100.0-x64.msi -passive
mkshortcut /o:"C:\\Users\\vagrant\\Desktop\\Iridium Browser.lnk" /t:"C:\\Program Files\\Iridium\\iridium.exe"

# Install fonts
/usr/bin/curl -L https://github.com/ChiefMikeK/ttf-symbola/raw/refs/heads/master/Symbola-12.ttf -o $WINDIR/Fonts/Symbola.ttf
reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" -v "Symbola (TrueType)" -t REG_SZ -d Symbola.ttf -f
/usr/bin/curl -L https://github.com/leanprover/presentations/raw/refs/heads/master/fonts/unifont.ttf -o $WINDIR/Fonts/unifont.ttf
reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" -v "Unifont (TrueType)" -t REG_SZ -d unifont.ttf -f

# Adjust font preferences
/usr/bin/mkdir -p "C:/Users/vagrant/AppData/Local/Iridium/User Data/Default"
findstr -r . << EOF > "C:/Users/vagrant/AppData/Local/Iridium/User Data/Default/Preferences"
{
  "webkit": {
    "webprefs": {
      "fonts": {
        "fixed": {
          "Zyyy": "Unifont"
        },
        "sansserif": {
          "Zyyy": "Symbola"
        },
        "serif": {
          "Zyyy": "Symbola"
        },
        "standard": {
          "Zyyy": "Symbola"
        }
      }
    }
  }
}
EOF

. ${0%.*}.pp

$WINDIR/System32/shutdown /s
