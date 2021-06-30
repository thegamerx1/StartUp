global script := {}
script.name := "Start Up"
script.version := "1.1"
script.starttime := new Counter()
script.args := Array2String(A_Args)
script.debug := (A_DebuggerName || InStr(script.args, "-debug"))

Debug.init()
Debug.print(script.name " " script.version, {label: "Loader"})
Debug.print("Parameters: " script.args, {label: "Loader"})