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
    optionalAttrs
    optionals
    types
    ;

  cfg = config.local.yubikey;

  managerBacked =
    cfg.management.enable
    || cfg.oath.enable
    || cfg.piv.enable
    || cfg.age.enable;
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

      control = mkOption {
        type = types.enum [
          "required"
          "requisite"
          "sufficient"
          "optional"
        ];
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
    #     control = "required";
    #     # authFile = /etc/u2f-mappings;
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
        enable = true;
        control = cfg.pamU2f.control;
        settings =
          {
            cue = cfg.pamU2f.cue;
            interactive = cfg.pamU2f.interactive;
          }
          // optionalAttrs (cfg.pamU2f.authFile != null) {
            authfile = cfg.pamU2f.authFile;
          };
      };
    })
  ];
}
