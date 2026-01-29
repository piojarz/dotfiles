{ config, lib, pkgs, ... }:

{
  # Link the existing mako configuration
  
  home.file.".config/mako" = {
    source = builtins.path {
      name = "mako-config-dir";
      path = ../../../../config/linux/mako;
    };
    recursive = true;
  };

  services.mako = {
    enable = true;
    
    # Basic configuration - rest is handled by config file
    defaultTimeout = 5000;
  };

  home.packages = with pkgs; [
    mako
  ];
}