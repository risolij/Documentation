{
  description = "Minimal Zensical development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.zensical;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.zensical
            pkgs.python3
            pkgs.cargo
            pkgs.rustc
          ];

          shellHook = ''
            echo "Zensical environment (Single System) loaded."
          '';
        };
      }
    );
}
