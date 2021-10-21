#include <timer>
#include <requests>
class extension_autodns extends extension_ {
	static extension := {}
	,extension.name := "Auto DNS"
	,extension.gui := true

	Start() {
		this.config.data := EzConf(this.config.data, {url: "https://dns.ndrx.ml", password: "password"})
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
		response := request.send(JSON.dump({password: this.config.data.password}))
		if (response.status == 200) {
			status := "ok"
		} else {
			status := response.text
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