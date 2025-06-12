{ lib, config, ... }:

{
  options = {
    my.luminovo.enable = lib.mkEnableOption "luminovo-specific stuff";
  };

  config = lib.mkIf config.my.luminovo.enable {
    programs.git.lfs.enable = true;

    home.shellAliases = {
      j = "just";
      k = "kubectl";
    };

    programs.starship.settings.kubernetes = {
      disabled = false;
      detect_env_vars = [ "LUMINOVO_REPO" ];
      contexts = [
        {
          context_pattern = "lumiquote-dev";
          style = "green";
          context_alias = "Luminovo Azure (Dev)";
        }
        {
          context_pattern = "lumiquote-prod-germanywestcentral";
          style = "bold red";
          context_alias = "Luminovo Azure (Prod)";
        }
        {
          context_pattern = "lumiquote-staging-germanywestcentral";
          style = "bold red";
          context_alias = "Luminovo Azure (Staging)";
        }
      ];
    };
  };
}
