{ config, lib, pkgs, ... }:

{
  # Install Noctalia shell
  # Note: This assumes noctalia-shell is available in nixpkgs or via overlay
  # If not available, you'll need to add it manually or via AUR
  
  # Noctalia-specific packages
  home.packages = with pkgs; [
    # Quickshell (Noctalia is built on this)
    quickshell
    
    # Matugen for Material You color theming
    matugen
    
    # Optional: GPU screen recorder for Noctalia's recording feature
    # gpu-screen-recorder
  ];

  # Link Noctalia config if you have custom settings
  # Noctalia stores its config in ~/.config/quickshell/noctalia-shell/
  # If you want to version control your Noctalia config, add it to your dotfiles
  xdg.configFile."quickshell/noctalia-shell" = lib.mkIf (builtins.pathExists "${config.home.homeDirectory}/.dotfiles/config/linux/noctalia") {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/linux/noctalia";
    recursive = true;
  };

  # Systemd service for Noctalia
  # This ensures Noctalia starts with your graphical session
  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia Desktop Shell";
      Documentation = "https://docs.noctalia.dev";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      # Avoid running multiple instances
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    
    Service = {
      Type = "simple";
      # Start Noctalia using Quickshell
      # Adjust the command if you installed Noctalia differently
      ExecStart = "${pkgs.quickshell}/bin/qs -c noctalia-shell";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Note about installation:
  # If noctalia-shell is not in nixpkgs, you have a few options:
  # 1. Install via AUR (pacman): yay -S noctalia-shell-git
  # 2. Clone and install manually: 
  #    git clone https://github.com/noctalia-dev/noctalia-shell
  #    Copy to ~/.config/quickshell/noctalia-shell/
  # 3. Add it to your flake as an input and overlay
  
  # For now, we'll assume manual installation or AUR
}
