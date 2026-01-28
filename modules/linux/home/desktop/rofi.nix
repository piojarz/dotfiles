{ config, lib, pkgs, ... }:

{
  # Link the existing rofi configuration
  
  home.file.".config/rofi" = {
    source = ../../../../config/linux/rofi;
    recursive = true;
  };

  home.packages = with pkgs; [
    rofi-wayland
  ];
}