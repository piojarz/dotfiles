{ inputs, ... }:

{
  # Import the official Noctalia Home Manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Enable Noctalia shell with systemd service
  programs.noctalia-shell = {
    enable = true;
    
    # Use the package from the flake input (set to null to use the module's default)
    # Setting this to null avoids IPC command issues as per documentation
    package = null;
    
    # Enable systemd service (recommended for proper session management)
    systemd.enable = true;
    
    # Optional: Add custom settings here
    # settings = {
    #   bar = {
    #     position = "top";
    #     density = "compact";
    #   };
    #   colorSchemes.predefinedScheme = "Monochrome";
    # };
  };
  
  # Note: When switching home manager generations, you may see errors about 
  # 'colors.json.backup' files. If this happens, delete the backup files in 
  # ~/.config/noctalia/ and rebuild.
}
