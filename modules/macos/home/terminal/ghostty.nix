{ config, lib, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    
    # Link any ghostty configuration if it exists
    # You can configure settings here directly or link config files
  };

  home.packages = with pkgs; [
    ghostty
  ];
}