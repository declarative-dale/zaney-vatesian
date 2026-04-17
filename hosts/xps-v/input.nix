{
  lib,
  username,
  ...
}: {
  # Keep clickfinger behavior consistent across libinput/Xwayland and Hyprland:
  # one-finger click = left, two-finger click = right, three-finger click = middle.
  services.libinput.touchpad = {
    clickMethod = "clickfinger";
    tappingButtonMap = "lrm";
  };

  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings.input.touchpad = {
      clickfinger_behavior = true;
      tap_button_map = "lrm";
    };

    home.file."./.config/wezterm/wezterm.lua".text = lib.mkForce (
      builtins.readFile ./wezterm.lua
    );

    programs.kitty.extraConfig = lib.mkAfter ''
      # On xps-v, use right click to paste instead of extending a selection.
      mouse_map right press ungrabbed
      mouse_map right release ungrabbed paste_from_selection
    '';

    programs.ghostty.settings = {
      copy-on-select = "clipboard";
      right-click-action = "paste";
    };

    programs.alacritty.settings = {
      selection.save_to_clipboard = true;
      mouse.bindings = lib.mkAfter [
        {
          mouse = "Right";
          action = "PasteSelection";
        }
      ];
    };
  };
}
