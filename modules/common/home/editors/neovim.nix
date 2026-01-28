{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # Link the complex nvim configuration from config/common/nvim
    # This preserves the existing Lua configuration structure
  };

  home.file.".config/nvim" = {
    source = ../../../../config/common/nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    neovim
    # Add any additional tools used by neovim
    lua-language-server
    nil # Nix language server
  ];
}