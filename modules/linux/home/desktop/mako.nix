{ config, lib, pkgs, ... }:

{
  # Link the existing mako configuration
  
  home.file.".config/mako/config" = {
    source = ../../../../config/linux/mako/config;
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