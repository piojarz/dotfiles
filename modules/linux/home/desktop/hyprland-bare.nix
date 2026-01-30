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
  # Bare Hyprland version - includes waybar, mako, rofi
  home.packages = with pkgs; [
    # Core Wayland compositor
    hyprland
    hyprpaper  # Wallpaper daemon
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
    
    # Bare Hyprland specific - these are managed by separate modules
    # waybar - managed by waybar.nix
    # mako - managed by mako.nix
    # rofi-wayland - managed by rofi.nix
    # swaylock - managed by swaylock.nix
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
  # Uses the bare config that starts waybar/mako instead of noctalia
  xdg.configFile."hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/.dotfiles/config/linux/hypr";
    recursive = true;
  };

  # Also link the bare-specific config as the main config
  # This overrides the default hyprland.conf with hyprland-bare.conf
  xdg.configFile."hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/config/linux/hypr/hyprland-bare.conf";

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
