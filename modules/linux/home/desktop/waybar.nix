{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    
    # Link the existing waybar configuration
  };

  home.file.".config/waybar" = {
    source = ../../../../config/linux/waybar;
    recursive = true;
  };

  home.packages = with pkgs; [
    waybar
  ];
}