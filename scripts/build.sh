#!/bin/bash
set -e

# --- CONFIGURATION ---
# Path to your forked Pkl (acore) repository
ACORE_REPO_PATH="/Users/yashmakan/AxiomCore/acore"
# Path to your Rust CLI repository
AXIOM_RUST_PATH="/Users/yashmakan/AxiomCore/axiom-cli"

# Orchestration Root (AxiomCore/cli)
CLI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
echo "🦀 Step 1: Building Axiom (Rust) in $AXIOM_RUST_PATH..."
cd "$AXIOM_RUST_PATH"
if [ -f "Cargo.toml" ]; then
    cargo build --release
    # Copy the binary back to our orchestration dist folder
    cp "target/release/axiom-cli" "$DIST_DIR/axiom"
    echo "✅ Axiom built successfully."
else
    echo "❌ Error: Cargo.toml not found at $AXIOM_RUST_PATH"
    exit 1
fi

echo ""

# 2. Build Acore (Java Native Image)
echo "☕ Step 2: Building Acore Native Image in $ACORE_REPO_PATH..."
cd "$ACORE_REPO_PATH"
./gradlew ":pkl-cli:$ACORE_TASK"

# Copy resulting binary to orchestration dist folder
if [ -f "pkl-cli/build/executable/$ACORE_OUTPUT_NAME" ]; then
    cp "pkl-cli/build/executable/$ACORE_OUTPUT_NAME" "$DIST_DIR/acore"
    echo "✅ Acore native binary built successfully."
else
    echo "❌ Error: Acore build failed. Checked: pkl-cli/build/executable/$ACORE_OUTPUT_NAME"
    exit 1
fi

cd "$CLI_ROOT"

# 3. Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Build Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Artifacts gathered in: $DIST_DIR"
ls -lh "$DIST_DIR"