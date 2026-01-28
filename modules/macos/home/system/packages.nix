{ pkgs, ... }:

{
  # We should use Homebrew for Casks (GUI apps) on macOS
  # Nix-darwin establishes the bridge, but assuming we use home-manager only for now,
  # we can't easily declaratively manage Casks without nix-darwin.
  # However, we can at least install the packages that ARE available in nix.
  
  home.packages = with pkgs; [
    # macOS specific CLI tools
    
    # Fonts are better managed by specific font modules or home.packages
    # but we will list them here for now
    nerd-fonts.symbols-only
    fira-code
    cascadia-code
    jetbrains-mono
    monaspace
    recursive
  ];
}
