{ config, lib, pkgs, ... }:

{
  imports = [
    # Common modules
    ../../modules/common/home/shell
    ../../modules/common/home/editors
    ../../modules/common/home/tools
    # Note: terminal removed to avoid conflict with ghostty
    
    # macOS-specific modules
    ../../modules/macos/home/system
    ../../modules/macos/home/terminal
  ];

  # Home Manager needs a bit more information about you so it can
  # properly configure your system. Specifically, it needs your
  # username and home directory.
  home.username = username; # Use username passed from flake
  home.homeDirectory = "/Users/${username}"; # Home directory follows username

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Host-specific settings
  # You can add any host-specific customizations here
}