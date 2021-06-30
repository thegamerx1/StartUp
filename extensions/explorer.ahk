class extension_explorer extends extension_ {
	static extension := {}
	,extension.name := "Explorer"

	Start() {
		this.explorer := "ahk_class CabinetWClass"
		this.addhotkey("^Backspace", "backspacefix", "check")
		this.addhotkey("#e", "open")
	}

	check() {
		return WinActive(this.explorer)
	}

	open() {
		if (!WinExist(this.explorer)) {
			run explorer.exe F:\
		} else if (WinActive(this.explorer)) {
			SendMessage 0x112, 0xF020,,, % this.explorer ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE
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