fn LandscapingGen = 
(
	frameRate  = 25
	rendStart = 0f 
rendEnd = 290f 
															
animationRange = interval rendStart rendEnd

LayerID = LayerManager.getLayerFromName "0"

LayerID.current = true


actionMan.executeAction 0 "550"

TopLeft_CRTL_POSY = $TopLeft_CRTL.position.y

BottomLeft_CRTL_POSY = $BottomLeft_CRTL.position.y

YDist = TopLeft_CRTL_POSY - BottomLeft_CRTL_POSY

BottomLeft_CRTL_POSX = $BottomLeft_CRTL.position.x

BottomRight_CRTL_POSX = $BottomRight_CRTL.position.x

XDist = BottomRight_CRTL_POSX - BottomLeft_CRTL_POSX

MasterCRTLPos = $Position_CRTL.pos

GroundPlane = Plane name:"Ground" length:(YDist) width:(XDist) pos:MasterCRTLPos isSelected:on
GroundPlane.position = MasterCRTLPos
select GroundPlane
modPanel.addModToSelection (Shell ())


TerrainGeo = Box lengthsegs:1 widthsegs:1 heightsegs:1 length:(YDist) width:(XDist) height:-1000 mapcoords:on pos:MasterCRTLPos isSelected:on
max modify mode
modPanel.addModToSelection (Edit_Poly ())

subobjectLevel = 4
TerrainGeo.modifiers[#Edit_Poly].Select #Face #{1}
TerrainGeo.modifiers[#Edit_Poly].ButtonOp #DeleteFace
subobjectLevel = 0
modPanel.addModToSelection (Uvwmap ())
TerrainGeo.modifiers[#UVW_Map].maptype = 4
TerrainGeo.modifiers[#UVW_Map].length = 25000
TerrainGeo.modifiers[#UVW_Map].width = 25000
TerrainGeo.modifiers[#UVW_Map].height = 25000
	
TEXTURE = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\underground_TEX.jpg"
Map = bitmaptexture filename:TEXTURE
UG_Mat = VRaymtl() 
UG_Mat.texmap_diffuse_on = True
UG_Mat.texmap_diffuse = Map
UG_Mat.name = "Under"
TerrainGeo.material = UG_mat
UG_Mat.showInViewport = true


MasterCRTLPos = $Position_CRTL.pos
BottomMasterPosY = $Bottom_Master.pos.y
MasterCRTLPosY = $Position_CRTL.pos.y

PathDist = MasterCRTLPosY - BottomMasterPosY


global PathGeo = Box name:"PathGeo" lengthsegs:1 widthsegs:1 heightsegs:1 length:(PathDist) width:(1250) height:10 mapcoords:on pos:MasterCRTLPos isSelected:on

Door_CRTL = $Door_CRTL
PathGeo.pos.x = Door_CRTL.pos.x

PathPosY = $Right_Master001.pos.y

if PathPosY >= $Position_CRTL.pos.y then
	(global MinYValue = PathGeo.max.y)
else
	(
	global MinYValue = PathGeo.min.y
	)

PathHelper = Point Size:500 name:"PathHelper" pos:MasterCRTLPos

$PathHelper.pos.x = PathGeo.pos.x
$PathHelper.pos.y = (MinYValue as float)
$PathHelper.pos.z = PathGeo.pos.z
$PathGeo.parent = PathHelper

PathHelper.pos.y = (PathPosY)

select PathGeo
	
modPanel.addModToSelection (Uvwmap ())
PathGeo.modifiers[#UVW_Map].maptype = 4
PathGeo.modifiers[#UVW_Map].length = 2500
PathGeo.modifiers[#UVW_Map].width = 2500
PathGeo.modifiers[#UVW_Map].height = 2500
	
Path_Diff = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Paving.jpg"
PathDiffMap = bitmaptexture filename:Path_Diff 
Path_Mat = VRaymtl() 
Path_Mat.texmap_diffuse_on = True
Path_Mat.texmap_diffuse = PathDiffMap
Path_Mat.name = "Path"
PathGeo.material = Path_Mat
Path_Mat.showInViewport = true




	
-----------------	
Garage_CRTL = $Garage_CRTL
if Garage_CRTL != undefined then
(
	
DriveInGeo = Box name:"DriveInGeo" lengthsegs:1 widthsegs:1 heightsegs:1 length:(PathDist+500) width:(2650) height:10 mapcoords:on pos:MasterCRTLPos isSelected:on
-- Garage_CRTL = $Garage_CRTL
DriveInGeo.pos.x = Garage_CRTL.pos.x	
PathPosY = $Right_Master001.pos.y

if Garage_CRTL.pos.y >= $Position_CRTL.pos.y then
	(
		MinYValue = DriveInGeo.max.y
		DriveInHelper = Point Size:500 Name:"DriveInHelper" pos:[DriveInGeo.pos.x,MinYValue,DriveInGeo.pos.z]
		DriveInGeo.parent = DriveInHelper
		DriveInHelper.pos.y = $TopRight_CRTL.pos.y
		
		DriveIn_Diff = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Road.jpg"
		DriveIn_DiffMap = bitmaptexture filename:DriveIn_Diff 
		DriveIn_Mat = VRaymtl() 
		DriveIn_Mat.texmap_diffuse_on = True
		DriveIn_Mat.texmap_diffuse = DriveIn_DiffMap
		DriveIn_Mat.name = "DriveIn"
		DriveInGeo.material = DriveIn_Mat
		DriveIn_Mat.showInViewport = true
		
		select DriveInGeo
	
		modPanel.addModToSelection (Uvwmap ())
		DriveInGeo.modifiers[#UVW_Map].maptype = 4
		DriveInGeo.modifiers[#UVW_Map].length = 2500
		DriveInGeo.modifiers[#UVW_Map].width = 2500
		DriveInGeo.modifiers[#UVW_Map].height = 2500
		
		mergemaxfile @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Car_Spin.max" #select
		$.name = "Car"
		$Car.pos = $DriveInGeo.pos
		$Car.pos.y = ($Car.pos.y + (-1500))	
		DriveInSurf = $DriveInGeo.max.z
		$Car.pos.z = DriveInSurf	
		CarBack = $Car.max.y	
		CarHelper = Point Size:500 Name:"CarHelper" pos:[DriveInGeo.pos.x,CarBack,DriveInGeo.pos.z]
		$Car.parent = CarHelper
		CarHelper.pos.y = $DriveInHelper.pos.y
	)
else
	(
	MinYValue = DriveInGeo.min.y
	DriveInHelper = Point Size:500 Name:"DriveInHelper" pos:[DriveInGeo.pos.x,MinYValue,DriveInGeo.pos.z]
	DriveInGeo.parent = DriveInHelper
	DriveInHelper.pos.y = (PathPosY)
		
	DriveIn_Diff = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Road.jpg"
	DriveIn_DiffMap = bitmaptexture filename:DriveIn_Diff 
	DriveIn_Mat = VRaymtl() 
	DriveIn_Mat.texmap_diffuse_on = True
	DriveIn_Mat.texmap_diffuse = DriveIn_DiffMap
	DriveIn_Mat.name = "DriveIn"
	DriveInGeo.material = DriveIn_Mat
	DriveIn_Mat.showInViewport = true
		
	select DriveInGeo

	modPanel.addModToSelection (Uvwmap ())
	DriveInGeo.modifiers[#UVW_Map].maptype = 4
	DriveInGeo.modifiers[#UVW_Map].length = 2500
	DriveInGeo.modifiers[#UVW_Map].width = 2500
	DriveInGeo.modifiers[#UVW_Map].height = 2500
	
	
		
	mergemaxfile @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Car_Spin.max" #select
	$.name = "Car"
	$Car.pos = $DriveInGeo.pos
	$Car.pos.y = ($Car.pos.y + (-1500))	
	DriveInSurf = $DriveInGeo.max.z
	$Car.pos.z = DriveInSurf	
	CarBack = $Car.min.y	
	CarHelper = Point Size:500 Name:"CarHelper" pos:[DriveInGeo.pos.x,CarBack,DriveInGeo.pos.z]
	$Car.parent = CarHelper
	CarHelper.pos.y = (PathPosY)
	)
	
ScaleRatio =  Garage_CRTL.scale.x-- 115
DriveInGeo.width = (DriveInGeo.width * ScaleRatio)

)
------------------
	
mergemaxfile @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\FP_Grass_AUTOSPIN.max" 
	
Surf_LIST = #()
Surf_LIST[1] = $Ground

Fp_Grass = $FP_Grass

Fp_Grass.surflist = Surf_LIST
Fp_Grass.surfanim = True


Fp_Grass.aridlist.count = 2
Fp_Grass.pf_aractivelist.count = 2
Fp_Grass.arnamelist.count = 2
Fp_Grass.arnamelist[2] = ""
Fp_Grass.arnodelist.count = 2
Fp_Grass.artypelist.count = 2
Fp_Grass.arincexclist.count = 2
Fp_Grass.arresollist.count = 2
Fp_Grass.arslicelist.count = 2
Fp_Grass.arslicetoplist.count = 2
Fp_Grass.arwidthlist.count = 2
Fp_Grass.armaplist.count = 2
Fp_Grass.arscalelist.count = 2
Fp_Grass.arthresholdlist.count = 2
Fp_Grass.arselspeclist.count = 2
Fp_Grass.arspeclist.count = 2
Fp_Grass.arspeclist[2] = ""
Fp_Grass.arpaintlist.count = 2
Fp_Grass.arflafdenslist.count = 2
Fp_Grass.arflafscalist.count = 2
Fp_Grass.arflinvlist.count = 2
Fp_Grass.arboundchecklist.count = 2
Fp_Grass.arshapelist.count = 2
Fp_Grass.arobscalelist.count = 2
Fp_Grass.arsurfidlist.count = 2
Fp_Grass.arsurfidlist[2] = ""
Fp_Grass.arzoffset.count = 2
Fp_Grass.aridlist[2] = 2
Fp_Grass.arnamelist[2] = "New object"
Fp_Grass.artypelist[2] = 1
Fp_Grass.arincexclist[2] = 1
Fp_Grass.arobscalelist[2] = 100
Fp_Grass.arnodelist[2] = $PathGeo
Fp_Grass.arnamelist[2] = "PathGeo"


if Garage_CRTL != undefined then
(
Fp_Grass.aridlist.count = 3
Fp_Grass.pf_aractivelist.count = 3
Fp_Grass.arnamelist.count = 3
Fp_Grass.arnamelist[3] = ""
Fp_Grass.arnodelist.count = 3
Fp_Grass.artypelist.count = 3
Fp_Grass.arincexclist.count = 3
Fp_Grass.arresollist.count = 
Fp_Grass.arslicelist.count = 3
Fp_Grass.arslicetoplist.count = 3
Fp_Grass.arwidthlist.count = 3
Fp_Grass.armaplist.count = 3
Fp_Grass.arscalelist.count = 3
Fp_Grass.arthresholdlist.count = 3
Fp_Grass.arselspeclist.count = 3
Fp_Grass.arspeclist.count = 3
Fp_Grass.arspeclist[3] = ""
Fp_Grass.arpaintlist.count = 3
Fp_Grass.arflafdenslist.count = 3
Fp_Grass.arflafscalist.count = 3
Fp_Grass.arflinvlist.count = 3
Fp_Grass.arboundchecklist.count = 3
Fp_Grass.arshapelist.count = 3
Fp_Grass.arobscalelist.count = 3
Fp_Grass.arsurfidlist.count = 3
Fp_Grass.arsurfidlist[3] = ""
Fp_Grass.arzoffset.count = 3
Fp_Grass.aridlist[3] = 3
Fp_Grass.arnamelist[3] = "New object"
Fp_Grass.artypelist[3] = 1
Fp_Grass.arincexclist[3] = 1
Fp_Grass.arobscalelist[3] = 100
Fp_Grass.arnodelist[3] = $DriveInGeo
Fp_Grass.arnamelist[3] = "DriveInGeo"
)	

HDRImap = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\HDRI.hdr"
				HDRIimg = VrayHDRI HDRIMapName:HDRImap multiplier:2.5  mapType:2

				Dome = VRayLight name:"Dome" 
				Dome.pos = $Right_Master001.pos
				Dome.type = 1 
				Dome.subdivs = 16 
				Dome.invisible = true
				Dome.texmap = HDRIimg
				
				_TEXTHDRI = $Dome.texmap

				if environmentMap == undefined do
					(
						useEnvironmentMap = true
						environmentMap  = _TEXTHDRI
						)


				Sun = VRaySun name:"Sun" size_multiplier:3 pos:(point3 10000 -10000 10000) 
				targetObj = point pos:(point3 1000 1000 1000) size:2500 name:"SunCRTL" --then target



				targetObj.lookat = Sun 
				

						RadiusNodeA = $TopLeft_CRTL

						RadiusNodeB  = $BottomRight_CRTL

						Diameter = distance RadiusNodeA RadiusNodeB

						Radius = (Diameter * 1.7)

						CamPath = Circle name:"CamPath" radius:Radius pos:MasterCRTLPos



						CamPath.pos.z = CamPath.pos.z + 5000
						rotate CamPath (angleaxis -60 [0,0,1])

						CamPath.adaptive = true

						select CamPath

						modPanel.addModToSelection (Bend ())

						CamPath.modifiers[#Bend].gizmo.rotation += quat 0 0 0.5 0.866025
						CamPath.modifiers[#Bend].BendAxis = 1	
						CamPath.modifiers[#Bend].BendAngle = 17
						CamPath.modifiers[#Bend].BendDir = 90
						CamPath.modifiers[#Bend].FromTo = on
						CamPath.modifiers[#Bend].BendTo = 3.15

						SPCam = VRayPhysicalCamera name:"SPCam" whiteBalance_preset:4 whiteBalance:(color 197.77 235.118 255) pos:[50341.9,16872.7,0] isSelected:on

						SPCam.targeted = on
							
						CTarget = $SPCam.Target

						CTarget.pos = MasterCRTLPos
						CTarget.pos.z = (CTarget.pos.z + 3200)

						pc = path_constraint()

						SPCam.position.controller = pc

						pc.path = CamPath
						HTName = (trimright maxfilename ".max")
						SPCam.name = HTName	
						select SPCam


						viewport.setType #view_camera
						max safeframe toggle
-- 						max tool maximize
)

try(destroydialog _AutoSpinTools)catch()
Rollout _AutoSpinTools "HT Spin Tools"
(

button _RigMerge "HT Rig" across:2 width:75 height:35
	on _RigMerge pressed do(
mergemaxfile @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Bounding_Box_Rigg.max"
	)
button _SaveRig "Save Rig" width:75 height:35
	on _SaveRig pressed do
		(
			MasterRigCRTL = $Position_CRTL
			SelArray = #()
			select $Position_CRTL...*
			SelArray = (selection as array)
			RigName = (trimright maxfilename ".max") + ("_SpinRIG.max")
			RigFilePath = maxfilepath + "AnimationFiles" + @"\" + "SpinRigFiles" + @"\"
			OutFile = RigFilePath + RigName
			Makedir RigFilePath
			saveNodes SelArray OutFile
			Delete SelArray
			)
			
Button _Preview "Preview" width:75 height:35	across:2
			on _Preview pressed do
				(	
					HTName = (trimright maxFileName ".max")
					MaxRigName = HTName + ("_SpinRIG.max") 
					FilePath = maxFilePath
					FileName = Maxfilename
					global CurrentFile =  (maxFilePath + maxfilename)
					RigXREF =(FilePath + @"\"  + "AnimationFiles" + @"\" + "SpinRigFiles" + @"\" + MaxRigName)
					RiggNameCheck = doesFileExist  RigXREF
					if RiggNameCheck == true then 
						(
							

							savemaxfile CurrentFile
							resetMaxFile #noPrompt

							HTXREF = xrefs.addNewXRefFile CurrentFile

							


								
							RigXREF = xrefs.addNewXRefFile (FilePath + @"\"  + "AnimationFiles" + @"\" + "SpinRigFiles" + @"\" + MaxRigName)
							
							merge RigXREF
							
							
								
							LandscapingGen() 
						)
					else
							(messagebox "Create and Save the Rigg for this HT first!")
					)
button _Revert "Revert" width:75 height:35	across:2
				on _Revert pressed do
					(loadmaxfile CurrentFile)
	
Button _Submit "Run Submission" width:150 height:35
	on _Submit pressed do
		(
			::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\AutoSpinGen_V2.ms"
			)
	
	
	
	
)
createdialog _AutoSpinTools
