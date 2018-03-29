-------------------------------------------------------------------------------
-- groupWithPoint.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.06
-- Created On: 10/15/05
-- Modified On: 10/20/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Takes selected objects and groups or ungroups them by linking them to a 
-- point helper instead of using the max group method. Very similar to the way
-- maya handles grouping.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a bunch of objects. Run the UI version of the script. Hit Do. Your objects
-- are now linked to a dummy that is placed at the center of your objects.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added some new code to more cleanly open and close the UI.
--
-- v 1.02 Added a spinner to make the point size some percentage of the 
-- max boundingbox of your selection.
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.04 Fixed an issue where the script did the wrong thing if you tried to Group
-- a Group. And tries to be a little smarter about grouping inside a 
-- hierarchy.
--
-- v 1.05 The Hierarchy smarts mentionned in my last fix ended up causing a lot of 
-- problems so I've simplified the functionality so at least it returns
-- consistent results.
--
-- v 1.06 Added option to not select the resulting point helper. Added some
-- options on what to do if your selected objects have existing hierarchy.
-- Cleaned up a lot of code.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global groupWithPoint
global groupWithPointDefaults
global groupWithPointUI

global gWPCloseOpenUI

global gWPDo
global gWPApply
global gWPHelp
global gWPLoadDef
global gWPSaveDef

global gWPDefineUI
global gWPRollout
global gWPFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

gWPModeValue = 1
gWPSizePercentageValue = 100
gWPSelectGroupValue = true
gWPHierarchyValue = 1
gWPPosValue = [400,400]

-- Functions

fn groupWithPoint gWPMode gWPSizePercentage gWPSelectGroup gWPHierarchy = 
	(
	gWPPoint = #()	
	
	undo "groupWithPoint" on
		(
		-- Group
		if gWPMode == 1 then
			(
			if selection.count < 1 then MessageBox "Please select at least 1 object." title:"groupWithPoint"
			else
				(
				-- select objects
				objs = for i in selection collect i

				-- setup point
				myPoint = Point box:on cross_radius:10 name:(uniquename "groupWithPoint")
				select objs
				
				-- find size of point
				bBoxSize = sLibGetCollectionBBox objs
				bBoxCenter = sLibGetCollectionBBoxCenter objs
				sizeX = abs (bBoxSize[2].x - bBoxSize[1].x)
				sizeY = abs (bBoxSize[2].y - bBoxSize[1].y)
				sizeZ = abs (bBoxSize[2].z - bBoxSize[1].z)
				myPoint.size = abs (2*(amax #(sizeX, sizeY, sizeZ))*(gWPSizePercentage*0.01))
				myPoint.pos = bBoxCenter
				
				-- remove group members
				objsNoGroup = #()
				for i in objs do (if isGroupMember i == false then append objsNoGroup i)

				-- parenting
				if gWPHierarchy == 1 then 
					(
					for i in objsNoGroup do i.parent = myPoint
					)
				else if gWPHierarchy == 2 then 
					(
					for i in (sLibFindParentsInObjs objsNoGroup) do i.parent = myPoint
					)
				else if gWPHierarchy == 3 then 
					(
					for i in (sLibFindParentsOfObjs objsNoGroup) do i.parent = myPoint
					)

				-- select point
				if gWPSelectGroup == true then (select myPoint)
				gWPPoint = myPoint
				)
			)
		-- Ungroup
		else
			(
			if selection.count == 1 then
				(
				if classof $ == point then
					(
					for i in $.children do
						(
						if classof $.parent == point then i.parent = $.parent else
						i.parent == undefined						
						)
					delete $
					)
				)
			)
		)
	return #(gWPPoint)
	)

fn groupWithPointDefaults = 
	(
	gWPLoadDef()
	groupWithPoint gWPModeValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue
	)
	
fn groupWithPointUI = 
	(
	gWPLoadDef()
	gWPCloseOpenUI gWPPosValue
	)

fn gWPCloseOpenUI pos = 
	(
	if gWPFloater != undefined then CloseRolloutFloater gWPFloater
	gWPDefineUI()
	gWPFloater = newRolloutFloater "groupWithPoint v1.06" 166 183 pos.x pos.y
	addRollout gWPRollout gWPFloater
	)

fn gWPDo = 
	(
	groupWithPoint gWPModeValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue
	if gWPFloater != undefined then CloseRolloutFloater gWPFloater
	)

fn gWPApply = 
	(
	groupWithPoint gWPModeValue gWPSizePercentageValue gWPSelectGroupValue gWPHierarchyValue
	)
	
fn gWPHelp = 
	(
	sLibSSPrintHelp "groupWithPoint"
	)
	
fn gWPLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gWPInputFilename = presetDir + "groupWithPoint.ini"
	if (sLibFileExist gWPInputFilename == true) then
		(
		gWPModeValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPModeValue")
		gWPSizePercentageValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPSizePercentageValue")
		gWPSelectGroupValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPSelectGroupValue")
		gWPHierarchyValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPHierarchyValue")
		gWPPosValue = execute (getINISetting gWPInputFilename "groupWithPoint" "gWPPosValue")
		
		if gWPModeValue == OK then gWPModeValue = 1
		if gWPSizePercentageValue == OK then gWPSizePercentageValue = 100
		if gWPSelectGroupValue == OK then gWPSelectGroupValue = true
		if gWPHierarchyValue == OK then gWPHierarchyValue = 1
		if gWPPosValue == OK then gWPPosValue = [400,400]
		)
	else
		(
		gWPModeValue = 1
		gWPSizePercentageValue = 100
		gWPSelectGroupValue = true
		gWPHierarchyValue = 1
		gWPPosValue = [400,400]
		)
	)
	
fn gWPSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gWPOutputFilename = presetDir + "groupWithPoint.ini"
	if (sLibFileExist gWPOutputFilename == true) then deleteFile gWPOutputFilename
	setINISetting gWPOutputFilename "groupWithPoint" "gWPModeValue" (gWPModeValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPSizePercentageValue" (gWPSizePercentageValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPSelectGroupValue" (gWPSelectGroupValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPHierarchyValue" (gWPHierarchyValue as string)
	setINISetting gWPOutputFilename "groupWithPoint" "gWPPosValue" (gWPFloater.pos as string)
	)

-- UI

fn gWPDefineUI = 
	(
	rollout gWPRollout "groupWithPoint"
		(
		dropdownlist gWPModeDropdown "" items:#("Group", "UnGroup") selection:gWPModeValue width:130
		on gWPModeDropdown selected i do gWPModeValue = i
		
		spinner gWPSizePercentageSpinner "Size %: " range:[0,10000,gWPSizePercentageValue] fieldWidth:50 type:#integer align:#left
		on gWPSizePercentageSpinner changed val do gWPSizePercentageValue = val

		checkbox gWPSelectGroupCheckbox "Select Point Helper?" checked:gWPSelectGroupValue
		on gWPSelectGroupCheckbox changed state do gWPSelectGroupValue = state	

		dropdownlist gWPHierarchyDropdown "" items:#("Remove Hierarchy", "Keep Hierarchy in Selection", "Keep All Hierarchy") selection:gWPHierarchyValue width:130
		on gWPHierarchyDropdown selected i do gWPHierarchyValue = i

		button gWPDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,103]
		on gWPDoButton pressed do gWPDo()
		button gWPApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,103]
		on gWPApplyButton pressed do gWPApply()
		button gWPHelpButton "Help" width:70 toolTip:"Help" pos:[5,127]
		on gWPHelpButton pressed do gWPHelp()
		button gWPSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[77,127]
		on gWPSaveDefButton pressed do gWPSaveDef()
		)
	)
)
-------------------------------------------------------------------------------