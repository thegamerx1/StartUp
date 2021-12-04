class extension_autoclick extends extension_ {
	static extension := {}
	,extension.name := "Autoclick"

	Start() {
		this.explorer := "ahk_class CabinetWClass"
		this.addhotkey("F3", "autoclick")
		this.toggle := false
	}

	autoclick() {
		if (this.toggle := !this.toggle) {
			this.timer := new timer(objbindmethod(this, "click"), 100)
		} else {
			this.timer.delete()
		}
	}

	click() {
		click, down
		sleep 50
		click, up
	}

}