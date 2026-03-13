-- Vim in Ghostty
-- Double-click text files in Finder to open them in Vim inside Ghostty.
-- Requires Ghostty 1.3+ (AppleScript support).

on run
	-- Launched directly (e.g. from Spotlight) — open Vim in a new Ghostty window
	try
		tell application id "com.mitchellh.ghostty"
			activate
			set cfg to new surface configuration
			set win to new window with configuration cfg
			set t to focused terminal of selected tab of win
			input text "clear && vim --cmd 'set title titlestring=Vim\\ in\\ Ghostty'; exit" to t
			send key "enter" to t
		end tell
	on error errMsg number errNum
		my showError(errMsg, errNum)
	end try
end run

on open droppedItems
	-- Collect valid file paths
	set filePaths to {}
	repeat with anItem in droppedItems
		set p to POSIX path of anItem
		try
			do shell script "/bin/test -f " & my shquote(p)
			set end of filePaths to p
		end try
	end repeat
	if (count of filePaths) is 0 then return

	try
		-- Build the vim command with all file paths
		set vimArgs to ""
		repeat with p in filePaths
			set vimArgs to vimArgs & " " & my shquote(contents of p)
		end repeat

		set firstDir to do shell script "/usr/bin/dirname " & my shquote(item 1 of filePaths)

		tell application id "com.mitchellh.ghostty"
			activate
			set cfg to new surface configuration
			set initial working directory of cfg to firstDir
			set win to new window with configuration cfg
			set t to focused terminal of selected tab of win
			input text ("clear && vim --cmd 'set title titlestring=Vim\\ in\\ Ghostty\\ [%F]' --" & vimArgs & "; exit") to t
			send key "enter" to t
		end tell
	on error errMsg number errNum
		my showError(errMsg, errNum)
	end try
end open

on showError(errMsg, errNum)
	display dialog ("Could not open file in Ghostty." & return & return & "Make sure Ghostty 1.3+ is installed and macos-applescript is not set to false in your Ghostty config." & return & return & "Error " & errNum & ": " & errMsg) buttons {"OK"} default button "OK"
end showError

-- Shell-safe quoting that handles single quotes in file paths
on shquote(s)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "'"
	set parts to every text item of (s as text)
	set AppleScript's text item delimiters to "'\"'\"'"
	set quoted to parts as text
	set AppleScript's text item delimiters to oldTID
	return "'" & quoted & "'"
end shquote
