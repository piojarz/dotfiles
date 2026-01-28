{ config, lib, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "GitHub";
      style = "numbers,changes,header";
    };
  };

  home.packages = with pkgs; [
    bat
  ];
}