{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in with pkgs; {
        packages = let beamPackages = pkgs.beamPackages;
        in {
          hyprland-ipc = let pname = "hyprland_ipc";
          in beamPackages.mixRelease {
            inherit pname;
            version = "0.2.0";

            src = ./.;

            removeCookie = false;
          };
        };
        devShells.default = mkShell { buildInputs = [ elixir elixir-ls ]; };
      });
}
