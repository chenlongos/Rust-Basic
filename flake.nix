{
  description = "Small exercises to get you used to reading and writing Rust code";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        });

        cargoBuildInputs = with pkgs; lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.CoreServices
        ];

        rustlings = pkgs.rustPlatform.buildRustPackage {
          pname = "rustlings";
          version = "5.5.1";

          src = pkgs.lib.cleanSourceWith {
            src = self;
            filter = path: type:
              let
                baseName = builtins.baseNameOf (toString path);
                path' = builtins.replaceStrings [ "${self}/" ] [ "" ] path;
                inDirectory = directory: pkgs.lib.hasPrefix directory path';
              in
              inDirectory "src" ||
              inDirectory "tests" ||
              inDirectory "exercises" ||
              pkgs.lib.hasPrefix "Cargo" baseName ||
              baseName == "info.toml" ||
              baseName == "flake.nix" ||
              baseName == "flake.lock";
          };

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          buildInputs = cargoBuildInputs;

          meta = with pkgs.lib; {
            description = "Small exercises to get you used to reading and writing Rust code";
            homepage = "https://github.com/rust-lang/rustlings";
            license = licenses.mit;
          };
        };
      in
      {
        packages = {
          default = rustlings;
          rustlings = rustlings;
        };

        devShells.default = pkgs.mkShell {
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          buildInputs = [
            rustToolchain
          ] ++ cargoBuildInputs;

          shellHook = ''
            echo "Rustlings development environment"
            echo "Run 'cargo run' to start rustlings"
          '';
        };

        # Legacy alias for backwards compatibility
        devShell = self.devShells.${system}.default;
      });
}
