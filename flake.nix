{
  description = "Sonic 3 A.I.R. Source Build";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        # shell utils
        bashInteractive

        # build deps
        zig_0_17
      ];
    };
  };
}
