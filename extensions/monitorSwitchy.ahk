#include <VCP>
class extension_monitorSwitchy extends extension_ {
	static extension := {}
	,extension.name := "Monitor Switchy"

	Start() {
		this.addhotkey("+PgDn", "switchy")
		this.old := ""
		this.isSwitched := false
	}

	action(coord, bright, const) {
		; ses.send(0x10, bright)
		; ses.send(0x12, const)
	}

	switchy() {
		ses := new VCP({x: 2500, y: 300})
		ses.send(0xD6, this.isSwitched ? 1 : 2)
		ses.close()
		this.isSwitched := !this.isSwitched
	}
}