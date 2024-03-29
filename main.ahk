#Include %A_ScriptDir%
#Include <mustExec>
#NoTrayIcon
#include scripts/variables.ahk

global extensions_includer := new includer("extensions")
extensions_includer.init()
; TODO: Use separate config files and replace UI
ExtensionGui.init()
extensions.init()

Debug.print(extensions.loadedExtensions " Extensions Loaded (" extensions.loadtime " ms)", {label: "Extensions"})

debug.print("Script initiated (" script.starttime.get() "ms)", {label: "Loader"})
script.ready := true
Return

FileInstall web/minify/index.html, ~

;@Ahk2Exe-SetMainIcon icons/icon.ico
;@Ahk2Exe-ExeName StartUp.exe

#Include scripts/gui.ahk
#Include scripts/extensions.ahk

#Include <counter>
#Include <EzGui>
#Include <includer>
#Include <debug>
#Include <configloader>
#Include scripts/functions.ahk
#Include *i extensions/_includer.ahk