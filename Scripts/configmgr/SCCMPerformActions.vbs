on error resume next

dim oCPAppletMgr 'Control Applet manager object.
dim oClientAction 'Individual client action.
dim oClientActions 'A collection of client actions.

'Get the Control Panel manager object.
set  oCPAppletMgr=CreateObject("CPApplet.CPAppletMgr")
if err.number <> 0 then
    Wscript.echo "Couldn't create control panel application manager"
    WScript.Quit
end if

'Get a collection of actions.
set oClientActions=oCPAppletMgr.GetClientActions
if err.number<>0 then
    wscript.echo "Couldn't get the client actions"
    set oCPAppletMgr=nothing
    WScript.Quit
end if

'Display each client action name and perform it.
For Each oClientAction In oClientActions
	'wscript.echo "Performing action " + oClientAction.Name 
		oClientAction.PerformAction
next

set oClientActions=nothing
set oCPAppletMgr=nothing