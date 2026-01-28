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
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        homeConfigurations = {
          # Linux desktop with Wayland/Hyprland
          "linux-desktop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { 
              inherit self;
              username = builtins.getEnv "USER";
              gitName = builtins.getEnv "GIT_NAME";
              gitEmail = builtins.getEnv "GIT_EMAIL";
            };
            modules = [
              ./hosts/linux-desktop
            ];
          };

          # macOS laptop configuration
          "macos-laptop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { 
              inherit self;
              username = builtins.getEnv "USER";
              gitName = builtins.getEnv "GIT_NAME";
              gitEmail = builtins.getEnv "GIT_EMAIL";
            };
            modules = [
              ./hosts/macos-laptop
            ];
          };

          # Common workstation (minimal, cross-platform)
          "common-workstation" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { 
              inherit self;
              username = builtins.getEnv "USER";
              gitName = builtins.getEnv "GIT_NAME";
              gitEmail = builtins.getEnv "GIT_EMAIL";
            };
            modules = [
              ./hosts/common-workstation
            ];
          };
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            home-manager
            nixfmt
          ];
        };
      });
}