set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

essay_tex := "checkpoint_quintilemma.tex"
essay_pdf := "checkpoint_quintilemma.pdf"

default:
    @just --list

fmt:
    tmp="$(mktemp --suffix=.tex)"; trap 'rm -f "$tmp"' EXIT; latexindent -l -s -c /tmp -o "$tmp" {{essay_tex}}; test -s "$tmp"; mv "$tmp" {{essay_tex}}

fmt-check:
    tmp="$(mktemp --suffix=.tex)"; trap 'rm -f "$tmp"' EXIT; latexindent -l -s -c /tmp -o "$tmp" {{essay_tex}}; diff -u {{essay_tex}} "$tmp"

build:
    latexmk -pdf -interaction=nonstopmode -file-line-error -halt-on-error {{essay_tex}}

watch:
    latexmk -pdf -pvc -interaction=nonstopmode -file-line-error {{essay_tex}}

clean:
    latexmk -C {{essay_tex}}

distclean: clean
    rm -f {{essay_pdf}}

nix-build:
    nix build .#checkpoint-quintilemma

nix-check:
    nix flake check
