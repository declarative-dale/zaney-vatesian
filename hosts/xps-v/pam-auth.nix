{config, ...}: {
  local.yubikey.pamU2f = {
    enable = true;
    globalEnable = false;
    authFile = /etc/Yubico/u2f_keys;
    cue = true;
    interactive = false;
    services = {
      # Login only checks for the inserted key. To keep this touchless, enroll
      # the credential with `pamu2fcfg -P`.
      login = {
        control = "required";
        settings = {
          cue = false;
          userpresence = 0;
        };
      };

      ly = {
        control = "required";
        settings = {
          cue = false;
          userpresence = 0;
        };
      };

      sudo = {
        control = "sufficient";
        settings = {
          cue = true;
          userpresence = 1;
        };
      };
    };
  };

  security.pam.services = {
    login = {
      unixAuth = true;
      fprintAuth = true;
      enableGnomeKeyring = true;
      # Fingerprint must run before the required U2F rule so a successful
      # fingerprint can short-circuit the stack for the passwordless path.
      rules.auth.fprintd.order = config.security.pam.services.login.rules.auth.u2f.order - 10;
    };

    ly = {
      unixAuth = true;
      fprintAuth = true;
      enableGnomeKeyring = true;
      rules.auth.fprintd.order = config.security.pam.services.ly.rules.auth.u2f.order - 10;
    };

    sudo = {
      unixAuth = true;
      fprintAuth = true;
      rules.auth.fprintd.order = config.security.pam.services.sudo.rules.auth.u2f.order - 10;
      # PAM auth is serialized, so the first interactive method blocks the rest.
      # Keep fingerprint first, but fall through quickly to YubiKey touch or password.
      rules.auth.fprintd.settings = {
        max-tries = 1;
        timeout = 3;
      };
    };
  };
}
