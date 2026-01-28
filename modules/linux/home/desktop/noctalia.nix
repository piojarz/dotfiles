{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    # Add any settings if desired, or let the graphical UI handle it.
    # settings = { ... };
  };
}
