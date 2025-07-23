#!/bin/bash

# Build script for Simple ngrok Mac app
# This script creates a standalone Mac application from the source script

set -e

# Configuration
APP_NAME="Simple ngrok"
SCRIPT_NAME="simple-ngrok.sh"
OUTPUT_DIR="build"

echo "🔨 Building Simple ngrok Mac App"
echo "================================"
echo ""

# Check if source script exists
if [ ! -f "src/$SCRIPT_NAME" ]; then
    echo "❌ Error: Source script 'src/$SCRIPT_NAME' not found"
    exit 1
fi

# Create build directory
mkdir -p "$OUTPUT_DIR"

# Remove existing app if it exists
rm -rf "$OUTPUT_DIR/$APP_NAME.app"

echo "📦 Creating Mac app bundle..."

# Create the AppleScript that will launch our script
osacompile -o "$OUTPUT_DIR/$APP_NAME.app" -e '
tell application "Terminal"
    activate
    set script_path to (path to me as string)
    set posix_path to POSIX path of script_path
    set script_dir to (do shell script "dirname " & quoted form of posix_path)
    set full_script_path to script_dir & "/simple-ngrok.sh"
    do script "clear && echo \"🚀 Simple ngrok\" && echo \"===============\" && echo \"\" && " & quoted form of full_script_path & " && echo \"\" && echo \"✅ You can close this Terminal window when done.\""
end tell'

# Copy the script to the app bundle Resources folder
echo "📋 Copying script to app bundle..."
cp "src/$SCRIPT_NAME" "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources/"
chmod +x "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources/$SCRIPT_NAME"

echo ""
echo "✅ Build complete!"
echo "📱 App created: $OUTPUT_DIR/$APP_NAME.app"
echo ""
echo "💡 To test: Double-click the app in Finder"
echo "📦 To distribute: Zip the .app file and share"
echo ""
