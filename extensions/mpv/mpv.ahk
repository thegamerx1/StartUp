#include <GraphQL>
FileInstall extensions/mpv/config.html, ~

class extension_mpv extends extension_ {
	static extension := {}
	,extension.name := "MPV"
	,extension.gui := true

	Start() {
		this.config.data := EzConf(this.config.data, {presence:false,list: "crunchyroll,allanime,animeout,kawaiifu,twist,gogoanime,animixplay,tenshi"})
		this.watch := StrSplit(this.config.data.list, ",", " ")
		this.template := "animdl stream ""{1:}:{2:}"" -r {3:}- -q best"
		this.templateurl := "animdl stream ""{1:}"" -r {2:}- -q best"
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
			if InStr(url, "youtube.com") {
				if this.yt && WinExist("ahk_id " this.yt)
				return
				this.youtube(url)
			} else if InStr(url, "anilist.co") {
				if this.running
				return
				regex := regex(url, "anilist\.co\/anime\/\d+\/(?<name>[^\/]+)\/?", "i")
				if !regex.name
				return
				this.anim := {mpv: 0, id: 0, name: "", ep: 0, run: 0, stream: "" }
				this.anilist(StrReplace(regex.name, "-", " "))
			} else {
				this.anim := {mpv: 0, id: 0, name: "", ep: 0, run: 0, stream: "" }
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
		this.anim.name := this.cache[name] ? this.cache[name] :  name
		this.loopindex := 0
		this.running := true
		while !contains("int", TypeOf(ep)) {
			Inputbox ep, Episode, % "Episode number`n" this.anim.name,,,,,,,2
			switch ErrorLevel {
				case 1:
				return
				case 2:
				ep := 0
			}
		}
		this.anim.ep := ep ? ep : 1
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
				this.animloop()
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
				run % format(this.templateurl (this.config.data.presence ? " -p" : ""), this.anim.stream, this.anim.ep),,, PID
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
			this.log(format(this.template (this.config.data.presence ? " -p" : ""), extractor, this.anim.name, this.anim.ep))
			run % format(this.template (this.config.data.presence ? " -p" : ""), extractor, this.anim.name, this.anim.ep),,, PID
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
}