{ config, lib, pkgs, ... }:

{
  programs.lazygit = {
    enable = true;
    
    # Link the existing lazygit configuration
  };

  home.file.".config/lazygit" = {
    source = builtins.path {
      name = "lazygit-config-dir";
      path = ../../../../config/common/lazygit;
    };
    recursive = true;
  };

}