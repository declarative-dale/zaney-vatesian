{
  config,
  lib,
  pkgs,
  ...
}: let
  kernelPackages = config.boot.kernelPackages;
  ipu7Drivers = pkgs.callPackage ../../pkgs/os-specific/linux/ipu7-drivers {
    kernel = kernelPackages.kernel;
    kernelModuleMakeFlags = kernelPackages.kernelModuleMakeFlags;
  };
in {
  # Lunar Lake already exposes the IPU7 ISYS capture nodes in-tree, but still
  # needs Intel's PSYS module plus the proprietary userspace stack to surface a
  # usable webcam to normal applications.
  boot.extraModulePackages = [ipu7Drivers];
  boot.kernelModules = ["intel_ipu7_psys"];
  boot.extraModprobeConfig = lib.mkAfter ''
    options v4l2loopback devices=0
  '';

  hardware.firmware = [pkgs.ipu7-camera-bins];

  services.udev.extraRules = ''
    KERNEL=="ipu7-psys[0-9]*", MODE="0660", GROUP="video"
  '';

  services.v4l2-relayd.instances.ipu7 = {
    enable = true;
    cardLabel = "Intel MIPI Camera";
    extraPackages = [pkgs.icamerasrc-ipu7x];
    input = {
      pipeline = "icamerasrc buffer-count=7";
      format = "NV12";
    };
  };
}
