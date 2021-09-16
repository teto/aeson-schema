{
  description = "Multipath tcp pcap analyzer tool";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    hls.url = "github:haskell/haskell-language-server";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let

      compilerVersion = "8107";
      # compilerVersion = "901";


      # pkgs = nixpkgs.legacyPackages."${system}";
      pkgs = import nixpkgs {
          inherit system;
          # overlays = pkgs.lib.attrValues (self.overlays);
          config = { allowUnfree = true; allowBroken = true; };
        };

      myHaskellPackages = pkgs.haskell.packages."ghc${compilerVersion}";

      hsEnv = myHaskellPackages.ghcWithPackages(hs: [
        # hs.cairo
        # hs.diagrams
        # inputs.hls.packages."${system}"."haskell-language-server-${compilerVersion}"
        hs.cabal-install
        hs.stylish-haskell
        hs.hasktags
        # myHaskellPackages.hlint
        # hs.shelltestrunner
      ]);

    in rec {
      # packages.mptcpanalyzer2 = flake.packages."mptcpanalyzer:exe:mptcpanalyzer";

      packages.mptcpanalyzer = pkgs.haskellPackages.developPackage {
        root = ./.;
        name = "mptcpanalyzer";
        returnShellEnv = false;
        withHoogle = true;
      };

      defaultPackage = packages.mptcpanalyzer;


      devShell = pkgs.mkShell {
        name = "dev-shell";
        buildInputs = with pkgs; [
          inputs.hls.packages."${system}"."haskell-language-server-${compilerVersion}"
          hsEnv
          pkg-config
        ];

        shellHook = ''
        '';
      };

    });
}
