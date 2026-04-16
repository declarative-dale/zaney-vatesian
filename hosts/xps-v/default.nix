{...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  services.keyd = {
    enable = true;
    keyboards.default.settings.main = {
      # Preserve the normal Meta keys and treat the Copilot key as an extra Super key.
      leftmeta = "leftmeta";
      rightmeta = "rightmeta";
      f23 = "rightmeta";
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
