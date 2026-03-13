#!/bin/bash
set -euo pipefail

APP_NAME="Vim in Ghostty"
APP_PATH="/Applications/${APP_NAME}.app"
BUNDLE_ID="com.williamwmarx.viminghostty"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPLESCRIPT="${SCRIPT_DIR}/VimInGhostty.applescript"

# UTIs to register as default handler
UTIS=(
	public.text
	public.plain-text
	public.source-code
	public.script
	public.shell-script
	public.json
	public.xml
	public.yaml
	net.daringfireball.markdown
)

echo "==> Checking prerequisites..."

if [ ! -d "/Applications/Ghostty.app" ]; then
	echo "ERROR: Ghostty.app not found in /Applications. Install from https://ghostty.org" >&2
	exit 1
fi

if ! command -v duti &>/dev/null; then
	echo "duti not found. Installing via Homebrew..."
	brew install duti
fi

echo "==> Compiling AppleScript..."
osacompile -o "${APP_PATH}" "${APPLESCRIPT}"

echo "==> Patching Info.plist..."
PLIST="${APP_PATH}/Contents/Info.plist"

plutil -replace CFBundleIdentifier -string "${BUNDLE_ID}" "${PLIST}"

# Hide from Dock — this is a background file handler, not a user-facing app
plutil -insert LSUIElement -bool true "${PLIST}" 2>/dev/null \
	|| plutil -replace LSUIElement -bool true "${PLIST}"

# Automation consent description
plutil -insert NSAppleEventsUsageDescription \
	-string "Vim in Ghostty needs to control Ghostty to open files in Vim." \
	"${PLIST}" 2>/dev/null \
	|| plutil -replace NSAppleEventsUsageDescription \
		-string "Vim in Ghostty needs to control Ghostty to open files in Vim." \
		"${PLIST}"

# Build UTI JSON array
UTI_JSON="["
for i in "${!UTIS[@]}"; do
	if [ "$i" -gt 0 ]; then UTI_JSON+=","; fi
	UTI_JSON+="\"${UTIS[$i]}\""
done
UTI_JSON+="]"

# Register document types
plutil -remove CFBundleDocumentTypes "${PLIST}" 2>/dev/null || true
plutil -insert CFBundleDocumentTypes -json "[{
	\"CFBundleTypeName\": \"Text File\",
	\"CFBundleTypeRole\": \"Editor\",
	\"LSHandlerRank\": \"Default\",
	\"LSItemContentTypes\": ${UTI_JSON}
}]" "${PLIST}"

echo "==> Signing app bundle..."
codesign --force --sign - "${APP_PATH}"

echo "==> Refreshing LaunchServices..."
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f "${APP_PATH}"

echo "==> Setting file associations..."
for uti in "${UTIS[@]}"; do
	duti -s "${BUNDLE_ID}" "${uti}" all 2>/dev/null && echo "   ${uti}" || echo "   ${uti} (skipped)"
done

echo ""
echo "Done! '${APP_NAME}' installed to ${APP_PATH}"
echo ""
echo "On first use, macOS will ask to allow '${APP_NAME}' to control Ghostty."
echo "Click 'OK' — this only happens once."
