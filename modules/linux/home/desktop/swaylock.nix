{ config, lib, pkgs, ... }:

{
  # Link the existing swaylock configuration
  
  home.file.".config/swaylock" = {
    source = ../../../../config/linux/swaylock;
    recursive = true;
  };

  programs.swaylock = {
    enable = true;
  };

  home.packages = with pkgs; [
    swaylock-effects
  ];
}