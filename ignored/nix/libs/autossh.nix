{ hostname, serverName, ... }:
let
  basePort = 32768;
  bias = 4096;
  atoi = (import ./atoi.nix);
  getPort = host: server: n:
    let
      hash = builtins.hashString "sha512"
        "${server}->${host}->${builtins.toString n}";
      port = atoi ("0x" + (builtins.substring 0 3 hash));
    in basePort + n * bias + port;
  go = n: getPort hostname serverName n;
in map go [ 1 2 ]
