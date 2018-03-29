-------------------------------------------------------------------------------
-- modelPreparer.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.01
-- Created On: 10/19/15
-- Modified On: 11/10/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Sets up your model to have materials applied to it from the Soulburn 
-- MaterialAssetPacks using SAL.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a number of objects. Run the UI version of the script. Hit Do. it
-- will perform all of the setup operations you have checkmarked in the
-- script.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added high and low values to the curvature feature because this is a 
-- value users may want to adjust on a more frequent basis. Decreasing the low 
-- and increasing the high will capture more edges on a more subtly curved 
-- surface.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global modelPreparer
global modelPreparerDefaults
global modelPreparerUI

global mPRECloseOpenUI

global mPREDo
global mPREApply
global mPREHelp
global mPRELoadDef
global mPRESaveDef

global mPREDefineUI
global mPRERollout
global mPREFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"
include "$scripts\\SoulburnScripts\\scripts\\iDSetter.ms"
include "$scripts\\SoulburnScripts\\scripts\\xFormResetter.ms"
include "$scripts\\SoulburnScripts\\scripts\\groupWithPoint.ms"
include "$scripts\\SoulburnScripts\\scripts\\cornerEdgeToVertexMap.ms"
include "$scripts\\SoulburnScripts\\scripts\\blendedCubeProjectionMaker.ms"
include "$scripts\\SoulburnScripts\\scripts\\cameraMapTemplateRenderer.ms"

-- Variables

mPREConvertBaseValue = true
mPREiDSetValue = true
mPRExFormSetValue = true
mPRExFormSetCollapseValue = false
mPRELinkHelperValue = true
mPRECurveSetValue = true
mPRECurveLowValue = 265
mPRECurveHighValue = 275
mPREBCPValue = true
mPREBCPSizeValue = 1024
mPREBCPLightValue = true
mPREBCPShadowsValue = true
mPREBCPDirValue = "D:\\"
mPREPosValue = [400,400]

-- Functions

fn modelPreparer mPREConvertBase mPREiDSet mPRExFormSet mPRExFormSetCollapse mPRELinkHelper mPRECurveSet mPRECurveLow mPRECurveHigh mPREBCP mPREBCPSize mPREBCPLight mPREBCPShadows mPREBCPDir = 
	(
	allgeom = #()
	for i in selection do (if superclassof i == GeometryClass then append allgeom i)
	select allgeom

	g = undefined
	bc = undefined
	
	if mPREConvertBase == true then
		(
		cb = sLibRemoveUnneededInstancesFromArray allgeom
		for i in cb do sLibConvertBaseObjectToPoly i
		)
	if mPREiDSet == true then
		(
		iDSetter 1 "ColorID" 3 1 1 10 "1,3,4,5" false
		)
	if mPRExFormSet == true then
		(
		xFormResetter mPRExFormSetCollapse 1
		)
	if mPRELinkHelper == true then
		(
		g = groupWithPoint 1 150 false 2
		)
	if mPRECurveSet == true then
		(
		cornerEdgeToVertexMap true (color 255 255 255) true (color 0 0 0) true mPRECurveLow mPRECurveHigh (color 0 0 0) false 85 95 (color 0 0 0) false
		)
	if mPREBCP == true then
		(
		select allgeom
		bc = blendedCubeProjectionMaker false 1 true 1 "" "" "" "" "" "" 1 1 5 8 6 9 7 10 false "" true 100 2.0
		if mPREBCPDir == undefined or mPREBCPDir == "" then (MessageBox "Please select a path to save rendered files" title:"modelPreparer")
		else
			(
			select bc[1]
			cameraMapTemplateRenderer 1 mPREBCPSize mPREBCPSize 100 true mPREBCPLight mPREBCPShadows mPREBCPDir
			if g != undefined then bc[2].parent = g[1]
			select allgeom
			)
		)
	)
	
fn modelPreparerDefaults = 
	(
	mPRELoadDef()
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveLowValue mPRECurveHighValue mPREBCPValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	)
	
fn modelPreparerUI = 
	(
	mPRELoadDef()
	mPRECloseOpenUI mPREPosValue
	)

fn mPRECloseOpenUI pos = 
	(
	if mPREFloater != undefined then CloseRolloutFloater mPREFloater
	mPREDefineUI()
	mPREFloater = newRolloutFloater "modelPreparer v1.01" 310 478 pos.x pos.y
	addRollout mPRERollout mPREFloater
	)

fn mPREDo = 
	(
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveLowValue mPRECurveHighValue mPREBCPValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	if mPREFloater != undefined then CloseRolloutFloater mPREFloater
	)

fn mPREApply = 
	(
	modelPreparer mPREConvertBaseValue mPREiDSetValue mPRExFormSetValue mPRExFormSetCollapseValue mPRELinkHelperValue mPRECurveSetValue mPRECurveLowValue mPRECurveHighValue mPREBCPValue mPREBCPSizeValue mPREBCPLightValue mPREBCPShadowsValue mPREBCPDirValue
	)
	
fn mPREHelp = 
	(
	sLibSSPrintHelp "modelPreparer"
	)
	
fn mPRELoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mPREInputFilename = presetDir + "modelPreparer.ini"
	if (sLibFileExist mPREInputFilename == true) then
		(
		mPREConvertBaseValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREConvertBaseValue")
		mPREiDSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREiDSetValue")
		mPRExFormSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRExFormSetValue")
		mPRExFormSetCollapseValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRExFormSetCollapseValue")
		mPRELinkHelperValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRELinkHelperValue")
		mPRECurveSetValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveSetValue")
		mPRECurveLowValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveLowValue")
		mPRECurveHighValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPRECurveHighValue")
		mPREBCPValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPValue")
		mPREBCPSizeValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPSizeValue")
		mPREBCPLightValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPLightValue")
		mPREBCPShadowsValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREBCPShadowsValue")
		mPREBCPDirValue = getINISetting mPREInputFilename "modelPreparer" "mPREBCPDirValue"
		mPREPosValue = execute (getINISetting mPREInputFilename "modelPreparer" "mPREPosValue")
		
		if mPREConvertBaseValue == OK then mPREConvertBaseValue = true
		if mPREiDSetValue == OK then mPREiDSetValue = true
		if mPRExFormSetValue == OK then mPRExFormSetValue = true
		if mPRExFormSetCollapseValue == OK then mPRExFormSetCollapseValue = false
		if mPRELinkHelperValue == OK then mPRELinkHelperValue = true
		if mPRECurveSetValue == OK then mPRECurveSetValue = true
		if mPRECurveLowValue == OK then mPRECurveLowValue = 265
		if mPRECurveHighValue == OK then mPRECurveHighValue = 275
		if mPREBCPValue == OK then mPREBCPValue = true
		if mPREBCPSizeValue == OK then mPREBCPSizeValue = 1024
		if mPREBCPLightValue == OK then mPREBCPLightValue = true
		if mPREBCPShadowsValue == OK then mPREBCPShadowsValue = true
		if mPREBCPDirValue == OK then mPREBCPDirValue = "D:\\"
		if mPREPosValue == OK then mPREPosValue = [400,400]
		)
	else
		(
		mPREConvertBaseValue = true
		mPREiDSetValue = true
		mPRExFormSetValue = true
		mPRExFormSetCollapseValue = false
		mPRELinkHelperValue = true
		mPRECurveSetValue = true
		mPRECurveLowValue = 265
		mPRECurveHighValue = 275
		mPREBCPValue = true
		mPREBCPSizeValue = 1024
		mPREBCPLightValue = true
		mPREBCPShadowsValue = true
		mPREBCPDirValue = "D:\\"
		mPREPosValue = [400,400]
		)
	)
	
fn mPRESaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mPREOutputFilename = presetDir + "modelPreparer.ini"
	if (sLibFileExist mPREOutputFilename == true) then deleteFile mPREOutputFilename
	setINISetting mPREOutputFilename "modelPreparer" "mPREConvertBaseValue" (mPREConvertBaseValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREiDSetValue" (mPREiDSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRExFormSetValue" (mPRExFormSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRExFormSetCollapseValue" (mPRExFormSetCollapseValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRELinkHelperValue" (mPRELinkHelperValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveSetValue" (mPRECurveSetValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveLowValue" (mPRECurveLowValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPRECurveHighValue" (mPRECurveHighValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPValue" (mPREBCPValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPSizeValue" (mPREBCPSizeValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPLightValue" (mPREBCPLightValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPShadowsValue" (mPREBCPShadowsValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREBCPDirValue" (mPREBCPDirValue as string)
	setINISetting mPREOutputFilename "modelPreparer" "mPREPosValue" (mPREFloater.pos as string)
	)

-- UI

fn mPREDefineUI = 
	(
	rollout mPRERollout "modelPreparer"
		(
		group ""
		(
		checkbox mPREConvertBaseCheckbox "Convert Base Objects To Poly?" checked:mPREConvertBaseValue
		)
		on mPREConvertBaseCheckbox changed state do mPREConvertBaseValue = state

		group ""
		(		
		checkbox mPREiDSetCheckbox "Set All Mat IDs to 1?" checked:mPREiDSetValue
		)
		on mPREiDSetCheckbox changed state do mPREiDSetValue = state

		group ""
		(
		checkbox mPRExFormSetCheckbox "Reset Xform?" checked:mPRExFormSetValue
		checkbox mPRExFormSetCollapseCheckbox "Collapse Stack After Reset?" checked:mPRExFormSetCollapseValue offset:[18,0]
		)
		
		on mPRExFormSetCheckbox changed state do mPRExFormSetValue = state
		on mPRExFormSetCollapseCheckbox changed state do mPRExFormSetCollapseValue = state

		group ""
		(		
		checkbox mPRELinkHelperCheckbox "Link Selected Models To Point Helper?" checked:mPRELinkHelperValue
		)
		on mPRELinkHelperCheckbox changed state do mPRELinkHelperValue = state
		
		group ""
		(
		checkbox mPRECurveSetCheckbox "Bake Curavture?" checked:mPRECurveSetValue
		spinner mPRECurveLowSpinner "Low Angle: " range:[0,360,mPRECurveLowValue] fieldWidth:55 type:#float align:#left offset:[18,0] enabled:mPRECurveSetValue
		spinner mPRECurveHighSpinner "High Angle: " range:[0,360,mPRECurveHighValue] fieldWidth:55 type:#float align:#left offset:[18,0] enabled:mPRECurveSetValue
		)
		on mPRECurveSetCheckbox changed state do 
			(
			mPRECurveSetValue = state
			mPRECurveLowSpinner.enabled = state
			mPRECurveHighSpinner.enabled = state
			)
		on mPRECurveLowSpinner changed val do mPRECurveLowValue = val
		on mPRECurveHighSpinner changed val do mPRECurveHighValue = val

		group ""
		(
		checkbox mPREBCPCheckbox "Prep For Blended Cube Projection?" checked:mPREBCPValue
		spinner mPREBCPSizeSpinner "Width: " range:[1,99999,mPREBCPSizeValue] fieldWidth:50 type:#integer align:#left offset:[18,0] enabled:mPREBCPValue
		checkbox mPREBCPLightCheckbox "Temporary Dome Light?" checked:mPREBCPLightValue offset:[18,0] enabled:mPREBCPValue
		checkbox mPREBCPShadowsCheckbox "Shadows?" checked:mPREBCPShadowsValue offset:[18,0] enabled:mPREBCPValue
		edittext mPREBCPDirEditText "" fieldWidth:230 text:mPREBCPDirValue align:#left across:2 offset:[12,0] enabled:mPREBCPValue
		button mPREBCPDirButton "F" width:20 toolTip:"Choose Path" align:#right offset:[0,-2] enabled:mPREBCPValue
		)
		
		on mPREBCPCheckbox changed state do 
			(
			mPREBCPValue = state
			mPREBCPSizeSpinner.enabled = state
			mPREBCPLightCheckbox.enabled = state
			mPREBCPShadowsCheckbox.enabled = state
			mPREBCPDirEditText.enabled = state
			mPREBCPDirButton.enabled = state
			)
		on mPREBCPSizeSpinner changed val do mPREBCPSizeValue = val
		on mPREBCPDirEditText changed text do 
			(
			if text[text.count] != "\\" then text = text + "\\"
			mPREBCPDirValue = text
			mPREBCPDirEditText.text = text
			)
		on mPREBCPDirButton pressed do 
			(
			mypath = getSavePath()
			if mypath != undefined then 
				(
				if mypath[mypath.count] != "\\" then mypath = mypath + "\\"
				mPREBCPDirValue = mypath
				mPREBCPDirEditText.text = mypath
				)
			else 
				(
				mPREBCPDirValue = ""
				mPREBCPDirEditText.text = ""
				)
			)
		on mPREBCPLightCheckbox changed state do mPREBCPLightValue = state
		on mPREBCPShadowsCheckbox changed state do mPREBCPShadowsValue = state
		
		button mPREDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,422]
		on mPREDoButton pressed do mPREDo()
		button mPREApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,422]
		on mPREApplyButton pressed do mPREApply()
		button mPREHelpButton "Help" width:70 toolTip:"Help" pos:[149,422]
		on mPREHelpButton pressed do mPREHelp()
		button mPRESaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,422]
		on mPRESaveDefButton pressed do mPRESaveDef()
		)
	)
)
-------------------------------------------------------------------------------