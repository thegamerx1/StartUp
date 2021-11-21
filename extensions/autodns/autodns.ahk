#include <timer>
#include <requests>
class extension_autodns extends extension_ {
	static extension := {}
	,extension.name := "Auto DNS"
	,extension.gui := true
	,extension.placeholder := {url: "https://dns.example.com/auth/password", password: "password"}

	Start() {
		this.config.data := EzConf(this.config.data, this.extension.placeholder)
		this.doWhite()
		this.time := new timer(ObjBindMethod(this, "doWhite"), 30*60*1000) ; 1/2 hour
		this.retries := 0
	}

	afterdelete() {
		this.time.delete()
		this.time := ""
		this.retrytimer.delete()
		this.retrytimer := ""
	}

	doWhite() {
		request := new requests("POST", this.config.data.url)
		request.headers["Content-Type"] := "application/json"
		try {
			response := request.send(JSON.dump({password: this.config.data.password}))
		} catch e {
			this.log("Couldn't complete request to " this.config.data.url  ", " e.message)
			return
		}
		if (response.status == 200) {
			status := "ok"
		} else {
			status := response.statusText
			this.retries++
			if (this.retries >= 3) {
				this.retrytimer.delete()
				this.retrytimer := ""
			} else {
				this.retrytimer := new timer(ObjBindMethod(this, "doWhite"), 1*60*1000)
			}
		}
		this.log("[" response.status "] (" response.time  "ms) " status)
	}

	save(obj) {
		this.config.data := obj
	}
}