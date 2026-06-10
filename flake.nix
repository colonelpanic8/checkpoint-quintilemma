{
  description = "Checkpoint Quintilemma build environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            collection-fontsrecommended
            collection-latexextra
            scheme-medium
            ;
        };

        checkpointQuintilemma = pkgs.stdenvNoCC.mkDerivation {
          pname = "checkpoint-quintilemma";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [
            tex
          ];

          buildPhase = ''
            runHook preBuild
            latexmk -pdf -interaction=nonstopmode -file-line-error -halt-on-error checkpoint_quintilemma.tex
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out"
            cp checkpoint_quintilemma.pdf "$out/"
            runHook postInstall
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.just
            pkgs.texlivePackages.latexindent
            tex
          ];
        };

        packages = {
          default = checkpointQuintilemma;
          checkpoint-quintilemma = checkpointQuintilemma;
        };

        checks.checkpoint-quintilemma = checkpointQuintilemma;
      }
    );
}
