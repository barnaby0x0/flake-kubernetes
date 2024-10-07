{
  description = "Flake pour installer une version spécifique de Kubernetes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux"; # Remplacez par votre système si nécessaire
      kubernetesVersion = "1.28.3";
      kubernetesSha256 = "1bsf3mcrpx9spi8g3qxx0j2p313dnfqcr1rcprv9zs6v9l14bgwm";

      overlay = final: prev: {
        kubernetes = prev.kubernetes.overrideAttrs (oldAttrs: rec {
          version = kubernetesVersion;
          src = prev.fetchFromGitHub {
            owner = "kubernetes";
            repo = "kubernetes";
            rev = "v${kubernetesVersion}";
            sha256 = kubernetesSha256;
          };
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      packages.${system}.kubernetes = pkgs.kubernetes;

      # Si vous utilisez NixOS
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            nixpkgs.overlays = [ overlay ];
            environment.systemPackages = with pkgs; [ kubernetes ];
          }
        ];
      };
      devShells = {
        default = pkgs.mkShell {  # Corriger ici : utiliser nixpkgs.mkShell au lieu de nixpkgs.lib.mkShell
          buildInputs = [ pkgs.kubernetes ];  # Utiliser Kubernetes avec les nouveaux attributs
        };
      };
    };
}

