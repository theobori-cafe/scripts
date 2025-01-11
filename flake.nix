{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-md2gemini.url = "github:NixOS/nixpkgs?rev=0215034f25d23eb6da0f8006a941ccbfd4d9c355";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-md2gemini,
      treefmt-nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        md2geminipkgs = nixpkgs-md2gemini.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        packages = {
          default = pkgs.callPackage ./. { inherit (md2geminipkgs.python3Packages) md2gemini; };
        };

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}
