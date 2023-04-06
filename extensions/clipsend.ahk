class extension_clipsend extends extension_ {
    static extension := {}
    ,extension.name := "Clip Send"

    Start() {
        this.addhotkey("^Insert", "sendClip")
    }

    sendClip() {
        KeyWait Insert
        SendInput % clipboard
    }
}