#!/usr/bin/env bash
# ==============================================================================
# Generate Android Release Keystore for Cecilian Alumnet
# Non-interactive command using standard Java keytool
# ==============================================================================

set -e

KEYSTORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORE_FILE="$KEYSTORE_DIR/cecilian-release-key.jks"
KEY_PROPERTIES="$KEYSTORE_DIR/key.properties"

ALIAS="cecilian_release_key"
PASSWORD="cecilian_alumnet_secret2026"

echo "=== Cecilian Alumnet Android Keystore Generator ==="

if [ -f "$KEYSTORE_FILE" ]; then
    echo "✓ Keystore already exists at: $KEYSTORE_FILE"
else
    if ! command -v keytool &> /dev/null; then
        echo "⚠️ Note: 'keytool' is not installed in this environment."
        echo "Run this command on your machine with JDK installed:"
        echo ""
        echo "keytool -genkeypair -v -keystore $KEYSTORE_FILE -keyalg RSA -keysize 2048 -validity 10000 -alias $ALIAS -dname \"CN=St. Cecilia's College, OU=Alumni Network, O=St. Cecilia's College - Cebu Inc., L=Minglanilla, ST=Cebu, C=PH\" -storepass $PASSWORD -keypass $PASSWORD"
        echo ""
    else
        echo "Generating release keystore at: $KEYSTORE_FILE..."
        keytool -genkeypair -v \
            -keystore "$KEYSTORE_FILE" \
            -keyalg RSA \
            -keysize 2048 \
            -validity 10000 \
            -alias "$ALIAS" \
            -dname "CN=St. Cecilia's College, OU=Alumni Network, O=St. Cecilia's College - Cebu Inc., L=Minglanilla, ST=Cebu, C=PH" \
            -storepass "$PASSWORD" \
            -keypass "$PASSWORD"
        echo "✓ Keystore generated successfully!"
    fi
fi

# Ensure key.properties is written
cat <<EOF > "$KEY_PROPERTIES"
storePassword=$PASSWORD
keyPassword=$PASSWORD
keyAlias=$ALIAS
storeFile=cecilian-release-key.jks
EOF

echo "✓ key.properties configured at: $KEY_PROPERTIES"
