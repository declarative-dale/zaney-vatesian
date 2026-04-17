{pkgs, ...}: {
  # Goodix 27c6:633c on the XPS 13 9350 needs the OEM TOD driver rather than
  # the generic upstream libfprint backend.
  # Authentication policy for when fingerprints are accepted lives in
  # ./pam-auth.nix; this file only enables the sensor driver.
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
}
