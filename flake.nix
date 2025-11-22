{
  description = "OCI/Docker container registry";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          inherit (cargoToml.package) name version;
          src = pkgs.lib.sourceByRegex ./. [
            "^src/?.*"
            "^Cargo\.lock$"
            "^Cargo\.toml$"
            "^README\.md$"
            # "^.data"
          ];
          doCheck = false;
          cargoLock.lockFile = ./Cargo.lock;
          cargoBuildFlags = [
            "--bin"
            "container-registry"
            "--features"
            "bin"
          ];
          meta = with pkgs.lib; {
            description = "A minimal implementation of an OCI container registry";
            homepage = "https://github.com/mbr/container_registry-rs";
            license = licenses.mit;
          };
        };
      }
    );
}
