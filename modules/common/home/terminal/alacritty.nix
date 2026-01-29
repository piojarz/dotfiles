{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    
    # Link the existing alacritty configuration
  };

  home.file.".config/alacritty" = {
    source = builtins.path {
      name = "alacritty-config-dir";
      path = ../../../../config/common/alacritty;
    };
    recursive = true;
  };

}