# Vim in Ghostty

Double-click text files in macOS Finder to open them in Vim inside [Ghostty](https://ghostty.org).

## Requirements

- macOS
- [Ghostty](https://ghostty.org) 1.3+ (AppleScript support)
- Vim

## Install

```bash
git clone https://github.com/williamwmarx/vim-in-ghostty.git
cd vim-in-ghostty
bash install.sh
```

The install script:
1. Compiles the AppleScript into `/Applications/Vim in Ghostty.app`
2. Registers the app as a handler for text file types (plain text, source code, Markdown, JSON, XML, YAML)
3. Sets file associations via [duti](https://github.com/moretension/duti) (installed automatically if missing)

On first use, macOS will ask to allow "Vim in Ghostty" to control Ghostty. Click OK — this only happens once.

## Uninstall

```bash
bash uninstall.sh
```

## How it works

macOS file associations only map to apps, not terminal commands. This wrapper app receives files via Finder's "Open With" mechanism, then uses Ghostty's AppleScript API to open a terminal window and launch Vim with the file. When you `:q`, the terminal closes.
