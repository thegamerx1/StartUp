class extension_discordkey extends extension_ {
	static extension := {}
	,extension.name := "Discord ^R"

	Start() {
		this.addhotkey("^r", "STOPIT", "check")
		this.addhotkey("^+r", "refresh", "check")
	}

	check() {
		return WinActive("ahk_exe Discord.exe")
	}

	refresh() {
		Send ^r
	}

	STOPIT() {
		this.log("YOU PRESSED CTRL+R DUMBFUCK")
	}
}