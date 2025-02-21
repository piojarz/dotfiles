#!/usr/bin/env bash

DOTFILES="$(pwd)"
linkables=(
    "config/common/zsh/.zshrc"
    "config/common/zsh/.zshenv"
    "config/common/zsh/.zstyles"
)

# Configuration home
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
  echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
  echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

cleanup_symlinks() {
  title "Cleaning up symlinks"
  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    if [ -L "$target" ]; then
      info "Cleaning up \"$target\""
      rm "$target"
    elif [ -e "$target" ]; then
      warning "Skipping \"$target\" because it is not a symlink"
    else
      warning "Skipping \"$target\" because it does not exist"
    fi
  done

  echo -e
  info "installing to $config_home"

  config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    if [ -L "$target" ]; then
      info "Cleaning up \"$target\""
      rm "$target"
    elif [ -e "$target" ]; then
      warning "Skipping \"$target\" because it is not a symlink"
    else
      warning "Skipping \"$target\" because it does not exist"
    fi
  done

  if [[ "$OSTYPE" == "darwin"* ]]; then
    mac_config_files=$(find "$DOTFILES/config/macos" -maxdepth 1 2>/dev/null)
    for config in $mac_config_files; do
      target="$config_home/$(basename "$config")"
      if [ -L "$target" ]; then
        info "Cleaning up \"$target\""
        rm "$target"
      elif [ -e "$target" ]; then
        warning "Skipping \"$target\" because it is not a symlink"
      else
        warning "Skipping \"$target\" because it does not exist"
      fi
    done
  fi
}

setup_symlinks() {
  title "Creating symlinks"

  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    if [ -e "$target" ]; then
      info "~${target#"$HOME"} already exists... Skipping."
    else
      info "Creating symlink for $file"
      ln -s "$DOTFILES/$file" "$target"
    fi
  done

  echo -e
  info "installing to $config_home"
  if [ ! -d "$config_home" ]; then
    info "Creating $config_home"
    mkdir -p "$config_home"
  fi

  if [ ! -d "$data_home" ]; then
    info "Creating $data_home"
    mkdir -p "$data_home"
  fi

  config_files=$(find "$DOTFILES/config/common" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    if [ -e "$target" ]; then
      info "~${target#"$HOME"} already exists... Skipping."
    else
      info "Creating symlink for $config"
      ln -s "$config" "$target"
    fi
  done

  if [[ "$OSTYPE" == "darwin"* ]]; then
    mac_config_files=$(find "$DOTFILES/config/macos" -maxdepth 1 2>/dev/null)
    for config in $mac_config_files; do
      target="$config_home/$(basename "$config")"
      if [ -e "$target" ]; then
        info "~${target#"$HOME"} already exists... Skipping."
      else
        info "Creating symlink for $config"
        ln -s "$config" "$target"
      fi
    done
  fi

  # symlink .zshenv into home directory to properly setup ZSH
  if [ ! -e "$HOME/.zshenv" ]; then
    info "Creating symlink for .zshenv"
    ln -s "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
  else
    info "~/.zshenv already exists... Skipping."
  fi
}

copy() {
  if [ ! -d "$config_home" ]; then
    info "Creating $config_home"
    mkdir -p "$config_home"
  fi

  if [ ! -d "$data_home" ]; then
    info "Creating $data_home"
    mkdir -p "$data_home"
  fi
  config_files=$(find "$DOTFILES/config/common" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    info "copying $config to $config_home/$config"
    cp -R "$config" "$target"
  done

  if [[ "$OSTYPE" == "darwin"* ]]; then
    mac_config_files=$(find "$DOTFILES/config/macos" -maxdepth 1 2>/dev/null)
    for config in $mac_config_files; do
      target="$config_home/$(basename "$config")"
      info "copying $config to $config_home/$config"
      cp -R "$config" "$target"
    done
  fi
}

setup_homebrew() {
  title "Setting up Homebrew"

  if test ! "$(command -v brew)"; then
    info "Homebrew not installed. Installing."
    # Run as a login shell (non-interactive) so that the script doesn't pause for user input
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
  fi

  # install brew dependencies from Brewfile
  brew bundle

  # install fzf
  echo -e
  info "Installing fzf"
  "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
}

setup_shell() {
  title "Configuring shell"

  [[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"
  if ! grep "$zsh_path" /etc/shells; then
    info "adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    info "default shell changed to $zsh_path"
  fi
}

setup_macos() {
  title "Configuring macOS"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "Set computer name (as done via System Preferences → Sharing)"
    sudo scutil --set ComputerName "megatron"
    sudo scutil --set HostName "megatron"
    sudo scutil --set LocalHostName "megatron"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "megatron"

    echo "Menu bar: show battery percentage"
    defaults write com.apple.menuextra.battery ShowPercent YES

    echo "Increase window resize speed for Cocoa applications"
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    echo "Finder: show all filename extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    echo "show hidden files by default"
    defaults write com.apple.Finder AppleShowAllFiles -bool false

    echo "Finder: allow text selection in Quick Look"
    defaults write com.apple.finder QLEnableTextSelection -bool true

    echo "Display full POSIX path as Finder window title"
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    echo "Keep folders on top when sorting by name"
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    echo "Avoid creating .DS_Store files on network or USB volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    echo "Use AirDrop over every interface."
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    echo "Always open everything in Finder's list view."
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    echo "Expand the following File Info panes:"
    defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

    echo "only use UTF-8 in Terminal.app"
    defaults write com.apple.terminal StringEncodings -array 4

    echo "expand save dialog by default"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    echo "Expand print panel by default"
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    echo "Automatically quit printer app once the print jobs complete"
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    echo "Save to disk (not to iCloud) by default"
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    echo "show the ~/Library folder in Finder"
    chflags nohidden ~/Library

    echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    echo "Enable subpixel font rendering on non-Apple LCDs"
    defaults write NSGlobalDomain AppleFontSmoothing -int 2

    echo "Use current directory as default search scope in Finder"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    echo "Show Path bar in Finder"
    defaults write com.apple.finder ShowPathbar -bool true

    echo "Show Status bar in Finder"
    defaults write com.apple.finder ShowStatusBar -bool true

    echo "Disable smart quotes and dashes as they’re annoying when typing code"
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    echo "Disable press-and-hold for keys in favor of key repeat"
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    echo "Set a blazingly fast keyboard repeat rate"
    defaults write NSGlobalDomain KeyRepeat -int 1

    echo "Set a shorter Delay until key repeat"
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    echo "Enable tap to click (Trackpad)"
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    echo "Trackpad: map bottom right corner to right-click"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    echo "Trackpad: swipe between pages with three fingers"
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

    echo "Increase sound quality for Bluetooth headphones/headsets"
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    echo "Turn off keyboard illumination when computer is not used for 5 minutes"
    defaults write com.apple.BezelServices kDimTime -int 300

    echo "Save screenshots to the ~/Screenshots folder"
    mkdir -p "${HOME}/Screenshots"
    defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

    echo "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
    defaults write com.apple.screencapture type -string "png"

    echo "Disable shadow in screenshots"
    defaults write com.apple.screencapture disable-shadow -bool true

    echo "Enable Safari's debug menu"
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    echo "Show indicator lights for open applications in the Dock"
    defaults write com.apple.dock show-process-indicators -bool true

    echo "Automatically hide and show the Dock"
    defaults write com.apple.dock autohide -bool true

    echo "Make Dock icons of hidden applications translucent"
    defaults write com.apple.dock showhidden -bool true

    echo "Disable hot corners"
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-br-corner -int 0

    echo "Don't show recently used applications in the Dock"
    defaults write com.Apple.Dock show-recents -bool false

    echo "Display emails in threaded mode"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"

    echo "Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    echo "Disable inline attachments (just show the icons)"
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    echo "Mark all messages as read when opening a conversation"
    defaults write com.apple.mail ConversationViewMarkAllAsRead -bool true

    echo "Disable includings results from trash in search"
    defaults write com.apple.mail IndexTrash -bool false

    echo "Automatically check for new message (not every 5 minutes)"
    defaults write com.apple.mail AutoFetch -bool true
    defaults write com.apple.mail PollTime -string "-1"

    echo "Show most recent message at the top in conversations"
    defaults write com.apple.mail ConversationViewSortDescending -bool true

    echo "Show week numbers (10.8 only)"
    defaults write com.apple.iCal "Show Week Numbers" -bool true

    echo "Week starts on monday"
    defaults write com.apple.iCal "first day of week" -int 1

    echo "Show the main window when launching Activity Monitor"
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    echo "Visualize CPU usage in the Activity Monitor Dock icon"
    defaults write com.apple.ActivityMonitor IconType -int 5

    echo "Show all processes in Activity Monitor"
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    echo "Sort Activity Monitor results by CPU usage"
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    echo "Enable the automatic update check"
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    echo "Check for software updates weekly ('dot update' includes software updates)"
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -string 7

    echo "Download newly available updates in background"
    defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true

    echo "Install System data files & security updates"
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

    echo "Turn on app auto-update"
    defaults write com.apple.commerce AutoUpdate -bool true

    echo "Allow the App Store to reboot machine on macOS updates"
    defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

    echo "Kill affected applications"

    for app in Safari Finder Dock Mail SystemUIServer Calendar iCal; do killall "$app" >/dev/null 2>&1; done
  else
    warning "macOS not detected. Skipping."
  fi
}

cleanup_symlinks
setup_symlinks

if [[ "$OSTYPE" == "darwin"* ]]; then
  setup_homebrew
fi

setup_shell

if [[ "$OSTYPE" == "darwin"* ]]; then
  setup_macos
fi

echo -e
success "Done."