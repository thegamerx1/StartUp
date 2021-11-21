#include <timer>
class extension_ramdisk extends extension_ {
	static extension := {}
	,extension.name := "Ram Disk"
	,extension.gui := true

	Start() {
		this.config.data := EzConf(this.config.data, {folders: "Downloads,Recordings"})
		if !InStr(FileExist("R:"), "D") {
			this.log("Running task")
			Run schtasks /run /TN "Me\RamDisk",, hide

			this.tries := 0
		}
		this.time := new timer(ObjBindMethod(this, "createfolders"), 1000)
	}

	afterdelete() {
		this.time.delete()
		this.time := ""
	}

	createfolders() {
		if InStr(FileExist("R:"), "D") {
			this.log("Checking folders")
			array := StrSplit(this.config.data.folders, ",", " ")
			for key, value in array {
				if !InStr(FileExist("R:\" value), "D") {
					this.log("Creating folder: " value)
					FileCreateDir R:\%value%
				}
			}
			this.log("Done")
			this.time.delete()
		} else {
			if (this.tries > 60*3) {
				this.log("Timed out")
				this.time.delete()
			}
			this.tries++
		}
	}

	save(obj) {
		this.config.data := obj
	}
}