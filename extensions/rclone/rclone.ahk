#include <timer>
class extension_rclone extends extension_ {
	static extension := {}
	,extension.name := "RClone"
	,extension.gui := true

	Start() {
		this.pids := []
		this.config.data := EzConf(this.config.data, [{name: "X", command: "rclone mount blabla"}])
		this.timer := this.addTimer("check", 10000)
		this.check()
	}

	check() {
		foundoneatleast := false
		for i, v in this.config.data {
			if (!InStr(FileExist(v.name), "D")) {
				if (this.pids[i]) {
					killPid(this.pids[i])
					this.log(v.name " restarting")
				}
				foundoneatleast := true
				this.pids[i] := ""
				; run % v.command,,hide, PID
				run % v.command,,, PID
				this.pids[i] := PID
				this.log("Started " v.name)
			}
		}
		if (!foundoneatleast) {
			this.timer.interval := 60*1000
		} else {
			this.timer.interval := 10*1000
		}
	}

	save(obj) {
		this.log(obj.data)
		try {
			data := JSON.load(obj.data)
		} catch e {
			this.log(e)
			return "Invalid json"
		}
		if (data[1]) {
			this.config.data := data
		} else {
			this.config.data := []
		}
	}

	getConfig() {
		return {data: JSON.dump(this.config.data)}
	}
}