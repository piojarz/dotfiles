{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };

  home.file.".config/hypr" = {
    source = builtins.path {
      name = "hyprland-config-dir";
      path = ../../../../config/linux/hypr;
    };
    recursive = true;
  };

  home.packages = with pkgs; [
    hyprland
    xwayland
    swayidle
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    networkmanagerapplet
  ];
}