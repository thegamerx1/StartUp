
class extension_minekra extends extension_ {
	static extension := {}
	,extension.name := "Minekra"

	Start() {
		this.chatopen := false
		this.addhotkey("*f", "fkey", "check")
		this.addhotkey("*g", "gkey", "check")
		this.addhotkey("esc", "checkesc", "checkesc")
		this.addhotkey("enter", "checkenter", "checkenter")
	}

	check() {
		return WinActive("ahk_class GLFW30") && !this.chatopen
	}

	checkesc() {
		if WinActive("ahk_class GLFW30") {
			this.chatopen := false
		}
	}

	checkenter() {
		if WinActive("ahk_class GLFW30") {
			this.chatopen := !this.chatopen
		}
	}

	fkey() {
		send {LButton down}
		KeyWait f
		send {LButton up}
	}

	gkey() {
		send {RButton down}
		KeyWait g
		send {RButton up}
	}
}