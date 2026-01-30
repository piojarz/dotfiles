{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };

  # Link your custom waybar config
  # If you're using Noctalia instead, you can comment this out
  xdg.configFile."waybar" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/linux/waybar";
    recursive = true;
  };
}
