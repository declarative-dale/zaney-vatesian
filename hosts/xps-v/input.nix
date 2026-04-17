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

    programs.kitty.extraConfig = lib.mkAfter ''
      # On xps-v, use right click to paste instead of extending a selection.
      mouse_map right press ungrabbed
      mouse_map right release ungrabbed paste_from_selection
    '';

    programs.ghostty.settings.right-click-action = "paste";
  };
}
