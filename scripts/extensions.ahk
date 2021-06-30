class extension_ {
	__New(ByRef config) {
		this.name := SubStr(this.base.__Class, StrLen("extension_")+1)
		if this.extension.gui {
			FileRead html, % "extensions\" this.name ".html"
			if html {
				this.extension.html := html
			} else {
				this.extension.gui := false
			}
		}
		this.config := config
		this.Start()
		this.extension.loaded := true
	}

	log(text) {
		s := script.starttime.get() / 1000
		stamp := Format("[{:02d}:{:02d}:{:02d}] ", s/3600 ,Mod(s/60,60), Mod(s,60))
		ExtensionGui.log(stamp text "`n", this.name)
		debug.print(">" text, {label: this.name})
	}
	reload() {
		extensions.queueReload(this.name)
	}

	callAfter(funcname, time) {
		f := ObjBindMethod(this, funcname)
		SetTimer %f%, -%time%
	}

	delete() {
		extensionHotkeys.clean(this.base.__Class)
		this.afterdelete()
	}

	addHotkey(hotkey, funcname, checkfunc := "", params := "") {
		extensionHotkeys.addhotkey(hotkey, funcname, checkfunc, params, this)
	}

	__Delete() {
		this.log("Disabled")
		extensions.DeleteManager(this.name)
	}
}

class extensionHotkeys {
	init() {
		this.keylist := {}
	}

	addhotkey(hotkey, funcname, checkfunc := "", params := "", extension := "") {
		extname := extension.base.__Class


		; TODO: FIX IT BRO WTF IS THIS
		if !IsObject(this.keylist[hotkey])
			this.keylist[hotkey] := {}
		if !IsObject(this.keylist[hotkey][extname])
			this.keylist[hotkey][extname] := {}
		if !IsObject(this.keylist[hotkey][extname][funcname])
			this.keylist[hotkey][extname][funcname] := {}
		; END FIX

		key := {func: ObjBindMethod(extension, funcname, params)}

		if checkfunc
			key.check := ObjBindMethod(extension, checkfunc, params)

		this.keylist[hotkey][extname][funcname] := key

		func := ObjBindMethod(this, "cally")
		this._createif(hotkey)
		hotkey % hotkey, % func, On
		hotkey if
	}

	_createif(hotkey) {
		fn := ObjBindMethod(this, "checky", hotkey)
		if (fn)
			hotkey if, % fn
	}

	cally() {
		for _, value in this.callys {
			value.call()
		}
	}

	checky(hotkey) {
		atleastone := false
		this.callys := []
		for _, value in this.keylist[hotkey] {
			for _, value in value {
				if (!IsObject(value.check) || value.check.call()) {
					this.callys.push(value.func)
					atleastone := true
				}
			}
		}
		return atleastone
	}

	clean(extension) {
		for hotkey, value in this.keylist {
			for extname, value in value {
				if (extname != extension)
					continue
				for funcname, key in value {
					f := func("DummyFunc")
					this.keylist[hotkey].delete(extname)
				}
			}
			if (this.keylist[hotkey].Count() = 0) {
				this._createif(hotkey)
				func := ObjBindMethod(this, "cally")
				Hotkey % hotkey, % func, off
				hotkey if
			}
		}
	}
}

class extensions {
/*
	=============================================
	=                 Check Hash                =
	=============================================
*/

	init() {
		this.log := debug.space("Extensions")
		this.loadtime := new Counter(, true)
		this.data := {}
		this.data.extensions := new configloader("data\extensions.json")
		this.data.config := new configloader("data\extensiondata.json")
		this.translate := {}
		this.data.tempextension := []

		extensionHotkeys.init()

		for k in this.data.extensions.data {
			if !FileExist("extensions\" k ".ahk") {
				this.data.extensions.data.delete(k)
			}
		}
		for _, ext in includer.list {
			name := ext.name
			error := this.LoadExtension(name)
			this.translate[name] := Extension_%name%.extension.name
			if !error
				ExtensionGui.AddExtension(this.data.extensions.data[name], Extension_%name%.extension.gui, name)
		}

		this.loadtime := this.loadtime.get()

		this.loadedExtensions := 0
		For key, value in this.data.extensions.data
			if (value)
				this.loadedExtensions++

		OnExit(ObjBindMethod(this, "Save"), -1)
	}

	getNameOf(name, reverse := false) {
		if (reverse) {
			for key, value in this.translate {
				if (value = name)
					return key
			}
		} else {
			return this.translate[name]
		}
	}

	UnloadExtension(name, actionit := false) {
		if actionit
			this.data.extensions.data[name] := false

		this.deleted := ""

		if (this.data.tempextension[name].extension.loaded) {
			this.data.tempextension[name].delete()
			this.data.tempextension[name] := ""
		} else {
			this.log(name "isnt loaded", "ERROR")
		}

		TimeOnce(ObjBindMethod(this, "DeleteChecker", name), 0)
	}

	LoadExtension(name, actionit := false) {
		extensiontimer := new Counter(, true)

		if actionit
			this.data.extensions.data[name] := true

		if !IsObject(extension_%name%) {
			this.log("NameError: nonmatching class """ name """", ERROR)
			return 1
		}

		if !this.data.extensions.data[name]
			return

		if !IsObject(this.data.config.data[name])
			this.data.config.data[name] := {}

		try {
			this.data.tempextension[name] := new extension_%name%(this.data.config.data[name])
		} catch e {
			this.log("Error in extension " name, ERROR)
			this.log(e)
		}

		if (!this.data.tempextension[name].extension.loaded) {
			this.log(name ": Not loaded", "ERROR")
			this.data.extensions.data[name] := false
		} else {
			timetaken := extensiontimer.get()
			if (timetaken > 50) {
				this.log(name " took " timetaken "ms!", "WARNING")
			}
			this.data.tempextension[name].log("Started in " timetaken "ms")
		}
		return 0
	}

	DeleteChecker(name) {
		if (this.deleted != name) {
			this.log("Error unloading " name, "ERROR")
		}
	}

	reloadExtension(name) {
		this.UnloadExtension(name, true)
		this.LoadExtension(name, true)
	}

	queueReload(name) {
		TimeOnce(ObjBindMethod(this, "reloadExtension", name), 0)
	}

	DeleteManager(name) {
		this.deleted := name
	}

	getExtension(name) {
		return this.data.tempextension[name]
	}

	Save(ExitReason, ExitCode) {
		if ExitReason {
			for name, extension in this.data.tempextension {
				if IsObject(extension) {
					extension.onexit(ExitReason, ExitCode)
				}
			}
		}
		this.data.extensions.save()
		this.data.config.save()
	}
}
