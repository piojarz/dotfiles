{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kanata
  ];

  xdg.configFile."kanata/kanata.kbd".source = ../../../../../config/common/kanata/kanata.kbd;
}
