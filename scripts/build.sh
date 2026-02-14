#!/bin/bash
set -e

# --- CONFIGURATION ---
# Path to your forked Pkl (acore) repository
ACORE_REPO_PATH="/Users/yashmakan/AxiomCore/acore"
# CLI Root (where this script is located)
CLI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$CLI_ROOT/dist"

mkdir -p "$DIST_DIR"

# Detect Architecture for Gradle Task
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    ACORE_TASK="assembleNativeMacOsAarch64"
    ACORE_OUTPUT_NAME="acore-macos-aarch64"
    echo "🚀 Detected Apple Silicon ($ARCH)"
else
    ACORE_TASK="assembleNativeMacOsAmd64"
    ACORE_OUTPUT_NAME="acore-macos-amd64"
    echo "🚀 Detected Intel Mac ($ARCH)"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  Starting Build Process"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Build Axiom (Rust)
echo "🦀 Step 1: Building Axiom (Rust)..."
if [ -f "Cargo.toml" ]; then
    cargo build --release
    cp "target/release/axiom" "$DIST_DIR/axiom"
    echo "✅ Axiom built successfully."
else
    echo "❌ Error: Cargo.toml not found. Are you in the axiom project root?"
    exit 1
fi

echo ""

# 2. Build Acore (Java Native Image)
echo "☕ Step 2: Building Acore Native Image (GraalVM)..."
echo "   (Note: This will take a few minutes and use high CPU)"
cd "$ACORE_REPO_PATH"
./gradlew ":pkl-cli:$ACORE_TASK"

# Copy resulting binary to CLI dist folder
if [ -f "pkl-cli/build/executable/$ACORE_OUTPUT_NAME" ]; then
    cp "pkl-cli/build/executable/$ACORE_OUTPUT_NAME" "$DIST_DIR/acore"
    echo "✅ Acore native binary built successfully."
else
    echo "❌ Error: Acore build failed or output not found."
    exit 1
fi

cd "$CLI_ROOT"

# 3. Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Build Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Artifacts located in: $DIST_DIR"
ls -lh "$DIST_DIR"
echo ""
echo "Next step: Run ./scripts/create_release.sh"