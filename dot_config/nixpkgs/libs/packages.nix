pkgs: name:
let
  all = builtins.filter (x: builtins.pathExists x) [
    ./packages.json
    ./packages.override.json
  ];
  allPkgs =
    builtins.foldl' (a: file: a // (builtins.fromJSON (builtins.readFile file)))
    { } all;
  p = allPkgs."${name}";
  source = pkgs."${p.fetchMethod}" (builtins.removeAttrs p [ "fetchMethod" ]);
in source
