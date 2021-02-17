with import <nixpkgs> { };
mkShell {
  sopsPGPKeyDirs = [ ./keys ];
  nativeBuildInputs = [
    (pkgs.callPackage "${builtins.fetchTarball
      "https://github.com/Mic92/sops-nix/archive/master.tar.gz"}"
      { }).sops-pgp-hook
  ];
}
