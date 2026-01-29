{ config, lib, pkgs, ... }:

{
  # Link the existing rofi configuration
  
  home.file.".config/rofi" = {
    source = builtins.path {
      name = "rofi-config-dir";
      path = ../../../../config/linux/rofi;
    };
    recursive = true;
  };

  home.packages = with pkgs; [
    rofi
  ];
}