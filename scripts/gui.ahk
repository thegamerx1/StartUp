class ExtensionGui {
	init() {
		Menu Tray, NoStandard
		Menu Tray, Click, 1
		Menu Tray, Tip, % script.name
		If !A_IsCompiled {
			Menu Tray, Icon, icons\icon.ico
		}

		this.gui := new EzGui(this, {w: 680
			,h: 320
			,title: script.name
			,caption: false
			,fixsize: true
			,browser: true
			,browserhtml: "web/"
			,handleExit: true})

		this.gui.initHooks()
		DllCall("RegisterShellHookWindow", "UInt", this.gui.controls.gui)
		Debug.attachRedirect := ObjBindMethod(this, "log")

		fn := ObjBindMethod(this.gui, "toggle")
		Menu Tray, Add, Open, % fn

		fn := func("windowspy")
		Menu Tray, Add, Window Spy, % fn
		fn := func("hotkeys")
		Menu Tray, Add, Hotkeys, % fn

		Menu Tray, Default, Open
		Menu Tray, Add
		fn := ObjBindMethod(includer, "restart")
		Menu Tray, Add, Reload, % fn
		fn := ObjBindMethod(this.gui, "exit")
		Menu Tray, Add, Exit, % fn
		Menu Tray, Icon
	}

	log(text, type := "main") {
		this.gui.wnd.log(text, type)
	}

	configSave(str) {
		output := extensions.getExtension(this.lastopentconfig).save(JSON.load(str))
		if output {
			msgbox % output
			return false
		}
		return true
	}

	getHtml(name) {
		this.lastopentconfig := name
		html := extensions.getExtension(name).extension.html
		return (html) ? html : 0
	}

	getConfig(name) {
		if (extensions.getExtension(name).getConfig) {
			data := extensions.getExtension(name).getConfig()
		} else {
			data := extensions.getExtension(name).config.data
		}
		return data ? JSON.dump(data) : "{}"
	}

	getPlaceholder(name) {
		data := JSON.dump(extensions.getExtension(name).config.placeholder)
		return data ? data : "{}"
	}

	AddExtension(enabled, config, name) {
		this.gui.wnd.addExtension(name, extensions.getNameOf(name), enabled, config)
	}

	getReal(name) {
		return extensions.getNameOf(name)
	}

	extensiontoggle(name, enabled) {
		if enabled {
			extensions.LoadExtension(name, true)
		} else {
			extensions.UnloadExtension(name, true)
		}
	}

	close() {
		this.gui.visible := false
		extensions.save()
	}

	save() {
		extensions.save()
	}
}