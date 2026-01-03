class extension_uselesskeys extends extension_ {
	static extension := {}
	,extension.name := "Useless Keys"

	Start() {
		this.addhotkey("+PgDown", "hotkey",, "prev")
		this.addhotkey("+Home", "hotkey",, "paus")
		this.addhotkey("+PgUp", "hotkey",, "next")
		this.addhotkey("^!WheelUp", "vol",, 1)
		this.addhotkey("^!WheelDown", "vol",, 0)
	}

	vol(isup) {
		if isup {
			SoundSet +5
		} else {
			SoundSet -5
		}
	}


	hotkey(name) {
		Switch name {
			case "prev":
				send {Media_Prev}

			case "paus":
				send {Media_Play_Pause}

			case "next":
				send {Media_Next}
		}
	}
}