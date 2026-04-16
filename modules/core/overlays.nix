{inputs, ...}: {
  nixpkgs.overlays = [
    # Provide pkgs.google-antigravity via antigravity-nix overlay
    inputs.antigravity-nix.overlays.default
    # Build tumbler without EPUB thumbnailer (libgepub) to avoid webkitgtk
    (final: prev: {
      xfce =
        prev.xfce
        // {
          tumbler = prev.xfce.tumbler.overrideAttrs (old: {
            buildInputs = prev.lib.remove prev.libgepub old.buildInputs;
          });
        };

      ipu7-camera-bins = final.callPackage ../../pkgs/by-name/ip/ipu7-camera-bins/package.nix {};

      ipu7x-camera-hal = final.callPackage ../../pkgs/development/libraries/ipu7-camera-hal {
        ipuVersion = "ipu7x";
      };

      icamerasrc-ipu7x = final.callPackage ../../pkgs/development/libraries/gstreamer/icamerasrc-ipu7x {
        ipu7-camera-hal = final.ipu7x-camera-hal;
      };
    })
  ];
}
