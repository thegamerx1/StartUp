#include <VCP>
#include <BetterPixel>
class extension_brightness extends extension_ {
	static extension := {}
	,extension.name := "Brightness"

	OnExit(reason) {
		if (reason != "Shutdown") {
			this.log("Not shutdown")
			return
		}

		for _, value in GetAllMonitors() {
			this.setSession({x: value.x, y: value.y}, 10, 50)
		}
	}

	setSession(coord, bright, const) {
		ses := new VCP(coord)
		if (ses.get(VCP.BRIGHTNESS).current < bright) {
			ses.send(VCP.BRIGHTNESS, bright)
		}

		if (ses.get(VCP.CONTRAST).current < const) {
			ses.send(VCP.CONTRAST, const)
		}

		ses.close()
	}
}