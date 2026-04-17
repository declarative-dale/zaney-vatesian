{...}: {
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
    };

    ly = {
      unixAuth = true;
      fprintAuth = true;
      enableGnomeKeyring = true;
    };

    sudo = {
      unixAuth = true;
      fprintAuth = true;
    };
  };
}
