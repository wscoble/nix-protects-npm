#!/usr/bin/env bash

# Automated Attack Testing Framework
# Runs comprehensive attack simulations and validates Nix protections

set -e

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}\")\" && pwd)"
TEST_RESULTS_DIR="$DEMO_DIR/test-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔒 Automated Attack Testing Framework"
echo "====================================="
echo "🕒 Started at: $(date)"
echo "📁 Results will be saved to: $TEST_RESULTS_DIR"
echo ""

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"

# Test counter and results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log_test_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "✅ $test_name: PASSED"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "❌ $test_name: FAILED - $details"
    fi

    # Log to file
    echo "[$TIMESTAMP] $test_name: $result - $details" >> "$TEST_RESULTS_DIR/test_results.log"
}

# ============================================================================
# Test 1: Hash Verification Attack
# ============================================================================

test_hash_verification_attack() {
    echo ""
    echo "🧪 TEST 1: Hash Verification Attack Protection"
    echo "=============================================="

    local temp_dir="$TEST_RESULTS_DIR/hash_test_$TIMESTAMP"
    mkdir -p "$temp_dir"

    # Create a Nix expression with intentionally wrong hash
    cat > "$temp_dir/malicious_fetch.nix" << 'EOF'
let
  pkgs = import <nixpkgs> {};
in
pkgs.fetchurl {
  url = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
  sha256 = "0000000000000000000000000000000000000000000000000000000000000000";  # Wrong hash
}
EOF

    echo "   📋 Testing Nix rejection of malicious package with wrong hash..."

    # Try to build - this should fail
    if timeout 10s nix-build "$temp_dir/malicious_fetch.nix" 2>"$temp_dir/error.log"; then
        log_test_result "Hash Verification Protection" "FAIL" "Nix did not reject package with wrong hash"
        return 1
    else
        # Check if it failed for the right reason
        if grep -q "hash mismatch\|invalid.*hash" "$temp_dir/error.log"; then
            log_test_result "Hash Verification Protection" "PASS" "Nix correctly rejected package with invalid hash"
            echo "   ✅ Nix properly rejected malicious package"
            echo "   📄 Error details saved to: $temp_dir/error.log"
        else
            log_test_result "Hash Verification Protection" "FAIL" "Build failed for wrong reason"
            echo "   ⚠️  Build failed but not due to hash verification"
        fi
    fi
}

# ============================================================================
# Test 2: Post-install Script Isolation
# ============================================================================

test_postinstall_script_isolation() {
    echo ""
    echo "🧪 TEST 2: Post-install Script Isolation"
    echo "========================================"

    local temp_dir="$TEST_RESULTS_DIR/script_test_$TIMESTAMP"
    mkdir -p "$temp_dir"

    # Create a malicious package structure
    cat > "$temp_dir/package.json" << 'EOF'
{
  "name": "malicious-test-package",
  "version": "1.0.0",
  "scripts": {
    "postinstall": "node malicious-script.js"
  }
}
EOF

    # Create malicious post-install script
    cat > "$temp_dir/malicious-script.js" << 'EOF'
const fs = require('fs');
const path = require('path');

// Attempt to write evidence of execution
const evidenceFile = '/tmp/malicious_script_executed_' + Date.now();

try {
    fs.writeFileSync(evidenceFile, 'MALICIOUS SCRIPT EXECUTED SUCCESSFULLY');
    console.log('🚨 MALICIOUS SCRIPT EXECUTED! Evidence written to:', evidenceFile);

    // Attempt to access environment variables
    console.log('🔍 Environment access test:');
    console.log('   HOME:', process.env.HOME || 'not accessible');
    console.log('   USER:', process.env.USER || 'not accessible');
    console.log('   PATH:', process.env.PATH ? 'accessible' : 'not accessible');

    process.exit(0);
} catch (error) {
    console.log('✅ Script execution blocked or restricted');
    process.exit(1);
}
EOF

    echo "   📋 Testing traditional npm post-install script execution..."

    # Test traditional npm (this will execute the script)
    cd "$temp_dir"
    if npm install --silent 2>/dev/null; then
        # Check if malicious script created evidence file
        if ls /tmp/malicious_script_executed_* 2>/dev/null; then
            echo "   🚨 Traditional npm: Malicious script executed successfully"
            echo "   📄 Evidence files found in /tmp/"

            # Clean up evidence files
            rm -f /tmp/malicious_script_executed_*

            log_test_result "Traditional npm Script Isolation" "FAIL" "Post-install script executed with full permissions"
        else
            log_test_result "Traditional npm Script Isolation" "PASS" "Post-install script was blocked (unexpected)"
        fi
    else
        log_test_result "Traditional npm Script Isolation" "INCONCLUSIVE" "npm install failed"
    fi

    # Test Nix isolation (create simple derivation)
    cat > "$temp_dir/nix_test.nix" << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "script-isolation-test";
  src = ./.;

  buildPhase = ''
    echo "Testing script isolation in Nix build environment"

    # Try to execute the malicious script
    if [ -f malicious-script.js ]; then
      echo "Attempting to run malicious script in Nix environment..."

      # This should be isolated and unable to affect the host system
      ${pkgs.nodejs}/bin/node malicious-script.js || echo "Script execution controlled by Nix"
    fi
  '';

  installPhase = ''
    mkdir -p $out
    echo "Nix isolation test completed" > $out/result
  '';
}
EOF

    echo "   📋 Testing Nix hermetic build environment..."

    if timeout 30s nix-build "$temp_dir/nix_test.nix" 2>"$temp_dir/nix_error.log"; then
        # Check if any evidence files were created during Nix build
        if ls /tmp/malicious_script_executed_* 2>/dev/null; then
            log_test_result "Nix Script Isolation" "FAIL" "Script affected host system during Nix build"
            rm -f /tmp/malicious_script_executed_*
        else
            log_test_result "Nix Script Isolation" "PASS" "Script execution isolated in hermetic environment"
            echo "   ✅ Nix successfully isolated script execution"
        fi
    else
        log_test_result "Nix Script Isolation" "INCONCLUSIVE" "Nix build failed"
        echo "   ⚠️  Nix build failed - check $temp_dir/nix_error.log"
    fi

    cd "$DEMO_DIR"
}

# ============================================================================
# Test 3: Dependency Substitution Attack
# ============================================================================

test_dependency_substitution_attack() {
    echo ""
    echo "🧪 TEST 3: Dependency Substitution Attack Protection"
    echo "=================================================="

    local temp_dir="$TEST_RESULTS_DIR/substitution_test_$TIMESTAMP"
    mkdir -p "$temp_dir"

    # Create legitimate package.json
    cat > "$temp_dir/package.json" << 'EOF'
{
  "name": "substitution-test",
  "version": "1.0.0",
  "dependencies": {
    "is-odd": "^3.0.1"
  }
}
EOF

    cd "$temp_dir"

    echo "   📋 Generating legitimate package-lock.json..."
    if npm install --package-lock-only --silent; then
        # Extract legitimate hash
        LEGITIMATE_HASH=$(node -p "require('./package-lock.json').packages['node_modules/is-odd'].integrity")
        PACKAGE_URL=$(node -p "require('./package-lock.json').packages['node_modules/is-odd'].resolved")

        echo "   📦 Legitimate package: is-odd@3.0.1"
        echo "   🔒 Legitimate hash: ${LEGITIMATE_HASH:0:20}..."
        echo "   🌐 Package URL: $PACKAGE_URL"

        # Create Nix expression with legitimate hash
        cat > "legitimate_fetch.nix" << EOF
let
  pkgs = import <nixpkgs> {};
in
pkgs.fetchurl {
  url = "$PACKAGE_URL";
  sha256 = "$(echo "$LEGITIMATE_HASH" | sed 's/sha512-//' | base64 -d | xxd -p -c 256 | xxd -r -p | sha256sum | cut -d' ' -f1)";
}
EOF

        echo "   📋 Testing legitimate package fetch with correct hash..."
        if timeout 15s nix-build "legitimate_fetch.nix" 2>/dev/null; then
            log_test_result "Legitimate Package Fetch" "PASS" "Correct hash allows package to be fetched"
            echo "   ✅ Legitimate package fetched successfully"
        else
            log_test_result "Legitimate Package Fetch" "FAIL" "Could not fetch legitimate package"
        fi

        # Create Nix expression simulating compromised package (wrong hash)
        cat > "compromised_fetch.nix" << EOF
let
  pkgs = import <nixpkgs> {};
in
pkgs.fetchurl {
  url = "$PACKAGE_URL";
  sha256 = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef";  # Simulated compromised hash
}
EOF

        echo "   📋 Testing compromised package simulation..."
        if timeout 10s nix-build "compromised_fetch.nix" 2>"compromised_error.log"; then
            log_test_result "Compromised Package Protection" "FAIL" "Nix accepted package with wrong hash"
        else
            if grep -q "hash mismatch" "compromised_error.log"; then
                log_test_result "Compromised Package Protection" "PASS" "Nix correctly rejected compromised package"
                echo "   ✅ Compromised package correctly rejected"
            else
                log_test_result "Compromised Package Protection" "INCONCLUSIVE" "Build failed for unclear reason"
            fi
        fi

    else
        log_test_result "Package Lock Generation" "FAIL" "Could not generate package-lock.json"
    fi

    cd "$DEMO_DIR"
}

# ============================================================================
# Test 4: Registry Tampering Simulation
# ============================================================================

test_registry_tampering_simulation() {
    echo ""
    echo "🧪 TEST 4: Registry Tampering Protection"
    echo "======================================="

    local temp_dir="$TEST_RESULTS_DIR/registry_test_$TIMESTAMP"
    mkdir -p "$temp_dir"

    echo "   📋 Simulating registry tampering scenario..."

    # Create two versions of the same package with different content
    mkdir -p "$temp_dir/legitimate_package" "$temp_dir/tampered_package"

    # Legitimate package
    cat > "$temp_dir/legitimate_package/package.json" << 'EOF'
{
  "name": "test-package",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

    cat > "$temp_dir/legitimate_package/index.js" << 'EOF'
module.exports = {
  message: "This is the legitimate package content",
  isLegitimate: true
};
EOF

    # Tampered package (same version, different content)
    cat > "$temp_dir/tampered_package/package.json" << 'EOF'
{
  "name": "test-package",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

    cat > "$temp_dir/tampered_package/index.js" << 'EOF'
module.exports = {
  message: "MALICIOUS CONTENT INJECTED",
  isLegitimate: false,
  maliciousPayload: "This represents compromised registry content"
};
console.log("🚨 MALICIOUS CODE EXECUTED ON REQUIRE");
EOF

    # Create tarballs
    cd "$temp_dir"
    tar -czf legitimate_package.tgz -C legitimate_package .
    tar -czf tampered_package.tgz -C tampered_package .

    # Calculate hashes
    LEGITIMATE_HASH=$(sha256sum legitimate_package.tgz | cut -d' ' -f1)
    TAMPERED_HASH=$(sha256sum tampered_package.tgz | cut -d' ' -f1)

    echo "   📦 Legitimate package hash: ${LEGITIMATE_HASH:0:16}..."
    echo "   🚨 Tampered package hash:   ${TAMPERED_HASH:0:16}..."

    if [ "$LEGITIMATE_HASH" != "$TAMPERED_HASH" ]; then
        log_test_result "Hash Difference Detection" "PASS" "Different content produces different hashes"
        echo "   ✅ Hash difference detected between legitimate and tampered packages"

        # Demonstrate how Nix would handle this
        echo "   📋 Demonstrating Nix protection against registry tampering..."

        # Create Nix expression expecting legitimate hash but getting tampered content
        cat > "registry_tampering_test.nix" << EOF
let
  pkgs = import <nixpkgs> {};
in
pkgs.fetchurl {
  url = "file://$temp_dir/tampered_package.tgz";  # Simulating compromised registry serving tampered content
  sha256 = "$LEGITIMATE_HASH";  # But package-lock.json still expects legitimate hash
}
EOF

        if timeout 10s nix-build "registry_tampering_test.nix" 2>"registry_error.log"; then
            log_test_result "Registry Tampering Protection" "FAIL" "Nix accepted tampered content"
        else
            if grep -q "hash mismatch" "registry_error.log"; then
                log_test_result "Registry Tampering Protection" "PASS" "Nix detected registry tampering via hash mismatch"
                echo "   ✅ Registry tampering successfully blocked by Nix"
            else
                log_test_result "Registry Tampering Protection" "INCONCLUSIVE" "Build failed for unclear reason"
            fi
        fi
    else
        log_test_result "Hash Difference Detection" "FAIL" "Same hash for different content (unexpected)"
    fi

    cd "$DEMO_DIR"
}

# ============================================================================
# Test 5: Transitive Dependency Attack
# ============================================================================

test_transitive_dependency_attack() {
    echo ""
    echo "🧪 TEST 5: Transitive Dependency Attack Protection"
    echo "================================================"

    local temp_dir="$TEST_RESULTS_DIR/transitive_test_$TIMESTAMP"
    mkdir -p "$temp_dir"

    # Create a package structure with deep dependencies
    cd "$temp_dir"

    cat > "package.json" << 'EOF'
{
  "name": "transitive-test",
  "version": "1.0.0",
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
EOF

    echo "   📋 Analyzing transitive dependency protection..."

    if npm install --package-lock-only --silent; then
        # Count all dependencies
        TOTAL_DEPS=$(cat package-lock.json | grep '"integrity":' | wc -l | tr -d ' ')
        DIRECT_DEPS=$(cat package.json | jq '.dependencies | length' 2>/dev/null || echo "1")
        TRANSITIVE_DEPS=$((TOTAL_DEPS - DIRECT_DEPS))

        echo "   📊 Dependency analysis:"
        echo "      → Direct dependencies: $DIRECT_DEPS"
        echo "      → Transitive dependencies: $TRANSITIVE_DEPS"
        echo "      → Total with integrity hashes: $TOTAL_DEPS"

        if [ "$TOTAL_DEPS" -gt "$DIRECT_DEPS" ]; then
            log_test_result "Transitive Dependency Detection" "PASS" "Found $TRANSITIVE_DEPS transitive dependencies with integrity hashes"
            echo "   ✅ All transitive dependencies have cryptographic verification"

            # Demonstrate protection by showing how changing any transitive dependency would break the build
            echo "   📋 Simulating transitive dependency compromise..."

            # Extract a transitive dependency
            TRANSITIVE_SAMPLE=$(cat package-lock.json | grep -A 5 '"node_modules/' | grep '"resolved":' | head -1 | sed 's/.*"resolved": *"//' | sed 's/".*//')

            if [ -n "$TRANSITIVE_SAMPLE" ]; then
                echo "   📦 Sample transitive dependency: $(basename "$TRANSITIVE_SAMPLE")"

                # Create Nix expression that would fail if this transitive dependency was compromised
                cat > "transitive_protection_test.nix" << EOF
let
  pkgs = import <nixpkgs> {};
in
pkgs.fetchurl {
  url = "$TRANSITIVE_SAMPLE";
  sha256 = "0000000000000000000000000000000000000000000000000000000000000000";  # Wrong hash simulating compromise
}
EOF

                if timeout 10s nix-build "transitive_protection_test.nix" 2>"transitive_error.log"; then
                    log_test_result "Transitive Dependency Protection" "FAIL" "Compromised transitive dependency was accepted"
                else
                    if grep -q "hash mismatch\|invalid.*hash" "transitive_error.log"; then
                        log_test_result "Transitive Dependency Protection" "PASS" "Compromised transitive dependency correctly rejected"
                        echo "   ✅ Transitive dependency compromise successfully blocked"
                    else
                        log_test_result "Transitive Dependency Protection" "INCONCLUSIVE" "Build failed for unclear reason"
                    fi
                fi
            else
                log_test_result "Transitive Dependency Protection" "INCONCLUSIVE" "Could not extract transitive dependency for testing"
            fi
        else
            log_test_result "Transitive Dependency Detection" "FAIL" "No transitive dependencies found"
        fi
    else
        log_test_result "Transitive Dependency Analysis" "FAIL" "Could not generate package-lock.json"
    fi

    cd "$DEMO_DIR"
}

# ============================================================================
# Main Test Execution
# ============================================================================

main() {
    echo "🚀 Starting automated attack testing sequence..."
    echo ""

    # Run all tests
    test_hash_verification_attack
    test_postinstall_script_isolation
    test_dependency_substitution_attack
    test_registry_tampering_simulation
    test_transitive_dependency_attack

    # Generate summary report
    echo ""
    echo "📊 TEST SUMMARY REPORT"
    echo "======================"
    echo "🕒 Completed at: $(date)"
    echo "📁 Results saved to: $TEST_RESULTS_DIR"
    echo ""
    echo "📈 Test Results:"
    echo "   Total Tests:  $TOTAL_TESTS"
    echo "   Passed:       $PASSED_TESTS"
    echo "   Failed:       $FAILED_TESTS"
    echo "   Success Rate: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"
    echo ""

    # Create summary report file
    cat > "$TEST_RESULTS_DIR/summary_report.txt" << EOF
Nix Supply Chain Protection - Automated Test Report
===================================================
Timestamp: $(date)
Test Suite Version: Phase 2 Implementation

RESULTS SUMMARY:
- Total Tests: $TOTAL_TESTS
- Passed: $PASSED_TESTS
- Failed: $FAILED_TESTS
- Success Rate: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%

PROTECTION EFFECTIVENESS:
$(if [ $PASSED_TESTS -ge 4 ]; then echo "✅ EXCELLENT - Nix provides comprehensive supply chain protection"; else echo "⚠️  NEEDS ATTENTION - Some protection mechanisms may need review"; fi)

DETAILED RESULTS:
$(cat "$TEST_RESULTS_DIR/test_results.log")

For complete test artifacts and logs, see individual test directories.
EOF

    echo "📄 Detailed report saved to: $TEST_RESULTS_DIR/summary_report.txt"

    if [ $FAILED_TESTS -eq 0 ]; then
        echo ""
        echo "🎉 ALL TESTS PASSED! Nix supply chain protection is working correctly."
        return 0
    else
        echo ""
        echo "⚠️  $FAILED_TESTS test(s) failed. Review the detailed logs for more information."
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi