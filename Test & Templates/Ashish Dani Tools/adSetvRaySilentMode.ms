-------------------------------------------------------------------------

/*
Name				: adSetVRaySilentMode
Version			: 1.0.0
Description		: Script to set VRay Silent Mode in 3ds Max
Type				: GUI
Date Created   	: 2015/04/12 
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com


UPDATES			:


*/


-------------------------------------------------------------------------






(


rollout adSetVRaySilentModeRoll "adSetVRaySilentMode" width:184 height:152
(
	button btnSetSilent "Set VRay Silent Mode" pos:[16,64] width:152 height:40
	label lbl1 "adSetVRaySilentMode" pos:[40,8] width:112 height:16
	GroupBox grp1 "" pos:[8,48] width:168 height:64
	
	
	HyperLink cust3 "Web Help" pos:[64,24] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[40,120] width:104 height:24 address:"www.ashishdani.com"	
	
	
	
	
	
	on btnSetSilent pressed do
	(
		setVRaySilentMode()
	)
)


fn adSetVRaySilentModeDefaults =
(
	createdialog adSetVRaySilentModeRoll
)



)