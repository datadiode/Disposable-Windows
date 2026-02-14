#!/bin/sh

# Switch keyboard language
reg add "HKEY_CURRENT_USER\\Keyboard Layout\\Preload" -v 1 -t REG_SZ -d $KEYBOARD_LANGUAGE -f

# Allow to suspend updates for up to 1 year
reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings" -v FlightSettingsMaxPauseDays -t REG_DWORD -d 365 -f

# Follow https://superuser.com/questions/1244934 to reduce visual effect bloat and tweak Windows Explorer behavior
# 0 = Let Windows choose what’s best for my computer
# 1 = Adjust for best appearance
# 2 = Adjust for best performance
# 3 = Custom
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" -v "VisualFXSetting" -t REG_DWORD -d 3 -f
# This disables the following 8 settings:
# - Animate controls and elements inside windows
# - Fade or slide menus into view
# - Fade or slide ToolTips into view
# - Fade out menu items after clicking
# - Show shadows under mouse pointer
# - Show shadows under windows
# - Slide open combo boxes
# - Smooth-scroll list boxes
reg add "HKCU\\Control Panel\\Desktop" -v "UserPreferencesMask" -t REG_BINARY -d "90 12 03 80 10 00 00 00" -f
# Open File Explorer to: This PC
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "LaunchTo" -t REG_DWORD -d 1 -f
# Show hidden files, folders, and drives
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "Hidden" -t REG_DWORD -d 1 -f
# Hide protected operating system files (Recommended)
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "ShowSuperHidden" -t REG_DWORD -d 0 -f
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "HideIcons" -t REG_DWORD -d 0 -f
# Hide extensions for known file types
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "HideFileExt" -t REG_DWORD -d 0 -f
# Navigation pane: Expand to open folder
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "NavPaneExpandToCurrentFolder" -t REG_DWORD -d 1 -f
# Navigation pane: Show all folders
reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "NavPaneShowAllFolders" -t REG_DWORD -d 1 -f
# Animate windows when minimizing and maximizing
reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" -v "MinAnimate" -d 0 -f
# Animations in the taskbar
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "TaskbarAnimations" -t REG_DWORD -d 0 -f
# Enable Peek
reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" -v "EnableAeroPeek" -t REG_DWORD -d 0 -f
# Save taskbar thumbnail previews
reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" -v "AlwaysHibernateThumbnails" -t REG_DWORD -d 0 -f
# Show translucent selection rectangle
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "ListviewAlphaSelect" -t REG_DWORD -d 0 -f
# Show thumbnails instead of icons
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "IconsOnly" -t REG_DWORD -d 0 -f
# Show window contents while dragging
reg add "HKCU\\Control Panel\\Desktop" -v "DragFullWindows" -d 0 -f
# Smooth edges of screen fonts
reg add "HKCU\\Control Panel\\Desktop" -v "FontSmoothing" -d 2 -f
# Use drop shadows for icon labels on the desktop
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" -v "ListviewShadow" -t REG_DWORD -d 0 -f

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
