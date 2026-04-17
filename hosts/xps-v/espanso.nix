{username, ...}: {
  users.users.${username}.extraGroups = ["input"];

  home-manager.users.${username}.services.espanso = {
    enable = true;

    # Generates ~/.config/espanso/config/default.yml
    configs.default = {
      show_notifications = false;
      keyboard_layout = {
        layout = "us";
      };
    };

    # Generates ~/.config/espanso/match/base.yml
    matches.base = {
      global_vars = [
        {
          name = "currentdate";
          type = "date";
          params = {
            format = "%Y-%m-%d";
          };
        }
        {
          name = "currenttime";
          type = "date";
          params = {
            format = "%H:%M";
          };
        }
      ];

      matches = [
        {
          trigger = ":date";
          replace = "{{currentdate}}";
        }
        {
          trigger = ":time";
          replace = "{{currenttime}}";
        }
      ];
    };
  };
}
