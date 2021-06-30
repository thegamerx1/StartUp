#include <VCP>
class extension_brightness extends extension_ {
	static extension := {}
	,extension.name := "Brightness"

	OnExit(reason) {
		if (reason != "Shutdown") {
			this.log("Not shutdown")
			return
		}

		this.setSession({x:0,y:0}, 70, 20)
		this.setSession({x:-1366, y:100}, 100, 50)
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