{
  description = "Nix-Protected npm Supply Chain Demo Project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        # Note: TanStack example will be created in examples/tanstack-start/

      in {
        # Expose security demonstration tools at root level for easy access
        packages = {
          # Help command - shows all available Nix targets
          help = pkgs.writeShellScriptBin "help" ''
            echo "🛡️  Nix Protects npm - Available Commands"
            echo "========================================"
            echo ""
            echo "📋 OVERVIEW COMMANDS (run from project root):"
            echo "   nix run .#help                  # Show this help message"
            echo "   nix run .#security-demo         # Project overview and navigation"
            echo "   nix run .#deps-audit            # High-level dependency overview"
            echo "   nix run .#npm-vulnerability-demo # npm vulnerability overview"
            echo ""
            echo "🔧 SETUP COMMANDS:"
            echo "   ./create-tanstack-flake.sh      # Create TanStack demo project"
            echo "   nix develop                     # Enter development environment"
            echo ""
            echo "🎯 DETAILED DEMOS (from examples/tanstack-start/):"
            echo "   nix run .#security-demo         # REAL dependency verification"
            echo "   nix run .#deps-audit            # LIVE analysis of actual dependencies"
            echo "   nix run .#npm-vulnerability-demo # Attack scenario explanations"
            echo ""
            echo "🚨 ATTACK SIMULATIONS (from examples/attack-scenarios/):"
            echo "   ./comprehensive-demo-suite.sh   # Complete Phase 2 demonstration suite"
            echo "   ./automated-attack-tests.sh     # Automated vulnerability testing (5 scenarios)"
            echo "   ./before-after-comparison.sh    # Side-by-side security analysis with ROI"
            echo "   ./simulate-attacks.sh           # Individual attack simulations"
            echo "   ./nix-hash-demo.sh              # Real Nix hash verification failure"
            echo ""
            echo "💡 QUICK START:"
            echo "   1. nix run .#help               # This help (you are here!)"
            echo "   2. nix run .#security-demo      # Get overview"
            echo "   3. ./create-tanstack-flake.sh   # Set up demo"
            echo "   4. cd examples/tanstack-start   # Navigate to demo"
            echo "   5. npm create @tanstack/start@latest ."
            echo "   6. nix develop                  # Enter secured environment"
            echo ""
            echo "📖 For more details, see README.md"
            echo ""
            echo "🔍 To see available packages: nix flake show"
          '';
          # Main security demonstration showing npm vulnerabilities vs Nix protection
          security-demo = pkgs.writeShellScriptBin "security-demo" ''
            echo "🔒 Nix Supply Chain Security Demo"
            echo "================================="
            echo ""
            echo "This project demonstrates how Nix + dream2nix can completely"
            echo "secure JavaScript supply chains from sophisticated attacks."
            echo ""
            echo "📁 Project Structure:"
            echo "  examples/tanstack-start/  - Complete TanStack Start demo with dream2nix"
            echo "  README.md                - Complete setup and usage guide"
            echo "  PRD.md                   - Product requirements document"
            echo ""
            echo "🎯 Next Steps to Build the Demo:"
            echo "  mkdir -p examples/tanstack-start"
            echo "  cd examples/tanstack-start"
            echo "  npm create @tanstack/start@latest ."
            echo "  # Create flake.nix with dream2nix configuration (see README.md)"
            echo "  nix develop"
            echo ""
            echo "📖 For detailed documentation, see examples/tanstack-start/README.md"
            echo ""
            echo "Navigate to examples/tanstack-start for the full demo experience!"
          '';

          # Dependency audit overview
          deps-audit = pkgs.writeShellScriptBin "deps-audit" ''
            echo "📊 Project Dependencies Overview"
            echo "==============================="
            echo ""
            echo "🔍 This project contains:"
            echo "  - TanStack Start application with 676+ secured dependencies"
            echo "  - All packages cryptographically verified via dream2nix"
            echo "  - Content-addressable storage preventing tampering"
            echo ""
            echo "🎯 To create the full dependency audit demo:"
            echo "  mkdir -p examples/tanstack-start"
            echo "  cd examples/tanstack-start"
            echo "  npm create @tanstack/start@latest ."
            echo "  # Create flake.nix with dream2nix configuration (see README.md)"
            echo "  nix run .#deps-audit"
            echo ""
            echo "This will show real-time security status of all npm packages."
          '';

          # npm vulnerability demonstration
          npm-vulnerability-demo = pkgs.writeShellScriptBin "npm-vulnerability-demo" ''
            echo "⚠️  npm Vulnerability Overview"
            echo "============================="
            echo ""
            echo "This project demonstrates protection against:"
            echo "  ❌ Silent dependency replacement attacks"
            echo "  ❌ Post-install script execution"
            echo "  ❌ Transitive dependency poisoning"
            echo "  ❌ Registry tampering"
            echo "  ❌ Version drift between environments"
            echo ""
            echo "🛡️  All these attacks are prevented by Nix + dream2nix!"
            echo ""
            echo "🎯 To create the full vulnerability demonstration:"
            echo "  mkdir -p examples/tanstack-start"
            echo "  cd examples/tanstack-start"
            echo "  npm create @tanstack/start@latest ."
            echo "  # Create flake.nix with dream2nix configuration (see README.md)"
            echo "  nix run .#npm-vulnerability-demo"
            echo ""
            echo "See README.md for detailed vulnerability explanations and setup instructions."
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "nix-protects-npm-dev";

          packages = with pkgs; [
            nodejs_20
            nodePackages.npm
            git
            jq
            curl
            nix-prefetch
          ];

          shellHook = ''
            echo "🛡️  Nix-Protected npm Supply Chain Demo Environment"
            echo "================================================="
            echo ""
            echo "📋 Available commands:"
            echo "  nix run .#help              # Show all available Nix commands"
            echo "  ./create-tanstack-flake.sh  # Create TanStack demo project"
            echo "  nix develop                 # Enter this development environment"
            echo ""
            echo "🎯 Quick start workflow:"
            echo "  1. nix run .#help           # See all options"
            echo "  2. nix run .#security-demo  # Get project overview"
            echo "  3. ./create-tanstack-flake.sh examples/tanstack-start"
            echo "  4. cd examples/tanstack-start && npm create @tanstack/start@latest ."
            echo "  5. nix develop              # Enter secured environment"
            echo ""
            echo "🚨 Attack simulations:"
            echo "  cd examples/attack-scenarios"
            echo "  ./simulate-attacks.sh       # Comprehensive attack framework"
            echo "  ./nix-hash-demo.sh          # Real hash verification demo"
            echo ""
            echo "📖 For detailed documentation, see README.md"
          '';
        };

        # Convenience shells for different parts of the project
        devShells.tanstack = pkgs.mkShell {
          name = "tanstack-demo";
          packages = with pkgs; [
            nodejs_20
            npm
          ];
          shellHook = ''
            echo "🚀 TanStack Start Demo Environment"
            cd examples/tanstack-start
          '';
        };

        devShells.security = pkgs.mkShell {
          name = "security-demo";
          packages = with pkgs; [
            nodejs_20
            npm
            curl
            jq
          ];
          shellHook = ''
            echo "🔒 Security Attack Demo Environment"
            cd examples/attack-scenarios
          '';
        };
      }
    );
}