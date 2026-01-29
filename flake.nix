{
  description = "Personal dotfiles - nexxeln-style organization with platform separation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    hyprland.url = "github:hyprwm/Hyprland";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      # Linux systems usually use x86_64-linux, macOS uses aarch64-darwin (M1/M2/M3) or x86_64-darwin (Intel)
      linuxSystem = "x86_64-linux";
      macosSystem = "aarch64-darwin";

      mkHomeConfig = system: host: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
          inherit self inputs;
          username = let envUser = builtins.getEnv "USER"; in if envUser != "" then envUser else "pj";
          gitName = let envName = builtins.getEnv "GIT_NAME"; in if envName != "" then envName else "Piotr Jarosz";
          gitEmail = let envEmail = builtins.getEnv "GIT_EMAIL"; in if envEmail != "" then envEmail else "piojarosz@gmail.com";
        };
        modules = [
          ./hosts/${host}
        ];
      };
    in
    {
      homeConfigurations = {
        # Linux desktop with Wayland/Hyprland
        "linux-desktop" = mkHomeConfig linuxSystem "linux-desktop";

        # macOS laptop configuration
        "macos-laptop" = mkHomeConfig macosSystem "macos-laptop";

        # Common workstation (minimal, cross-platform)
        "common-workstation" = mkHomeConfig linuxSystem "common-workstation";
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      # Development shell
      devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          home-manager
          nixfmt
        ];
      };
    });
}