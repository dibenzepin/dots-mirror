{
  lib,
  config,
  pkgs,
  ...
}:

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

    programs = {
      starship.settings.kubernetes = {
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

      zed-editor = {
        extensions = [ "helm" ];
        userSettings = {
          languages.YAML.format_on_save = "off"; # todo: remove when devcontainer is made
          lsp.yaml-language-server.settings.yaml.customTags = [ "!reference sequence" ];
          # https://www.reddit.com/r/ZedEditor/comments/1krqxzc/the_eslint_configuration_does_not_find_the/mtn8e12/
          lsp.eslint.settings.workingDirectory.mode = "location";
          file_types = {
            "Helm" = [
              "**/templates/**/*.tpl"
              "**/templates/**/*.yaml"
              "**/templates/**/*.yml"
              "**/helmfile.d/**/*.yaml"
              "**/helmfile.d/**/*.yml"
              "**/values*.yaml"
            ];
          };
        };
      };
    };

    # do i like it? no
    # does the helm extension only look on PATH and doesn't allow you to specify a location? yes
    home.packages = [ pkgs.helm-ls ];
  };
}
