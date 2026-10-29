{ ... }: {
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
}
