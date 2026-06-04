{
  description = "Checkpoint Quadrilemma build environment";

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

        checkpointQuadrilemma = pkgs.stdenvNoCC.mkDerivation {
          pname = "checkpoint-quadrilemma";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [
            tex
          ];

          buildPhase = ''
            runHook preBuild
            latexmk -pdf -interaction=nonstopmode -file-line-error -halt-on-error checkpoint_quadrilemma.tex
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out"
            cp checkpoint_quadrilemma.pdf "$out/"
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
          default = checkpointQuadrilemma;
          checkpoint-quadrilemma = checkpointQuadrilemma;
        };

        checks.checkpoint-quadrilemma = checkpointQuadrilemma;
      }
    );
}
