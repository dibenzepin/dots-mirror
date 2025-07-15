{ lib, config, ... }:
{

  options = {
    my.discord.enable = lib.mkEnableOption "home-manager managed discord";
  };

  config = lib.mkIf config.my.discord.enable {

    programs.vesktop = {
      enable = true;
      vencord = {
        useSystem = true;
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          enabledThemes = [ "EmojiReplace.theme.css" ];
        };
        themes = {
          "EmojiReplace.theme" = ''
            /**
             * @name EmojiReplace
             * @description Replaces Discord's Emojis with Emojis of a different Provider (Apple, Facebook...)
             * @author DevilBro
             * @version 1.0.0
             * @authorId 278543574059057154
             * @invite Jx3TjNS
             * @donate https://www.paypal.me/MircoWittrien
             * @patreon https://www.patreon.com/MircoWittrien
             * @website https://mwittrien.github.io/
             */
            @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Apple.css);
          '';
        };
      };
    };
  };
}
