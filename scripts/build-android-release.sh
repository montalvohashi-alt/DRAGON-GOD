#!/usr/bin/env bash
# ==============================================================================
# Cecilian Alumnet - Dedicated Android Release Build Pipeline
# Generates signed Release APK and signed App Bundle (.aab)
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/flutter_app"
ANDROID_DIR="$FLUTTER_DIR/android"

echo -e "\n${BOLD}${CYAN}====================================================================${NC}"
echo -e "${BOLD}${CYAN}  CECILIAN ALUMNET - ANDROID RELEASE SIGNING & BUILD PIPELINE       ${NC}"
echo -e "${BOLD}${CYAN}====================================================================${NC}\n"

# Step 1: Ensure google-services.json is verified
GSERVICES="$ANDROID_DIR/app/google-services.json"
if [ ! -f "$GSERVICES" ]; then
    echo -e "${RED}❌ Error: google-services.json not found at $GSERVICES${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Verified google-services.json at:${NC} flutter_app/android/app/google-services.json"

# Step 2: Ensure Keystore and key.properties are generated
if [ ! -f "$ANDROID_DIR/cecilian-release-key.jks" ]; then
    echo -e "${YELLOW}Keystore not detected. Generating release keystore...${NC}"
    bash "$ANDROID_DIR/generate-keystore.sh"
else
    echo -e "${GREEN}✓ Release Keystore verified:${NC} flutter_app/android/cecilian-release-key.jks"
fi

if [ -f "$ANDROID_DIR/key.properties" ]; then
    echo -e "${GREEN}✓ Signing configuration loaded from:${NC} flutter_app/android/key.properties"
else
    echo -e "${RED}❌ Error: key.properties could not be created.${NC}"
    exit 1
fi

# Step 3: Run Flutter Clean & Dependencies
cd "$FLUTTER_DIR"
echo -e "\n${CYAN}Resolving dependencies...${NC}"
flutter clean
flutter pub get

# Step 4: Build Signed Release APK
echo -e "\n${CYAN}Building Signed Release APK (flutter build apk --release)...${NC}"
flutter build apk --release

APK_PATH="$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk"

# Step 5: Build Signed App Bundle (.aab)
echo -e "\n${CYAN}Building Signed App Bundle (flutter build appbundle --release)...${NC}"
flutter build appbundle --release

AAB_PATH="$FLUTTER_DIR/build/app/outputs/bundle/release/app-release.aab"

echo -e "\n${BOLD}${GREEN}====================================================================${NC}"
echo -e "${BOLD}${GREEN}  ANDROID RELEASE ARTIFACTS GENERATED SUCCESSFULLY!                 ${NC}"
echo -e "${BOLD}${GREEN}====================================================================${NC}"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    echo -e "1. ${BOLD}Signed Release APK:${NC}  $APK_PATH (${CYAN}$APK_SIZE${NC})"
    echo -e "   -> Direct install on Android phones via USB, email, or download link."
fi

if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(ls -lh "$AAB_PATH" | awk '{print $5}')
    echo -e "2. ${BOLD}Signed App Bundle:${NC}   $AAB_PATH (${CYAN}$AAB_SIZE${NC})"
    echo -e "   -> Upload directly to Google Play Console for store distribution."
fi

echo -e "${BOLD}${GREEN}====================================================================${NC}\n"
