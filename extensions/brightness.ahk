#include <VCP>
class extension_brightness extends extension_ {
	static extension := {}
	,extension.name := "Brightness"

	OnExit(reason) {
		if (reason != "Shutdown") {
			this.log("Not shutdown")
			return
		}

		for _, value in GetAllMonitors() {
			this.setSession({x:value.x,y:value.y}, 10, 50)
		}
	}

	setSession(coord, bright, const) {
		ses := new VCP(coord)
		if ses.get(0x10).current < bright
			ses.send(0x10, bright)

		if ses.get(0x12).current < const
			ses.send(0x12, const)

		ses.close()
	}
}