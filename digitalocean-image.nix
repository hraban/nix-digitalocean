{
  pkgs ? import <nixpkgs> { },
}:
let
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = [
      <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix>
      ./digitalocean-config.nix
    ];
  };
in
(pkgs.nixos config).digitalOceanImage
