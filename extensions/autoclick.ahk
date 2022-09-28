class extension_autoclick extends extension_ {
	static extension := {}
	,extension.name := "Autoclick"

	Start() {
		this.addhotkey("F3", "autoclick")
	}

	autoclick() {
		if (this.timer) {
			this.timer.delete()
		} else {
			this.timer := new timer(objbindmethod(this, "click"), 100)
		}
	}

	click() {
		click, down
		sleep 50
		click, up
	}

}