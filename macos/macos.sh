#!/usr/bin/env bash
# macos.sh — system preferences
# Usage: bash "$0" [--check]
#
# Inspect any domain directly:
#   defaults read com.apple.dock
#   defaults read com.apple.finder
#   defaults read NSGlobalDomain
#   defaults read com.apple.AppleMultitouchTrackpad
#   defaults read com.apple.universalaccess
#   defaults read com.apple.Safari
#   defaults read com.apple.menuextra.clock
#   defaults read /Library/Preferences/com.apple.alf   # firewall (needs sudo)
# Diff trick:
#   defaults read <domain> > /tmp/before.txt  # change in System Settings  # diff /tmp/before.txt <(defaults read <domain>)

# rd <domain> <key> — print value or "not set"; never exits 1
rd() { defaults read "$1" "$2" 2>/dev/null || echo "not set"; }

if [[ "${1:-}" == "--check" ]]; then
  echo "=== Appearance ==="
  echo "Dark mode:              $(rd NSGlobalDomain AppleInterfaceStyle)"
  echo "Scroll bars:            $(rd NSGlobalDomain AppleShowScrollBars)"
  echo "First weekday:          $(defaults read NSGlobalDomain AppleFirstWeekday 2>/dev/null | grep -o '[0-9]' | tail -1 || echo 'not set')"
  echo "=== Keyboard ==="
  echo "KeyRepeat:              $(rd NSGlobalDomain KeyRepeat)"
  echo "InitialKeyRepeat:       $(rd NSGlobalDomain InitialKeyRepeat)"
  echo "PressAndHold:           $(rd NSGlobalDomain ApplePressAndHoldEnabled)"
  echo "SmartQuotes:            $(rd NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled)"
  echo "SmartDashes:            $(rd NSGlobalDomain NSAutomaticDashSubstitutionEnabled)"
  echo "AutoCapitalise:         $(rd NSGlobalDomain NSAutomaticCapitalizationEnabled)"
  echo "=== Trackpad ==="
  echo "Tap to click:           $(rd com.apple.AppleMultitouchTrackpad Clicking)"
  echo "Three-finger drag:      $(rd com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag)"
  echo "App Exposé:             $(rd com.apple.dock showAppExposeGestureEnabled)"
  echo "=== Accessibility ==="
  echo "Control+scroll zoom:    $(rd com.apple.universalaccess closeViewScrollWheelToggle)"
  echo "=== Dock ==="
  echo "Autohide:               $(rd com.apple.dock autohide)"
  echo "Autohide delay:         $(rd com.apple.dock autohide-delay)"
  echo "Tile size:              $(rd com.apple.dock tilesize)"
  echo "Orientation:            $(rd com.apple.dock orientation)"
  echo "Show recents:           $(rd com.apple.dock show-recents)"
  echo "Magnification:          $(rd com.apple.dock magnification)"
  echo "=== Menu bar ==="
  echo "Auto-hide:              $(rd NSGlobalDomain _HIHideMenuBar)"
  echo "Spotlight icon hidden:  $(rd com.apple.controlcenter Spotlight)"
  echo "=== Finder ==="
  echo "New window target:      $(rd com.apple.finder NewWindowTarget)"
  echo "Hidden files:           $(rd com.apple.finder AppleShowAllFiles)"
  echo "All extensions:         $(rd NSGlobalDomain AppleShowAllExtensions)"
  echo "Path in title:          $(rd com.apple.finder _FXShowPosixPathInTitle)"
  echo "Folders on top:         $(rd com.apple.finder _FXSortFoldersFirst)"
  echo "Folders on top desktop: $(rd com.apple.finder _FXSortFoldersFirstOnDesktop)"
  echo "Recent tags:            $(rd com.apple.finder ShowRecentTags)"
  echo "External drives desktop:$(rd com.apple.finder ShowExternalHardDrivesOnDesktop)"
  echo "Removable on desktop:   $(rd com.apple.finder ShowRemovableMediaOnDesktop)"
  echo "=== Safari ==="
  echo "Develop menu:           $(rd com.apple.Safari IncludeDevelopMenu)"
  echo "Status bar:             $(rd com.apple.Safari ShowStatusBar)"
  echo "=== Screenshots ==="
  echo "Location:               $(rd com.apple.screencapture location)"
  echo "Disable shadow:         $(rd com.apple.screencapture disable-shadow)"
  echo "=== Firewall ==="
  echo "State:                  $(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo 'unknown (try sudo)')"
  exit 0
fi

set -euo pipefail
echo "Applying macOS preferences..."

# When run as root: apply only settings that require elevated privileges, then exit
if [ "$(id -u)" = "0" ]; then
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  echo "Done (sudo: accessibility + firewall applied)."
  exit 0
fi

# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

echo "Accessibility zoom: run manually → sudo bash \"$0\""

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 75
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock magnification -bool false

# Menu bar

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Safari — sandboxed on Sequoia; these writes are no-ops but kept for reference
defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null || true
defaults write com.apple.Safari ShowStatusBar -bool true 2>/dev/null || true

# Screenshots
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Menu bar clock
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowSeconds -bool false

# Stats
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
if [ -f "$DOTFILES/config/stats.plist" ]; then
  defaults import eu.exelban.Stats "$DOTFILES/config/stats.plist"
fi

echo "Firewall: run manually → sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1"

for app in "Finder" "Dock" "SystemUIServer" "Safari"; do
  killall "$app" &>/dev/null || true
done
echo "Done. Menu bar auto-hide and zoom need a logout/restart."
