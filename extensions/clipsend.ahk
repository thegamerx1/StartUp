class extension_clipsend extends extension_ {
    static extension := {}
    ,extension.name := "Clip Send"

    Start() {
        this.addhotkey("^Insert", "sendClip")
    }

    sendClip() {
        KeyWait Ctrl
        KeyWait Insert
        text := StrReplace(clipboard, "`r", "")
        keydelay := 10
        Loop, Parse, text
        {
            SendRaw, % A_LoopField
            sleep, % keydelay
        }
    }
}