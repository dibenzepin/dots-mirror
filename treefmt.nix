{ ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  settings.global.excludes = [
    "*.md"
    "*.conf"
    "*.png"
    "*.txt"
    "*.jpg"
  ];
}
