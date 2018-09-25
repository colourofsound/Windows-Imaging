Set oWMI = GetObject("winmgmts://./root/ccm")
set oClient = oWMI.Get("SMS_Client")
oClient.ResetPolicy(0)
Set cpApplet = CreateObject("CPAPPLET.CPAppletMgr")
Set oCommands = cpApplet.GetClientActions 
For Each oAction In oCommands
	oAction.PerformAction
Next