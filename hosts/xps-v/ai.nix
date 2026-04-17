{pkgs, ...}: let
  codexCli =
    builtins.getFlake
    "github:sadjow/codex-cli-nix/7c050fa951b5ca20a4754b42ec5242231edda35f?narHash=sha256-kCvsC6JxJtcpLLPrrjptgmBlV7Zmz0NWdLfoP15%2BjOc%3D";
in {
  environment.systemPackages = [
    codexCli.packages.${pkgs.system}.default
  ];

  nix.settings = {
    extra-substituters = ["https://codex-cli.cachix.org"];
    extra-trusted-public-keys = [
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };
}
