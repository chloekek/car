let
    pkgs = import ./nix/pkgs.nix {};
    card = pkgs.stdenv.mkDerivation {
        name = "card";
        buildInputs = [pkgs.ldc];
        phases = ["unpackPhase" "buildPhase"
                  "installPhase" "fixupPhase"];
        unpackPhase = ''
            cp --recursive ${./card} src
        '';
        buildPhase = ''
            flags=(-dip1000)
            sources=$(find src -type f -name '*.d')
            ldc2 $flags -unittest $sources -of=card.test
            ldc2 $flags -release -O2 $sources -of=card
        '';
        installPhase = ''
            mkdir --parents $out/bin
            mv card{,.test} $out/bin
        '';
    };
in
    {
        inherit card;
    }
