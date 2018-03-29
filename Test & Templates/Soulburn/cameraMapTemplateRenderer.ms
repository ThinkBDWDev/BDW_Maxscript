-------------------------------------------------------------------------------
-- cameraMapTemplateRenderer.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.04
-- Created On: 12/13/14
-- Modified On: 11/08/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Will render out templates for all selected cameras or all cameras associated 
-- with a single cameraMapGemini modifier. Automates the process so you're 
-- not stuck rendering a lot of cameras and changing lots of render resolutions 
-- by hand. Originally called cameraMapTemplateRenderer, now generalized to do 
-- all cameras.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- 1) Make a sphere. Make 2 cameras. Select the cameras. Run the script in UI 
-- mode. Choose an output directory for the rendered files. Hit Do. Now that 
-- directory will have images in it from each camera you had selected.
-- 2) Make a sphere. Make 2 cameras. Apply a cameraMapGemini modifier to the 
-- sphere. Hook the modifier up to the 2 cameras. Run the script in UI mode. 
-- Choose an output directory for the rendered files. Hit Do. Now that directory 
-- will have images in it from each camera specified in the modifier.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Cleaned Up Some Code.
--
-- v 1.02 Adjusted some code in the render area to be more efficient.
--
-- v 1.03 After a render, now returns the active viewport to the last viewport 
-- type you had instead of the view of one of the cameras you rendered from. Added
-- option for adding a default light, and for turning shadows on and off.
--
-- v 1.04 Fixed a bug where the script would crash if the vray render failed
-- for some reason.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global cameraMapTemplateRenderer
global cameraMapTemplateRendererDefaults
global cameraMapTemplateRendererUI

global cMTRCloseOpenUI

global cMTRDo
global cMTRApply
global cMTRHelp
global cMTRLoadDef
global cMTRSaveDef

global cMTRDefineUI
global cMTRRollout
global cMTRFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cMTRModeValue = 1
cMTRSpecificSizeWidthValue = 4096
cMTRSpecificSizeHeightValue = 4096
cMTRRenderScaleValue = 100
cMTRVFBValue = true
cMTRLightValue = false
cMTRShadowsValue = true

cMTROutputDirValue = ""
cMTRPosValue = [400,400]

-- Functions

fn cameraMapTemplateRenderer cMTRMode cMTRSpecificSizeWidth cMTRSpecificSizeHeight cMTRRenderScale cMTRVFB cMTRLight cMTRShadows cMTROutputDir = 
	(
	if cMTROutputDir == undefined or cMTROutputDir == "" then (MessageBox "Please select an path to save rendered files" title:"cameraMapTemplateRenderer")
	else
		(
		if cMTRMode == 2 and (classof (modPanel.getCurrentObject ())) != CameraMapGeminiModifier then (MessageBox "Please select a CameraMapGemini modifier in the modify panel" title:"cameraMapTemplateRenderer")
		else
			(
			cams = #()
			-- Selected Cameras
			if cMTRMode == 1 then
				(
				mycameras = #()
				for c in selection do (if superclassof c == camera then append mycameras c)
				for i in mycameras do
					(
					a = i
					b = cMTRSpecificSizeWidth
					c = cMTRSpecificSizeHeight
					if a != undefined then append cams #(a,b,c)
					)
				)
			-- CameramapGemini
			else
				(
				for i = 1 to 10 do
					(
					newi = sLibPadValue i 2
					a = execute ("(modPanel.getCurrentObject ()).nodeCam" + (newi as string))
					b = execute ("(modPanel.getCurrentObject ()).width" + (newi as string))
					c = execute ("(modPanel.getCurrentObject ()).height" + (newi as string))
					if a != undefined then append cams #(a,b,c)
					)
				)
			renderSceneDialog.close()
			unlocked = rendUseActiveView
			rendUseActiveView = true
			vtype = viewport.getType()
			if vtype == #view_camera then vcam = getActiveCamera()
			for c in cams do
				(
				-- Setup Vars
				outname = cMTROutputDir + c[1].name + ".tif"

				-- Store current parameters
				tempVFB = rendshowVFB
				tempRenderElements = (maxOps.GetCurRenderElementMgr()).GetElementsActive()
				tempWidth = RenderWidth
				tempHeight = RenderHeight
				tempSave = rendSaveFile
				tempTime = rendTimeType

				-- Change current renderer
				rendshowVFB = cMTRVFBValue
				(maxOps.GetCurRenderElementMgr()).SetElementsActive false
				RenderWidth = (c[2]*cMTRRenderScale*0.01)
				RenderHeight = (c[3]*cMTRRenderScale*0.01)
				rendSaveFile = false
				rendTimeType = 1

				-- Render
				if sLibWhatsCurrentRenderer() == "vray" then
					(
					if cMTRLight == true then
						(
						cMTRL = VRayLight type:1 multiplier:1 invisible:true subdivs:16
						)
					
					tempImageSampler = renderers.current.imageSampler_type
					tempFixedRateSubdivs = renderers.current.fixedRate_subdivs
					tempGI = renderers.current.gi_on
					tempShadows = renderers.current.options_shadows
					
					renderers.current.imageSampler_type = 0
					renderers.current.fixedRate_subdivs = 1
					renderers.current.gi_on = false
					renderers.current.options_shadows = cMTRShadows
					
					viewport.setCamera c[1]
					max quick render
					a = vrayVFBGetChannelBitmap 1
					if a != undefined then 
						(
						a.filename = outname
						save a
						)

					renderers.current.imageSampler_type = tempImageSampler
					renderers.current.fixedRate_subdivs = tempFixedRateSubdivs
					renderers.current.gi_on = tempGI
					renderers.current.options_shadows = tempShadows	
					
					if cMTRL != undefined then delete cMTRL
					vfbControl #hide
					)
				else 
					(
					if cMTRLight == true then
						(
						cMTRL = Skylight multiplier:1
						)
						
					temprendSaveFile = rendSaveFile
					temprendOutputFilename = rendOutputFilename
					rendSaveFile = true
					rendOutputFilename = outname
					
					viewport.setCamera c[1]
					max quick render
				
					rendSaveFile = temprendSaveFile
					rendOutputFilename = temprendOutputFilename
					
					if cMTRL != undefined then delete cMTRL
					)
					
				-- Put everything back
				rendshowVFB = tempVFB
				(maxOps.GetCurRenderElementMgr()).SetElementsActive tempRenderElements
				RenderWidth = tempWidth
				RenderHeight = tempHeight
				rendSaveFile = tempSave
				rendTimeType = tempTime
				) 
			rendUseActiveView = unlocked
			if vtype != #view_camera then viewport.setType vtype
			else viewport.setCamera vcam
			)
		)
	)
	
fn cameraMapTemplateRendererDefaults = 
	(
	cMTRLoadDef()
	cameraMapTemplateRenderer cMTRModeValue cMTRSpecificSizeWidthValue cMTRSpecificSizeHeightValue cMTRRenderScaleValue cMTRVFBValue cMTRLightValue cMTRShadowsValue cMTROutputDirValue
	)
	
fn cameraMapTemplateRendererUI = 
	(
	cMTRLoadDef()
	cMTRCloseOpenUI cMTRPosValue
	)
	
fn cMTRCloseOpenUI pos = 
	(
	if cMTRFloater != undefined then CloseRolloutFloater cMTRFloater
	cMTRDefineUI()
	cMTRFloater = newRolloutFloater "cameraMapTemplateRenderer v1.04" 310 320 pos.x pos.y
	addRollout cMTRRollout cMTRFloater
	)
	
fn cMTRDo = 
	(
	cameraMapTemplateRenderer cMTRModeValue cMTRSpecificSizeWidthValue cMTRSpecificSizeHeightValue cMTRRenderScaleValue cMTRVFBValue cMTRLightValue cMTRShadowsValue cMTROutputDirValue
	if cMTRFloater != undefined then CloseRolloutFloater cMTRFloater
	)

fn cMTRApply = 
	(
	cameraMapTemplateRenderer cMTRModeValue cMTRSpecificSizeWidthValue cMTRSpecificSizeHeightValue cMTRRenderScaleValue cMTRVFBValue cMTRLightValue cMTRShadowsValue cMTROutputDirValue
	)
	
fn cMTRHelp = 
	(
	sLibSSPrintHelp "cameraMapTemplateRenderer"
	)
	
fn cMTRLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cMTRInputFilename = presetDir + "cameraMapTemplateRenderer.ini"
	if (sLibFileExist cMTRInputFilename == true) then
		(
		cMTRModeValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRModeValue")
		cMTRSpecificSizeWidthValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRSpecificSizeWidthValue")
		cMTRSpecificSizeHeightValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRSpecificSizeHeightValue")
		cMTRRenderScaleValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRRenderScaleValue")
		cMTRVFBValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRVFBValue")
		cMTRLightValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRLightValue")
		cMTRShadowsValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRShadowsValue")
		cMTROutputDirValue = getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTROutputDirValue"
		cMTRPosValue = execute (getINISetting cMTRInputFilename "cameraMapTemplateRenderer" "cMTRPosValue")
		
		if cMTRModeValue == OK then cMTRModeValue = 1
		if cMTRSpecificSizeWidthValue == OK then cMTRSpecificSizeWidthValue = 4096
		if cMTRSpecificSizeHeightValue == OK then cMTRSpecificSizeHeightValue = 4096
		if cMTRRenderScaleValue == OK then cMTRRenderScaleValue = 100
		if cMTRVFBValue == OK then cMTRVFBValue = true
		if cMTRLightValue == OK then cMTRLightValue = false
		if cMTRShadowsValue == OK then cMTRShadowsValue = true
		if cMTROutputDirValue == OK then cMTROutputDirValue = ""
		if cMTRPosValue == OK then cMTRPosValue = [400,400]
		)
	else
		(
		cMTRModeValue = 1
		cMTRSpecificSizeWidthValue = 4096
		cMTRSpecificSizeHeightValue = 4096
		cMTRRenderScaleValue = 100
		cMTRVFBValue = true
		cMTRLightValue = false
		cMTRShadowsValue = true
		cMTROutputDirValue = ""
		cMTRPosValue = [400,400]
		)
	)
	
fn cMTRSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cMTROutputFilename = presetDir + "cameraMapTemplateRenderer.ini"
	if (sLibFileExist cMTROutputFilename == true) then deleteFile cMTROutputFilename
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRModeValue" (cMTRModeValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRSpecificSizeWidthValue" (cMTRSpecificSizeWidthValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRSpecificSizeHeightValue" (cMTRSpecificSizeHeightValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRRenderScaleValue" (cMTRRenderScaleValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRVFBValue" (cMTRVFBValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRLightValue" (cMTRLightValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRShadowsValue" (cMTRShadowsValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTROutputDirValue" (cMTROutputDirValue as string)
	setINISetting cMTROutputFilename "cameraMapTemplateRenderer" "cMTRPosValue" (cMTRFloater.pos as string)
	)

-- UI

fn cMTRDefineUI = 
	(
	rollout cMTRRollout "cameraMapTemplateRenderer"
		(
		group "Mode"
		(
		dropdownlist cMTRModeDropdown "" items:#("Selected Cameras", "CameramapGemini") selection:cMTRModeValue
		)
	
		group "Options"
		(
		spinner cMTRSpecificSizeWidthSpinner "Width: " range:[1,99999,cMTRSpecificSizeWidthValue] fieldWidth:50 type:#integer align:#right
		spinner cMTRSpecificSizeHeightSpinner "Height: " range:[1,99999,cMTRSpecificSizeHeightValue] fieldWidth:50 type:#integer align:#right
		spinner cMTRRenderScaleSpinner "Render Scale: " range:[1,100,cMTRRenderScaleValue] fieldWidth:50 type:#integer across:2 align:#right offset:[120,0]
		label label1 "%" align:#right
		checkbox cMTRVFBCheckbox "VFB?:" checked:cMTRVFBValue align:#right
		checkbox cMTRLightCheckbox "Temporary Dome Light?:" checked:cMTRLightValue align:#right
		checkbox cMTRShadowsCheckbox "Shadows?:" checked:cMTRShadowsValue align:#right
		)

		group "Path To Save Rendered Files"
		(
		edittext cMTROutputDirEditText "" fieldWidth:240 text:cMTROutputDirValue align:#left across:2
		button cMTROutputDirButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2]
		)

		on cMTRModeDropdown selected i do 
			(
			if i == 1 then
				(
				cMTRSpecificSizeWidthSpinner.enabled = true
				cMTRSpecificSizeHeightSpinner.enabled = true
				)
			else
				(
				cMTRSpecificSizeWidthSpinner.enabled = false
				cMTRSpecificSizeHeightSpinner.enabled = false
				)
			cMTRModeValue = i
			)
			
		on cMTRSpecificSizeWidthSpinner changed val do cMTRSpecificSizeWidthValue = val
		on cMTRSpecificSizeHeightSpinner changed val do cMTRSpecificSizeHeightValue = val
		on cMTRRenderScaleSpinner changed val do cMTRRenderScaleValue = val
		on cMTRVFBCheckbox changed state do cMTRVFBValue = state
		on cMTRLightCheckbox changed state do cMTRLightValue = state
		on cMTRShadowsCheckbox changed state do cMTRShadowsValue = state
		
		on cMTROutputDirEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			cMTROutputDirValue = text
			cMTROutputDirEditText.text = text
			)
		on cMTROutputDirButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				cMTROutputDirValue = mypath
				cMTROutputDirEditText.text = mypath
				)
			else 
				(
				cMTROutputDirValue = ""
				cMTROutputDirEditText.text = ""
				)
			)
		
		button cMTRDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,263]
		on cMTRDoButton pressed do cMTRDo()
		button cMTRApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,263]
		on cMTRApplyButton pressed do cMTRApply()
		button cMTRHelpButton "Help" width:70 toolTip:"Help" pos:[149,263]
		on cMTRHelpButton pressed do cMTRHelp()
		button cMTRSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,263]
		on cMTRSaveDefButton pressed do cMTRSaveDef()	
		
		on cMTRRollout open do
			(
			if cMTRModeValue == 1 then
				(
				cMTRSpecificSizeWidthSpinner.enabled = true
				cMTRSpecificSizeHeightSpinner.enabled = true
				)
			else
				(
				cMTRSpecificSizeWidthSpinner.enabled = false
				cMTRSpecificSizeHeightSpinner.enabled = false
				)
			)
		)
	)
)
-------------------------------------------------------------------------------