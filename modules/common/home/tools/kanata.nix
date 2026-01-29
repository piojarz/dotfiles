{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kanata
  ];

  xdg.configFile."kanata/kanata.kbd".source = builtins.path {
    name = "kanata-config";
    path = ../../../../config/common/kanata/kanata.kbd;
  };
}
