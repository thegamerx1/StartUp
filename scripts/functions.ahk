WindowSpy() {
	Run % RegExReplace(A_AhkPath, "\w+\.exe") "windowspy.ahk"
}

Exit() {
	ExitApp, 0
}

hotkeys() {
	ListHotkeys
}