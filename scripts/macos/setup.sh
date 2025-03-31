#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_homebrew() {
  title "Setting up Homebrew"

  if test ! "$(command -v brew)"; then
    info "Homebrew not installed. Installing."
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
  fi

  # install brew dependencies from Brewfile
  brew bundle

  # install fzf
  info "Installing fzf"
  "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
}

setup_macos_preferences() {
  title "Configuring macOS preferences"
  
  # System preferences
  set_system_preferences
  
  # Finder preferences
  set_finder_preferences
  
  # Dock preferences
  set_dock_preferences
  
  # Mail preferences
  set_mail_preferences
  
  # Calendar preferences
  set_calendar_preferences
  
  # Activity Monitor preferences
  set_activity_monitor_preferences
  
  # Software Update preferences
  set_software_update_preferences
  
  # Kill affected applications
  killall Safari Finder Dock Mail SystemUIServer Calendar iCal >/dev/null 2>&1
}

set_system_preferences() {
  echo "Setting system preferences..."
  
  # Computer name
  sudo scutil --set ComputerName "megatron"
  sudo scutil --set HostName "megatron"
  sudo scutil --set LocalHostName "megatron"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "megatron"

  # Battery percentage
  defaults write com.apple.menuextra.battery ShowPercent YES

  # Window resize speed
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # File extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Hidden files
  defaults write com.apple.Finder AppleShowAllFiles -bool false

  # Quick Look text selection
  defaults write com.apple.finder QLEnableTextSelection -bool true

  # POSIX path in title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Folders on top
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # .DS_Store files
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # AirDrop
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  # List view
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # File Info panes
  defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

  # Terminal UTF-8
  defaults write com.apple.terminal StringEncodings -array 4

  # Save dialog
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Print panel
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Printer app
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Save to disk
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Library folder
  chflags nohidden ~/Library

  # Keyboard access
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Font rendering
  defaults write NSGlobalDomain AppleFontSmoothing -int 2

  # Search scope
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Smart quotes
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
}

set_finder_preferences() {
  echo "Setting Finder preferences..."
}

set_dock_preferences() {
  echo "Setting Dock preferences..."
  defaults write com.apple.dock show-process-indicators -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock showhidden -bool true
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tr-corner -int 0
  defaults write com.apple.dock wvous-bl-corner -int 0
  defaults write com.apple.dock wvous-br-corner -int 0
  defaults write com.Apple.Dock show-recents -bool false
}

set_mail_preferences() {
  echo "Setting Mail preferences..."
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true
  defaults write com.apple.mail ConversationViewMarkAllAsRead -bool true
  defaults write com.apple.mail IndexTrash -bool false
  defaults write com.apple.mail AutoFetch -bool true
  defaults write com.apple.mail PollTime -string "-1"
  defaults write com.apple.mail ConversationViewSortDescending -bool true
}

set_calendar_preferences() {
  echo "Setting Calendar preferences..."
  defaults write com.apple.iCal "Show Week Numbers" -bool true
  defaults write com.apple.iCal "first day of week" -int 1
}

set_activity_monitor_preferences() {
  echo "Setting Activity Monitor preferences..."
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  defaults write com.apple.ActivityMonitor IconType -int 5
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}

set_software_update_preferences() {
  echo "Setting Software Update preferences..."
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -string 7
  defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
  defaults write com.apple.commerce AutoUpdate -bool true
  defaults write com.apple.commerce AutoUpdateRestartRequired -bool true
} 