{
  description = "Digitalocean management using Nix";

  inputs = {
    nixpkgs.url = "nixpkgs";
    systems.url = "systems";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      systems,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      imports = [
        inputs.treefmt-nix.flakeModule
        { flake.nixosModules.default = import ./digitalocean-config.nix; }
      ];
      perSystem =
        {
          system,
          pkgs,
          lib,
          ...
        }:
        let
          scope = pkgs.lib.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage newScope;
            directory = ./packages;
          };
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          packages = {
            inherit (scope) do-launch do-upload-image do-load-vars;
            default = scope.do-launch;
          };
          devShells.default = pkgs.mkShell {
            name = "dodl";
            packages = with scope; [
              do-launch
              do-upload-image
              do-load-vars
            ];
          };
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt = {
              enable = true;
              strict = true;
            };
            programs.shfmt.enable = true;
          };
        };
    };
}
