#include <BetterPixel>
class extension_mpv extends extension_ {
	static extension := {}
	,extension.name := "MPV"

	Start() {
		this.addhotkey("End", "checkyy", "check")
		this.browser := "ahk_exe vivaldi.exe"
		this.anim := {mpv: 0, id: 0 }
		this.yt := 0
	}

	check() {
		return WinExist(this.browser)
	}

	checkyy() {
		if (WinActive(this.browser)) {
			send ^l
			sleep 50
			url := ClipboardCopy()
			WinGetTitle title
			if (InStr(title, "Youtube")) {
				this.youtube(url)
			} else if (InStr(title, "Anime Twist")) {
				this.animdl(url)
			}
		} else if (WinActive("ahk_exe mpv.exe")) {
			this.OnExit()
		}
	}

	youtube(url) {
		run mpv %url%,,, PID
		WinWaitActive ahk_exe mpv.exe
		Winget id, ID, ahk_pid %PID%
		this.yt := id
		this.log("yt: " + url)
	}

	animdl(url) {
		this.timer.delete()
		regex := regex(url, "(\d+)$")
		current := regex[1]
		this.log("Current episode: " current)
		run animdl stream "%url%" -r %current%-,,, PID
		WinWaitActive ahk_exe animdl.exe
		Winget id, ID, ahk_pid %PID%
		this.anim.id := id
		WinWaitActive ahk_exe mpv.exe
		this.anim.mpv := WinExist("A")
		this.timer := new timer(ObjBindMethod(this, "mpver"), 3000)
		this.log("Started ANIMDL in episode " current)
	}

	OnExit() {
		active := WinExist("A")
		if (active == this.anim.mpv) {
			this.timer.delete()
			WinKill % "ahk_id " this.anim.id
			WinKill % "ahk_id " this.anim.mpv
			this.anim := {}
		} else if (active == this.yt) {
			WinKill % "ahk_id " this.yt
			this.yt := 0
		}
	}

	mpver() {
		if !WinExist("ahk_id " this.anim.id) {
			this.log("ANIMDL closed")
			this.timer.delete()
			return
		}

		if !WinExist("ahk_id " this.anim.mpv) {
			WinWaitActive ahk_exe mpv.exe
			this.log("Next ep")
			sleep 50
			send ^4
			this.anim.mpv := WinExist("ahk_exe mpv.exe")
		}
	}


	; wetImage(imgarr, time := 100, force := false, diff := 0) {
	; 	if !IsObject(imgarr) {
	; 		imgarr := [imgarr]
	; 	}
	; 	total := []
	; 	for _, img in imgarr {
	; 		total.push(this.getAsset(img ".png"))
	; 	}
	; 	pos := WaitImage(total, diff, time)
	; 	if (pos) {
	; 		this.log("found " imgarr[pos.index] " at " pos.x ", " pos.y)
	; 	} else {
	; 		this.log("couldn't find")
	; 		this.log(imgarr)
	; 		if (force) {
	; 			throw "erroredsobadly"
	; 		}
	; 	}

	; 	return pos
	; }

	; epwrap(retry := false) {
	; 	try {
	; 		this.ep(retry)
	; 	} catch e {
	; 		if (e == "erroredsobadly") {
	; 			if (this.retries < 6) {
	; 				this.epwrap(true)
	; 			}
	; 			return
	; 		}
	; 		throw e
	; 	}
	; }

	; ep(retry) {
	; 	if (retry) {
	; 		this.retries++
	; 		this.log("Retry: " this.retries)
	; 		MouseMove(0,0)
	; 		sleep 50
	; 		pos := this.wetImage(["menu", "episode"], 100, true)
	; 		pos.x -= 50
	; 		Click(pos)
	; 		sleep 50
	; 		MouseMove(0,0)
	; 	} else {
	; 		this.log("Start")
	; 		this.retries := 0
	; 	}
	; 	keywait End
	; 	pid := WinExist("Watch ahk_exe firefox.exe")
	; 	if !pid
	; 		return
	; 	WinActivate % "ahk_id" pid
	; 	WinWaitActive % "ahk_id" pid
	; 	isNextEp := false
	; 	if WinExist("ahk_exe mpv.exe") {
	; 		isNextEp := true
	; 	}
	; 	if (isNextEp) {
	; 		if (this.nextep())
	; 			return
	; 		WinClose ahk_exe mpv.exe
	; 		sleep 100
	; 	}
	; 	if (isNextEp) {
	; 		Click(20, 1021, 100)
	; 		sleep 100
	; 		send n
	; 		sleep 400
	; 	}
	; 	pos := this.wetImage("wrong", 100)
	; 	if (pos) {
	; 		this.log("Wrong")
	; 		send n
	; 		sleep 300
	; 		send b
	; 		sleep 50
	; 	}
	; 	pos := this.wetImage(["play_my", "play_vard", "play_gen"], 100)
	; 	if (pos) {
	; 		MouseMove(pos, 50)
	; 		sleep 50
	; 		Click(pos, 100)
	; 		MouseMove(0,0)
	; 	}
	; 	url := this.getHLS()
	; 	if !url
	; 		return
	; 	run mpv %url%
	; 	while true {
	; 		if WinActive("ahk_exe mpv.exe") {
	; 			break
	; 		}
	; 		WinActivate ahk_exe mpv.exe
	; 		sleep 100
	; 	}
	; 	send ^4
	; }

	; getHLS() {
	; 	qpos := this.wetImage("quality_vard", 100, false, 20)
	; 	if (qpos) {
	; 		sleep 100
	; 	} else {
	; 		this.log("Max quality first checky")
	; 		pos := this.wetImage(["auto_my", "auto_vid"], 100)
	; 		if (pos) {
	; 			pos.y += 25
	; 			Click(pos, 400)
	; 			this.log("Quality")
	; 		} else {
	; 			sleep 150
	; 			qpos := this.wetImage(["quality_my", "quality_vid"], 200, true)
	; 			Click(pos, 100)

	; 			this.log("Max quality")
	; 			pos := this.wetImage(["auto_my", "auto_vid"], 200, true)
	; 			pos.y += 25
	; 			Click(pos, 300)
	; 			click(qpos, 100)
	; 		}
	; 	}

	; 	send m
	; 	sleep 50

	; 	pos := this.wetImage("hls_icon", 200, true)
	; 	Click(pos, 300)
	; 	pos := this.wetImage("hls_arrow", 200, true)
	; 	Click(pos, 300)

	; 	pos := this.wetImage("hls_resolution", 200, true)
	; 	pos.y += 50
	; 	pos.x += 50
	; 	Click(pos, 100)

	; 	send ^a
	; 	url := ClipboardCopy()

	; 	qpos.y -= 100
	; 	pixel := WaitPixel(qpos, 0x000000, 100, true)
	; 	if (pixel) {
	; 		Click(qpos, 50)
	; 	}
	; 	return url
	; }

	; nextep() {
	; 	this.log("Next ep")
	; 	pos := this.wetImage("episode", 100, true)
	; 	MouseMove(pos)
	; 	sleep 50
	; 	click down
	; 	sleep 50
	; 	pos.x += 150
	; 	MouseMove(pos, 5)
	; 	sleep 50
	; 	click up
	; 	text := ClipboardCopy()
	; 	regex := regex(text, ": /(\d+)$")
	; 	if (!regex) {
	; 		this.log("regex")
	; 		throw "erroredsobadly"
	; 	}
	; 	maxep := regex[1]
	; 	this.log("Max episode: " maxep)

	; 	send ^l
	; 	sleep 50
	; 	url := ClipboardCopy()
	; 	regex := regex(url, "ep-(\d+)$")
	; 	current := regex[1]
	; 	this.log("Current episode: " current)
	; 	if (current == maxep) {
	; 		this.log("Last episode")
	; 		return true
	; 	} else {
	; 		pos.x -= 80
	; 		Click(pos, 100)
	; 		Click(pos, 100)
	; 		send % current
	; 		sleep 50
	; 		send {enter}
	; 	}
	; }
}