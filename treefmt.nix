{ ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.shfmt.enable = true;
  programs.black.enable = true;
}
