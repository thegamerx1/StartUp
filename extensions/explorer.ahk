class extension_explorer extends extension_ {
    static extension := {}
    ,extension.name := "Explorer"

    Start() {
        this.explorer := "ahk_class CabinetWClass"
        this.alacritty := "ahk_exe wezterm-gui.exe"

        this.addhotkey("^Backspace", "backspacefix", "check")
        this.addhotkey("#e", "open")

        this.addhotkey("!#c", "terminal")
        this.addhotkey("#c", "terminalI")

        EnvGet UserProfile, UserProfile
        this.userprofile := UserProfile
    }

    check() {
        return WinActive(this.explorer)
    }

    runalacritty() {
        local directory := GetActiveExplorerPath()
        run wezterm.exe, % directory ? directory : this.userprofilem, Hide
        ; sleep 100
        ; WinWait ahk_pid %pid% ahk_class Window Class
        ; WinActivate ahk_pid %pid% ahk_class Window Class
    }

    terminalI() {
        this.runalacritty()
        KeyWait #
        KeyWait c
    }

    terminal() {
        if (!WinExist(this.alacritty)) {
            this.runalacritty()
        } else if (WinActive(this.alacritty)) {
            SendMessage 0x112, 0xF020,,, % this.alacritty
        } else {
            WinActivate % this.alacritty
        }
        KeyWait #
        KeyWait c
    }


    open() {
        if (!WinExist(this.explorer)) {
            run explorer.exe
        } else if (WinActive(this.explorer)) {
            SendMessage 0x112, 0xF020,,, % this.explorer
        } else {
            WinActivate % this.explorer
        }
        KeyWait #
        KeyWait e
    }

    backspacefix() {
        Send ^+{Left}{Backspace}
    }
}

; https://www.autohotkey.com/boards/viewtopic.php?t=69925
GetActiveExplorerPath() {
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd) {
		for window in ComObjCreate("Shell.Application").Windows {
			if (window.hwnd == explorerHwnd) {
				return window.Document.Folder.Self.Path
			}
		}
	}
}
