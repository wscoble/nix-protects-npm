# Product Requirements Document: Nix-Protected npm Supply Chain Demo

## Overview

Create a comprehensive demonstration project that showcases how Nix can protect JavaScript applications from supply chain attacks, implementing the security principles outlined in `ARTICLE.md`.

## Problem Statement

JavaScript supply chain attacks are escalating, with attackers increasingly targeting:
- Transitive dependencies through silent content replacement (same version, malicious content)
- Post-install scripts for data exfiltration and backdoor injection
- Mutable npm registry exploitation

Traditional npm + `package-lock.json` approaches provide insufficient protection against these sophisticated attacks.

## Success Criteria

1. **Demonstration Completeness**: Working examples that prove Nix prevents the specific attack vectors described in ARTICLE.md
2. **Educational Value**: Clear, step-by-step implementations that developers can follow and understand
3. **Real-world Applicability**: Uses modern JavaScript frameworks and realistic project structures
4. **Performance Viability**: Shows how binary caches make Nix practical for daily development

## Core Features

### 1. Attack Vector Demonstrations

#### 1.1 Silent Dependency Replacement Demo
- **What**: Create a scenario showing how traditional npm fails when a transitive dependency's content is maliciously replaced (same version)
- **Implementation**:
  - Mock registry with compromised package
  - Show npm installing malicious content despite correct version
  - Demonstrate Nix build failure due to hash mismatch
- **Success Metric**: Clear visual proof that Nix prevents the attack

#### 1.2 Post-install Script Protection
- **What**: Show how Nix eliminates dangerous post-install script execution
- **Implementation**:
  - Package with malicious post-install script
  - Traditional npm execution vs Nix hermetic build
  - Evidence of script prevention in Nix environment
- **Success Metric**: Proof that malicious scripts don't execute in Nix builds

### 2. Practical Implementation Examples

#### 2.1 TanStack Start Application
- **What**: Complete modern React application using TanStack Start
- **Implementation**:
  - Initialize TanStack Start project
  - Create comprehensive `flake.nix` with `node2nix` integration
  - Working development and build environments
- **Success Metric**: Fully functional React app built entirely through Nix

#### 2.2 Multi-Framework Comparison
- **What**: Show Nix protection across different JavaScript frameworks
- **Implementation**:
  - Next.js application example
  - Node.js backend service example
  - Shared dependency management patterns
- **Success Metric**: Consistent security model across different project types

### 3. Development Experience Optimization

#### 3.1 Binary Cache Integration
- **What**: Demonstrate fast development workflows using shared caches
- **Implementation**:
  - Cachix integration setup
  - Before/after performance comparisons
  - CI/CD pipeline with cache pushing/pulling
- **Success Metric**: Sub-minute setup times for complex dependency graphs

#### 3.2 Developer Workflow
- **What**: Seamless development experience matching traditional npm workflows
- **Implementation**:
  - `nix develop` shell with proper tooling
  - npm script compatibility
  - Hot reloading and development server integration
- **Success Metric**: Developer productivity equivalent to traditional npm

### 4. Security Verification Tools

#### 4.1 Dependency Audit Dashboard
- **What**: Visual representation of security benefits
- **Implementation**:
  - Dependency graph visualization
  - Hash verification status display
  - Comparison with traditional npm audit
- **Success Metric**: Clear security posture visibility

#### 4.2 Attack Simulation Framework
- **What**: Controlled environment for testing attack scenarios
- **Implementation**:
  - Mock malicious packages
  - Automated attack scenario runners
  - Security validation scripts
- **Success Metric**: Repeatable demonstrations of protection

## Technical Requirements

### 5.1 Environment Setup
- **Nix Installation**: Flakes-enabled Nix setup
- **Node.js Versions**: Support for Node 18, 20, 22
- **Platform Support**: macOS (Intel/Apple Silicon), Linux (x86_64/aarch64)

### 5.2 Integration Points
- **node2nix**: Latest version with proper lock file parsing
- **Binary Caches**: Cachix, Determinate Systems, Flox compatibility
- **CI/CD**: GitHub Actions workflow examples

### 5.3 Documentation Standards
- **Step-by-step Guides**: Beginner-friendly implementation instructions
- **Troubleshooting**: Common issues and solutions
- **Performance Benchmarks**: Quantified speed improvements with caches

## Project Structure

```
nix-protects-npm/
├── README.md                    # Main project documentation
├── ARTICLE.md                   # Theoretical foundation (existing)
├── PRD.md                       # This document
├── CLAUDE.md                    # Claude Code guidance (existing)
├── flake.nix                    # Nix development environment and packages
├── examples/
│   ├── tanstack-start/          # Primary TanStack example
│   ├── nextjs-app/              # Next.js comparison
│   ├── node-backend/            # Backend service example
│   └── attack-scenarios/        # Security demonstration scenarios
├── docs/
│   ├── getting-started.md       # Setup instructions
│   ├── security-comparison.md   # Before/after security analysis
│   └── performance-guide.md     # Cache optimization guide
├── scripts/
│   ├── setup-demo.sh           # Automated demo environment setup
│   ├── run-attack-sim.sh       # Attack simulation runner
│   └── benchmark.sh            # Performance measurement tools
└── flake.nix                   # Root flake for the entire project
```

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Set up base flake.nix for project
- [ ] Create TanStack Start example with working Nix integration
- [ ] Implement basic attack scenario demonstration
- [ ] Document setup process

### Phase 2: Security Demonstrations (Week 2)
- [ ] Build silent dependency replacement demo
- [ ] Create post-install script protection example
- [ ] Implement dependency audit visualization
- [ ] Add attack simulation framework

### Phase 3: Developer Experience (Week 3)
- [ ] Integrate binary cache optimization
- [ ] Create multi-framework examples
- [ ] Build seamless development workflow
- [ ] Performance benchmarking tools

### Phase 4: Documentation & Polish (Week 4)
- [ ] Comprehensive documentation suite
- [ ] Video walkthroughs and demos
- [ ] Troubleshooting guides
- [ ] Community feedback integration

## Success Metrics

### Quantitative
- **Setup Time**: < 2 minutes for cached environments
- **Build Reproducibility**: 100% identical builds across environments
- **Security Coverage**: Protection against all attack vectors in ARTICLE.md
- **Framework Support**: 3+ JavaScript frameworks demonstrated

### Qualitative
- **Developer Adoption**: Positive feedback from JavaScript developers
- **Educational Impact**: Clear understanding of security benefits
- **Community Engagement**: GitHub stars, forks, and contributions
- **Industry Recognition**: Citation in security best practices

## Risk Assessment

### Technical Risks
- **node2nix Limitations**: May not support all npm packages perfectly
- **Mitigation**: Provide workarounds and alternative approaches

- **Performance Overhead**: Initial builds may be slow without caches
- **Mitigation**: Emphasize binary cache setup and provide benchmarks

### Adoption Risks
- **Learning Curve**: Nix has steep learning curve for JavaScript developers
- **Mitigation**: Provide excellent documentation and gradual introduction

- **Ecosystem Compatibility**: Some tools may not work well with Nix
- **Mitigation**: Test with popular tools and provide compatibility guides

## Future Enhancements

1. **IDE Integration**: VS Code extensions for Nix-managed JavaScript projects
2. **Automated Migration**: Tools to convert existing projects to Nix
3. **Enterprise Features**: SBOM generation, compliance reporting
4. **Registry Integration**: Direct integration with private npm registries