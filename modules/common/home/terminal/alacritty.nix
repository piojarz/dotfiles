{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    
    # Link the existing alacritty configuration
  };

  home.file.".config/alacritty/alacritty.toml" = {
    source = ../../../../config/common/alacritty/alacritty.toml;
  };

  home.packages = with pkgs; [
    alacritty
  ];
}