#Include %A_ScriptDir%
#Include <mustExec>
#NoTrayIcon
#include scripts/variables.ahk

includer.init("extensions")
ExtensionGui.init()
extensions.init()

Debug.print(extensions.loadedExtensions " Extensions Loaded (" extensions.loadtime " ms)", {label: "Extensions"})

debug.print("Script initiated (" script.starttime.get() "ms)", {label: "Loader"})
script.ready := true
Return

#Include scripts/gui.ahk
#Include scripts/extensions.ahk

#Include <counter>
#Include <EzGui>
#Include <includer>
#Include <debug>
#Include <configloader>
#Include scripts/functions.ahk
#Include *i extensions/_includer.ahk