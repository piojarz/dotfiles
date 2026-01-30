{ config, lib, pkgs, ... }:

{
  imports = [
    ./hyprland-bare.nix  # Bare hyprland without Noctalia
    ./waybar.nix
    ./rofi.nix
    ./mako.nix
    ./swaylock.nix
  ];

  # Bare Hyprland desktop utilities
  # No Noctalia - uses waybar, rofi, mako separately
  home.packages = with pkgs; [
    # File managers
    nautilus         # GNOME file manager
    thunar           # XFCE file manager (lighter alternative)
    
    # Archive management
    file-roller      # Archive manager
    
    # Image viewers
    imv              # Image viewer
    
    # PDF viewer
    zathura          # Minimal PDF viewer
    
    # Network management
    networkmanagerapplet
    
    # Audio management
    pavucontrol      # PulseAudio volume control
    
    # Bluetooth
    blueman          # Bluetooth manager
    
    # Theme and appearance
    qt5ct            # Qt5 configuration tool
    qt6ct            # Qt6 configuration tool
    lxappearance     # GTK theme switcher
    nwg-look         # GTK theme manager for Wayland
    
    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    material-design-icons
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    
    # Notification testing
    libnotify        # notify-send command
  ];

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };

  # Qt configuration
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Font configuration
  fonts.fontconfig.enable = true;
}
