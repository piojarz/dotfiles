{ ... }:

{
  imports = [
    ./hyprland.nix
    # ./mako.nix # Disabled in favor of Noctalia
    ./rofi.nix
    ./swaylock.nix
    # ./waybar.nix # Disabled in favor of Noctalia
    ./noctalia.nix
  ];
}
