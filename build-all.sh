#!/usr/bin/env bash
# ==============================================================================
# St. Cecilia's College Global Alumni Association - Unified Build Pipeline
# Builds Flutter Web Portal and Android App Bundle, syncing Firebase artifacts.
# ==============================================================================

set -e # Exit immediately on error

# Terminal Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Determine Directory Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
FLUTTER_DIR="$ROOT_DIR/flutter_app"
FIREBASE_CONFIG="$ROOT_DIR/firebase-applet-config.json"
FIREBASE_JSON="$ROOT_DIR/firebase.json"

# Resolve Firebase Public Hosting Folder from firebase.json (Default: dist)
FIREBASE_PUBLIC_DIR="$ROOT_DIR/dist"
if [ -f "$FIREBASE_JSON" ]; then
    PARSED_PUBLIC=$(grep -o '"public": *"[^"]*"' "$FIREBASE_JSON" | head -n 1 | cut -d'"' -f4)
    if [ -n "$PARSED_PUBLIC" ]; then
        FIREBASE_PUBLIC_DIR="$ROOT_DIR/$PARSED_PUBLIC"
    fi
fi

echo -e "\n${BOLD}${CYAN}====================================================================${NC}"
echo -e "${BOLD}${CYAN}  ST. CECILIA'S COLLEGE ALUMNI APP - UNIFIED BUILD PIPELINE         ${NC}"
echo -e "${BOLD}${CYAN}====================================================================${NC}"
echo -e "Project Root:      ${ROOT_DIR}"
echo -e "Flutter Workspace: ${FLUTTER_DIR}"
echo -e "Firebase Public:   ${FIREBASE_PUBLIC_DIR}\n"

# ------------------------------------------------------------------------------
# 1. Environment & Dependency Validation
# ------------------------------------------------------------------------------
echo -e "${CYAN}[1/5] Checking Build Environment...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Error: 'flutter' command not found in PATH.${NC}"
    echo -e "Please ensure Flutter SDK is installed and added to your environment variables."
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✓ Detected Flutter SDK:${NC} $FLUTTER_VERSION"

# Ensure Flutter project directory exists
if [ ! -d "$FLUTTER_DIR" ]; then
    echo -e "${RED}❌ Error: Flutter directory '$FLUTTER_DIR' does not exist.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Firebase Configuration Synchronization
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[2/5] Validating Firebase Configuration...${NC}"
if [ -f "$FIREBASE_CONFIG" ]; then
    PROJECT_ID=$(grep -o '"projectId": *"[^"]*"' "$FIREBASE_CONFIG" | cut -d'"' -f4)
    DB_ID=$(grep -o '"firestoreDatabaseId": *"[^"]*"' "$FIREBASE_CONFIG" | cut -d'"' -f4)
    echo -e "${GREEN}✓ Firebase Project ID:${NC} $PROJECT_ID"
    echo -e "${GREEN}✓ Firestore DB ID:${NC}    $DB_ID"

    # Sync into Android google-services.json if present
    ANDROID_GSERVICES="$FLUTTER_DIR/android/app/google-services.json"
    if [ -f "$ANDROID_GSERVICES" ]; then
        echo -e "${GREEN}✓ Google Services JSON confirmed at:${NC} android/app/google-services.json"
    fi
else
    echo -e "${YELLOW}⚠️ Notice: firebase-applet-config.json not found in root. Using default configs.${NC}"
fi

# ------------------------------------------------------------------------------
# 3. Flutter Dependencies & Preparation
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[3/5] Resolving Flutter Dependencies...${NC}"
cd "$FLUTTER_DIR"
flutter pub get

# ------------------------------------------------------------------------------
# 4. Build Web Portal & Copy into Firebase Public Directory
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[4/5] Building Flutter Web Portal (--release)...${NC}"
flutter build web --release

# Ensure Firebase public directory exists
mkdir -p "$FIREBASE_PUBLIC_DIR"

WEB_BUILD_DIR="$FLUTTER_DIR/build/web"
if [ -d "$WEB_BUILD_DIR" ]; then
    echo -e "${CYAN}Syncing Web artifacts into Firebase public folder: ${FIREBASE_PUBLIC_DIR}...${NC}"
    
    # Copy build artifacts to the root of the Firebase public folder
    cp -R "$WEB_BUILD_DIR"/* "$FIREBASE_PUBLIC_DIR"/

    # Also maintain a dedicated /flutter subpath for multi-route setups
    mkdir -p "$FIREBASE_PUBLIC_DIR/flutter"
    cp -R "$WEB_BUILD_DIR"/* "$FIREBASE_PUBLIC_DIR/flutter"/

    echo -e "${GREEN}✓ Web portal build successfully deployed to Firebase public directory.${NC}"
else
    echo -e "${RED}❌ Error: Web build directory not found at '$WEB_BUILD_DIR'.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 5. Build Android Release App Bundle (.aab)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[5/5] Building Android App Bundle (flutter build appbundle)...${NC}"

# Check for release signing key configuration
KEY_PROPERTIES="$FLUTTER_DIR/android/key.properties"
if [ -f "$KEY_PROPERTIES" ]; then
    echo -e "${GREEN}✓ Signing configuration detected in android/key.properties${NC}"
else
    echo -e "${YELLOW}ℹ️ Notice: android/key.properties not found. Building with default/debug signing.${NC}"
    echo -e "   For production Play Store release, configure key.properties with your keystore."
fi

flutter build appbundle --release

AAB_OUTPUT="$FLUTTER_DIR/build/app/outputs/bundle/release/app-release.aab"

# ------------------------------------------------------------------------------
# Build Summary & Deployment Next Steps
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}${GREEN}====================================================================${NC}"
echo -e "${BOLD}${GREEN}  BUILD COMPLETED SUCCESSFULLY!                                      ${NC}"
echo -e "${BOLD}${GREEN}====================================================================${NC}"

echo -e "\n${BOLD}Generated Artifacts:${NC}"
echo -e "1. ${CYAN}Web Portal (Firebase Public):${NC} $FIREBASE_PUBLIC_DIR"
echo -e "   - Entry File: $FIREBASE_PUBLIC_DIR/index.html"
echo -e "   - Manifest:   $FIREBASE_PUBLIC_DIR/manifest.json"

if [ -f "$AAB_OUTPUT" ]; then
    AAB_SIZE=$(ls -lh "$AAB_OUTPUT" | awk '{print $5}')
    echo -e "2. ${CYAN}Android App Bundle (.aab):${NC}    $AAB_OUTPUT ($AAB_SIZE)"
else
    echo -e "2. ${CYAN}Android App Bundle (.aab):${NC}    $FLUTTER_DIR/build/app/outputs/bundle/release/"
fi

echo -e "\n${BOLD}Deployment Commands:${NC}"
echo -e "• Deploy Web to Firebase Hosting:"
echo -e "  ${YELLOW}firebase deploy --only hosting${NC}"
echo -e "• Publish Android App Bundle to Google Play Store:"
echo -e "  Upload ${YELLOW}$AAB_OUTPUT${NC} to Google Play Console (Production / Internal Testing)."
echo -e "${BOLD}${GREEN}====================================================================${NC}\n"
