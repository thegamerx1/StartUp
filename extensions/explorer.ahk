class extension_explorer extends extension_ {
	static extension := {}
	,extension.name := "Explorer"

	Start() {
		; this.explorer := "ahk_class CabinetWClass"
		this.explorer := "ahk_exe OneCommander.exe"
		this.addhotkey("^Backspace", "backspacefix", "check")
		this.addhotkey("#e", "open")
		this.id := 0
		this.nonoktitlelist := ["MediaContextNotificationWindow", "One Commander Window Manager", "SystemResourceNotifyWindow"]
		this.generateList()
	}

	check() {
		return WinActive(this.explorer)
	}

	generateList() {
		WinGet id, List, % this.explorer
		Loop, %id%
		{
			this_id := id%A_Index%
			WinGetClass class, ahk_id %this_id%
			WinGetTitle title, ahk_id %this_id%
			if (InStr(class, "HwndWrapper") && title != "") {
				ok := true
				for index, value in this.nonoktitlelist {
					if (title == value) {
						ok := false
					}
				}
				if (ok) {
					this.id := this_id
				}
			}
		}
	}

	open() {
		if (!WinExist("ahk_id " this.id)) {
			if (!WinExist(this.explorer)) {
				run H:\Programs\OneCommander\OneCommander.exe,,, PID
				sleep 2000
			}
			this.generateList()
		} else if (WinActive(this.explorer)) {
			SendMessage 0x112, 0xF020,,, % "ahk_id " this.id ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE

		} else {
			WinActivate % "ahk_id " this.id
		}
		KeyWait #
		KeyWait e
	}

	backspacefix() {
		Send ^+{Left}{Backspace}
	}
}