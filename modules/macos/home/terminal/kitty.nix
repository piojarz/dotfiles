{ config, lib, pkgs, ... }:

{
  # Link the existing kitty configuration (macOS-specific)
  
  home.file.".config/kitty" = {
    source = builtins.path {
      name = "kitty-config-dir";
      path = ../../../../config/macos/kitty;
    };
    recursive = true;
  };

  programs.kitty = {
    enable = true;
  };

  home.packages = with pkgs; [
    kitty
  ];
}