{...}: {
  # Keep the existing zram-only setup and avoid stacking zswap on top of it.
  boot.zswap.enable = false;

  # Lunar Lake on this machine only exposes s2idle, so make lid-close suspend
  # explicit and leave docked use alone.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Hibernation needs real disk-backed swap and resume wiring; zram alone is
  # not sufficient, so disable the hibernate paths until that exists.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };
}
