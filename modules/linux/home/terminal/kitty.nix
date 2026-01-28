{ config, lib, pkgs, ... }:

{
  # Link the existing kitty configuration (Linux-specific)
  
  home.file.".config/kitty" = {
    source = ../../../../config/linux/kitty;
    recursive = true;
  };

  programs.kitty = {
    enable = true;
  };

  home.packages = with pkgs; [
    kitty
  ];
}