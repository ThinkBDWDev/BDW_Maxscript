/*HeaderStart*******************************************************
:Created By:			Rodri Garcia
:Company:				Rodri Garcia
:Site:					http://rgarcia-digitaldesign.com
:Email:				info@rgarcia-digitaldesign.com
:Client:				Think BDW
:Purpose:				Submit Render to Our Farm from the interior department

:History:
	V:0.00.01A 
		Getting started. 
:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/
VerNumber = undefined
VRstate = False
::Filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\Vray_Presets_Functions.ms"

global SMTDSettings
global SMTDFunctions

renderscenedialog.close()

vr = renderers.current
RDialog = renderscenedialog.isopen()
JobNameGRP = #()
JobIDGrp = #()

RenderPath = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\" + _UserSelected + @"\*")
RenderPathUI = #()

for i =1 to RenderPath.count do
	(
		RenderPathUI[i] = (filterstring RenderPath[i] @"\")[5]
		
		)
		
print RenderPathUI

_FName = maxfilename
_FPath = maxfilepath
_FNameT = trimright _FName ".max" 
global _PresetN =  _FNameT + ".rps"
PresetPath =_FPath +  _PresetN
		
PresetDir = getfiles (_FPath + _FNameT +"*.rps")
PresetDirUI = #()
		for i =1 to PresetDir.count do
	(
		TEMPStringPath = filterstring maxfilepath @"\"
		PresetDirUI[i] = (filterstring PresetDir[i] @"\")[TEMPStringPath.count+1]
		
		)
		




--Function: Submit Prepass for Interior Stills (Non Tiled)
fn submitPrepass JobName SuspVal PriorSVal _Dep  = 
(	
global SMTDSettings
global SMTDFunctions

local theNetworkRoot = @"\\CGISERVER\Repository"
local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"    
fileIn remoteScript 
            
SMTDFunctions.loadSettings()
SMTDSettings.JobName = JobName 
SMTDSettings.priority = PriorSVal
SMTDSettings.SubmitAsDependent = false	
SMTDSettings.RegionRenderingMode= #none
SMTDSettings.SubmitAsSuspended = SuspVal
	if VRstate == true then
		(
		SMTDSettings.StereoCameraMode = #all
		setIniSetting SMTDPaths.InIFile "JobSettings"  "StereoCameraMode" SMTDSettings.StereoCameraMode
		)

local maxFileToSubmit = SMTDPaths.tempdir + maxFileName
SMTDFunctions.SaveMaxFileCopy maxFileToSubmit
    
local SubmitInfoFile = SMTDPaths.tempdir + "\\max_submit_info.job"
local JobInfoFile = SMTDPaths.tempdir  + "\\max_job_info.job"

SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
SMTDFunctions.CreateJobInfoFile JobInfoFile  
                            
local initialArgs="\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+"\" " 
SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission
)




--Function: Submit Final Render for Interior Stills (Dependant & Tiled)
fn submitFinalRender JobName SuspVal PriorSVal  _Dep = 
(
global SMTDSettings
global SMTDFunctions

local theNetworkRoot = @"\\CGISERVER\Repository"
local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"    
fileIn remoteScript 
            
SMTDFunctions.loadSettings()
SMTDSettings.JobName = JobName 
SMTDSettings.priority = PriorSVal
-- SMTDSettings.RegionRenderingMode=#none
SMTDSettings.SubmitAsSuspended = SuspVal
SMTDSettings.SubmitAsDependent = true
SMTDSettings.DependOnPreviousJobMode = #none
SMTDSettings.IncludeLocalPaths = true
	
if VRstate == true then
	(
	SMTDSettings.StereoCameraMode = #all
	setIniSetting SMTDPaths.InIFile "JobSettings"  "StereoCameraMode" SMTDSettings.StereoCameraMode
	SMTDSettings.RegionRenderingMode= #none
	)
	else(
	
SMTDSettings.RegionRenderingMode= #singleFrameTiles --  enable it and set the tile counts...
SMTDSettings.TilesInX = 4--spn_TilesInX.value
SMTDSettings.TilesInY = 4--spn_TilesInY.value
SMTDSettings.TilesPadding = 0 -- This could be exposed to the artist, but it is up to you. Just add a spinner and set to its value,,,
			
-- The following settings are also related to single frame tile rendering, you can expose them to the user if you want, or set them up as you want them 
SMTDSettings.SingleTileJobDependent = true --Should be True
SMTDSettings.SingleTileJobCleanup = true --Delete the tiles after assembly (normally it is False)
SMTDSettings.SingleTileJobDraft = True --Should be True to use Draft, False to use the old tile assembler. Keep it True.
SMTDSettings.SingleTileJobDraftErrorOnMissing = True --Defaults to True, should be left at True. If False, running the Draft Assembly 	
	)
	
	
SMTDSettings.JobsArray = #(#(JobNameGRP[1], JobIDGrp[1]))
SMTDSettings.dependencyJobItems = #(1)
	


local maxFileToSubmit = SMTDPaths.tempdir + maxFileName
SMTDFunctions.SaveMaxFileCopy maxFileToSubmit
    
local SubmitInfoFile = SMTDPaths.tempdir + "\\max_submit_info.job"
local JobInfoFile = SMTDPaths.tempdir  + "\\max_job_info.job"

SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
SMTDFunctions.CreateJobInfoFile JobInfoFile  
                            
local initialArgs="\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+"\" " 
-- SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission
SMTDFunctions.submitJobFromUI()

)

fn prepassSettings RenDIR = 
(
vr = renderers.current -- Set Vray As current Render
	
vr.gi_on = true 
vr.gi_primary_type = 0
vr.gi_secondary_type = 3


	
rendTimeType = 1
rendSaveFile = false
vr.output_splitgbuffer =false
vr.options_dontRenderImage = true
-- vr.gi_irradmap_preset = _IrrMode.value
-- vr.adv_irradmap_mode = 0
vr.adv_irradmap_autoSave = true
-- vr.gi_irradmap_multipleViews = true
-- vr.lightcache_subdivs = _LCSubdivs.value
-- vr.lightcache_multipleViews = true
-- vr.lightcache_mode = 0

actionMan.executeAction 0 "40247"  -- Selects Current Camera View
global CamName = $.Name  --Camera Name 
RenDIR = RenderPath[_PRJ.selection] --Render Directory
RenCamDir = RenDIR + CamName  -- Render Output 
												
IRMapName = CamName + ".vrmap"	
IRMapDir =RenCamDir + @"\" + "IM" + @"\" + IRMapName
IRMapFolder =RenCamDir + @"\" + "IM"
makedir IRMapFolder
vr.adv_irradmap_autoSaveFileName = IRMapDir --Irradiance Map Directory

-- vr.lightcache_loadFileName : filename
vr.adv_irradmap_mode = 0
vr.lightcache_autoSave = true
LCMapName = CamName + ".vrlmap"
LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
LCMapFolder =RenCamDir + @"\" + "LC"
makedir LCMapFolder
vr.lightcache_autoSaveFileName = LCMapDir
						
print RenCamDir
makedir RenCamDir
						
								
-- 				clearselection()
				
JobName = ("_Prepass_") + CamName	
Print JobName
				
-- PriorSVal = (_PriorS.value + 1)
-- SuspVal = SUSP.state
				
JobNameGRP[1] = JobName

_Dep = False

)

fn FinalRenderSettings RenDIR = 
(
vr = renderers.current -- Set Vray As current Render
	
vr.gi_on = true 
vr.gi_primary_type = 0
vr.gi_secondary_type = 3
		
rendTimeType = 1
rendSaveFile = false
vr.output_splitgbuffer =true
vr.options_dontRenderImage = False

-- vr.gi_irradmap_preset = _IrrMode.value
-- vr.adv_irradmap_mode = 0
vr.adv_irradmap_autoSave = false
-- vr.gi_irradmap_multipleViews = true
-- vr.lightcache_subdivs = _LCSubdivs.value
-- vr.lightcache_multipleViews = true
vr.lightcache_mode = 2
vr.adv_irradmap_mode = 2
fopenexr.SetCompression 7 
fopenexr.setSaveScanline false 
fopenexr.setSaveRegion false	
vr.output_getsetsfrommax =true
vr.output_splitRGB =true
vr.output_splitAlpha =true
vr.output_rawExrUseHalf = true

actionMan.executeAction 0 "40247"  -- Selects Current Camera View
CamName = $.Name  --Camera Name 
RenDIR = RenderPath[_PRJ.selection] --Render Directory
RenCamDir = RenDIR + CamName  -- Render Output 
vr.output_splitfilename = RenCamDir + @"\" + CamName + "_" + ".exr"												
IRMapName = CamName + ".vrmap"	
IRMapDir =RenCamDir + @"\" + "IM" + @"\" + IRMapName
IRMapFolder =RenCamDir + @"\" + "IM"
-- makedir IRMapFolder
vr.adv_irradmap_loadFileName = IRMapDir --Irradiance Map Directory

-- vr.lightcache_loadFileName : filename
vr.lightcache_autoSave = False
LCMapName = CamName + ".vrlmap"
LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
LCMapFolder =RenCamDir + @"\" + "LC"
-- makedir LCMapFolder
vr.lightcache_loadFileName = LCMapDir
						
print RenCamDir
makedir RenCamDir
						
								
-- 				clearselection()
				
JobName = ("_Final Render_") + CamName	
Print JobName
				
-- PriorSVal = (_PriorS.value + 1)
-- SuspVal = SUSP.state
				
-- JobNameGRP[1] = JobName

_Dep = False
-- submitTDDep JobName SuspVal PriorSVal  _Dep -- Submit to Deadline Prepass
)



-- clearlistener()

try(destroydialog IntStillsSubmitter )catch()
	rollout IntStillsSubmitter "Interior Submitter"
(	
		--#### UI
		---------------
-- 		imgTag img_header "Header" width:600 height:450 bitmap:(openBitmap @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\BG.jpg") offset:[-2,0] 
	

	
		groupbox OutP "Output" across:2 pos:[5,5] width:100 height:65
		groupbox VRdmc "DMC/AA" across:2 pos:[110,5] width:165 height:150
		groupbox ClrMap "Color Mapping" pos:[5,75] width:100 height:95
		groupbox IR "IR Map" pos:[5,180] width:145 height:170
		groupbox LC "Light Cache" pos:[150,180] width:120 height:170
		groupbox DL "Deadline" pos:[5,352] width:265 height:95
		groupbox StillPresets "Presets" pos:[545,5] width:147 height:433

		
		button _ADD "Add" align:#right pos:[285,35] width:250 height:35 
		edittext FolderName "Add Folder" text:"name" width:125 pos:[285,10] 
		edittext VersionT "Version" text:"_V" width:115 pos:[417,10]
		listbox _PRJ "Project Selector" height:20 items:RenderPathUI pos:[285,75] width:250
		
		Spinner ImgW "Width   " type:#integer  range:[500,12000,renderWidth] fieldwidth:40 align:#center pos:[10,25] 
		Spinner ImgH "Height  " type:#integer  range:[500,12000,renderHeight] fieldwidth:40 align:#center pos:[10,50] 
		
		spinner MinShRate "Min Shading Rate" type:#integer range:[1,100,vr.imageSampler_shadingRate] fieldwidth:40 align:#center pos:[125,25] 
		spinner MinSubs "Min Subdivs         " type:#integer range:[1,2,vr.twoLevel_baseSubdivs] fieldwidth:40 align:#center pos:[125,50]
		spinner MaxSubs "Max Subdivs        " type:#integer range:[1,100,vr.twoLevel_fineSubdivs] fieldwidth:40 align:#center pos:[125,75]
		spinner ClrTh "Color Threshold   " type:#float range:[0,100.0,vr.twoLevel_threshold] fieldwidth:40 align:#center pos:[125,100]
		checkbox LocalSubs "Use Local Subdivs" align:#center pos:[125,125] checked:vr.dmc_useLocalSubdivs
		
		dropdownlist ClrType "Type" items:#("Linear Multiply","Exponential","HSV Exponential","Inten Exponential","Gamma Correction","Intensity Gamma","Reinhard") pos:[10,95] width:85
		checkbox AffectBG "Affect BG" align:#center pos:[10,140] checked:vr.colorMapping_affectBackground
		
		spinner IRMin "IR Min Samples   " type:#integer range:[-10,0,vr.gi_irradmap_minRate] fieldwidth:40 align:#right pos:[10,200]
		spinner IRMax "IR Max Samples  " type:#integer range:[-10,1,vr.gi_irradmap_maxRate] fieldwidth:40 align:#right pos:[10,220]
		spinner IRSubs "IR Subdivs          " type:#integer range:[0,200,vr.gi_irradmap_subdivs] fieldwidth:40 align:#right pos:[10,240]
		spinner IRInter "IR Interpolation  " type:#integer range:[0,150,vr.gi_irradmap_interpSamples] fieldwidth:40 align:#right pos:[10,260]
		spinner IRClrTh "Color Threshol     " type:#float range:[0,5,vr.gi_irradmap_colorThreshold] fieldwidth:40 align:#right pos:[10,290]
		spinner NorTh "Normal Threshold" type:#float range:[0,5,vr.gi_irradmap_normalThreshold] fieldwidth:40 align:#right pos:[10,310]
		spinner DisTh "Dist Threshold     " type:#float range:[0,5,vr.gi_irradmap_distThreshold] fieldwidth:40 align:#right pos:[10,330]
		
		spinner LCSubs "LC Subdivs" type:#integer range:[0,5000,vr.lightcache_subdivs] fieldwidth:40 align:#right pos:[155,200]
		spinner SampleSize "Sample Size" type:#float range:[0,1,vr.lightcache_sampleSize] fieldwidth:40 align:#right pos:[155,220]
		spinner IntSamples "Interp" type:#integer range:[0,15,vr.lightcache_interpSamples] fieldwidth:40 align:#right pos:[155,240]
		checkbox Prefilter "Pre-Filter LC" align:#right pos:[155,260] checked:vr.lightcache_prefilter_on 
		Spinner FInter "Filter Blend" type:#integer range:[0,50,vr.lightcache_prefilter_samples] fieldwidth:40 align:#right pos:[155,280]
		
		checkbutton RenderSettings "VRay Settings" align:#center pos:[160,305] width:100 height:40 highlightColor:[255,255,255]
		spinner _PriorS "Priority"  type:#integer range:[0,99,75] fieldwidth:40  width:100 pos:[5,375]
		checkbox VRMode "VR Mode"  pos:[110,375]
		checkbox SUSP "Suspend Job"  align:#Right  pos:[175,375]
		
		button submit "Submit Image" pos:[10,400] width:250 height:40 
		
		imgTag tag_submitTop height:2 width:250 pos:[10,400] 
		imgTag tag_submitBottom height:2 width:250 pos:[10,440] 
-- 		progressbar SubmitBG "" pos:[5,395] width:260 height:50 value:100 color:green --enabled:false
-- 		imgTag tag_submitBottom height:2 width:188 pos:[5,395]

		
		edittext PresetName "Preset Name"  width:250 pos:[285,375]
		button _SaveS "Save State" pos:[285,400] width:115 height:40
		dropdownlist RenderP "Load State" pos:[420,396] width:115 items:PresetDirUI
		
		progressbar SubProg orient:#vertical pos:[700,10] color:Red width:35 height:430	


		
		Button Ext4K "Ext 4K" pos:[554,25] width:130 height:35 
		Button Ext8K "Ext 8K" pos:[554,65] width:130 height:35 
		Button Int4K "Int 4K" pos:[554,105] width:130 height:35 
		Button Int8K "Int 10K" pos:[554,145] width:130 height:35
		Button Clay "Clay" pos:[554,185] width:130 height:35
		Button QR "Quick Render" pos:[554,225] width:130 height:35
		slider QControlUp "Better" orient:#vertical pos:[750,10] ticks:2 type:#float range:[1,3,1] 
		slider QControlDown "Poor" orient:#vertical pos:[750,110] ticks:2 type:#float range:[1,3,3]
		
		
		button SetDef "Set Default State" pos:[554,295] width:130 height:35
		button LoadDef "Load Default State" pos:[554,335] width:130 height:35
		
		label Info "       Stills Render \n      Control Panel \n        Ver - 1.07  \n\n"style_sunkenedge:true pos:[567,385] width:100 height:45
		
		
		Button Slaves "Slaves" pos:[742,405] width:50 height:35
		
		--#### UI FUNCTIONALITY
		-------------------------------------
		
-- 		on QControlUp buttonup do
-- 			(			
-- 						print QControlUp.value	
-- 						vr.twoLevel_fineSubdivs = vr.twoLevel_fineSubdivs * QControlUp.value
-- 						vr.imageSampler_shadingRate = vr.imageSampler_shadingRate  
-- 						vr.twoLevel_threshold = 0.02
-- 						
-- 						
-- 						vr.gi_irradmap_minRate = -5 vr.gi_irradmap_minRate 
-- 						vr.gi_irradmap_maxRate = -2 vr.gi_irradmap_maxRate
-- 						vr.gi_irradmap_subdivs = 80 vr.gi_irradmap_subdivs
-- 						vr.gi_irradmap_interpSamples = 20 vr.gi_irradmap_interpSamples
-- 						vr.lightcache_subdivs = 3000 vr.lightcache_subdivs
-- 						vr.lightcache_sampleSize = 0.01 vr.lightcache_sampleSize
-- 						vr.lightcache_prefilter_samples = 5 vr.lightcache_prefilter_samples 
-- 				)



		on Slaves pressed do
			(try(destroydialog SMTD_BlackListSlaves)catch()
				createdialog SMTD_BlackListSlaves width:500
				)

		on VRMode	Changed P do
			(

				
				VRstate = P
				VRNodes = getclassinstances VRayStereoscopic
				if VRNodes == undefined then (messagebox = "No Stereo Helper Found \n")
				AspectRatio = GetRendImageAspect()
				if AspectRatio != 0.75 then (messagebox = "Aspect Ratio NOT SET CORRECTLY")
				CamType = vr.camera_type
				if CamType != 4 then (messagebox = "Camera Type not Set as BOX")
				
				
				
				
				
				)

		on SetDef pressed do
			(		
					renderscenedialog.close()
					_DefName = "DefState"
					_DefPath = getdir #plugcfg + @"\"
					global _DefPresetN =  _DefPath + "_" +_DefName + ".rps"
													
					renderPresets.saveall 0 (_DefPresetN)
					::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms"
			)
			
		on LoadDef pressed do
			(
					renderscenedialog.close()
					_DefName = "DefState"
					_DefPath = getdir #plugcfg + @"\"
					global _DefPresetN =  _DefPath + "_" +_DefName + ".rps"
													
					renderPresets.loadall 0 (_DefPresetN)
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms"
				)
		
		on Ext4k pressed do
			(renderscenedialog.close()
				Exterior4K()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")
		on Ext8K pressed do
			(renderscenedialog.close()
				Exterior8K()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")		
		on Int4k pressed do
			(renderscenedialog.close()
				Interior4K()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")		
		on Int8k pressed do
			(renderscenedialog.close()
				Interior10K()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")
		on Clay pressed do
			(renderscenedialog.close()
				ClayR()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")
		on QR pressed do
			(renderscenedialog.close()
				QuickRn()
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")
		
		on SubProg clicked O do
			(if keyboard.escPressed do exit)
		
		on _SaveS pressed do
				(
					renderscenedialog.close()
					_ExtraName = PresetName.text
					_FName = maxfilename
					_FPath = maxfilepath
					_FNameT = trimright _FName ".max" 
					global _PresetN =  _FNameT + "_" +_ExtraName + ".rps"
					PresetPath =_FPath +  _PresetN
								
					renderPresets.saveall 0 (PresetPath)
					::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms"
					)
			
		on IntStillsSubmitter open do
			(
				thebmp = bitmap 1 1 color:green
				tag_submitTop.bitmap = thebmp
				tag_submitBottom.bitmap = thebmp
				renderscenedialog.close()
				RenderSettings.checked = RDialog
				CrlTypeNumber = (vr.colorMapping_type)
				ClrType.selection = (CrlTypeNumber + 1)
				)
		
				
		on _ADD pressed do
			(
				renderscenedialog.close()
				NewFolder = FolderName.text
				_PRJ.items = append _PRJ.items (NewFolder as string)
				makedir (@"\\CGISERVER\BDWRenderC\CGIRender\" + _UserSelected + @"\" + NewFolder)
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms"
			)
		on _PRJ rightClick do
			(
				OpenDIR = RenderPath[_PRJ.selection]
			
				shelllaunch OpenDIR ""
				
				)		
				
		on RenderP selected D do
			(renderPresets.loadall 0 (PresetDir[RenderP.selection]))		
				
		on ImgW changed O do
			(
				renderscenedialog.close()
				renderWidth = O)
		on ImgH changed P do
			(
				renderscenedialog.close()
				renderHeight = P)
		on MinShRate changed Q do
			(renderscenedialog.close()
				vr.imageSampler_shadingRate = Q)
		on MinSubs changed A do
			(renderscenedialog.close()
				vr.twoLevel_baseSubdivs = A)
		on MaxSubs changed B do
			(renderscenedialog.close()
				vr.twoLevel_fineSubdivs = B)
		on ClrTh changed C do
			(renderscenedialog.close()
				vr.twoLevel_threshold = C)
		on LocalSubs changed P do
			(renderscenedialog.close()
				vr.dmc_useLocalSubdivs = P )
		on AffectBG changed P do
			(renderscenedialog.close()
				vr.colorMapping_affectBackground = P)
		on ClrType selected D do
			(renderscenedialog.close()
				vr.colorMapping_type = (D-1))
		on IRMin changed F do
			(renderscenedialog.close()
				vr.gi_irradmap_minRate = F)
		on IRMax changed G do
			(renderscenedialog.close()
				vr.gi_irradmap_maxRate = G)
		on IRSubs changed H do
			 (renderscenedialog.close()
				 vr.gi_irradmap_subdivs = H)
		on IRInter changed I do
			(renderscenedialog.close()
				vr.gi_irradmap_interpSamples = I)
		on IRClrTh changed J do
			(renderscenedialog.close()
				vr.gi_irradmap_colorThreshold = J)
		on NorTh changed K do
			(renderscenedialog.close()
				vr.gi_irradmap_normalThreshold = K)
		on DisTh changed L do
			(renderscenedialog.close()
				vr.gi_irradmap_distThreshold = L)
		on LCSubs changed M do
			(renderscenedialog.close()
				vr.lightcache_subdivs = M)
		on SampleSize changed N do
			(renderscenedialog.close()
				vr.lightcache_sampleSize = N)
		on IntSamples changed O do
			(renderscenedialog.close()
				vr.lightcache_interpSamples = O)
		on Prefilter changed O do
			(renderscenedialog.close()
				vr.lightcache_prefilter_on = O)
		on FInter changed P do
			(renderscenedialog.close()
				vr.lightcache_prefilter_samples = P)
		
		
		on RenderSettings changed state do
			(
				if state == on then
					(renderscenedialog.open())
				if state == off then
					(renderscenedialog.close())
				)		
		
		
		on submit pressed do
			(
				thebmp = bitmap 1 1 color:Red
				tag_submitTop.bitmap = thebmp
				tag_submitBottom.bitmap = thebmp
-- 				SubmitBG.color = red
				UserPath = (dotNetClass "System.Environment").GetEnvironmentVariable "UserProfile"
				UserTempPath = UserPath + @"\AppData\Local\Autodesk\3dsMax\2014 - 64bit\ENU\temptemp"
				doesfileexist UserTempPath

					if doesfileexist UserTempPath == false do
					(


					Makedir UserTempPath
					)
					
				renderscenedialog.close()
				actionMan.executeAction 0 "40247"  -- Selects Current Camera View
				CamName = $.Name 
				
				
		--#### PREPASS SUBMISSION
		--------------------------------------------
			vr.gi_on = true 
			vr.gi_primary_type = 0
			vr.gi_secondary_type = 3


				
			rendTimeType = 1
			rendSaveFile = false
			vr.output_on =False
			vr.output_saveFile =False
			vr.output_splitgbuffer =false
			vr.options_dontRenderImage = true
			vr.adv_irradmap_autoSave = true


			actionMan.executeAction 0 "40247"  -- Selects Current Camera View
			global CamName = $.Name  --Camera Name 
			RenDIR = RenderPath[_PRJ.selection] --Render Directory
			if VersionT.text == "_V" then
				(VerText = "")
			RenCamDir = RenDIR + CamName + VerText -- Render Output 
			
			SubProg.value = 20
			VerNumber = 0
			
			fn VersionChecker RenCamDir =
				(
				global PathT = RenCamDir
				global PathHolder = PathT
				For i=1 to 20 while doesFileExist PathHolder do
					(	
						Global VersionC = "_V00" + (i as string)
						(PathHolder = (PathT + VersionC))
						
						Global Ver = i
						Print PathHolder
					
						Global VerNumber = i
					)
					If VersionC != undefined then
						(	
							Global VersionPath = PathT + VersionC
							MSG = "Folder already exists" + "\n" + "New Version for Files Created" + "\n" + "----------------------" + "\n" + "Version No " + VersionC
							If VerNumber > 0 do
							(messagebox MSG)
						)

				)
				VersionChecker RenCamDir
				
				if VersionPath != undefined then
					(RenCamDir = VersionPath)
				
-- 				RenCamDir = VersionPath
			

			makedir RenCamDir
				
															
			IRMapName = CamName + ".vrmap"	
			IRMapDir =RenCamDir + @"\" + "IM" + @"\" + IRMapName
			IRMapFolder =RenCamDir + @"\" + "IM"
			makedir IRMapFolder
				
			vr.lightcache_mode = 0
			vr.adv_irradmap_mode = 0
			vr.adv_irradmap_autoSave = true	
			vr.adv_irradmap_autoSaveFileName = IRMapDir --Irradiance Map Directory

			vr.lightcache_autoSave = true
			LCMapName = CamName + ".vrlmap"
			LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
			LCMapFolder =RenCamDir + @"\" + "LC"
			vr.lightcache_autoSaveFileName = LCMapDir
			makedir LCMapFolder						
			

			JobName = ("_Prepass_") + CamName	
			Print JobName
							
			JobNameGRP[1] = JobName

			_Dep = False

			JobName = "_Prepass_" + CamName	
																	
			PriorSVal = (_PriorS.value + 1)
			SuspVal = SUSP.state
																	
			JobNameGRP[1] = JobName
																	
			submitPrepass JobName SuspVal PriorSVal  _Dep
			
			SubProg.value = 50
			
				--------------------------------------------
				--#### FINAL SUBMISSION PREP
				---------------			
																	
													SMTDFunctions.GetJobIDFromMessage (SMTDFunctions.GetRenderMessage())
													JobIDGrp[1] = SMTDSettings.DeadlineSubmissionLastJobID 
														
	
			--#### FINAL RENDER SUBMISSION
		--------------------------------------------------
	
			vr.gi_on = true 
			vr.gi_primary_type = 0
			vr.gi_secondary_type = 3
														
					
			rendTimeType = 1
			rendSaveFile = false

-- 			vr.adv_irradmap_autoSave = false
			vr.lightcache_mode = 2
			vr.adv_irradmap_mode = 2
			fopenexr.SetCompression 7 
			fopenexr.setSaveScanline false 
			fopenexr.setSaveRegion false	
														
			TMP_filename = sysInfo.tempdir + "tmpFile.jpg"
			BitM=Bitmap 10 10 fileName: TMP_filename
			save BitM
			close BitM
			vr.output_splitbitmap=BitM
			deleteFile TMP_filename											
			
			vr.output_on =True
			vr.output_saveFile = true
			vr.output_splitgbuffer =True
			vr.options_dontRenderImage = False
			
			vr.output_getsetsfrommax =true
			vr.output_splitRGB =true
			vr.output_splitAlpha =true
			vr.output_rawExrUseHalf = true

-- 			actionMan.executeAction 0 "40247"  -- Selects Current Camera View
-- 			CamName = $.Name  --Camera Name 
-- 			RenDIR = RenderPath[_PRJ.selection] --Render Directory
-- 			RenCamDir = RenDIR + CamName + VersionT.text  -- Render Output 
-- 			
-- 			fn VersionChecker PathT =
-- 				(
-- 				PathHolder = PathT
-- 				For i=1 to 20 while doesFileExist PathHolder do
-- 					(	
-- 						Global VersionC = "_V00" + (i as string)
-- 						(PathHolder = (PathT + VersionC))
-- 						
-- 						Global Ver = i
-- 						Print PathHolder
-- 						Global VerNumber = i
-- 						)
-- 						Global VersionPath = PathT + VersionC

-- 				)
-- 				VersionChecker RenCamDir
-- 				RenCamDir = VersionPath

			vr.output_splitfilename = RenCamDir + @"\" + CamName + "_" + ".exr"												
			IRMapName = CamName + ".vrmap"	
			IRMapDir =RenCamDir + @"\" + "IM" + @"\" + IRMapName
			IRMapFolder =RenCamDir + @"\" + "IM"
			vr.adv_irradmap_loadFileName = IRMapDir --Irradiance Map Directory
-- 			vr.lightcache_autoSave = False
			LCMapName = CamName + ".vrlmap"
			LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
			LCMapFolder =RenCamDir + @"\" + "LC"
			vr.lightcache_loadFileName = LCMapDir

			JobName = ("_Final Render_") + CamName	
			Print JobName
							
			_Dep = False

			SubProg.value = 60
				
			JobName = "_Final Render_" + CamName	
				
			SubmitFinalRender JobName SuspVal PriorSVal  _Dep
			
			SubProg.value = 100
			SubProg.color = green
			
			PathHolder = undefined
			PathT = undefined
			Ver = undefined
			VerNumber = undefined
			VersionC = undefined
			VersionPath = undefined
-- 			SubmitBG.color = green
			
				thebmp = bitmap 1 1 color:green
				tag_submitTop.bitmap = thebmp
				tag_submitBottom.bitmap = thebmp
				)
		
	)
	createdialog IntStillsSubmitter width:800 height:450 --bgcolor:[50,50,50]

	
	
	
	
	rollout SMTD_ShowSlaveInfo "Slave Info"
	(
		listbox lbx_slaveInfo items:#() height:54 width:395 align:#center
		on lbx_slaveInfo doubleClicked itm do
		(
			format "%\n" lbx_slaveInfo.selected
		)
		on SMTD_ShowSlaveInfo close do
		(
			try(SMTD_BlackListSlaves.btn_ShowSlaveInfo.checked = false)catch()
		)
	)
	
	
	
	rollout SMTD_BlackListSlaves "Blacklist/Whitelist Slaves" rolledup:false
	(
		local theSlaveInfoFile = (SMTDPaths.SettingsDir + "slaveselectionsets\\slavesinfo.ini" )
		local theSelSetFiles = #()
		--button btn_help_blacklist "?" width:12 across:5 align:#left offset:[-11,-2] tooltip:"Click for Online Help on Blacklisting Slaves."
		checkbox chk_blacklistSticky "Sticky Blacklist Settings" align:#left height:18 offset:[-10,-3] across:4 tooltip:"When checked, the Black List settings specified in this dialog will be stored between sessions and will be applied each time the SMTD Dialog is opened.\n\nWhen unchecked, the Black List settings will have to be specified manually in each new SMTD session."
		
		button btn_saveSelSet "Save List As Selection Set"  align:#right width:137 height:18 offset:[147,-3] tooltip:"Enter a name in the text field below and press this button to save the right-hand-side list of Slave names as a named preset.\n\nIt can be restored easily by selecting from the drop-down list on the left side, or cleared by selecting the [None] entry."
		button btn_deleteSelSet "Delete"  align:#right width:45 height:18 offset:[78,-3] tooltip:"Select a Selection Set from the drop-down list on the left or enter the name in the text field, then press this button to DELETE the named Selection Set from Disk."
		button btn_exploreSelSet "Explore"  align:#right width:45 height:18 offset:[9,-3] tooltip:"Press to EXPLORE the Selection Sets Folder"
		
		dropdownlist ddl_slaveSelSet width:230 align:#left across:2 offset:[-10,-5] tooltip:"Lists the previously saved Slave Selection Sets plus the [None] entry which cannot be removed.\n\nSelect a Slave Selection Set from the list to quickly populate the Blacklist/Whitelist with pre-defined machine names."
		edittext edt_SelSetName width:232 align:#right offset:[8,-3]
		
		label lbl_slavesList " Blacklisted Slaves (Will Not Render):  " align:#left offset:[-10,-3] across:2
		label lbl_blackList " Blacklisted Slaves (May Render):       " align:#right offset:[10,-3]
		dotNetControl dnc_slavesList "ListView" width:230 height:160 align:#left offset:[-10,-3] across:2
		dotNetControl dnc_blackList "ListView" width:230 height:160 align:#right offset:[10,-3]
		
		button btn_selectAllSlaves "Select ALL" width:114 align:#left across:4 height:18 offset:[-9,-3] tooltip:"Select All Slaves in the left list."
		button btn_selectInvertSlaves "INVERT Selection" width:114 align:#left offset:[-9,-3] height:18 tooltip:"Invert Current Selection."
		button btn_selectAllList "Select ALL" width:114 align:#right offset:[10,-3] height:18 tooltip:"Select All Slaves in the right list."
		button btn_selectInvertList "INVERT Selection" width:114 align:#right height:18 offset:[10,-3] tooltip:"Invert Current Selection."
		
		edittext edt_filter "" text:"" across:4 align:#left offset:[-13,-3] fieldwidth:114
		button btn_update "UPDATE Slaves Info"  align:#left width:114 height:18 offset:[-9,-3] tooltip:"Reloads the Slave Names and Info from the Repository."
		
		checkbutton btn_ShowSlaveInfo ">SHOW Slave Info" align:#center width:100 height:18 offset:[4,-3] tooltip:"Show details about any selected Slaves."
		radiobuttons rad_blackList labels:#("Blacklist","Whitelist") offset:[15,0] align:#right columns:2 tooltip:"Controls whether the right list will be used as a Blacklist or Whitelist.\n\nWhen set to Blacklist, the machines listed on the right side will be excluded from rendering the submitted job, while the machines listed on the left will be allowed to work on it.\n\nWhen set to Whitelist, the machines listed on the right will be allowed to work on the job and the ones on the left will not."

		button btn_moveToList ">>" width:20 offset:[0,-187] height:72 tooltip:"Move selected Slaves to the right list" --images:#(oneArrowIconBitmap,oneArrowIconMask,2,1,1,2,2)
		button btn_moveToSlaves "<<" width:20 offset:[0,-5] height:72 tooltip:"Move selected Slaves back to the left list." --images:#(oneArrowIconReverseBitmap,oneArrowIconReverseMask,2,1,1,2,2)

		fn initDotNetControl lv foreColor BgColor =
		(
			local layout_def = #(#("Slave Name",120), #("Status",50), #("User",55) )
			lv.Clear()
			lv.backColor = (dotNetClass "System.Drawing.Color").fromARGB BgColor.r BgColor.g BgColor.b
			lv.foreColor = (dotNetClass "System.Drawing.Color").fromARGB foreColor.r foreColor.g foreColor.b
			lv.View = (dotNetClass "System.Windows.Forms.View").Details
			lv.gridLines = true
			lv.fullRowSelect = true
			lv.checkboxes = false
			lv.hideSelection = false
			--lv.HeaderStyle = lv.HeaderStyle.None
			for i in layout_def do lv.Columns.add i[1] i[2]
		)
		
		fn populateDotNetControl lv theList =
		(
			local theRange = #()
			lv.Items.clear()
			--local foreColor =  (dotNetClass "System.Drawing.Color").fromARGB SMTD_ColorPalette.textColor.r SMTD_ColorPalette.textColor.g SMTD_ColorPalette.textColor.b
			local offlineColor = (dotNetClass "System.Drawing.Color").fromARGB 150 150 150
			local idleColor = (dotNetClass "System.Drawing.Color").fromARGB 50 150 255
			local renderColor = (dotNetClass "System.Drawing.Color").fromARGB 0 200 50
			local stalledColor = (dotNetClass "System.Drawing.Color").fromARGB 255 50 50
			local startingColor = (dotNetClass "System.Drawing.Color").fromARGB 200 100 50
			
			for i in theList do
			(
				local li = dotNetObject "System.Windows.Forms.ListViewItem" i
				local theState = (getIniSetting theSlaveInfoFile i "SlaveStatus")
				local subLi = li.SubItems.add theState
				case theState of
				(
					"Offline": li.forecolor = offlineColor
					"Rendering": (li.forecolor = renderColor; subLi.text = "Render")
					"Idle": li.forecolor = idleColor
					"Stalled": li.forecolor = stalledColor
					default: li.forecolor = startingColor
				)
				local subLi = li.SubItems.add (getIniSetting theSlaveInfoFile i "UserName")
				append theRange li
			)	
			lv.Items.AddRange theRange
		)

		fn displaySlaveInfo theSlaves =
		(
			local tempArray = #()
			makeDir SMTDPaths.SettingsDir 
			makeDir (SMTDPaths.SettingsDir + "slaveselectionsets")
			local theSlaveInfoFile = (SMTDPaths.SettingsDir + "slaveselectionsets\\slavesinfo.ini" )
			for i in theSlaves do
			(
				theKeys = getIniSetting theSlaveInfoFile i
				append tempArray ("===[" + i + "]=================================================================================")
				for k in theKeys do 
					append tempArray (k + " = " + (getIniSetting theSlaveInfoFile i k))
			)
			try(SMTD_ShowSlaveInfo.lbx_slaveInfo.items = tempArray)catch()
		)
		
		fn storeSlaveList = 
		(
			local theListString = "#("
			if SMTDSettings.SlavesList.count > 0 do
			(
				for i = 1 to SMTDSettings.SlavesList.count-1 do theListString += "\"" + SMTDSettings.SlavesList[i] + "\","
				theListString += "\"" + SMTDSettings.SlavesList[SMTDSettings.SlavesList.count] 
			)	
			theListString += "\")"
			setIniSetting SMTDPaths.InIFile "Blacklist"  "SlavesList" theListString		
		)
		
		fn storeNamedSelectionSet =
		(
			setIniSetting SMTDPaths.InIFile "Blacklist"  "SlavesNamedSet"  (SMTDSettings.SlavesNamedSet )
			SMTD_MainRollout.Ui_report ("+Black/Whitelist: Named Slave Selection set to [" + SMTDSettings.SlavesNamedSet + "]")
		)	
		
		fn populateSlavelists =
		(
			local List1 = for i in (sort SMTDSettings.Slaves) where findItem SMTDSettings.SlavesList i == 0 collect i
			local List2 = for i in (sort SMTDSettings.SlavesList) collect i
			populateDotNetControl dnc_slavesList List1
			populateDotNetControl dnc_blackList List2
			storeSlaveList()
		)

		fn updateSlaveList forceUpdate:false=
		(
			if SMTDSettings.Slaves.count == 0 or forceUpdate do
			(
				SMTDFunctions.CollectSlaves()
			)	

			local BgColor1 = color 255 255 255
			local foreColor1 = color 50 50 50
			local BgColor2 = color 50 50 50
			local foreColor2 = color 255 255 255 
			if not SMTDSettings.SlavesBlackList then 
			(
				BgColor1 = color 50 50 50
				foreColor1 = color 255 255 255
				BgColor2 = color 255 255 255 
				foreColor2 = color 50 50 50
			)
			initDotNetControl dnc_slavesList foreColor1 BgColor1 
			initDotNetControl dnc_blackList foreColor2 BgColor2 
			
			populateSlavelists()
		)
		
		fn updateSelectionSetList =
		(
			local thePath = (SMTDPaths.SettingsDir + "slaveselectionsets")
			makeDir SMTDPaths.SettingsDir 
			makeDir thePath
			theSelSetFiles = getFiles (thePath + "\\*.slaves") 
			ddl_slaveSelSet.items = join #("[None]") (for f in theSelSetFiles collect getFileNameFile f)
			theIndex = findItem ddl_slaveSelSet.items SMTDSettings.SlavesNamedSet
			if theIndex == 0 do theIndex = 1
			ddl_slaveSelSet.selection = theIndex
		)	

		fn updateWhiteBlackListCaption =
		(
			case rad_blackList.state of
			(
				1:
				(
					lbl_slavesList.caption = "Whitelisted Slaves (May Render):" 
					lbl_blackList.caption = "Blacklisted Slaves (Will Not Render):" 
				)
				2:
				(
					lbl_slavesList.caption = "Blacklisted Slaves (Will Not Render):" 
					lbl_blackList.caption = "Whitelisted Slaves (May Render):"  
				)
			)
		
		)

		on chk_blacklistSticky changed state do
		(
			setIniSetting SMTDPaths.InIFile "Blacklist"  "SlaveSettingsSticky"  ((SMTDSettings.SlaveSettingsSticky = state) as string)
-- 			SMTD_MainRollout.Ui_report ("+Black/Whitelist: Make Settings Sticky set to [" + state as string + "]")
		)	
		
		on rad_blackList changed val do 
		(
			setIniSetting SMTDPaths.InIFile "Blacklist"  "BlackOrWhite" ( (SMTDSettings.SlavesBlackList = (val == 1) ) as string)
-- 			SMTD_MainRollout.Ui_report ("+Black/Whitelist: Mode set to [" + #("Blacklist","Whitelist")[val] + "]")
			updateWhiteBlackListCaption()
			updateSlaveList()
		)
		
		fn getListViewSelection lv =	--returns an array of the selected ListView items
		(
			try
				for i = 1 to lv.items.count where lv.items.item[i-1].Selected collect i
			catch 
				#()
		)

		fn setListViewSelection lv theSel =
		(
			for i = 1 to lv.items.count do lv.items.item[i-1].Selected = theSel[i]
		)
		
		on btn_selectAllSlaves pressed do
		(
			setListViewSelection dnc_slavesList #{1..dnc_slavesList.Items.Count}
		)
			
		on btn_selectInvertSlaves pressed do
		(
			local theSel = (getListViewSelection dnc_slavesList) as bitarray
			setListViewSelection dnc_slavesList (#{1..dnc_slavesList.Items.Count}-theSel)
		)
			
		on btn_selectAllList pressed do
		(
			setListViewSelection dnc_blackList #{1..dnc_blackList.Items.Count}
		)
			
		on btn_selectInvertList pressed do
		(
			local theSel = (getListViewSelection dnc_blackList) as bitarray
			setListViewSelection dnc_blackList (#{1..dnc_blackList.Items.Count}-theSel)
		)
			
		on edt_filter changed txt do
		(	
			if txt != "" then
			(
				local theSel = (for i = 1 to dnc_slavesList.items.count where matchPattern dnc_slavesList.items.item[i-1].text pattern:(txt+"*") collect i) as bitarray
				setListViewSelection dnc_slavesList theSel
			)
			else	
				setListViewSelection dnc_slavesList #{}
		)
		
		on btn_update pressed do
		(
			SMTDFunctions.CollectSlavesInfo()
			updateSlaveList forceUpdate:true
		)
		
		on btn_moveToList pressed do
		(
			local theSel = getListViewSelection dnc_slavesList
			local tempArray = deepCopy SMTDSettings.SlavesList 
			--local tempArray = for i = 1 to dnc_blackList.items.count collect dnc_blackList.items.item[i-1].text
			local tempArray2 = (for i in theSel collect dnc_slavesList.items.item[i-1].text)
			join tempArray tempArray2
			sort tempArray 
			SMTDSettings.SlavesList = deepCopy tempArray
			populateSlavelists()
			theSel = for i in tempArray2 collect findItem tempArray i
			setListViewSelection dnc_blackList (theSel as bitarray)	
		)
		
		on btn_moveToSlaves pressed do
		(
			local theSel = getListViewSelection dnc_blackList
			local tempArray = deepCopy SMTDSettings.SlavesList 
			local tempArray2 = for i in theSel collect SMTDSettings.SlavesList[i]
			for i = theSel.count to 1 by -1 do deleteItem tempArray theSel[i]
			SMTDSettings.SlavesList = deepCopy tempArray
			populateSlavelists()
			local tempArray3 = for i = 1 to dnc_slavesList.items.count collect dnc_slavesList.items.item[i-1].text
			theSel = for i in tempArray2 collect findItem tempArray3 i
			setListViewSelection dnc_slavesList (theSel as bitarray)		
		)
		
		on dnc_slavesList DoubleClick EventArgs do btn_moveToList.pressed()
		on dnc_blackList DoubleClick EventArgs do btn_moveToSlaves.pressed()
		
		on dnc_slavesList ItemSelectionChanged EventArgs do
		(	
			local theSel = getListViewSelection dnc_slavesList
			local tempArray = for i in theSel collect dnc_slavesList.items.item[i-1].text
			local theSel2 = getListViewSelection dnc_blackList
			join tempArray (for i in theSel2 collect dnc_blackList.items.item[i-1].text)
			displaySlaveInfo tempArray
		)	
		on dnc_blackList ItemSelectionChanged EventArgs do
		(	
			local theSel = getListViewSelection dnc_slavesList
			local tempArray = for i in theSel collect dnc_slavesList.items.item[i-1].text
			local theSel2 = getListViewSelection dnc_blackList
			join tempArray (for i in theSel2 collect dnc_blackList.items.item[i-1].text)
			displaySlaveInfo tempArray
		)	
		
		
		on btn_ShowSlaveInfo changed state do 
		(
			if state then
			(
				if SMTDSettings.SlaveInfoCollected == false do
				(
					SMTDFunctions.CollectSlavesInfo()
					SMTDSettings.SlaveInfoCollected = true
				)	
				try(destroyDialog SMTD_ShowSlaveInfo)catch()
				
				local thePos = [100,100]
				local theVal = getIniSetting SMTDPaths.InIFile "Dialog" "Position"
				if theVal != "" do thePos = execute theVal
				createDialog SMTD_ShowSlaveInfo 400 730 (thePos.x+510) thePos.y
				
				local theSel = getListViewSelection dnc_slavesList
				local tempArray = for i in theSel collect dnc_slavesList.items.item[i-1].text
				local theSel2 = getListViewSelection dnc_blackList
				join tempArray (for i in theSel2 collect dnc_blackList.items.item[i-1].text)
				displaySlaveInfo tempArray
			)
			else
				try(destroyDialog SMTD_ShowSlaveInfo)catch()	
		)

		
		on btn_saveSelSet pressed do
		(
			if edt_SelSetName.text != "" then
			(
				local theFileName = (SMTDPaths.SettingsDir + "slaveselectionsets\\" + edt_SelSetName.text + ".slaves" )
				if doesFileExist theFileName then
-- 					SMTD_MainRollout.Ui_report ("+Black/Whitelist: Updated Slave Selection Set [" + edt_SelSetName.text + "]." )
-- 				else	
-- 					SMTD_MainRollout.Ui_report ("+Black/Whitelist: Created Slave Selection Set [" + edt_SelSetName.text + "]." )
				
				local theFile = createFile theFileName
				if theFile != undefined then
				(
					tempArray = SMTDSettings.SlavesList
					for i in tempArray do
						format "%\n" i to:theFile
					close theFile
					SMTDSettings.SlavesNamedSet = edt_SelSetName.text
					storeNamedSelectionSet()
					--edt_SelSetName.text = ""
					updateSelectionSetList()
				)	
			)
-- 			else
-- 				SMTD_MainRollout.Ui_report ("--Black/Whitelist: Could NOT Save - No Name for the Slave Selection Set specified.")
		)
		
		on btn_exploreSelSet pressed do
		(
			shellLaunch "explorer.exe" (SMTDPaths.SettingsDir + "slaveselectionsets\\")
		)
		
		
		on btn_deleteSelSet pressed do
		(
			if edt_SelSetName.text != "" then
			(
				local theFileName = (SMTDPaths.SettingsDir + "slaveselectionsets\\" + edt_SelSetName.text + ".slaves" )
				if doesFileExist theFileName then
				(
					local q = querybox ("Delete Slave Selection Set ["+edt_SelSetName.text+"]?\nIf you click Yes, a Backup of the Selection Set will be created.\nYou can restore the Selection Set by pressing [E] to Explore the folder\nand by removing the .BAK Extension manually.") title:"Delete Slave Selection Set"
					if q then
					(
						if doesFileExist (theFileName+".bak") do deleteFile (theFileName+".bak")
						renameFile theFileName (theFileName+".bak")
-- 						SMTD_MainRollout.Ui_report ("+Black/Whitelist: Removed Slave Selection Set [" + edt_SelSetName.text + "]. Backup File Created." )
						updateSelectionSetList()
						edt_SelSetName.text = ""
					)
				)
-- 				else
-- 					SMTD_MainRollout.Ui_report ("+Black/Whitelist: Could NOT Remove Slave Selection Set [" + edt_SelSetName.text + "] - No Such List!" )
			)		
		)		
		
		on ddl_slaveSelSet selected itm do
		(
			if itm > 1 then
			(
				local theFileName = theSelSetFiles[itm-1]
				local theFile = openFile theFileName
				local theArray = #()
				while not eof theFile do
					append theArray (readline theFile)
				close theFile
				SMTDSettings.SlavesList = deepCopy theArray
				populateSlavelists()
			)
			else
			(
				SMTDSettings.SlavesList = #()
				populateSlavelists()
				--mlb_blackList.items = #()
				--mlb_slavesList.items = for i in (sort SMTDSettings.Slaves) collect i
			)	
			edt_SelSetName.text = SMTDSettings.SlavesNamedSet = ddl_slaveSelSet.selected
			storeNamedSelectionSet()
			if itm == 1 then edt_SelSetName.text = ""
			storeSlaveList()
		)
		
		on SMTD_BlackListSlaves open do
		(
			if SMTDSettings.SlaveInfoCollected == false do 
			(
				SMTDFunctions.CollectSlavesInfo()
				SMTDSettings.SlaveInfoCollected = true
			)
			
			chk_blacklistSticky.state = SMTDSettings.SlaveSettingsSticky
			rad_blackList.state = if SMTDSettings.SlavesBlackList then 1 else 2
				
			updateSlaveList()
			updateSelectionSetList()
			updateWhiteBlackListCaption()
		)	
		
		on SMTD_BlackListSlaves close do
		(
			try(destroyDialog SMTD_ShowSlaveInfo)catch()	
		)	
		
		on btn_help_blacklist pressed do ShellLaunch  (SMTD_HelpURL + "#limits-tab") ""
	)
