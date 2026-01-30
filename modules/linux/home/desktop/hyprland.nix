{ config, lib, pkgs, ... }:

{
  # Enable Wayland session variables
  home.sessionVariables = {
    # Wayland-specific environment
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    
    # Enable Wayland support in various applications
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # Hyprland-specific
    WLR_NO_HARDWARE_CURSORS = "1";
    
    # NVIDIA specific (uncomment if using NVIDIA)
    # LIBVA_DRIVER_NAME = "nvidia";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Install Hyprland and essential Wayland packages
  # NOTE: This module is designed to work WITH Noctalia
  # We do NOT install:
  # - waybar (Noctalia provides its own bar)
  # - mako/dunst (Noctalia handles notifications)
  # - rofi (Noctalia has built-in launcher)
  # - swaylock (Noctalia provides lock screen)
  home.packages = with pkgs; [
    # Core Wayland compositor
    hyprland
    hyprpaper  # Wallpaper daemon (Noctalia can use this)
    hyprpicker # Color picker
    
    # Wayland protocols and libraries
    wayland
    wayland-protocols
    wayland-utils
    wayland-scanner
    
    # XWayland for X11 app compatibility
    xwayland
    
    # Graphics and rendering
    mesa
    libva
    libva-utils
    vulkan-tools
    vulkan-loader
    
    # Display management
    wlr-randr      # Monitor configuration
    wl-clipboard   # Clipboard utilities
    wl-clip-persist # Persist clipboard after app closes
    
    # Session management
    polkit
    lxqt.lxqt-policykit  # LXQt polkit agent (replaces removed polkit-kde-agent)
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    
    # Screenshots and screen recording
    grim           # Screenshot utility
    grimblast      # Grim wrapper with more features
    slurp          # Region selector
    swappy         # Screenshot editor
    wf-recorder    # Screen recorder
    
    # Screen sharing
    pipewire
    wireplumber
    
    # Additional utilities
    wtype          # Wayland xdotool alternative
    wl-gammarelay-rs # Gamma control
    wlsunset       # Day/night gamma adjustment
    cliphist       # Clipboard manager
    
    # System information
    btop           # System monitor
    
    # Brightness and audio control
    brightnessctl
    pamixer
    playerctl
    
    # Noctalia dependencies
    # Quickshell is needed for Noctalia (it's built with it)
    quickshell
    
    # Matugen for Material You theming (used by Noctalia)
    matugen
  ];

  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # Link Hyprland config from your config directory
  # This assumes your config is in ~/.dotfiles/config/linux/hypr
  xdg.configFile."hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.dotfiles/config/linux/hypr";
    recursive = true;
  };

  # Enable systemd user services for Hyprland
  systemd.user = {
    services = {
      # Polkit authentication agent (LXQt replacement for removed kde-agent)
      polkit-agent = {
        Unit = {
          Description = "Polkit Authentication Agent";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
