{ config, lib, pkgs, ... }:

{
  # Link the existing swaylock configuration
  
  home.file.".config/swaylock/config" = {
    source = ../../../../config/linux/swaylock/config;
  };

  programs.swaylock = {
    enable = true;
  };

  home.packages = with pkgs; [
    swaylock-effects
  ];
}