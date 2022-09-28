#include <notify>
#include <requests>

class extension_shorter extends extension_ {
	static extension := {}
	,extension.name := "Link Shorter"

	Start() {
		this.clipchange := objbindmethod(this, "change")
		OnClipboardChange(this.clipchange)
		this.shorters := {}
		this.shorters.GDrive := "drive\.google\.\w+\/file\/d\/(?<id>[\w-]+)"
		this.shorters.amazon := "(?<protocol>\w+\:\/\/)(www\.)(?<url>amazon\.\w+)(.*)(\/dp\/)(?<id>\w+)\/"
	}

	gdrive(re) {
		local request
		shorter.data.link := Format("https://drive.google.com/file/d/{1}/view", re.id)
		request := new requests("https://gdbypass.host/api/", "GET")
		request.data := shorter.data
		return request.send().responseText
	}

	amazon(re) {
		return Format("{1}{2}/dp/{3}", re.protocol, re.url, re.id)
	}

	change() {
		for shorter, regex in this.shorters {
			if RegExMatch(clipboard, "O)" regex, match) {
				notf := new notification("Shorter", "Short " shorter "?")
				notf.onclick := objbindmethod(this, "makerequest", shorter, match, false)
				notf.queue()
				return
			}
		}
	}

	makerequest(shorter, match, auto := true) {
		clip := this[shorter](match)
		if !auto {
			clipboard := clip
		}
		return clip
	}

	afterdelete() {
		OnClipboardChange(this.clipchange, 0)
		this.clipchange := ""
	}
}