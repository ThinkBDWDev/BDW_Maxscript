-------------------------------------------------------------------------------
-- cornerEdgeToVertexMap.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.13
-- Created On: 03/14/08
-- Modified On: 10/20/15
-- tested using Max 2016
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Selects edges of a mesh based on the angle between adjacent faces, and then 
-- converts them to a vertex map. For example, you can select all the corner 
-- edges of a mesh and then convert them to a vertex map for use with a bump 
-- map or a mask to blend between textures.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a cube with segments set to 3 in all 3 directions. Collapse to Editable
-- Poly. Run the UI version of the script. Set low value to 80 degrees. Set 
-- high value to 90. Hit Do. All the vertexes along the sharp edges will now 
-- be black, and the rest white.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- Doesn't support Editpoly since editpoly can't affect the vertex color of 
-- your mesh.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added a few new modes for capturing open border edges, or just 
-- selecting all edges. Replaced the Close button with a Help button. Use 
-- the X button to Close the Floater.
--
-- v 1.02 Fixed a bug that would cause the script to crash when working on
-- non Editable Poly objects.
--
-- v 1.10 Redid the interface. Can now select concave and convex edges 
-- seperately. Colors can now be defined per edge type.
--
-- v 1.11 Fixed a bug where the border edge color always defaulted to black. 
-- Added ability to turn off the base color.
--
-- v 1.12 Fixed a bug where polyOp.getEdgeFaces returns undefined on some
-- meshes and then crashes the script. Now the script will continue to 
-- function even if it runs into these situations. Set the defaults to
-- turn off the Border Edges by default. Can be turned back on if you wish.
--
-- v 1.13 Added better error messages.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global cornerEdgeToVertexMap
global cornerEdgeToVertexMapDefaults
global cornerEdgeToVertexMapUI

global cETVMCloseOpenUI

global cETVMgetAngleBetweenFaces

global cETVMDo
global cETVMApply
global cETVMHelp
global cETVMLoadDef
global cETVMSaveDef

global cETVMDefineUI
global cETVMRollout
global cETVMFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

cETVMBaseValue = true
cETVMBaseColorValue = color 255 255 255

cETVMSelectBorderValue = false
cETVMSelectBorderColorValue = color 0 0 0

cETVMSelectByConvexAngleValue = true
cETVMConvexLowValue = 265
cETVMConvexHighValue = 275
cETVMSelectByConvexAngleColorValue = color 0 0 0

cETVMSelectByConcaveAngleValue = true
cETVMConcaveLowValue = 85
cETVMConcaveHighValue = 95
cETVMSelectByConcaveAngleColorValue = color 0 0 0

cETVMDisplayValue = true
cETVMPosValue = [400,400]

-- Functions

fn cornerEdgeToVertexMap cETVMBase cETVMBaseColor cETVMSelectBorder cETVMSelectBorderColor cETVMSelectByConvexAngle cETVMConvexLow cETVMConvexHigh cETVMSelectByConvexAngleColor cETVMSelectByConcaveAngle cETVMConcaveLow cETVMConcaveHigh cETVMSelectByConcaveAngleColor cETVMDisplay = 
	(
	undo "cornerEdgeToVertexMap" on
		(
		-- swap high and low
		if cETVMConvexLow > cETVMConvexHigh then (ConvexLowVal = cETVMConvexHigh;ConvexHighVal = cETVMConvexLow)
		else (ConvexLowVal = cETVMConvexLow;ConvexHighVal = cETVMConvexHigh)
		if cETVMConcaveLow > cETVMConcaveHigh then (ConcaveLowVal = cETVMConcaveHigh;ConcaveHighVal = cETVMConcaveLow)
		else (ConcaveLowVal = cETVMConcaveLow;ConcaveHighVal = cETVMConcaveHigh)
		
		objs = for i in selection collect i
		setCommandPanelTaskMode #modify
		objectsIgnored = 0
		for obj in objs do
			(
			if (classof obj.baseobject) == Editable_Poly then
				(
				-- Variables
				finalAllEdges = #()
				finalBorderEdges = #()
				finalConvexAngleEdges = #()
				finalConcaveAngleEdges = #()
				finalVerts = #()

				-- Base
				if cETVMBase == true then
					(
					numEdges = polyOp.getNumEdges obj.baseobject
					for i = 1 to numEdges do append finalAllEdges i
					)				
				polyOp.setEdgeSelection obj.baseobject (finalAllEdges as bitarray)
				obj.baseobject.ConvertSelection #Edge #Vertex
				finalVerts = (polyOp.getvertselection obj.baseobject) as array
				polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cETVMBaseColor
					
				-- Border Edges
				if cETVMSelectBorder == true then
					(
					finalBorderEdges = (polyop.getOpenEdges obj.baseobject) as array
					)
				polyOp.setEdgeSelection obj.baseobject (finalBorderEdges as bitarray)
				obj.baseobject.ConvertSelection #Edge #Vertex
				finalVerts = (polyOp.getvertselection obj.baseobject) as array
				polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cETVMSelectBorderColor

				-- Convex Edges
				if cETVMSelectByConvexAngle == true then
					(				
					numEdges = polyOp.getNumEdges obj.baseobject
					for i = 1 to numEdges do
						(
						a = polyOp.getEdgeFaces obj.baseobject i
						if a != undefined then
							(
							if a.count == 2 then
								(
								theAngle = cETVMgetAngleBetweenFaces (polyOp.getFaceNormal obj.baseobject a[1]) (polyOp.getFaceNormal obj.baseobject a[2]) (polyOp.getFaceCenter obj.baseobject a[1]) (polyOp.getFaceCenter obj.baseobject a[2])
								if theAngle >= (ConvexLowVal - 0.001) and theAngle <= (ConvexHighVal + 0.001) then append finalConvexAngleEdges i
								)
							)
						)
					)
				polyOp.setEdgeSelection obj.baseobject (finalConvexAngleEdges as bitarray)
				obj.baseobject.ConvertSelection #Edge #Vertex
				finalVerts = (polyOp.getvertselection obj.baseobject) as array
				polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cETVMSelectByConvexAngleColor
					
				-- Concave Edges
				if cETVMSelectByConcaveAngle == true then
					(				
					numEdges = polyOp.getNumEdges obj.baseobject
					for i = 1 to numEdges do
						(
						a = polyOp.getEdgeFaces obj.baseobject i
						if a != undefined then
							(
							if a.count == 2 then
								(
								theAngle = cETVMgetAngleBetweenFaces (polyOp.getFaceNormal obj.baseobject a[1]) (polyOp.getFaceNormal obj.baseobject a[2]) (polyOp.getFaceCenter obj.baseobject a[1]) (polyOp.getFaceCenter obj.baseobject a[2])
								if theAngle >= (ConcaveLowVal - 0.001) and theAngle <= (ConcaveHighVal + 0.001) then append finalConcaveAngleEdges i
								)
							)
						)
					)
				polyOp.setEdgeSelection obj.baseobject (finalConcaveAngleEdges as bitarray)
				obj.baseobject.ConvertSelection #Edge #Vertex
				finalVerts = (polyOp.getvertselection obj.baseobject) as array
				polyop.setVertColor obj.baseobject 0 (finalVerts as bitarray) cETVMSelectByConcaveAngleColor
					
				-- display the vertex map
				if cETVMDisplay == true then obj.showVertexColors = true
				)
			else objectsIgnored += 1
			)
		if objectsIgnored != 0 then 
			(
			mainText = "The cornerEdgeToVertexMap script only works on Editable Poly objects. " + (objectsIgnored as string) + " object(s) were ignored."
			MessageBox mainText title:"cornerEdgeToVertexMap"
			)
		)
	)
	
fn cornerEdgeToVertexMapDefaults = 
	(
	cETVMLoadDef()
	cornerEdgeToVertexMap cETVMBase cETVMBaseColorValue cETVMSelectBorderValue cETVMSelectBorderColorValue cETVMSelectByConvexAngleValue cETVMConvexLowValue cETVMConvexHighValue cETVMSelectByConvexAngleColorValue cETVMSelectByConcaveAngleValue cETVMConcaveLowValue cETVMConcaveHighValue cETVMSelectByConcaveAngleColorValue cETVMDisplayValue
	)
	
fn cornerEdgeToVertexMapUI = 
	(
	cETVMLoadDef()
	cETVMCloseOpenUI cETVMPosValue
	)

fn cETVMCloseOpenUI pos = 
	(
	if cETVMFloater != undefined then CloseRolloutFloater cETVMFloater
	cETVMDefineUI()
	cETVMFloater = newRolloutFloater "cornerEdgeToVertexMap v1.13" 230 480 pos.x pos.y
	addRollout cETVMRollout cETVMFloater
	)

fn cETVMgetAngleBetweenFaces normal1 normal2 center1 center2 =
	(
	local face1Matrix = translate (matrixFromNormal normal1) center1
	local face2Coord = (center2 * (inverse face1Matrix)).z
	local normAngle = acos(dot (normalize normal1) (normalize normal2))
	if face2Coord < 0 do normAngle = 360 - normAngle
	normAngle 
	)

fn cETVMDo = 
	(
	cornerEdgeToVertexMap cETVMBaseValue cETVMBaseColorValue cETVMSelectBorderValue cETVMSelectBorderColorValue cETVMSelectByConvexAngleValue cETVMConvexLowValue cETVMConvexHighValue cETVMSelectByConvexAngleColorValue cETVMSelectByConcaveAngleValue cETVMConcaveLowValue cETVMConcaveHighValue cETVMSelectByConcaveAngleColorValue cETVMDisplayValue
	if cETVMFloater != undefined then CloseRolloutFloater cETVMFloater
	)

fn cETVMApply = 
	(
	cornerEdgeToVertexMap cETVMBaseValue cETVMBaseColorValue cETVMSelectBorderValue cETVMSelectBorderColorValue cETVMSelectByConvexAngleValue cETVMConvexLowValue cETVMConvexHighValue cETVMSelectByConvexAngleColorValue cETVMSelectByConcaveAngleValue cETVMConcaveLowValue cETVMConcaveHighValue cETVMSelectByConcaveAngleColorValue cETVMDisplayValue
	)
	
fn cETVMHelp = 
	(
	sLibSSPrintHelp "cornerEdgeToVertexMap"
	)
	
fn cETVMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cETVMInputFilename = presetDir + "cornerEdgeToVertexMap.ini"
	if (sLibFileExist cETVMInputFilename == true) then
		(
		cETVMBaseValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMBaseValue")
		cETVMBaseColorValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMBaseColorValue")
		cETVMSelectBorderValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectBorderValue")
		cETVMSelectBorderColorValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectBorderColorValue")
		cETVMSelectByConvexAngleValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectByConvexAngleValue")
		cETVMConvexLowValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMConvexLowValue")
		cETVMConvexHighValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMConvexHighValue")
		cETVMSelectByConvexAngleColorValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectByConvexAngleColorValue")
		cETVMSelectByConcaveAngleValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectByConcaveAngleValue")
		cETVMConcaveLowValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMConcaveLowValue")
		cETVMConcaveHighValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMConcaveHighValue")
		cETVMSelectByConcaveAngleColorValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMSelectByConcaveAngleColorValue")
		cETVMDisplayValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMDisplayValue")
		cETVMPosValue = execute (getINISetting cETVMInputFilename "cornerEdgeToVertexMap" "cETVMPosValue")
		
		if cETVMBaseValue == OK then cETVMBaseValue = true
		if cETVMBaseColorValue == OK then cETVMBaseColorValue = color 255 255 255
		if cETVMSelectBorderValue == OK then cETVMSelectBorderValue = false
		if cETVMSelectBorderColorValue == OK then cETVMSelectBorderColorValue = color 0 0 0
		if cETVMSelectByConvexAngleValue == OK then cETVMSelectByConvexAngleValue = true
		if cETVMConvexLowValue == OK then cETVMConvexLowValue = 265
		if cETVMConvexHighValue == OK then cETVMConvexHighValue = 275
		if cETVMSelectByConvexAngleColorValue == OK then cETVMSelectByConvexAngleColorValue = color 0 0 0
		if cETVMSelectByConcaveAngleValue == OK then cETVMSelectByConcaveAngleValue = true
		if cETVMConcaveLowValue == OK then cETVMConcaveLowValue = 85
		if cETVMConcaveHighValue == OK then cETVMConcaveHighValue = 95
		if cETVMSelectByConcaveAngleColorValue == OK then cETVMSelectByConcaveAngleColorValue = color 0 0 0
		if cETVMDisplayValue == OK then cETVMDisplayValue = true
		if cETVMPosValue == OK then cETVMPosValue = [400,400]
		)
	else
		(
		cETVMBaseValue = true
		cETVMBaseColorValue = color 255 255 255
		cETVMSelectBorderValue = false
		cETVMSelectBorderColorValue = color 0 0 0
		cETVMSelectByConvexAngleValue = true
		cETVMConvexLowValue = 265
		cETVMConvexHighValue = 275
		cETVMSelectByConvexAngleColorValue = color 0 0 0
		cETVMSelectByConcaveAngleValue = true
		cETVMConcaveLowValue = 85
		cETVMConcaveHighValue = 95
		cETVMSelectByConcaveAngleColorValue = color 0 0 0
		cETVMDisplayValue = true
		cETVMPosValue = [400,400]
		)
	)
	
fn cETVMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cETVMOutputFilename = presetDir + "cornerEdgeToVertexMap.ini"
	if (sLibFileExist cETVMOutputFilename == true) then deleteFile cETVMOutputFilename
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMBaseValue" (cETVMBaseValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMBaseColorValue" (cETVMBaseColorValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectBorderValue" (cETVMSelectBorderValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectBorderColorValue" (cETVMSelectBorderColorValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectByConvexAngleValue" (cETVMSelectByConvexAngleValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMConvexLowValue" (cETVMConvexLowValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMConvexHighValue" (cETVMConvexHighValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectByConvexAngleColorValue" (cETVMSelectByConvexAngleColorValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectByConcaveAngleValue" (cETVMSelectByConcaveAngleValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMConcaveLowValue" (cETVMConcaveLowValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMConcaveHighValue" (cETVMConcaveHighValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMSelectByConcaveAngleColorValue" (cETVMSelectByConcaveAngleColorValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMDisplayValue" (cETVMDisplayValue as string)
	setINISetting cETVMOutputFilename "cornerEdgeToVertexMap" "cETVMPosValue" (cETVMFloater.pos as string)
	)

-- UI

fn cETVMDefineUI = 
	(
	rollout cETVMRollout "cornerEdgeToVertexMap"
		(
		group "Base Color"
		(
		checkbox cETVMBaseCheckbox "Add Base Color?" checked:cETVMBaseValue align:#right
		colorpicker cETVMBaseColorPicker "Base Color:" color:cETVMBaseColorValue modal:false align:#right fieldwidth:40 height:15
		)
		on cETVMBaseCheckbox changed state do 
			(
			cETVMBaseValue = state
			cETVMBaseColorPicker.enabled = state
			)
		on cETVMBaseColorPicker changed val do cETVMBaseColorValue = val

		group "Border Edges"
		(
		checkbox cETVMSelectBorderCheckbox "Select Border Edges?" checked:cETVMSelectBorderValue align:#right
		colorpicker cETVMSelectBorderColorPicker "Color:" color:cETVMSelectBorderColorValue modal:false align:#right fieldwidth:40 height:15 enabled:cETVMSelectBorderValue
		)
		on cETVMSelectBorderCheckbox changed state do 
			(
			cETVMSelectBorderValue = state
			cETVMSelectBorderColorPicker.enabled = state
			)
		on cETVMSelectBorderColorPicker changed val do cETVMSelectBorderColorValue = val

		group "Convex Edges"
		(
		checkbox cETVMSelectByConvexAngleCheckbox "Convex Angle:" checked:cETVMSelectByConvexAngleValue align:#right
		spinner cETVMConvexLowSpinner "Low Angle: " range:[0,360,cETVMConvexLowValue] fieldWidth:55 type:#float align:#right enabled:cETVMSelectByConvexAngleValue
		spinner cETVMConvexHighSpinner "High Angle: " range:[0,360,cETVMConvexHighValue] fieldWidth:55 type:#float align:#right enabled:cETVMSelectByConvexAngleValue
		colorpicker cETVMSelectByConvexAngleColorPicker "Color:" color:cETVMSelectByConvexAngleColorValue modal:false align:#right fieldwidth:40 height:15 enabled:cETVMSelectByConvexAngleValue
		)
		on cETVMSelectByConvexAngleCheckbox changed state do 
			(
			cETVMSelectByConvexAngleValue = state
			cETVMConvexLowSpinner.enabled = state
			cETVMConvexHighSpinner.enabled = state
			cETVMSelectByConvexAngleColorPicker.enabled = state			
			)
		on cETVMConvexLowSpinner changed val do cETVMConvexLowValue = val
		on cETVMConvexHighSpinner changed val do cETVMConvexHighValue = val
		on cETVMSelectByConvexAngleColorPicker changed val do cETVMSelectByConvexAngleColorValue = val

		group "Concave Edges"
		(
		checkbox cETVMSelectByConcaveAngleCheckbox "Concave Angle:" checked:cETVMSelectByConcaveAngleValue align:#right
		spinner cETVMConcaveLowSpinner "Low Angle: " range:[0,360,cETVMConcaveLowValue] fieldWidth:55 type:#float align:#right enabled:cETVMSelectByConcaveAngleValue
		spinner cETVMConcaveHighSpinner "High Angle: " range:[0,360,cETVMConcaveHighValue] fieldWidth:55 type:#float align:#right enabled:cETVMSelectByConcaveAngleValue
		colorpicker cETVMSelectByConcaveAngleColorPicker "Color:" color:cETVMSelectByConcaveAngleColorValue modal:false align:#right fieldwidth:40 height:15 enabled:cETVMSelectByConcaveAngleValue
		)
		on cETVMSelectByConcaveAngleCheckbox changed state do 
			(
			cETVMSelectByConcaveAngleValue = state
			cETVMConcaveLowSpinner.enabled = state
			cETVMConcaveHighSpinner.enabled = state
			cETVMSelectByConcaveAngleColorPicker.enabled = state
			)
		on cETVMConcaveLowSpinner changed val do cETVMConcaveLowValue = val
		on cETVMConcaveHighSpinner changed val do cETVMConcaveHighValue = val
		on cETVMSelectByConcaveAngleColorPicker changed val do cETVMSelectByConcaveAngleColorValue = val

		group "Display Colors"
		(
		checkbox cETVMDisplayCheckbox "Display Vertex Colors?" checked:cETVMDisplayValue align:#right
		)
		
		on cETVMDisplayCheckbox changed state do cETVMDisplayValue = state

		button cETVMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[35,398]
		on cETVMDoButton pressed do cETVMDo()
		button cETVMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[107,398]
		on cETVMApplyButton pressed do cETVMApply()
		button cETVMHelpButton "Help" width:70 toolTip:"Help" pos:[35,424]
		on cETVMHelpButton pressed do cETVMHelp()
		button cETVMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[107,424]
		on cETVMSaveDefButton pressed do cETVMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------