class extension_uselesskeys extends extension_ {
	static extension := {}
	,extension.name := "Useless Keys"

	Start() {
		this.addhotkey("+Insert", "hotkey",, "prev")
		this.addhotkey("+Home", "hotkey",, "paus")
		this.addhotkey("#s", "hotkey",, "keypirinha")
		this.addhotkey("+PgUp", "hotkey",, "next")
	}

	hotkey(name) {
		Switch name {
			case "prev":
				send {Media_Prev}

			case "paus":
				send {Media_Play_Pause}

			case "next":
				send {Media_Next}

			case "keypirinha":
				action := winactive("ahk_class keypirinha_wndcls_run") ? "hide" : "show"
				run H:\Programs\Keypirinha\keypirinha.exe --%action%
		}
	}
}