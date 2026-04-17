{...}: {
  imports = [
    ./ai.nix
    ./espanso.nix
    ./hardware.nix
    ./fingerprint.nix
    ./host-packages.nix
    ./input.nix
    ./pam-auth.nix
    ./power.nix
    ./webcam.nix
    ./yubikey.nix
  ];

  services.keyd = {
    enable = true;
    keyboards.default.settings.main = {
      # Dell XPS 13 9350 firmware/kernel combos can expose the Copilot/Super keys
      # as either meta, search, or f23. Normalize them all to a single Super key.
      leftmeta = "leftmeta";
      rightmeta = "leftmeta";
      search = "leftmeta";
      f23 = "leftmeta";
    };
  };

  # keyd creates a virtual keyboard; mark it as internal so libinput keeps laptop touchpad behavior sane.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd*keyboard
    AttrKeyboardIntegration=internal
  '';
}
