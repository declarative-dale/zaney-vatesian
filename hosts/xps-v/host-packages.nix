{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #  Add local pacakaged here
    bitwarden-desktop
    bubblewrap # Needed for Codex's sandbox environment.
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
        "im.riot.Riot"
        "com.nextcloud.desktopclient.nextcloud"
      ];
    };
  };
}
