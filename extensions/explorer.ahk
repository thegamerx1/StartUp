class extension_explorer extends extension_ {
    static extension := {}
    ,extension.name := "Explorer"

    Start() {
        ; this.explorer := "ahk_class CabinetWClass"
        this.explorer := "ahk_exe onecommander.exe"

        this.addhotkey("^Backspace", "backspacefix", "check")
        this.addhotkey("#e", "open")

        this.addhotkey("#f", "terminal")
        this.addhotkey("#w", "windowclose")
        this.addhotkey("#n", "minimizewindow")
        this.addhotkey("#m", "maximizewindow")

        EnvGet UserProfile, UserProfile
        this.userprofile := UserProfile
    }

    windowclose() {
        WinClose A
    }

    closewindow() {
        WinMinimize A
    }

    maximizewindow() {
        WinMaximize A
    }

    check() {
        return WinActive(this.explorer)
    }


    terminal() {
        if (!WinExist("ahk_id" this.terminalid)) {
            this.terminalid := this.runterminal()
        } else if (WinActive("ahk_id" this.terminalid)) {
            WinHide % "ahk_id" this.terminalid
            MouseGetPos,,, WinUMID
            WinActivate, ahk_id %WinUMID%
            ; SendMessage 0x112, 0xF020,,, % this.terminalid
        } else {
            WinShow % "ahk_id" this.terminalid
            WinWait % "ahk_id" this.terminalid
            WinActivate % "ahk_id" this.terminalid
        }
        KeyWait #
        KeyWait t
    }

    runterminal() {
        local directory := GetActiveExplorerPath()
        WinGet currentid, ID, A
        run C:/users/%A_UserName%/scoop/apps/windows-terminal/current/WindowsTerminal.exe
        loop {
            WinWait ahk_exe WindowsTerminal.exe
            nowid := WinExist("A")
            this.log(nowid)
            if (nowid != currentid) {
                return nowid
            }
        }
    }


    open() {
        local old := A_DetectHiddenWindows
        DetectHiddenWindows Off
        if (!WinExist(this.explorer)) {
            run C:/users/%A_UserName%/scoop/apps/onecommander/current/OneCommander.exe,, hide
        } else if (WinActive(this.explorer)) {
            ; SendMessage 0x112, 0xF020,,, % this.explorer
            WinClose A
        } else {
            WinActivate % this.explorer
        }
        DetectHiddenWindows % old
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
