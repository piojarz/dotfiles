{ config, lib, pkgs, ... }:

{
  programs.ripgrep = {
    enable = true;
    
    # Link the existing ripgrep configuration
  };

  home.file.".config/ripgrep" = {
    source = builtins.path {
      name = "ripgrep-config-dir";
      path = ../../../../config/common/ripgrep;
    };
    recursive = true;
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}