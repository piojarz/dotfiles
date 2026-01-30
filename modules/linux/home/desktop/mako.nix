{ config, lib, pkgs, ... }:

{
  services.mako = {
    enable = true;
    
    # Basic appearance
    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    borderSize = 2;
    borderRadius = 10;
    
    # Behavior
    defaultTimeout = 5000;
    ignoreTimeout = false;
    
    # Position
    anchor = "top-right";
    margin = "10";
    
    # Size
    width = 400;
    height = 150;
    
    # Font
    font = "sans-serif 11";
    
    # Icons
    icons = true;
    maxIconSize = 64;
    
    # Grouping
    groupBy = "app-name";
    
    # Extra config
    extraConfig = ''
      [urgency=low]
      border-color=#89b4fa
      
      [urgency=normal]
      border-color=#89b4fa
      
      [urgency=high]
      border-color=#f38ba8
      default-timeout=0
    '';
  };

  # If you have a custom mako config file, link it instead
  # Uncomment the following if you prefer to use your own config file:
  # xdg.configFile."mako/config" = {
  #   source = config.lib.file.mkOutOfStoreSymlink
  #     "${config.home.homeDirectory}/.dotfiles/config/linux/mako/config";
  # };
}
