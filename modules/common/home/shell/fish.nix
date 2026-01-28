{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      cat = "bat";
      vim = "nvim";
    };
    shellInit = ''
      # Environment variables
      set -x EDITOR nvim
      set -x VISUAL nvim
      
      # Starship prompt
      starship init fish | source
      
      # Zoxide
      zoxide init fish | source
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    starship
    zoxide
  ];
}