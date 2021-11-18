#include <BetterPixel>
class extension_mpv extends extension_ {
	static extension := {}
	,extension.name := "MPV"

	Start() {
		this.addhotkey("End", "ep", "check")
		this.retries := 0
	}

	check() {
		return true
	}

	ep(retry := false) {
		if (retry) {
			this.retries++
			MouseMove(0, 0)
			this.log("Retry: " this.retries)
			if (this.retries > 3) {
				return
			}
		} else {
			this.log("Start")
			this.retries := 0
		}
		keywait End
		isNextEp := false
		if WinExist("ahk_exe mpv.exe") {
			isNextEp := true
			WinClose
			sleep 100
		}
		pid := WinExist("Watch ahk_exe firefox.exe")
		if !pid
			return
		WinActivate % "ahk_id" pid
		WinWaitActive % "ahk_id" pid
		if (isNextEp) {
			Click(20, 1021, 100)
			sleep 100
			send n
			sleep 400
		}
		pos := WaitImage(this.getAsset("wrong.png"), 0, 100)
		if (pos) {
			this.log("Wrong")
			send b
			sleep 300
			send n
			sleep 50
		}
		pos := WaitImage(this.getAsset("my_play.png"), 0, 100)
		if (pos) {
			this.log("My play")
			Click(pos)
		}
		url := this.getHLS()
		if !url
			return
		run mpv %url%
		WinWaitActive ahk_exe mpv.exe
		sleep 200
		send ^4
	}

	getHLS() {
		this.log("Quality")
		pos := WaitImage(this.getAsset("quality_my.png"), 0, 200)
		if (pos) {
			Click(pos, 100)
		} else {
			this.ep(true)
			return
		}
		this.log("Max quality")
		pos := WaitImage(this.getAsset("auto_my.png"), 0, 200)
		if (pos) {
			pos.y += 25
			Click(pos, 400)
		} else {
			this.ep(true)
			return
		}
		pos := WaitImage(this.getAsset("hls_icon.png"))
		Click(pos, 300)
		pos := WaitImage(this.getAsset("hls_arrow.png"))
		Click(pos, 300)

		pos := WaitImage(this.getAsset("hls_resolution.png"))
		pos.y += 50
		pos.x += 50
		Click(pos, 100)
		send ^a
		sleep 50
		oldclip := Clipboard
		clipboard := ""
		send ^c
		sleep 25
		clipwait
		url := clipboard
		Clipboard := oldclip
		click(834, 597, 100)
		return url
	}
}