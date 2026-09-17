{
  description = "A simple project. Just a fok (seal) with a quote cloud, saying some fun stuff (mostly ripped out of context, from my vc talks with Frends)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "path:./systems.nix";
    systems.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    systems
  }: let
      forAllSystems = f: nixpkgs.lib.genAttrs (import systems) f;
    in {
      packages = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        config = import ./configuration.nix;
        lib = nixpkgs.lib;
      in rec {
        default = fokquote;
        fokquote = pkgs.runCommand "fokquote" {
          buildInputs = [pkgs.rustc pkgs.gcc];
          src = ./src;
          quotes =
            ["["]
            ++ (lib.lists.forEach config.quotes (x: "[\"" + toString (builtins.elemAt x 0) + "\" \"" + toString (builtins.elemAt x 1) + "\"]"))
            ++ ["]"];
          plush = #"\\\"" + config.plush + "\\\"";
            ["["]
            ++ (lib.lists.forEach (lib.strings.splitString "\n" config.plush) (x: "\"" + toString x + "\""))
            ++ ["]"];
          #quotes = "[[\"test quote\" \"fokfok\"]]";
        } ''
          mkdir -p "$out/bin"
          export CONFIG="{quotes=$quotes; plush=$plush}"
          rustc $src/fokquote.rs -o $out/bin/fokquote
        '';
        }
      );
    };
}
