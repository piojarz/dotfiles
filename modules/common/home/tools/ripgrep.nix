{ config, lib, pkgs, ... }:

{
  programs.ripgrep = {
    enable = true;
    
    # Link the existing ripgrep configuration
  };

  home.file.".config/ripgrep" = {
    source = ../../../../config/common/ripgrep;
    recursive = true;
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}