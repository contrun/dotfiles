{
  allowUnfree = true;
  allowBroken = true;
  packageOverrides = pkgs: with pkgs; rec {
    # myPython = python36.withPackages (ps: with ps;
    # [ pip setuptools virtualenvwrapper yapf black jupyter ]
    # );
    myPython2 = python27.withPackages (ps: with ps;
      [ pip setuptools ]
    );
  };
}
