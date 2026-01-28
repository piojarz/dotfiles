{ config, lib, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--color bg:-1,bg+:-1,fg:-1,fg+:#feffff,hl:#993f84,hl+:#d256b5,info:#676767,prompt:#676767,pointer:#676767"
    ];
  };

  home.packages = with pkgs; [
    fzf
    fd
  ];
}