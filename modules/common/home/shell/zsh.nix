{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    
    history = {
      save = 10000;
      size = 10000;
      ignoreAllDups = true;
      extended = true;
      share = true;
    };

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      cat = "bat";
      vim = "nvim";
    };

    initExtra = ''
      # Environment variables
      export EDITOR=nvim
      export VISUAL=nvim
      
      # define the code directory
      if [[ -d ~/code ]]; then
          export CODE_DIR=~/code
      elif [[ -d ~/Developer ]]; then
          export CODE_DIR=~/Developer
      fi
      
      # display how long all tasks over 10 seconds take
      export REPORTTIME=10
      export KEYTIMEOUT=1
      
      setopt NO_LIST_BEEP
      setopt LOCAL_OPTIONS
      setopt LOCAL_TRAPS
      setopt COMPLETE_ALIASES
      
      # make terminal command navigation sane again
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey '^[^[[C' forward-word
      bindkey '^[^[[D' backward-word
      bindkey '^[[1;3D' beginning-of-line
      bindkey '^[[1;3C' end-of-line
      bindkey '^[[5D' beginning-of-line
      bindkey '^[[5C' end-of-line
      bindkey '^?' backward-delete-char
      if [[ "''${terminfo[kdch1]}" != "" ]]; then
        bindkey "''${terminfo[kdch1]}" delete-char
      else
        bindkey "^[[3~" delete-char
        bindkey "^[3;5~" delete-char
        bindkey "\e[3~" delete-char
      fi
      
      # FZF configuration
      if [ -x "$(command -v fzf)" ]; then
        export FZF_DEFAULT_COMMAND='fd --type f'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_DEFAULT_OPTS="--color bg:-1,bg+:-1,fg:-1,fg+:#feffff,hl:#993f84,hl+:#d256b5,info:#676767,prompt:#676767,pointer:#676767"
        source <(fzf --zsh)
      fi
      
      # add color to man pages
      export MANROFFOPT='-c'
      export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
      export LESS_TERMCAP_md=$(tput bold; tput setaf 6)
      export LESS_TERMCAP_me=$(tput sgr0)
      export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
      export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
      export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
      export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
      export LESS_TERMCAP_mr=$(tput rev)
      export LESS_TERMCAP_mh=$(tput dim)
      
      # Starship prompt
      eval "$(starship init zsh)"
    '';
  };

  # Note: For antidote plugins, you would need to handle that separately
  # as it's not directly supported in home-manager
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Packages moved to tool modules
  home.packages = with pkgs; [
    starship
    zoxide
  ];
}