{config, lib, ...}: {
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
          debug = true;
          debug_file = "syslog";
          userpresence = 0;
        };
      };

      ly = {
        control = "required";
        settings = {
          cue = false;
          debug = true;
          debug_file = "syslog";
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
      # Prefer the YubiKey-present path. If U2F succeeds, jump over the
      # fingerprint fallback gate and continue into the password path.
      rules.auth.u2f.control = lib.mkForce "[success=2 default=ignore]";
      rules.auth.fprintd.order = config.security.pam.services.login.rules.auth.u2f.order + 10;
      rules.auth.u2f_fallback_gate = {
        order = config.security.pam.services.login.rules.auth.fprintd.order + 10;
        control = "requisite";
        modulePath = "${config.security.pam.package}/lib/security/pam_deny.so";
      };
    };

    ly = {
      unixAuth = true;
      fprintAuth = true;
      enableGnomeKeyring = true;
      rules.auth.u2f.control = lib.mkForce "[success=2 default=ignore]";
      rules.auth.fprintd.order = config.security.pam.services.ly.rules.auth.u2f.order + 10;
      rules.auth.u2f_fallback_gate = {
        order = config.security.pam.services.ly.rules.auth.fprintd.order + 10;
        control = "requisite";
        modulePath = "${config.security.pam.package}/lib/security/pam_deny.so";
      };
    };

    sudo = {
      unixAuth = true;
      fprintAuth = true;
      rules.auth.fprintd.order = config.security.pam.services.sudo.rules.auth.u2f.order + 10;
      # PAM auth is serialized, so give U2F first shot, then allow up to five
      # fingerprint attempts before falling through to password auth.
      rules.auth.fprintd.settings = {
        max-tries = 5;
        timeout = 10;
      };
    };
  };
}
