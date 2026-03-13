#!/bin/bash
set -euo pipefail

APP_PATH="/Applications/Vim in Ghostty.app"
BUNDLE_ID="com.williamwmarx.viminghostty"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

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

if [ ! -d "${APP_PATH}" ]; then
	echo "Nothing to remove — ${APP_PATH} not found."
	exit 0
fi

# Reset file associations to TextEdit before removing the app
if command -v duti &>/dev/null; then
	echo "==> Resetting file associations..."
	for uti in "${UTIS[@]}"; do
		duti -s com.apple.TextEdit "${uti}" all 2>/dev/null || true
	done
fi

# Unregister from LaunchServices
echo "==> Unregistering from LaunchServices..."
"${LSREGISTER}" -u "${APP_PATH}" 2>/dev/null || true

echo "==> Removing app..."
rm -rf "${APP_PATH}"

echo "Done. File associations reset to TextEdit."
