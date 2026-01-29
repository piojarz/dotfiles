{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };

  home.file.".config/hypr" = {
    source = ../../../../config/linux/hypr;
    recursive = true;
  };

  home.packages = with pkgs; [
    hyprland
    # Add any additional Hyprland-related packages
    xwayland
  ];
}