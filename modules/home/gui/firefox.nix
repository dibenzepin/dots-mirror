{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.firefox;
in
with lib;
{

  options = {
    my.firefox = {
      enable = mkEnableOption "home-manager managed firefox";
      package = mkOption {
        type = types.package;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    # there's profiles path?
    programs.firefox = {
      enable = true;
      package = cfg.package;
      profiles = {
        default = {
          id = 0;
          search = {
            force = true;
            engines = {
              "Nix Packages (unstable)" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nix" ];
              };
              "NixOS Wiki" = {
                urls = [
                  {
                    template = "https://wiki.nixos.org/w/index.php";
                    params = [
                      {
                        name = "search";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nwiki" ];
              };
            };
          };

          settings = {
            # cos it makes sense not jumping to the tab
            # https://support.mozilla.org/en-US/questions/1348563
            "browser.tabs.insertAfterCurrent" = true;

            # better scrolling on touchpad, on by default
            # https://discourse.gnome.org/t/add-touchpad-scroll-sensitivity-adjustment-feature/18097/11
            "apz.overscroll.enabled" = true;

            # restore previous sess on startup
            # https://kb.mozillazine.org/Browser.startup.page
            "browser.startup.page" = 3;

            # thick scrollbar
            # https://old.reddit.com/r/firefox/comments/17hlkhp/what_are_your_must_have_changes_in_aboutconfig/k6o4ub1/
            "widget.non-native-theme.scrollbar.style" = 1;

            "extensions.pocket.enabled" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.toolbars.bookmarks.visibility" = "never";

            # use apple emoji EVERYWHERE
            # https://superuser.com/a/1186161
            "font.name-list.emoji" = "Apple Color Emoji";

            "signon.rememberSignons" = false;            
          };
        };
      };
    };
  };
}
