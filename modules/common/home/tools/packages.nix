{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # General utilities
    atuin      # better history
    cloc       # lines of code counter
    entr       # file watcher
    git-lfs    # large files for git
    glow       # markdown viewer
    gnupg      # GPG
    htop       # a top alternative
    jq         # work with JSON files
    neofetch   # pretty system info
    tree       # pretty-print directory contents
    wget       # internet file retriever

    # Deployment / Dev Ops
    # fzf is managed in its own module
    
    # Editors & Text
    # neovim is managed by its own module
    
    # Formatters & Linters
    shellcheck # diagnostics for shell sripts
    stylua     # lua code formatter
    
    # Language Tools
    nodejs     # used for many tools
    python3    # python
    sqlite     # command-line interface for SQLite
    
    # Misc
    noti       # notifications
  ];

  # Some tools have their own modules which we might want to enable specifically
  # referenced in other files but good to have packages here as fallback
}
