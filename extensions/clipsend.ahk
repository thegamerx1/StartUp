class extension_clipsend extends extension_ {
    static extension := {}
    ,extension.name := "Clip Send"

    Start() {
        this.addhotkey("^!v", "sendClip")
    }

    sendClip() {
        KeyWait Ctrl
        KeyWait Alt
        KeyWait v
        text := StrReplace(clipboard, "`r", "")
        keydelay := 10
        Loop, Parse, text
        {
            SendRaw, % A_LoopField
            sleep, % keydelay
        }
    }
}