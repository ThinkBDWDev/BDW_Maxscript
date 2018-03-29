/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: Quick render button
:History:V3.1

:Todo: make progressive
:Bugs:
:Tests:
*******************************************************HeaderEnd*/

Global iniFileOutput = (getdir #Scene + "/" + (maxfileName as string) + "_" + "Renderfile.ini")

fn ReadWriteIniToRoot StringContent:"" FilePath:(getdir #Scene + "/" + "Temp.ini") Write:false ID:-1000200 =
(
	if Write == true then
	(
		
	RootNodeID = (getAppData rootNode ID)
	
	if RootNodeID == undefined do
	(
		setAppData rootNode ID StringContent
	)	
		
	getTxt = getAppData rootNode ID
	File = FilePath
	txt = getTxt
	f = (createFile File)
	format txt to:f
	close f
		
	txt = ((dotnetClass "System.IO.File").ReadAllText FilePath as string)
	setAppData rootNode ID ""
	setAppData rootNode ID txt
	)
	else
	(
	try(
	txt = ((dotnetClass "System.IO.File").ReadAllText FilePath as string)
	setAppData rootNode ID txt)catch()
	)

)

fn SaveLoadINI Arr: INIFilePath: CatName: VarName: Content: Load:false SingleItem: Del:false =
(
	if Del == true then
	(
	delIniSetting INIFilePath CatName VarName
	)
	
	else
	(
	options.printallelements = true 
	if Load == true then
	(
	try (
	LoadFiles = (getIniSetting INIFilePath CatName)
	for i = 1 to LoadFiles.count do (append Arr LoadFiles[i])
	append SingleItem (getIniSetting INIFilePath CatName VarName)
	)catch()
	)
	else 
	(
	
	setINISetting INIFilePath CatName VarName (Content as string)

	)
	options.printallelements = false
    )
)


--####################################



fn SaveOutINI Var: Item: LoadIn: = 
(
	SaveLoadINI Arr:"" INIFilePath:iniFileOutput CatName:"Saved Vray Settings" VarName:Var Content:Item Load:LoadIn SingleItem:""
)

fn VraySettingsLoad =
(
    vr = (renderers.current)
	renderSceneDialog.close() 
	
-- 	vl = getclassinstances VRaylight
-- 	vl.storeWithIrradMap = true
	
	try(
	
		--change img size
	 ImgAs = getRendImageAspect()
	 Renderwidth = 1000
	 RenderHeight = (Renderwidth / ImgAs)
	
	
	re = maxOps.GetCurRenderElementMgr() --activate elements
	re.SetElementsActive true
	rendSaveFile = false
	
		for n = 0 to (re.NumRenderElements() - 1) do
		(
			el = re.GetRenderElement n
			fl = re.GetRenderElementFileName n

			re.SetRenderElementFilename n ""
		)
		
-- 	vr.adv_irradmap_AutoSave = false
-- 	vr.lightcache_autoSave = false
		
		VR.adv_irradmap_mode = 0
		vr.lightcache_mode = 0
	
	vr.output_on = true 
	vr.imageSampler_type = 1
	vr.filter_on=false		

	vr.imageSampler_shadingRate =15
	vr.twoLevel_threshold =0.05
	vr.twoLevel_fineSubdivs =3
	vr.dmc_useLocalSubdivs =false

	vr.gi_primary_type = 0
	vr.gi_secondary_type = 3

	vr.gi_irradmap_minRate = -5
	vr.gi_irradmap_maxRate = -5
	vr.gi_irradmap_subdivs = 30
	vr.gi_irradmap_colorThreshold = 0.3
	vr.gi_irradmap_normalThreshold = 0.2

	vr.lightcache_subdivs = 250
)catch()
)

fn SaveSettingsLoad =
(	
	vr = (renderers.current)
	renderSceneDialog.close() 
	ImgAs = getRendImageAspect()
	
	
	--write to ini file
	ReadWriteIniToRoot StringContent:"" FilePath:iniFileOutput Write:true ID:-3000200
	
	SaveOutINI Var:"Renderwidth" Item:Renderwidth LoadIn:false
	SaveOutINI Var:"Renderheight" Item:Renderheight LoadIn:false
	
	SaveOutINI Var:"vr.output_on" Item:vr.output_on LoadIn:false
	SaveOutINI Var:"vr.imageSampler_type" Item:vr.imageSampler_type LoadIn:false
	SaveOutINI Var:"vr.filter_on" Item:vr.filter_on LoadIn:false
	SaveOutINI Var:"vr.imageSampler_shadingRate" Item:vr.imageSampler_shadingRate LoadIn:false
	SaveOutINI Var:"vr.twoLevel_threshold" Item:vr.twoLevel_threshold LoadIn:false
	SaveOutINI Var:"vr.twoLevel_fineSubdivs" Item:vr.twoLevel_fineSubdivs LoadIn:false
	SaveOutINI Var:"vr.dmc_useLocalSubdivs" Item:vr.dmc_useLocalSubdivs LoadIn:false
	
	SaveOutINI Var:"vr.gi_primary_type" Item:vr.gi_primary_type LoadIn:false
	SaveOutINI Var:"vr.gi_secondary_type" Item:vr.gi_secondary_type LoadIn:false
	SaveOutINI Var:"vr.gi_irradmap_minRate" Item:vr.gi_irradmap_minRate LoadIn:false
	SaveOutINI Var:"vr.gi_irradmap_maxRate" Item:vr.gi_irradmap_maxRate LoadIn:false
	SaveOutINI Var:"vr.gi_irradmap_subdivs" Item:vr.gi_irradmap_subdivs LoadIn:false
	SaveOutINI Var:"vr.gi_irradmap_colorThreshold" Item:vr.gi_irradmap_colorThreshold LoadIn:false
	SaveOutINI Var:"vr.gi_irradmap_normalThreshold" Item:vr.gi_irradmap_normalThreshold LoadIn:false
	SaveOutINI Var:"vr.lightcache_subdivs" Item:vr.lightcache_subdivs LoadIn:false
	
    --write to root
	ReadWriteIniToRoot StringContent:"" FilePath:iniFileOutput Write:false ID:-3000200
	deletefile iniFileOutput 

	
)

fn ReloadOldSettings =
(
	vr = (renderers.current)
	renderSceneDialog.close() 
-- 	vl = getclassinstances VRaylight
-- 	vl.storeWithIrradMap = false
	
	re = maxOps.GetCurRenderElementMgr() --activate elements
	re.SetElementsActive true
	---------------------------------------------------------------------------
	
	ReadWriteIniToRoot StringContent:"" FilePath:iniFileOutput Write:true ID:-3000200 
	
	renderwidth = (getIniSetting iniFileOutput "Saved Vray Settings" "renderwidth") as integer
	renderheight = (getIniSetting iniFileOutput "Saved Vray Settings" "renderheight") as integer

	vr.output_on = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.output_on") as booleanClass
	vr.imageSampler_type = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.imageSampler_type") as integer
	vr.filter_on = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.filter_on") as booleanClass
	vr.imageSampler_shadingRate = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.imageSampler_shadingRate") as integer
	vr.twoLevel_threshold = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.twoLevel_threshold") as float
	vr.twoLevel_fineSubdivs = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.twoLevel_fineSubdivs") as integer
	vr.dmc_useLocalSubdivs = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.dmc_useLocalSubdivs") as booleanClass
	
	vr.gi_primary_type = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_primary_type") as integer
	vr.gi_secondary_type = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_secondary_type") as integer

	vr.gi_irradmap_minRate = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_irradmap_minRate") as integer
	vr.gi_irradmap_maxRate = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_irradmap_maxRate") as integer
	vr.gi_irradmap_subdivs = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_irradmap_subdivs") as integer
	vr.gi_irradmap_colorThreshold = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_irradmap_colorThreshold") as float
	vr.gi_irradmap_normalThreshold = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.gi_irradmap_normalThreshold") as float
	
	vr.lightcache_subdivs = (getIniSetting iniFileOutput "Saved Vray Settings" "vr.lightcache_subdivs") as integer	
	
			setAppData rootNode -3000200 ""
			deletefile iniFileOutput 
			
	
)

fn reloadNewScene RolloutName: =
		 (
			 setAppData rootNode -3000200 ""
			 RolloutName.ckb1.checked = false
		 )
		 
fn reloadButton RolloutName: =
 (
	checkRoot = getappdata rootNode -3000200
	
	if checkRoot == undefined then
	(
		setAppData rootNode -3000200 ""
	)
	 
	checkRoot = getappdata rootNode -3000200

	if checkRoot == "" then
	(
	  RolloutName.ckb1.checked = false
	)
	
	else 
	(
	  RolloutName.ckb1.checked = true
	)
	 
 )


 --UI
 
 try(destroydialog Quickren) catch() 

 rollout Quickren "Tool" 
 (
	 checkButton ckb1 "LR RENDER" width:84 height:42 highlightColor:red
	 


	 on ckb1 changed state do
	 (
		if ckb1.checked then
		(
			try (
			SaveSettingsLoad()
			VraySettingsLoad())catch()
			
		)	
		else
		(	
			try(
			ReloadOldSettings())catch()
				
		)			
		
	 )

	on Quickren open do
	(
	  reloadButton RolloutName:Quickren
	  callbacks.removescripts id: #CheckRenderState
	  callbacks.addscript #filePostOpen "reloadButton RolloutName:Quickren" id:#CheckRenderState
	  callbacks.addscript #systemPreNew "reloadNewScene RolloutName:Quickren" id:#CheckRenderState
	)

 ) 
 CreateDialog Quickren

cui.RegisterDialogBar Quickren style:#(#cui_dock_topRight)
	 cui.DockDialogBar Quickren #cui_dock_top