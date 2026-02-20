#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS and Architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    case "$OS" in
        Darwin)
            OS="macos"
            ;;
        Linux)
            OS="linux"
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
    
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    PLATFORM="${OS}-${ARCH}"
}

# Get the latest release version
get_latest_version() {
    # LATEST_VERSION=$(curl -s https://api.github.com/repos/AxiomCore/cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # if [ -z "$LATEST_VERSION" ]; then
    #     echo -e "${RED}Failed to fetch latest version${NC}"
    #     exit 1
    # fi
    
    # Remove 'v' prefix if present
    VERSION="0.0.65"
}

# Download and install binary
install_binary() {
    local BINARY_NAME=$1
    local DOWNLOAD_URL="https://github.com/AxiomCore/cli/releases/download/${LATEST_VERSION}/${BINARY_NAME}-${PLATFORM}.tar.gz"
    
    echo -e "${YELLOW}Downloading ${BINARY_NAME} ${VERSION} for ${PLATFORM}...${NC}"
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if ! curl -fsSL "$DOWNLOAD_URL" -o "${BINARY_NAME}.tar.gz"; then
        echo -e "${RED}Failed to download ${BINARY_NAME}${NC}"
        echo -e "${RED}URL: ${DOWNLOAD_URL}${NC}"
        exit 1
    fi
    
    tar -xzf "${BINARY_NAME}.tar.gz"
    
    # Ensure executable permissions
    chmod +x "${BINARY_NAME}"
    
    # Install to /usr/local/bin
    if [ -w /usr/local/bin ]; then
        mv "${BINARY_NAME}" /usr/local/bin/
    else
        echo -e "${YELLOW}Installing ${BINARY_NAME} requires sudo permissions...${NC}"
        sudo mv "${BINARY_NAME}" /usr/local/bin/
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}✓ ${BINARY_NAME} installed successfully${NC}"
}

# Main installation
main() {
    echo -e "${GREEN}Installing Axiom CLI...${NC}"
    echo ""
    
    detect_platform
    get_latest_version
    
    echo "Platform: $PLATFORM"
    echo "Version: $VERSION"
    echo ""
    
    # Install acore first (dependency)
    install_binary "acore"
    
    # Install axiom
    install_binary "axiom"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Run 'axiom --help' to get started"
    echo ""
}

main
