{ config, lib, pkgs, ... }:

{
  programs.ripgrep = {
    enable = true;
    
    # Link the existing ripgrep configuration
  };

  home.file.".config/ripgrep/config" = {
    source = ../../../../config/common/ripgrep/config;
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}