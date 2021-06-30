function ready() {
	els = {
		loggy: $("#logarea"),
		extlist: $("#extensionlist"),
		config: $("#extensionconfig"),
		configform: $(document.forms["configForm"])
	}
	logs = {}
	logareaSet("main")
	removeLoader()
}

function debug() {
	let array = ["Extensiuon", "Another one", "And another one", "Im an extension", "Who is the extension", "Uhmmmmmm", "EXTENSION", "Not an extension"]
	let i = 0
	while (array.length) {
		addExtension(i++, array.pop(), !(i % 2), !(i % 4))
	}
	for (let i = 0; i < 50; i++) {
		log("ie sucks" + random(10999,5909999) +"\n", "main")
	}
}

function log(text, type) {
	if (typeof logs[type] == "undefined") logs[type] = ""
	logs[type] += text
	if (els.loggy.attr("current") == type) {
		els.loggy.html(logs[type])
		els.loggy.animate({ scrollTop: els.loggy.scrollTop() + els.loggy.height() }, 120);
	}
}

function addExtension(fake, name, enabled, hasconfig) {
	let ext = $("template[name=extension-item]").contents().clone(true)
	ext.find(".name").html(name).attr("real", fake)
	ext.find("input").prop("checked", enabled)
	if (hasconfig) ext.find(".config").removeClass("d-none")
	els.extlist.append(ext)
	log("",name)
}

function actionExtension(e, action) {
	let name = $(e).closest(".extension-item").find(".name")
	var fake = name.html()
	var real = name.attr("real")
	switch (action) {
		case "toggle":
			ahk.extensiontoggle(real, e.checked)
			break
		case "config":
			let html = ahk.getHtml(real)
			let config = JSON.parse(ahk.getConfig(real))
			els.config.find(".content").html(html)
			els.config.find(".modal-title").html(fake)
			setDataToForm(els.configform, config)
			els.config.modal("show")
			break

		case "log":
			logareaSet(els.loggy.attr("current") == real ? "main" : real)
	}
}

function config(e, action) {
	switch (action) {
		case "save":
			ahk.configSave(JSON.stringify(formObject(els.configform)))
			break

		case "reset":
			els.config.find("input").each(function () {
				this.value = this.placeholder
			})
			return
	}
	els.config.modal("hide")
}

function logareaSet(type) {
	let title = $("#console-container .title")
	els.loggy.html(logs[type])
	els.loggy.attr("current", type)
	type = (type == "main" ? "Main" : ahk.getReal(type))
	title.html(type)
}