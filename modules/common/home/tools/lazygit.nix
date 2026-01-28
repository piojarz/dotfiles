{ config, lib, pkgs, ... }:

{
  programs.lazygit = {
    enable = true;
    
    # Link the existing lazygit configuration
  };

  home.file.".config/lazygit/config.yml" = {
    source = ../../../../config/common/lazygit/config.yml;
  };

  home.packages = with pkgs; [
    lazygit
  ];
}