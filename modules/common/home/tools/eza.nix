{ config, lib, pkgs, ... }:

{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
  };

  home.packages = with pkgs; [
    eza
  ];
}