-------------------------------------------------------------------------

/*
Name				: adSetSystemGammaValues
Version			: 1.0.0
Description		: Script for System Gamma Values & Settings
Type				: GUI
Date Created   	: 2015/03/16
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com


UPDATES			:


*/


-------------------------------------------------------------------------

(






rollout adSetSystemGammaValuesRoll "adSetSystemGammaValues" width:200 height:424
(
	GroupBox grp1 "System Settings" pos:[8,48] width:184 height:304
	GroupBox grp5 "" pos:[16,184] width:168 height:160

	spinner spnIP "" pos:[128,72] width:48 height:16 range:[1,3,2.2] type:#float
	spinner spnOP "" pos:[128,96] width:48 height:16 range:[1,3,2.2] type:#float
	spinner spnDP "" pos:[128,208] width:48 height:16 range:[1,3,2.2] type:#float
	
	
	button btnApply "Apply" pos:[24,360] width:152 height:32
	button btn111 "1.0 / 1.0" pos:[32,128] width:56 height:16
	button btn221 "2.2 / 1.0" pos:[120,128] width:56 height:16
	button btn222 "2.2 / 2.2" pos:[120,152] width:56 height:16
	button btn188 "1.8 / 1.8" pos:[32,152] width:56 height:16
	
	label lbl3 "adSetSystemGammaValues" pos:[32,8] width:136 height:16
	label lbl1 "File Input Gamma" pos:[24,72] width:96 height:16
	label lbl2 "File Output Gamma" pos:[24,96] width:96 height:16
	label lbl13 "Enable System Gamma Correction" pos:[32,240] width:96 height:32
	label lbl19 "Affect Material Editor" pos:[32,280] width:96 height:32
	label lbl20 "Affect Color Picker" pos:[32,320] width:96 height:16
	label lbl28 "Display Gamma" pos:[32,208] width:96 height:16
	
	checkbox chkSysGamma "Checkbox" pos:[152,248] width:16 height:16 checked:true
	checkbox chkMedit "Checkbox" pos:[152,280] width:16 height:16 checked:true
	checkbox chkColPick "Checkbox" pos:[152,320] width:16 height:16 checked:true
	
	
	HyperLink cust3 "Web Help" pos:[72,24] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[48,400] width:104 height:24 address:"www.ashishdani.com"
	
	
	on btnApply pressed do
	(
		FileInGamma = spnIP.value
		FileOutGamma = spnOP.value
		displaygamma = spnDP.value
		
		---------------------------------------------------------------------------------------------------
		---------------------------SYSTEM GAMMA----------------------------------------------------
		if chkSysGamma.checked == true do
		(
			iDisplayGamma.colorCorrectionMode = #gamma
		)
		
		if chkSysGamma.checked == false do
		(
			iDisplayGamma.colorCorrectionMode = #none
		)
		---------------------------------------------------------------------------------------------------
		
		
		
		---------------------------------------------------------------------------------------------------
		---------------------------AFFECT MEDIT------------------------------------------------------
		if chkMedit.checked == true do
		(
			iDisplayGamma.affectMEdit = true
		)
		if chkMedit.checked == false do
		(
			iDisplayGamma.affectMEdit = false
		)
		---------------------------------------------------------------------------------------------------
		
		
		
		---------------------------------------------------------------------------------------------------
		---------------------------AFFECT COLORPICKER----------------------------------------------
		if chkColPick.checked == true do
		(
			iDisplayGamma.affectColorPickers = true
		)
		if chkColPick.checked == false do
		(
			iDisplayGamma.affectColorPickers = false
		)
		---------------------------------------------------------------------------------------------------
		
		
	)
	on btn111 pressed do
	(
		spnIP.value = 1.0
		spnOP.value = 1.0
	)
	on btn221 pressed do
	(
		spnIP.value = 2.2
		spnOP.value = 1.0
	)
	on btn222 pressed do
	(
		spnIP.value = 2.2
		spnOP.value = 2.2
	)
	on btn188 pressed do
	(
		spnIP.value = 1.8
		spnOP.value = 1.8
	)
)


 fn adSetSystemGammaValuesDefaults =
(
	createdialog adSetSystemGammaValuesRoll()
)








)
