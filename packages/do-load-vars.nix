{
  _1password-cli,
  lib,
  writeShellApplication,
  writeText,
}:
let
  vars = builtins.toFile "dodl-vars" ''
    : "''${DO_REGION="nyc1"}"
    export DO_REGION
    DO_IMAGE_URL="https://github.com/hraban/nix-digitalocean/releases/download/latest/nixos-digitalocean-x86_64-linux.qcow.gz"
    export DO_IMAGE_URL
    DO_IMAGE_SLUG="nixos-nixpkgs-unstable-$DO_REGION"
    export DO_IMAGE_SLUG
    : "''${DIGITALOCEAN_ACCESS_TOKEN=$(op read "op://Personal/DigitalOcean/api key")}"
    export DIGITALOCEAN_ACCESS_TOKEN
  '';
in
# usage: eval "$(do-load-vars)"
writeShellApplication {
  name = "do-load-vars";
  meta.description = "Eval the output of this script to set do-compatible envvars";
  runtimeInputs = [ _1password-cli ];
  text = ''
    cat ${vars}
  '';
}
