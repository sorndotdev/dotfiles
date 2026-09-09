{ ... }:

{
    nix.enable = false;
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "aarch64-darwin";
    users.users.sorn = {
        home = "/Users/sorn";
    };
    system.primaryUser = "sorn";
    system.stateVersion = 6;
    system.defaults = {
        NSGlobalDomain = {
            AppleShowAllExtensions = true;
        };
        finder.FXPreferredViewStyle = "Nlsv"; # list view
        finder.AppleShowAllFiles = true;      # show hidden files
        finder.CreateDesktop = false;         # clean desktop
        trackpad.Clicking = false;            # disable tap to click
    };
    system.activationScripts.postActivation.text = ''
      # Caps Lock → Left Command
      hidutil property --set '{
        "UserKeyMapping": [
          {
            "HIDKeyboardModifierMappingSrc": 0x700000039,
            "HIDKeyboardModifierMappingDst": 0x7000000E3
          }
        ]
      }'
    '';
    nix-homebrew = {
        enable = true;
        user = "sorn";
        autoMigrate = true; # overwrite existing homebrew
    };
    homebrew = {
        enable = true;
        onActivation.cleanup = "zap";  # remove anything not listed here
        onActivation.autoUpdate = true;
        onActivation.extraFlags = [ "--force" ];
        brews = [
            "gnupg"
            "tmux"
            "opencode"
        ];
        casks = [
            "wezterm"
        ];
    };
}
