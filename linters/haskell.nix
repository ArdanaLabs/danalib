{ pkgs }:
rec {
  lintScript = pkgs.writers.writeBashBin "lint" ''
    PATH="$PATH:${pkgs.git}/bin:${pkgs.stylish-haskell}/bin:${pkgs.haskellPackages.cabal-fmt}/bin:${pkgs.hlint}/bin"
    # Find all of the .hs and .cabal files in the current directory
    HS_FILES=$(find . -type f -name '*.hs' ! -path './dist-newstyle/*')
    CB_FILES=$(find . -type f -name '*.cabal' ! -path '*/dist-newstyle/*')

    # Lint and modify the files in place.
    stylish-haskell --inplace $HS_FILES 
    cabal-fmt --inplace $CB_FILES

    # Exit with non zero status if we're now in unclean state
    if [ -z "$(git status --porcelain)" ]; then
        echo "No style errors detected."
    else
        echo "Style errors detected:"
        git --no-pager diff
        echo
        echo "Run git status to see the changes made."
        exit 1
    fi
    hlint .
  '';
  lintDerivation = src: pkgs.stdenv.mkDerivation {
    name = "lint-haskell";
    src = src;
    dontBuild = true;
    installPhase = ''
      PATH="$PATH:${pkgs.git}/bin"
      export GIT_AUTHOR_NAME="nobody"
      export EMAIL="no@body.com"
      git init
      git add .
      git commit -m "init"
      ${lintScript}/bin/lint | tee $out
    '';
  };
}
