{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    my.dbeaver.enable = lib.mkEnableOption "home-manager managed dbeaver";
  };

  config = lib.mkIf config.my.dbeaver.enable {
    home.packages = [ pkgs.dbeaver-bin ];

    # from https://github.com/dbeaver/dbeaver/issues/1774#issuecomment-1125835108
    # todo: add Linux
    home.file."Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.ui.editors.data/dialog_settings.xml".text =
      ''
        <?xml version="1.0" encoding="UTF-8"?>
        <section name="Workbench">
          <section name="AbstractTextPanelEditor">
            <item key="content.text.editor.auto-format" value="true"/>
            <item key="content.text.editor.word-wrap" value="true"/>
          </section>
        </section>
      '';
  };
}
