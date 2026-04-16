{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #  Add local pacakaged here
    codex
    sbctl
    _1password-gui
    _1password-cli
    micro
    efibootmgr
    lazygit
  ];
  # Add host specific flatpaks here
  services = {
    flatpak = {
      packages = [
      ];
    };
  };
}
