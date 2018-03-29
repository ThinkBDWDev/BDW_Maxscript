-------------------------------------------------------------------------------
-- blendedBoxMapManager.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.00
-- Created On: 10/21/15
-- Modified On: 11/05/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Lets you change parameters to any Blended Box Map inside the material
-- you currently have selected in the Material Editor.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a material in the Material Editor that contains several VrayTriplanarTex
-- maps. Run The UI version of the script. Check "Do Scale", set the Scale to 1.
-- Click "Do". Now all VrayTriplanarTex maps in the material have that same
-- value.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global blendedBoxMapManager
global blendedBoxMapManagerDefaults
global blendedBoxMapManagerUI

global bBMMANCloseOpenUI

global bBMMANDo
global bBMMANApply
global bBMMANHelp
global bBMMANLoadDef
global bBMMANSaveDef

global bBMMANDefineUI
global bBMMANRollout
global bBMMANFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global bBMMANNodeObject = undefined

bBMMANModeValue = 1
bBMMANDoScaleValue = false
bBMMANScaleValue = 0.01
bBMMANDoBlendValue = true
bBMMANBlendValue = 0.3
bBMMANDoSpaceValue = false
bBMMANSpaceValue = 2
bBMMANDoRandTexOffsetValue = false
bBMMANRandTexOffsetValue = true
bBMMANPosValue = [400,400]

-- Functions

fn blendedBoxMapManager bBMMANMode bBMMANDoScale bBMMANScale bBMMANDoBlend bBMMANBlend bBMMANDoSpace bBMMANSpace bBMMANDoRandTexOffset bBMMANRandTexOffset = 
	(
	undo "blendedBoxMapManager" on
		(
		mat = undefined
		if MatEditor.mode == #basic then mat = medit.GetCurMtl()
		else (if (sme.IsOpen()) == false then (sme.Open());mat = sme.GetMtlInParamEditor())
		
		a = #()
		if bBMMANMode == 1 then sLibGetMapsFromMaxWrapperObject mat a else a = sLibGetAllMapsFromSelectedObjects()
		b = #()
		for i in a do
			(
			if (classof i) == VRayTriplanarTex then append b i
			)
		for i in b do
			(
			if bBMMANDoScale == true then i.scale = bBMMANScale
			if bBMMANDoBlend == true then i.blend = bBMMANBlend
			if bBMMANDoSpace == true then 
				(
				i.space = (bBMMANSpace - 1)
				i.reference_node = bBMMANNodeObject
				)
			if bBMMANDoRandTexOffset == true then i.random_texture_offset = bBMMANRandTexOffset
			)
		)
	)
	
fn blendedBoxMapManagerDefaults = 
	(
	bBMMANLoadDef()
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue
	)
	
fn blendedBoxMapManagerUI = 
	(
	bBMMANLoadDef()
	bBMMANCloseOpenUI bBMMANPosValue
	)

fn bBMMANCloseOpenUI pos = 
	(
	if bBMMANFloater != undefined then CloseRolloutFloater bBMMANFloater
	bBMMANDefineUI()
	bBMMANFloater = newRolloutFloater "blendedBoxMapManager v1.00" 310 341 pos.x pos.y
	addRollout bBMMANRollout bBMMANFloater
	)

fn bBMMANDo = 
	(
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue
	if bBMMANFloater != undefined then CloseRolloutFloater bBMMANFloater
	)

fn bBMMANApply = 
	(
	blendedBoxMapManager bBMMANModeValue bBMMANDoScaleValue bBMMANScaleValue bBMMANDoBlendValue bBMMANBlendValue bBMMANDoSpaceValue bBMMANSpaceValue bBMMANDoRandTexOffsetValue bBMMANRandTexOffsetValue
	)
	
fn bBMMANHelp = 
	(
	sLibSSPrintHelp "blendedBoxMapManager"
	)
	
fn bBMMANLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	bBMMANInputFilename = presetDir + "blendedBoxMapManager.ini"
	if (sLibFileExist bBMMANInputFilename == true) then
		(
		bBMMANModeValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANModeValue")
		bBMMANDoScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoScaleValue")
		bBMMANScaleValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANScaleValue")
		bBMMANDoBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoBlendValue")
		bBMMANBlendValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANBlendValue")
		bBMMANDoSpaceValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoSpaceValue")
		bBMMANSpaceValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANSpaceValue")
		bBMMANDoRandTexOffsetValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANDoRandTexOffsetValue")
		bBMMANRandTexOffsetValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANRandTexOffsetValue")
		bBMMANPosValue = execute (getINISetting bBMMANInputFilename "blendedBoxMapManager" "bBMMANPosValue")
		
		if bBMMANModeValue == OK then bBMMANModeValue = 1
		if bBMMANDoScaleValue == OK then bBMMANDoScaleValue = false
		if bBMMANScaleValue == OK then bBMMANScaleValue = 0.01
		if bBMMANDoBlendValue == OK then bBMMANDoBlendValue = true
		if bBMMANBlendValue == OK then bBMMANBlendValue = 0.3
		if bBMMANDoSpaceValue == OK then bBMMANDoSpaceValue = false
		if bBMMANSpaceValue == OK then bBMMANSpaceValue = 2
		if bBMMANDoRandTexOffsetValue == OK then bBMMANDoRandTexOffsetValue = false
		if bBMMANRandTexOffsetValue == OK then bBMMANRandTexOffsetValue = true
		if bBMMANPosValue == OK then bBMMANPosValue = [400,400]
		)
	else
		(
		bBMMANModeValue = 1
		bBMMANDoScaleValue = false
		bBMMANScaleValue = 0.01
		bBMMANDoBlendValue = true
		bBMMANBlendValue = 0.3
		bBMMANDoSpaceValue = false
		bBMMANSpaceValue = 2
		bBMMANDoRandTexOffsetValue = false
		bBMMANRandTexOffsetValue = true
		bBMMANPosValue = [400,400]
		)
	)
	
fn bBMMANSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	bBMMANOutputFilename = presetDir + "blendedBoxMapManager.ini"
	if (sLibFileExist bBMMANOutputFilename == true) then deleteFile bBMMANOutputFilename
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANModeValue" (bBMMANModeValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoScaleValue" (bBMMANDoScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANScaleValue" (bBMMANScaleValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoBlendValue" (bBMMANDoBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANBlendValue" (bBMMANBlendValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoSpaceValue" (bBMMANDoSpaceValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANSpaceValue" (bBMMANSpaceValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANDoRandTexOffsetValue" (bBMMANDoRandTexOffsetValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANRandTexOffsetValue" (bBMMANRandTexOffsetValue as string)
	setINISetting bBMMANOutputFilename "blendedBoxMapManager" "bBMMANPosValue" (bBMMANFloater.pos as string)
	)

-- UI

fn bBMMANDefineUI = 
	(
	rollout bBMMANRollout "blendedBoxMapManager"
		(
		group "Mode"
		(
		dropdownlist bBMMANModeDropdown "" items:#("Maps in Active Medit Slot", "Maps On Sel Objects") selection:bBMMANModeValue align:#right width:270
		)
		on bBMMANModeDropdown selected i do bBMMANModeValue = i
		
		group "VrayTriplanarTex"
		(
		checkbox bBMMANDoScaleCheckbox "Do Scale?" checked:bBMMANDoScaleValue align:#left
		spinner bBMMANScaleSpinner "Scale: " range:[0,10000,bBMMANScaleValue] fieldWidth:50 type:#float align:#right
		checkbox bBMMANDoBlendCheckbox "Do Blend?" checked:bBMMANDoBlendValue align:#left
		spinner bBMMANBlendSpinner "Blend: " range:[0.0,1.0,bBMMANBlendValue] fieldWidth:50 type:#float align:#right
		checkbox bBMMANDoSpaceCheckbox "Do Space?" checked:bBMMANDoSpaceValue align:#left
		label label1 "Space:" offset:[30,3] across:2
		dropdownlist bBMMANSpaceDropdown "" items:#("Local object", "Node") selection:bBMMANSpaceValue align:#right width:150
		pickbutton bBMMANPickObject "Pick The Node" width:150 toolTip:"Pick The Node" align:#right
		checkbox bBMMANDoRandTexOffsetCheckbox "Do Rand Tex Offset?" checked:bBMMANDoRandTexOffsetValue align:#left
		checkbox bBMMANRandTexOffsetCheckbox "Rand Tex Offset" checked:bBMMANRandTexOffsetValue align:#right
		)
		
		on bBMMANDoScaleCheckbox changed state do 
			(
			bBMMANDoScaleValue = state
			bBMMANScaleSpinner.enabled = state
			)
		on bBMMANScaleSpinner changed state do bBMMANScaleValue = state
		on bBMMANDoBlendCheckbox changed state do 
			(
			bBMMANDoBlendValue = state
			bBMMANBlendSpinner.enabled = state
			)
		on bBMMANBlendSpinner changed state do bBMMANBlendValue = state
		on bBMMANDoSpaceCheckbox changed state do 
			(
			bBMMANDoSpaceValue = state
			label1.enabled = state
			bBMMANSpaceDropdown.enabled = state
			bBMMANPickObject.enabled = state
			)
		on bBMMANSpaceDropdown selected i do bBMMANSpaceValue = i
		on bBMMANPickObject picked obj do 
			(
			if obj == undefined then 
				(
				bBMMANPickObject.text = "Pick The Node"
				)
			else
				(
				bBMMANNodeObject = obj
				bBMMANPickObject.text = obj.name
				)
			)
		on bBMMANDoRandTexOffsetCheckbox changed state do 
			(
			bBMMANDoRandTexOffsetValue = state
			bBMMANRandTexOffsetCheckbox.enabled = state
			)
		on bBMMANRandTexOffsetCheckbox changed state do 
			(
			bBMMANRandTexOffsetValue = state
			)
		
		button bBMMANDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,284]
		on bBMMANDoButton pressed do bBMMANDo()
		button bBMMANApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,284]
		on bBMMANApplyButton pressed do bBMMANApply()
		button bBMMANHelpButton "Help" width:70 toolTip:"Help" pos:[149,284]
		on bBMMANHelpButton pressed do bBMMANHelp()
		button bBMMANSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,284]
		on bBMMANSaveDefButton pressed do bBMMANSaveDef()
		
		on bBMMANRollout open do
			(
			bBMMANScaleSpinner.enabled = bBMMANDoScaleValue
			bBMMANBlendSpinner.enabled = bBMMANDoBlendValue
			label1.enabled = bBMMANDoSpaceValue
			bBMMANSpaceDropdown.enabled = bBMMANDoSpaceValue
			bBMMANPickObject.enabled = bBMMANDoSpaceValue
			bBMMANRandTexOffsetCheckbox.enabled = bBMMANDoRandTexOffsetValue
			)
		)
	)
)
-------------------------------------------------------------------------------