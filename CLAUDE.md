# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project demonstrates how Nix can protect JavaScript supply chains from malicious attacks. The project showcases:

- **Supply Chain Security**: How Nix's content-addressable storage and cryptographic verification prevents malicious dependency injection
- **Immutable Dependencies**: Using Nix flakes and `node2nix` to create hermetic, reproducible JavaScript environments
- **TanStack Example**: A practical implementation using TanStack Start to show real-world Nix-secured JavaScript development

The project uses Nix flakes for development environment management and demonstrates Nix principles for securing npm dependencies.

## Development Environment

### Nix Development Shell

This project provides a Nix development shell with all necessary tools. Key commands:

- `nix develop` - Enter the development environment
- `nix run .#help` - Show all available commands and packages
- `nix flake show` - Display available packages and development shells

**Important for Claude Code**: Use `nix develop` to enter the development environment which includes Node.js, npm, and all necessary development tools.

### Getting Started

1. Ensure you have Nix with flakes enabled
2. Navigate to the project directory
3. Run `nix develop` to enter the development environment
4. All necessary dependencies and tools will be available within the shell

## Project Structure

- `README.md` - Comprehensive guide explaining the security vulnerabilities in JavaScript supply chains and how Nix solves them
- `PRD.md` - Product Requirements Document outlining the complete implementation plan
- `flake.nix` - Nix flake configuration with development environment and security demo packages
- `examples/tanstack-start/` - **COMPLETED**: TanStack Start application with dream2nix security
  - `flake.nix` - Dream2nix configuration with nodejs-package-lock-v3 module
  - `README.md` - Comprehensive security documentation and usage guide
  - Security demonstration tools (`security-demo`, `deps-audit`, `npm-vulnerability-demo`)
- `examples/attack-scenarios/` - Future attack simulation framework
- `docs/` - Additional documentation and guides
- `scripts/` - Automation and demo scripts

## Key Concepts Demonstrated

1. **Content-Addressed Security**: How Nix's content-addressable store prevents silent dependency tampering
2. **Cryptographic Verification**: Using integrity hashes from `package-lock.json` to verify package authenticity
3. **Hermetic Builds**: Eliminating dangerous post-install scripts and ensuring reproducible builds
4. **Dream2nix Integration**: Modern Node.js package management with nodejs-package-lock-v3 module
5. **Attack Prevention**: Live demonstrations of how traditional npm vulnerabilities are blocked
6. **Binary Caches**: Optimizing build times with shared caches (Cachix, Determinate Nix, Flox)

## Implementation Status

### ✅ Phase 1: Foundation (COMPLETED)
- TanStack Start application with dream2nix security integration
- Working `nix develop` environment with Node.js 20.x support
- Comprehensive security demonstration tools
- 676+ dependencies with cryptographic verification
- Attack prevention demonstrations for silent replacement, post-install scripts, and registry tampering

### 🚧 Phase 2: Security Demonstrations (Next)
- Attack simulation framework
- Mock compromised package scenarios
- Before/after security comparisons
- Automated vulnerability testing

## Quick Start Commands

```bash
# Navigate to TanStack example
cd examples/tanstack-start

# Enter secured development environment
nix develop

# Run security demonstrations
nix run .#security-demo        # Show comprehensive security comparison
nix run .#deps-audit          # Audit dependency security status
nix run .#npm-vulnerability-demo  # Show npm attack scenarios

# Development workflow with secured dependencies
npm run dev     # Start development server
npm run build   # Build for production
npm test        # Run tests
nix build       # Build with full Nix security verification
```