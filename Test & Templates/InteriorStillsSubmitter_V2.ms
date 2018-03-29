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
	
SMTDSettings.RegionRenderingMode= #singleFrameTiles --  enable it and set the tile counts...
SMTDSettings.TilesInX = 4--spn_TilesInX.value
SMTDSettings.TilesInY = 4--spn_TilesInY.value
SMTDSettings.TilesPadding = 0 -- This could be exposed to the artist, but it is up to you. Just add a spinner and set to its value,,,
			
-- The following settings are also related to single frame tile rendering, you can expose them to the user if you want, or set them up as you want them 
SMTDSettings.SingleTileJobDependent = true --Should be True
SMTDSettings.SingleTileJobCleanup = true --Delete the tiles after assembly (normally it is False)
SMTDSettings.SingleTileJobDraft = true --Should be True to use Draft, False to use the old tile assembler. Keep it True.
SMTDSettings.SingleTileJobDraftErrorOnMissing = true --Defaults to True, should be left at True. If False, running the Draft Assembly 	

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



clearlistener()

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
		spinner IRSubs "IR Subdivs          " type:#integer range:[0,100,vr.gi_irradmap_subdivs] fieldwidth:40 align:#right pos:[10,240]
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
		spinner _PriorS "Priority"  type:#integer range:[0,99,75] fieldwidth:40  width:100 pos:[10,375]
		checkbox SUSP "Suspended Job"  align:#Right  pos:[155,375]
		button submit "Submit Image" pos:[10,400] width:250 height:40
		
		edittext PresetName "Preset Name"  width:250 pos:[285,375]
		button _SaveS "Save State" pos:[285,400] width:115 height:40
		dropdownlist RenderP "Load State" pos:[420,396] width:115 items:PresetDirUI
		
		progressbar SubProg orient:#vertical pos:[550,10] color:Red width:35 height:430		
		
		--#### UI FUNCTIONALITY
		-------------------------------------
		
		on SubProg clicked O do
			(if keyboard.escPressed do exit)
		
		on _SaveS pressed do
				(
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
				RenderSettings.checked = RDialog
				CrlTypeNumber = (vr.colorMapping_type)
				ClrType.selection = (CrlTypeNumber + 1)
				)
		
				
		on _ADD pressed do
			(
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
			(renderWidth = O)
		on ImgH changed P do
			(renderHeight = P)
		on MinShRate changed Q do
			(vr.imageSampler_shadingRate = Q)
		on MinSubs changed A do
			(vr.twoLevel_baseSubdivs = A)
		on MaxSubs changed B do
			(vr.twoLevel_fineSubdivs = B)
		on ClrTh changed C do
			(vr.twoLevel_threshold = C)
		on LocalSubs changed P do
			(vr.dmc_useLocalSubdivs = P )
		on AffectBG changed P do
			(vr.colorMapping_affectBackground = P)
		on ClrType selected D do
			(vr.colorMapping_type = (D-1))
		on IRMin changed F do
			(vr.gi_irradmap_minRate = F)
		on IRMax changed G do
			(vr.gi_irradmap_maxRate = G)
		on IRSubs changed H do
			 (vr.gi_irradmap_subdivs = H)
		on IRInter changed I do
			(vr.gi_irradmap_interpSamples = I)
		on IRClrTh changed J do
			( vr.gi_irradmap_colorThreshold = J)
		on NorTh changed K do
			(vr.gi_irradmap_normalThreshold = K)
		on DisTh changed L do
			(vr.gi_irradmap_distThreshold = L)
		on LCSubs changed M do
			(vr.lightcache_subdivs = M)
		on SampleSize changed N do
			(vr.lightcache_sampleSize = N)
		on IntSamples changed O do
			(vr.lightcache_interpSamples = O)
		on Prefilter changed O do
			(vr.lightcache_prefilter_on = O)
		on FInter changed P do
			(vr.lightcache_prefilter_samples = P)
		
		
		on RenderSettings changed state do
			(
				if state == on then
					(renderscenedialog.open())
				if state == off then
					(renderscenedialog.close())
				)		
		
		
		on submit pressed do
			(
				actionMan.executeAction 0 "40247"  -- Selects Current Camera View
				CamName = $.Name 
				
				
		--#### PREPASS SUBMISSION
		--------------------------------------------
			vr.gi_on = true 
			vr.gi_primary_type = 0
			vr.gi_secondary_type = 3


				
			rendTimeType = 1
			rendSaveFile = false
			vr.output_on =true
			vr.output_saveFile =true
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
			

			
			Print RenCamDir												
			IRMapName = CamName + ".vrmap"	
			IRMapDir =RenCamDir + @"\" + "IM" + @"\" + IRMapName
			IRMapFolder =RenCamDir + @"\" + "IM"
			makedir IRMapFolder
			vr.adv_irradmap_autoSaveFileName = IRMapDir --Irradiance Map Directory

			vr.lightcache_mode = 0
			vr.adv_irradmap_mode = 0
			vr.lightcache_autoSave = true
			LCMapName = CamName + ".vrlmap"
			LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
			LCMapFolder =RenCamDir + @"\" + "LC"
			makedir LCMapFolder
			vr.lightcache_autoSaveFileName = LCMapDir
									
			makedir RenCamDir

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
														
			vr.output_splitgbuffer =true
					
			rendTimeType = 1
			rendSaveFile = false
			
			vr.options_dontRenderImage = False

			vr.adv_irradmap_autoSave = false
			vr.lightcache_mode = 2
			vr.adv_irradmap_mode = 2
			fopenexr.SetCompression 7 
			fopenexr.setSaveScanline false 
			fopenexr.setSaveRegion false	
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
			vr.lightcache_autoSave = False
			LCMapName = CamName + ".vrlmap"
			LCMapDir =RenCamDir + @"\" + "LC" + @"\" + LCMapName
			LCMapFolder =RenCamDir + @"\" + "LC"
			vr.lightcache_loadFileName = LCMapDir
									
			print RenCamDir
			makedir RenCamDir

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
				
				)
		
	)
	createdialog IntStillsSubmitter width:600 height:450 --bgcolor:[50,50,50]
