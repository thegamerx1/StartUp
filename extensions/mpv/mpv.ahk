#include <GraphQL>
class extension_mpv extends extension_ {
	static extension := {}
	,extension.name := "MPV"
	,extension.gui := true

	Start() {
		this.config.data := EzConf(this.config.data, {list: "crunchyroll,allanime,animeout,kawaiifu,twist,gogoanime,animixplay,tenshi"})
		this.watch := StrSplit(this.config.data.list, ",", " ")
		this.template := "animdl stream ""{1:}:{2:}"" -r {3:}- -q best -p"
		this.templateurl := "animdl stream ""{1:}"" -r {2:}- -q best -p"
		this.addhotkey("End", "checkyy", "check")
		this.addhotkey("!F4", "closempv", "mpvCheck")
		this.act := {browser: "ahk_exe vivaldi.exe", mpv: "ahk_exe mpv.exe", anim: "ahk_exe animdl.exe"}
		this.yt := 0
		this.cache := {}
		this.graph := new GraphQL("https://graphql.anilist.co")
		var =
		(LTrim
			{
				Media(search: "{1}") {
					title {
						romaji
					}
				}
			}
		)
		this.query := var
	}

	save(obj) {
		this.config.data := obj
		this.watch := StrSplit(obj.list, ",", " ")
	}

	mpvCheck() {
		return WinActive(this.act.mpv) && this.anim.run
	}

	check() {
		return WinActive(this.act.browser) || WinActive(this.act.mpv) || WinActive(this.act.anim)
	}

	closempv() {
		WinKill % "ahk_id " this.anim.id
		WinKill % "ahk_id " this.anim.mpv
		this.running := false
	}

	checkyy() {
		if WinActive(this.act.browser) {
			send ^l
			sleep 50
			url := ClipboardCopy()
			this.anim := {mpv: 0, id: 0, name: "", ep: 0, run: 0, stream: "" }
			if InStr(url, "youtube.com") {
				this.youtube(url)
			} else if InStr(url, "anilist.co") {
				regex := regex(url, "anilist\.co\/anime\/\d+\/(?<name>.+)\/", "i")
				if (!regex.name)
					return
				this.anilist(StrReplace(regex.name, "-", " "))
			} else {
				this.stream(url)
			}
		} else if WinActive(this.act.mpv) {
			active := WinExist("A")
			this.running := false
			if (active == this.anim.mpv) {
				this.timer.delete()
				WinKill % "ahk_id " this.anim.id
				WinKill % "ahk_id " this.anim.mpv
				this.anim := {}
			} else if (active == this.yt) {
				WinKill % "ahk_id " this.yt
				this.yt := 0
			}
		} else if WinActive(this.act.anim) {
			WinKill % "ahk_id " this.anim.id
			WinKill % "ahk_id " this.anim.mpv
			this.running := false
		}
	}

	stream(url) {
		this.anim.ep := urlCode.url(url).params["ep"] || 0
		this.anim.stream := url
		this.loopindex := 0
		this.running := true
		this.animloop()
		this.timer := new timer(objbindmethod(this, "animloop"), 250)
	}

	anilist(name) {
		if (this.running) {
			this.closempv()
			return
		}
		ep := ""
		if this.cache[name] {
			this.cache[name]
		} else {

			try {
				this.cache[name] := this.graph.query(format(this.query, name)).Media.title.romaji
			} catch {
				this.log("Anilist failed")
			}
		}
		while !contains("int", TypeOf(ep)) {
			Inputbox ep, Episode, Episode number,,,,,,,2
			switch ErrorLevel {
				case 1:
					return
				case 2:
					ep := 0
			}
		}
		this.anim.name := this.cache[name] ? this.cache[name] :  name
		this.anim.ep := ep ? ep : 1
		this.loopindex := 0
		this.running := true
		this.animloop()
		this.timer := new timer(objbindmethod(this, "animloop"), 250)
	}

	animloop() {
		if !this.running {
			this.timer.delete()
			return
		}
		if (this.anim.id) {
			if !WinExist("ahk_id " this.anim.id) {
				this.log("AnimDL " this.anim.id  " closed")
				this.anim.id := 0
				this.loop()
				return
			}

			if !WinExist("ahk_id " this.anim.mpv) {
				id := WinActive(this.act.mpv)
				if (id == this.yt || !id) {
					this.timer.interval := 250
					return
				}
				this.anim.run := true
				this.log("MPV OPEN " id)
				sleep 50
				send ^4
				this.anim.mpv := id
				this.timer.interval := 1000
			}
		} else {
			if (this.anim.run) {
				this.log("ANIMDL finished")
				this.running := false
				return
			}

			if this.anim.stream {
				run % format(this.templateurl, this.anim.stream, this.anim.ep),,, PID
				WinWaitActive ahk_exe animdl.exe,, 4
				if (ErrorLevel) {
					this.log("AnimDL failed")
					this.running := false
					return
				}
				Winget id, ID, ahk_pid %PID%
				this.anim.id := ID
				this.anim.run := true
				return
			}
			extractor := this.watch[++this.loopindex]
			if !extractor {
				this.running := false
				this.log("No extractor found")
				return
			}
			this.log("Trying animdl " extractor " for " this.anim.name)
			this.log(format(this.template, extractor, this.anim.name, this.anim.ep))
			run % format(this.template, extractor, this.anim.name, this.anim.ep),,, PID
			WinWaitActive ahk_exe animdl.exe
			Winget id, ID, ahk_pid %PID%
			this.anim.id := ID
			this.anim.run := false
		}
	}

	youtube(url) {
		run mpv %url%,,, PID
		WinWaitActive ahk_exe mpv.exe
		Winget id, ID, ahk_pid %PID%
		this.yt := id
		this.log("yt: " + url)
	}

	; animdl(url, episode) {
	; 	this.timer.delete()
	; 	this.log("Current episode: " episode)
	; 	run animdl stream "%url%" -r %episode%-,,, PID
	; 	WinWaitActive ahk_exe animdl.exe
	; 	Winget id, ID, ahk_pid %PID%
	; 	this.anim.id := id
	; 	this.timer := new timer(ObjBindMethod(this, "mpver"), 3000)
	; 	this.log("Started ANIMDL in episode " episode)
	; }


	; mpver() {
	; 	if !WinExist("ahk_id " this.anim.id) {
	; 		this.log("ANIMDL closed")
	; 		this.timer.delete()
	; 		return
	; 	}

	; 	if !WinExist("ahk_id " this.anim.mpv) {
	; 		WinWaitActive ahk_exe mpv.exe
	; 		this.log("Next ep")
	; 		sleep 50
	; 		send ^4
	; 		this.anim.mpv := WinExist("ahk_exe mpv.exe")
	; 	}
	; }


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