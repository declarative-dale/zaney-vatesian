{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mapAttrs
    optionalAttrs
    optionals
    types
    ;

  cfg = config.local.yubikey;

  pamU2fControlType = types.enum [
    "required"
    "requisite"
    "sufficient"
    "optional"
  ];

  pamU2fSettingsType = with types; attrsOf (nullOr (oneOf [
    bool
    str
    int
    path
  ]));

  managerBacked =
    cfg.management.enable
    || cfg.oath.enable
    || cfg.piv.enable
    || cfg.age.enable;

  basePamU2fSettings =
    {
      cue = cfg.pamU2f.cue;
      interactive = cfg.pamU2f.interactive;
    }
    // cfg.pamU2f.settings;

  basePamU2fSettingsWithAuthFile =
    basePamU2fSettings
    // optionalAttrs (cfg.pamU2f.authFile != null) {
      authfile = cfg.pamU2f.authFile;
    };

  renderPamU2fSettings = settings:
    mapAttrs (_: value:
      if builtins.typeOf value == "path"
      then toString value
      else value)
    settings;
in {
  options.local.yubikey = {
    management.enable = mkEnableOption "basic YubiKey management tooling";

    oath.enable = mkEnableOption "Yubico Authenticator / OATH support";

    piv.enable = mkEnableOption "PIV smart-card tooling";

    gpgSmartcard.enable = mkEnableOption "GnuPG smart-card / OpenPGP applet support";

    sshAgent.enable = mkEnableOption "PIV-backed SSH authentication via yubikey-agent";

    age.enable = mkEnableOption "age-plugin-yubikey tooling";

    pamU2f = {
      enable = mkEnableOption "pam_u2f-based login, unlock, and sudo authentication";

      globalEnable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable U2F for every PAM service that follows the
          global `security.pam.u2f` defaults. Set this to `false` when you
          want to opt individual services into U2F with `pamU2f.services`.
        '';
      };

      control = mkOption {
        type = pamU2fControlType;
        default = "sufficient";
        description = "PAM control value to use when U2F authentication is enabled.";
      };

      authFile = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Optional pam_u2f mapping file. Leave null to use the per-user
          default at ~/.config/Yubico/u2f_keys.
        '';
      };

      cue = mkOption {
        type = types.bool;
        default = true;
        description = "Show a reminder prompt when pam_u2f is waiting for the token.";
      };

      interactive = mkOption {
        type = types.bool;
        default = true;
        description = "Wait for a user confirmation prompt before checking for the token.";
      };

      settings = mkOption {
        type = pamU2fSettingsType;
        default = {};
        description = ''
          Extra `pam_u2f` settings to apply globally. Use this for options
          such as `pinverification`, `userpresence`, or `origin`.
        '';
      };

      services = mkOption {
        type = types.attrsOf (types.submodule ({...}: {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether the named PAM service should enable U2F.";
            };

            control = mkOption {
              type = with types; nullOr pamU2fControlType;
              default = null;
              description = ''
                Service-specific PAM control override. Leave null to inherit
                `local.yubikey.pamU2f.control`.
              '';
            };

            settings = mkOption {
              type = pamU2fSettingsType;
              default = {};
              description = ''
                Service-specific `pam_u2f` settings override. These are merged
                on top of the global `pamU2f.settings`.
              '';
            };
          };
        }));
        default = {};
        description = ''
          Per-service U2F configuration. Each attribute name should match a
          PAM service such as `login`, `ly`, or `sudo`.
        '';
      };
    };
  };

  config = mkMerge [
    # Example future host override:
    # local.yubikey = {
    #   management.enable = true;
    #   piv.enable = true;
    #   gpgSmartcard.enable = true;
    #   age.enable = true;
    #   pamU2f = {
    #     enable = true;
    #     globalEnable = false;
    #     control = "required";
    #     # authFile = /etc/u2f-mappings;
    #     services.login.control = "required";
    #     services.sudo.control = "sufficient";
    #   };
    # };
    #
    # Leave sshAgent disabled unless you explicitly want yubikey-agent to own
    # SSH_AUTH_SOCK instead of gpg-agent.
    # Attached device on this host:
    # Yubico 1050:0407 - YubiKey OTP+FIDO+CCID (5C Nano class token).
    (mkIf managerBacked {
      programs.yubikey-manager.enable = true;

      environment.systemPackages =
        optionals cfg.management.enable [pkgs.yubikey-personalization]
        ++ optionals cfg.oath.enable [pkgs.yubioath-flutter]
        ++ optionals cfg.piv.enable [pkgs.yubico-piv-tool]
        ++ optionals cfg.age.enable [pkgs.age-plugin-yubikey];
    })

    (mkIf cfg.gpgSmartcard.enable {
      hardware.gpgSmartcards.enable = true;
    })

    (mkIf cfg.sshAgent.enable {
      # yubikey-agent owns SSH_AUTH_SOCK; don't let gpg-agent take that role.
      programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
      services.yubikey-agent.enable = true;
    })

    (mkIf cfg.pamU2f.enable {
      security.pam.u2f = {
        enable = cfg.pamU2f.globalEnable;
        control = cfg.pamU2f.control;
        settings =
          if cfg.pamU2f.globalEnable
          then basePamU2fSettingsWithAuthFile
          else basePamU2fSettings;
      };

      security.pam.services = mapAttrs (_: serviceCfg: {
        u2f = {
          enable = serviceCfg.enable;
          control =
            if serviceCfg.control != null
            then serviceCfg.control
            else cfg.pamU2f.control;
        };

        rules.auth.u2f.settings =
          renderPamU2fSettings basePamU2fSettingsWithAuthFile
          // renderPamU2fSettings serviceCfg.settings;
      }) cfg.pamU2f.services;
    })
  ];
}
