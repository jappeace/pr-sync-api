{ pkgs ? import ./pkgs.nix { }
,
}:
pkgs.haskellPackages.override {
  overrides = hnew: hold: {
    pr-sync-api = hnew.callCabal2nix "pr-sync-api" ../. { };
  };
}
