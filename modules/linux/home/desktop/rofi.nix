{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      icon-theme = "Adwaita";
      display-drun = "";
      display-run = "";
      display-window = "";
      drun-display-format = "{name}";
    };
  };

  # Link your custom rofi config
  # If you have custom themes/configs, they'll be linked here
  xdg.configFile."rofi" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/linux/rofi";
    recursive = true;
  };
}
