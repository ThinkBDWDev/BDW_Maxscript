-------------------------------------------------------------------------------
-- pipeMaker.ms
-- By Neil Blevins (neil@soulburn3d.com)
-- v 1.00
-- Created On: 09/23/14
-- Modified On: 01/30/15
-- tested using Max 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Creates a big mess of pipes. This script uses a lot of code from vidarn's 
-- "Pipe Dream" script (www.creativetools.se), I've taken the basics of his 
-- script and rebuilt it to do pipes that have more options on how dense the
-- final geometry is, the full volume the pipes inhabit, etc. Maybe you'll find 
-- my changes useful too.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Open the ui version of the script, hit "Do". It will create a pipe bundle 
-- with the default parameters.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global pipeMaker
global pipeMakerDefaults
global pipeMakerUI

global pMACloseOpenUI

global pMAChamferKnot
global pMAMakeJoint
global pMAPlaceJoint

global pMADo
global pMAApply
global pMAHelp
global pMALoadDef
global pMASaveDef

global pMADefineUI
global pMARollout
global pMAFloater

-- Includes

include "$scripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global pMALastPipeBundle = #()

pMAPipeNumberValue = 50
pMAHeightValue = 2000
pMAWidthValue = 2000
pMADepthValue = 500
pMAComplexityHeightValue = 4
pMAComplexityWidthValue = 4
pMAStepsValue = 5
pMAPipeTypePercentageValue = 50
pMAChamferTypePercentageValue = 50
pMARenderableValue = true
pMASidesValue = 8
pMASmoothValue = true
pMAThicknessMinValue = 10
pMAThicknessMaxValue = 40
pMAMultiPercentageValue = 15
pMAJointPercentageValue = 60
pMAJointDensityValue = 2
pMAPosValue = [400,400]

-- Functions

fn pipeMaker pMAPipeNumber pMAHeight pMAWidth pMADepth pMAComplexityHeight pMAComplexityWidth pMASteps pMAPipeTypePercentage pMAChamferTypePercentage pMARenderable pMASmooth pMASides pMAThicknessMin pMAThicknessMax pMAMultiPercentage pMAJointPercentage pMAJointDensity = 
	(
	-- Variables
	pMALastPipeBundle = #()
	local maxLength = [pMAWidth/pMAComplexityHeight, pMAHeight/pMAComplexityWidth,0]
	local z = 0
	local layerW = 0
	local oldR = 0
	
	-- Make Splines
	for i = 1 to pMAPipeNumber do 
		(
		-- Variables And Create Spline
		SplineThickness = random pMAThicknessMin pMAThicknessMax
		local obj = SplineShape pos:[0,0,0]
		obj.name = UniqueName "Pipe"
		addNewSpline obj
		local p = [0,0,0]
		addKnot obj 1 #corner #line p
		local dir = 1
		local minx = 0
		local maxx = 0
		local firstKnot = true
		local PipeType = 0
		local ChamferType = 0
		local offset = 0
		local chamferRadius = random (pMAHeight*0.005*1) (pMAHeight*0.005*6)

		-- PipeType (0 is straight, 1 is curved)
		a = (random 1 100) < pMAPipeTypePercentage
		if a == true then PipeType = 0 else PipeType = 1
		if PipeType == 0 then (offset = random (pMAHeight*0.005*1) (pMAHeight*0.005*10))

		-- Chamfer Type (0 is round, 1 is 45 degree angle straight)
		a = (random 1 100) < pMAChamferTypePercentage
		if a == true then ChamferType = 0 else ChamferType = 1
		if ChamferType == 0 then (chamferRadius = random (pMAHeight*0.005*4) (pMAHeight*0.005*10))

		-- Construct Spline
		while p[2] < pMAHeight-chamferRadius do 
			(
			if PipeType == 0 then 
				(
				local dir2 = 2
				local l = pMAHeight 
				local sOld = 1
				local s = 1
				)
			else 
				(
				local sign = 1 - 2*floor(random 0 1)
				local dir2 = 1+ mod (dir) 2
				local l = random (chamferRadius*3) maxLength[dir2]
				local sOld = s
				local s = case dir2 of
					(
					1: sign
					2: 1
					)
				)
			local pOld = [p[1],p[2],p[3]]
			p[dir2] = p[dir2] + l*s
			if p[1] < minx then (minx = p[1])
			if p[1] > maxx then (maxx = p[1])
			if p[2] > pMAHeight-chamferRadius then (p[2] = pMAHeight)
			if not firstKnot then (pMAChamferKnot obj chamferRadius pOld dir dir2 sOld s ChamferType)
			firstKnot = false
			dir = dir2
		)
		local w = maxx-minx + offset
		addKnot obj 1 #corner #line p
		if(w) > pMAWidth then (delete obj) 
		else 
			(
			local maxr = 350
			if chamferRadius*1.5 < maxr then (maxr = chamferRadius*1.5)
			local r = random 100 maxr
			if r > oldR then (oldR = r)
			obj.objectoffsetpos = [-minx,0,0]
			local posX = layerW
			layerW += w + r*2
			if layerW >= pMAWidth then 
				(
				z += r + oldR
				layerW = w  + r*2
				posX = 0
				oldR = r
				)
			
			-- Spline Placement
			obj.pos = [posX+r,(random 0 pMADepth),0]
			rotate obj (eulerangles 90 0 0)
			updateShape obj

			-- Spline Attributes
			append pMALastPipeBundle obj
			obj.wirecolor = color 50 50 50
			obj.baseobject.steps = pMASteps
			obj.baseobject.sides = pMASides
			obj.baseobject.mapCoords = true
			obj.baseobject.optimize = false
			obj.baseobject.adaptive = false
			obj.baseobject.thickness = SplineThickness
			obj.baseobject.render_thickness = SplineThickness

			if (random 1 100) > pMAMultiPercentage then 
				(
				-- Single Pipe
				obj.baseobject.renderable = pMARenderable
				obj.baseobject.DisplayRenderMesh = pMARenderable
				obj.baseobject.render_auto_smooth = true
				if pMASmooth == true then obj.baseobject.render_threshold = 90 else obj.baseobject.render_threshold = 0
				
				-- Add Joint
				if (random 1 100) < pMAJointPercentage then 
					(
					local jointStep = (((random 500 2000) / (curveLength obj))/pMAJointDensity)*(pMAHeight/2000)
					local joint = pMAMakeJoint r 1 "cylinder" SplineThickness pMASides
					local accum = 0
					while accum < 1 do 
						(
						local inst = instance joint name:(UniqueName "joint")
						inst.wirecolor = color 80 80 80
						pMAPlaceJoint obj inst accum
						accum  += jointStep
						append pMALastPipeBundle inst
						if pMASmooth == false then addmodifier inst (Smooth())
						)
					delete joint
					)
				)
			else
				(
				-- MultiPipe
				if pMARenderable != false then
					(
					obj.baseobject.renderable = false
					obj.baseobject.DisplayRenderMesh = false
					profileNum = random 2 3
					s = sweep()
					r2 = (SplineThickness)/(profileNum as float)
					local profile = splineshape pos:[0,0,0] name:"Profile"
					addAndWeld profile (convertToSplineShape (Circle radius:r2 pos:[-r2*(profileNum-1),0,0])) 0.0
					for i = 1 to profileNum-1 do (addAndWeld profile (convertToSplineShape (Circle radius:r2 pos:[r2*2*i-r2*(profileNum-1),0,0])) 0.0)
					profile.steps = ((1.0/8.0)*pMASides) as integer
					s.shapes[1] = profile
					s.customShape = 1
					addModifier obj s
					if pMASmooth == false then addmodifier obj (Smooth())
					delete profile
					)
				)
			)
		)
	completeRedraw()
	)
	
fn pipeMakerDefaults = 
	(
	pMALoadDef()
	pipeMaker pMAPipeNumberValue pMAHeightValue pMAWidthValue pMADepthValue pMAComplexityHeightValue pMAComplexityWidthValue pMAStepsValue pMAPipeTypePercentageValue pMAChamferTypePercentageValue pMARenderableValue pMASmoothValue pMASidesValue pMAThicknessMinValue pMAThicknessMaxValue pMAMultiPercentageValue pMAJointPercentageValue pMAJointDensityValue
	)
	
fn pipeMakerUI = 
	(
	pMALoadDef()
	pMACloseOpenUI pMAPosValue
	)

fn pMACloseOpenUI pos = 
	(
	if pMAFloater != undefined then CloseRolloutFloater pMAFloater
	pMADefineUI()
	pMAFloater = newRolloutFloater "pipeMaker v1.00" 200 573 pos.x pos.y
	addRollout pMARollout pMAFloater
	)

fn pMAChamferKnot spline width pos dir1 dir2 s1 s2 chamfertype = 
	(
	local p = [pos[1],pos[2],pos[3]]
	p[dir1] = p[dir1] - s1*width
	if chamfertype == 0 then
		(
		local t = [0,0,0]
		t[dir1] = -s1*width*0.75
		addknot spline 1 #bezier #curve p (p + t) (p - t)
		)
	else (addknot spline 1 #corner #line p)
	p = pos
	p[dir2] += s2*width
	if chamfertype == 0 then
		(
		local t = [0,0,0]
		t[dir2] = -s2*width*0.75
		addknot spline 1 #bezier #curve p (p + t) (p - t)
		)
	else (addknot spline 1 #corner #line p)
	)
	
fn pMAMakeJoint r profileNum type splinethickness mysides = 
	(
	local joint
	if type == "cylinder" then 
		(
		joint = Cylinder name:"joint" radius:0.5 height:1 heightsegs:3 capsegs:2 sides:mysides mapcoords:on pos:[0,0,0]
		local hght = ((splinethickness) * (random 0.3 2.5))
		local rad = ((splinethickness)+(splinethickness/5))
		joint.scale = [rad,rad,hght]
		--convertToPoly joint
		)
	return joint
	)

fn pMAPlaceJoint spline obj l = 
	(
	local p = lengthInterp spline 1 l
	obj.pos = p
	local t = lengthTangent spline 1 l
	local a = atan2 t[1] t[3]
	rotate obj (eulerangles 0 a 0)
	)

fn pMADo = 
	(
	pipeMaker pMAPipeNumberValue pMAHeightValue pMAWidthValue pMADepthValue pMAComplexityHeightValue pMAComplexityWidthValue pMAStepsValue pMAPipeTypePercentageValue pMAChamferTypePercentageValue pMARenderableValue pMASmoothValue pMASidesValue pMAThicknessMinValue pMAThicknessMaxValue pMAMultiPercentageValue pMAJointPercentageValue pMAJointDensityValue
	if pMAFloater != undefined then CloseRolloutFloater pMAFloater
	)

fn pMAApply = 
	(
	pipeMaker pMAPipeNumberValue pMAHeightValue pMAWidthValue pMADepthValue pMAComplexityHeightValue pMAComplexityWidthValue pMAStepsValue pMAPipeTypePercentageValue pMAChamferTypePercentageValue pMARenderableValue pMASmoothValue pMASidesValue pMAThicknessMinValue pMAThicknessMaxValue pMAMultiPercentageValue pMAJointPercentageValue pMAJointDensityValue
	)
	
fn pMAHelp = 
	(
	sLibSSPrintHelp "pipeMaker"
	)
	
fn pMALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pMAInputFilename = presetDir + "pipeMaker.ini"
	if (sLibFileExist pMAInputFilename == true) then
		(
		pMAPipeNumberValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAPipeNumberValue")
		pMAHeightValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAHeightValue")
		pMAWidthValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAWidthValue")
		pMADepthValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMADepthValue")
		pMAComplexityHeightValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAComplexityHeightValue")
		pMAComplexityWidthValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAComplexityWidthValue")
		pMAStepsValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAStepsValue")
		pMAPipeTypePercentageValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAPipeTypePercentageValue")
		pMAChamferTypePercentageValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAChamferTypePercentageValue")
		pMARenderableValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMARenderableValue")
		pMASidesValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMASidesValue")
		pMASmoothValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMASmoothValue")
		pMAThicknessMinValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAThicknessMinValue")
		pMAThicknessMaxValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAThicknessMaxValue")
		pMAMultiPercentageValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAMultiPercentageValue")
		pMAJointPercentageValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAJointPercentageValue")
		pMAJointDensityValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAJointDensityValue")
		pMAPosValue = execute (getINISetting pMAInputFilename "pipeMaker" "pMAPosValue")
		
		if pMAPipeNumberValue == OK then pMAPipeNumberValue = 50
		if pMAHeightValue == OK then pMAHeightValue = 2000
		if pMAWidthValue == OK then pMAWidthValue = 2000
		if pMADepthValue == OK then pMADepthValue = 500
		if pMAComplexityHeightValue == OK then pMAComplexityHeightValue = 4
		if pMAComplexityWidthValue == OK then pMAComplexityWidthValue = 4
		if pMAStepsValue == OK then pMAStepsValue = 5
		if pMAPipeTypePercentageValue == OK then pMAPipeTypePercentageValue = 50
		if pMAChamferTypePercentageValue == OK then pMAChamferTypePercentageValue = 50
		if pMARenderableValue == OK then pMARenderableValue = true
		if pMASidesValue == OK then pMASidesValue = 8
		if pMASmoothValue == OK then pMASmoothValue = true
		if pMAThicknessMinValue == OK then pMAThicknessMinValue = 10
		if pMAThicknessMaxValue == OK then pMAThicknessMaxValue = 40
		if pMAMultiPercentageValue == OK then pMAMultiPercentageValue = 15
		if pMAJointPercentageValue == OK then pMAJointPercentageValue = 60
		if pMAJointDensityValue == OK then pMAJointDensityValue = 2
		if pMAPosValue == OK then pMAPosValue = [400,400]
		)
	else
		(
		pMAPipeNumberValue = 50
		pMAHeightValue = 2000
		pMAWidthValue = 2000
		pMADepthValue = 500
		pMAComplexityHeightValue = 4
		pMAComplexityWidthValue = 4
		pMAStepsValue = 5
		pMAPipeTypePercentageValue = 50
		pMAChamferTypePercentageValue = 50
		pMARenderableValue = true
		pMASidesValue = 8
		pMASmoothValue = true
		pMAThicknessMinValue = 10
		pMAThicknessMaxValue = 40
		pMAMultiPercentageValue = 15
		pMAJointPercentageValue = 60
		pMAJointDensityValue = 2
		pMAPosValue = [400,400]
		)
	)
	
fn pMASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pMAOutputFilename = presetDir + "pipeMaker.ini"
	if (sLibFileExist pMAOutputFilename == true) then deleteFile pMAOutputFilename
	setINISetting pMAOutputFilename "pipeMaker" "pMAPipeNumberValue" (pMAPipeNumberValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAHeightValue" (pMAHeightValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAWidthValue" (pMAWidthValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMADepthValue" (pMADepthValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAComplexityHeightValue" (pMAComplexityHeightValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAComplexityWidthValue" (pMAComplexityWidthValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAStepsValue" (pMAStepsValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAPipeTypePercentageValue" (pMAPipeTypePercentageValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAChamferTypePercentageValue" (pMAChamferTypePercentageValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMARenderableValue" (pMARenderableValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMASidesValue" (pMASidesValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMASmoothValue" (pMASmoothValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAThicknessMinValue" (pMAThicknessMinValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAThicknessMaxValue" (pMAThicknessMaxValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAMultiPercentageValue" (pMAMultiPercentageValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAJointPercentageValue" (pMAJointPercentageValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAJointDensityValue" (pMAJointDensityValue as string)
	setINISetting pMAOutputFilename "pipeMaker" "pMAPosValue" (pMAFloater.pos as string)
	)

-- UI

fn pMADefineUI = 
	(
	rollout pMARollout "pipeMaker"
		(
		group "Pipe Volume Control"
		(
		spinner pMAPipeNumberSpinner "Number Of Pipes:" range:[1,1000,pMAPipeNumberValue] fieldWidth:50 type:#integer align:#right
		spinner pMAHeightSpinner "Height:" range:[100,100000,pMAHeightValue] fieldWidth:50 type:#float align:#right
		spinner pMAWidthSpinner "Width:" range:[100,100000,pMAWidthValue] fieldWidth:50 type:#float align:#right
		spinner pMADepthSpinner "Depth:" range:[100,100000,pMADepthValue] fieldWidth:50 type:#float align:#right
		spinner pMAComplexityHeightSpinner "Complexity Height:" range:[1,10,pMAComplexityHeightValue] fieldWidth:50 type:#integer align:#right
		spinner pMAComplexityWidthSpinner "Complexity Width:" range:[1,10,pMAComplexityWidthValue] fieldWidth:50 type:#integer align:#right
		spinner pMAStepsSpinner "Path Steps:" range:[0,100,pMAStepsValue] fieldWidth:50 type:#integer align:#right
		spinner pMAPipeTypePercentageSpinner "% Straight Pipes:" range:[0,100,pMAPipeTypePercentageValue] fieldWidth:50 type:#float align:#right
		spinner pMAChamferTypePercentageSpinner "% Round Chamfers:" range:[0,100,pMAChamferTypePercentageValue] fieldWidth:50 type:#float align:#right
		)

		on pMAPipeNumberSpinner changed val do pMAPipeNumberValue = val
		on pMAHeightSpinner changed val do pMAHeightValue = val
		on pMAWidthSpinner changed val do pMAWidthValue = val
		on pMADepthSpinner changed val do pMADepthValue = val
		on pMAComplexityHeightSpinner changed val do pMAComplexityHeightValue = val
		on pMAComplexityWidthSpinner changed val do pMAComplexityWidthValue = val
		on pMAStepsSpinner changed val do pMAStepsValue = val
		on pMAPipeTypePercentageSpinner changed val do pMAPipeTypePercentageValue = val
		on pMAChamferTypePercentageSpinner changed val do pMAChamferTypePercentageValue = val
		
		group "Individual Pipe Control"
		(
		checkbox pMARenderableCheckbox "Renderable?" checked:pMARenderableValue align:#right
		spinner pMASidesSpinner "Sides:" range:[3,100,pMASidesValue] fieldWidth:50 type:#integer align:#right
		checkbox pMASmoothCheckbox "Smooth?" checked:pMASmoothValue align:#right
		spinner pMAThicknessMinSpinner "Thickness Min:" range:[0.01,999999,pMAThicknessMinValue] fieldWidth:50 type:#float align:#right
		spinner pMAThicknessMaxSpinner "Thickness Max:" range:[0.01,999999,pMAThicknessMaxValue] fieldWidth:50 type:#float align:#right
		spinner pMAMultiPercentageSpinner "% Multi Pipes:" range:[0,100,pMAMultiPercentageValue] fieldWidth:50 type:#float align:#right
		)

		on pMARenderableCheckbox changed state do pMARenderableValue = state
		on pMASidesSpinner changed val do pMASidesValue = val
		on pMASmoothCheckbox changed state do pMASmoothValue = state
		on pMAThicknessMinSpinner changed val do pMAThicknessMinValue = val
		on pMAThicknessMaxSpinner changed val do pMAThicknessMaxValue = val
		on pMAMultiPercentageSpinner changed val do pMAMultiPercentageValue = val

		group "Individual Pipe Joint Control"
		(
		spinner pMAJointPercentageSpinner "% That Have Joints:" range:[0,100,pMAJointPercentageValue] fieldWidth:50 type:#float align:#right
		spinner pMAJointDensitySpinner "Joint Density:" range:[0,100,pMAJointDensityValue] fieldWidth:50 type:#float align:#right
		)

		on pMAJointPercentageSpinner changed val do pMAJointPercentageValue = val
		on pMAJointDensitySpinner changed val do pMAJointDensityValue = val

		group "Tools"
		(
		button pMASelectPipesButton "Select" width:70 align:#center toolTip:"Select Previous PipeBundle" across:2
		button pMADeletePipesButton "Delete" width:70 align:#center toolTip:"Delete Previous PipeBundle"
		)

		on pMASelectPipesButton pressed do 
			(
			try
				(
				undo "pipeMaker" on
					(
					select pMALastPipeBundle
					completeRedraw()
					)
				)
			catch (MessageBox "This operation has failed. The previous PipeBundle either no longer exists, or you've closed the script floater since it was made." title:"pipeMaker")
			)
		on pMADeletePipesButton pressed do 
			(
			try
				(
				undo "pipeMaker" on
					(
					for i in pMALastPipeBundle do delete i
					completeRedraw()
					)
				)
			catch (MessageBox "This operation has failed. The previous PipeBundle either no longer exists, or you've closed the script floater since it was made." title:"pipeMaker")
			)

		button pMADoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[23,489]
		on pMADoButton pressed do pMADo()
		button pMAApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[95,489]
		on pMAApplyButton pressed do pMAApply()
		button pMAHelpMAtton "Help" width:70 toolTip:"Help" pos:[23,513]
		on pMAHelpMAtton pressed do pMAHelp()
		button pMASaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[95,513]
		on pMASaveDefButton pressed do pMASaveDef()
		)
	)
)
-------------------------------------------------------------------------------