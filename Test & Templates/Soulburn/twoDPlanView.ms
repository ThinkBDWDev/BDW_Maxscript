-------------------------------------------------------------------------------
-- twoDPlanView.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.03
-- Created On: 11/23/06
-- Modified On: 11/29/11
-- tested using Max 2011
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Creates an orthogonal 2D Plan view of your scene, perfect for creating 2d
-- elements using max's tools.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version of the script. Hit Do. Now you have a camera from the top
-- view set to orthogonal.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Does a much better job of zooming to the extents of your scene.
--
-- v 1.02 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.03 Fixed a bug where the script would improperly calclate the size of 
-- your scene if it was far from the origin. Changed the cameras from target
-- to free.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global twoDPlanView
global twoDPlanViewDefaults
global twoDPlanViewUI

global tDPVCloseOpenUI

global tDPVDo
global tDPVApply
global tDPVHelp
global tDPVLoadDef
global tDPVSaveDef

global tDPVDefineUI
global tDPVRollout
global tDPVFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

tDPVAxisValue = 1
tDPVPosValue = [400,400]

-- Functions

fn twoDPlanView tDPVAxis = 
	(
	undo "twoDPlanView" on
		(
		w = renderWidth as float
		h = renderHeight as float
		sceneBoundingBox = sLibGetCollectionBBox $*
		sceneCenter = [(sceneBoundingBox[1].x + sceneBoundingBox[2].x)/2, (sceneBoundingBox[1].y + sceneBoundingBox[2].y)/2, (sceneBoundingBox[1].z + sceneBoundingBox[2].z)/2]
		xLength =  abs(sceneBoundingBox[2].x-sceneBoundingBox[1].x)
		yLength =  abs(sceneBoundingBox[2].y-sceneBoundingBox[1].y)
		zLength =  abs(sceneBoundingBox[2].z-sceneBoundingBox[1].z)

		-- Top
		if tDPVAxis == 1 then
			(
			if xLength <= 0 or yLength <= 0 then zoomFactor = 100
			else
				(
				if xLength > yLength then zoomFactor = (xLength/2) * 2.5
				else zoomFactor = (yLength/2) * (w/h) * 2.5
				)
			newCam = Targetcamera pos:[sceneCenter.x,sceneCenter.y,zoomFactor] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [sceneCenter.x,sceneCenter.y,0]))
			newCam.name = ("twoDPlanView_TopView")
			)
		-- Front
		else if tDPVAxis == 2 then
			(
			if xLength <= 0 or zLength <= 0 then zoomFactor = 100
			else
				(
				if xLength > zLength then zoomFactor = (xLength/2) * 2.5
				else zoomFactor = (zLength/2) * (w/h) * 2.5
				)
			newCam = Targetcamera pos:[sceneCenter.x,-zoomFactor,sceneCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [sceneCenter.x,0,sceneCenter.z]))
			newCam.name = ("twoDPlanView_FrontView")
			)
		-- Side
		else if tDPVAxis == 3 then
			(
			if yLength <= 0 or zLength <= 0 then zoomFactor = 100
			else
				(
				if yLength > zLength then zoomFactor = (yLength/2) * 2.5
				else zoomFactor = (zLength/2) * (w/h) * 2.5
				)
			newCam = Targetcamera pos:[zoomFactor,sceneCenter.y,sceneCenter.z] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,sceneCenter.y,sceneCenter.z]))
			newCam.name = ("twoDPlanView_SideView")
			)
		newCam.orthoProjection = true
		newCam.type = #free
		newCam.target_Distance = zoomFactor
		
		viewport.setCamera newCam
		displaySafeFrames = true
		)
	)
	
fn twoDPlanViewDefaults = 
	(
	tDPVLoadDef()
	twoDPlanView tDPVAxisValue
	)
	
fn twoDPlanViewUI = 
	(
	tDPVLoadDef()
	tDPVCloseOpenUI tDPVPosValue
	)

fn tDPVCloseOpenUI pos = 
	(
	if tDPVFloater != undefined then CloseRolloutFloater tDPVFloater
	tDPVDefineUI()
	tDPVFloater = newRolloutFloater "twoDPlanView v1.03" 310 91 pos.x pos.y
	addRollout tDPVRollout tDPVFloater
	)

fn tDPVDo = 
	(
	twoDPlanView tDPVAxisValue
	if tDPVFloater != undefined then CloseRolloutFloater tDPVFloater
	)

fn tDPVApply = 
	(
	twoDPlanView tDPVAxisValue
	)
	
fn tDPVHelp = 
	(
	sLibSSPrintHelp "twoDPlanView"
	)
	
fn tDPVLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	tDPVInputFilename = presetDir + "twoDPlanView.ini"
	if (sLibFileExist tDPVInputFilename == true) then
		(
		tDPVActionValue = execute (getINISetting tDPVInputFilename "twoDPlanView" "tDPVAxisValue")
		tDPVPosValue = execute (getINISetting tDPVInputFilename "twoDPlanView" "tDPVPosValue")
		
		if tDPVActionValue == OK then tDPVAxisValue = 1
		if tDPVPosValue == OK then tDPVPosValue = [400,400]
		)
	else
		(
		tDPVAxisValue = 1
		tDPVPosValue = [400,400]
		)
	)
	
fn tDPVSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	tDPVOutputFilename = presetDir + "twoDPlanView.ini"
	if (sLibFileExist tDPVOutputFilename == true) then deleteFile tDPVOutputFilename
	setINISetting tDPVOutputFilename "twoDPlanView" "tDPVAxisValue" (tDPVAxisValue as string)
	setINISetting tDPVOutputFilename "twoDPlanView" "tDPVPosValue" (tDPVFloater.pos as string)
	)

-- UI

fn tDPVDefineUI = 
	(
	rollout tDPVRollout "twoDPlanView"
		(
		label label1 "Axis:" pos:[10,10]
		dropdownlist tDPVAxisDropdown "" items:#("Top View", "Front View", "Side View") selection:tDPVAxisValue pos:[50,7] width:237
		on tDPVAxisDropdown selected i do tDPVAxisValue = i

		button tDPVDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on tDPVDoButton pressed do tDPVDo()
		button tDPVApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on tDPVApplyButton pressed do tDPVApply()
		button tDPVHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on tDPVHelpButton pressed do tDPVHelp()
		button tDPVSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on tDPVSaveDefButton pressed do tDPVSaveDef()
		)
	)
)
-------------------------------------------------------------------------------