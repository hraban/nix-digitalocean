let
  defaults = { config, lib, ... }: {
    options.dodo.defaultSettings = lib.mkEnableOption "Bare default settings for DigitalOcean images";
    config = lib.mkIf config.dodo.defaultSettings {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          # Swap to evaluate nixpkgs even on the smallest droplets (10 GiB disk with
          # 512 MiB RAM).  3 GiB seems to hit the sweet spot between evaluating
          # nixpkgs and not running out of disk space at least until the next phase in
          # the bootstrap process.  Of course this can overridden / disabled in a
          # do-userdata.nix.
          size = 3 * 1024;
        }
      ];
    };
  };
  userDataFileModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dodo.extractConstants = lib.mkEnableOption "Extract files from the footer of userdata comments";
      # copied / cargo culted from the digitalocean-init &
      # github:hraban/nix-tools’ digitalocean-extract-keys services
      config = lib.mkIf config.dodo.extractConstants {
        systemd.services.digitalocean-extract-constants = rec {
          description = "Extract contents from do-userdata.nix comments";
          requires = [
            "digitalocean-init.service"
            "digitalocean-metadata.service"
          ];
          after = requires;
          unitConfig = {
            ConditionPathExists = "/etc/nixos/do-userdata.nix";
            X-StopOnRemoval = false;
          };
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          restartIfChanged = true;
          path = with pkgs; [
            gnused
            coreutils
            findutils # xargs
          ];
          environment = {
            HOME = "/root";
            # ??
            NIX_PATH = lib.concatStringsSep ":" [
              "/nix/var/nix/profiles/per-user/root/channels/nixos"
              "nixos-config=/etc/nixos/configuration.nix"
              "/nix/var/nix/profiles/per-user/root/channels"
            ];
          };
          # This doesn’t keep state so old secrets are not cleared up! Doesn’t
          # matter for userdata stuff anyway but good to keep in mind.
          script = ''
            set -e
            if [[ -f /etc/nixos/do-userdata.nix ]]; then
              < /etc/nixos/do-userdata.nix sed -ne 's/^\s*# file: //p' | while read -r file content; do
                dirname "$file" | xargs mkdir -p
                printf "%s" "$content" > "$file"
              done
            fi
          '';
        };
      };
    };
in
{ lib, ... }: {
  imports = [
    defaults
    userDataFileModule
  ];
  dodo.defaultSettings = lib.mkDefault true;
  dodo.extractConstants = lib.mkDefault true;
}
