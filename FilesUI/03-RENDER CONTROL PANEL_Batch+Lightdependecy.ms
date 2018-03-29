

JobNameGRP = #()
JobIDGrp = #()
-- DEADLINE Submission Function 
--------------------------------------------------------
fn submitTD JobName SuspVal PriorSVal  = 
(
global SMTDSettings
global SMTDFunctions

local theNetworkRoot = @"\\CGISERVER\Repository"
local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"    
fileIn remoteScript 
            
SMTDFunctions.loadSettings()
SMTDSettings.JobName = JobName 
SMTDSettings.priority = PriorSVal
SMTDSettings.RegionRenderingMode=#none
SMTDSettings.SubmitAsSuspended = SuspVal

local maxFileToSubmit = SMTDPaths.tempdir + maxFileName
SMTDFunctions.SaveMaxFileCopy maxFileToSubmit
    
local SubmitInfoFile = SMTDPaths.tempdir + "\\max_submit_info.job"
local JobInfoFile = SMTDPaths.tempdir  + "\\max_job_info.job"

SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
SMTDFunctions.CreateJobInfoFile JobInfoFile  
                            
local initialArgs="\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+"\" " 
SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission



)--end script

fn submitTDDep JobName SuspVal PriorSVal  _Dep = 
(
global SMTDSettings
global SMTDFunctions

local theNetworkRoot = @"\\CGISERVER\Repository"
local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"    
fileIn remoteScript 
            
SMTDFunctions.loadSettings()
SMTDSettings.JobName = JobName 
SMTDSettings.priority = PriorSVal
SMTDSettings.RegionRenderingMode=#none
SMTDSettings.SubmitAsSuspended = SuspVal
SMTDSettings.SubmitAsDependent = _Dep
SMTDSettings.DependOnPreviousJobMode = #none

SMTDSettings.JobsArray = #(#(JobNameGRP[1], JobIDGrp[1]))
SMTDSettings.dependencyJobItems = #(1)

local maxFileToSubmit = SMTDPaths.tempdir + maxFileName
SMTDFunctions.SaveMaxFileCopy maxFileToSubmit
    
local SubmitInfoFile = SMTDPaths.tempdir + "\\max_submit_info.job"
local JobInfoFile = SMTDPaths.tempdir  + "\\max_job_info.job"

SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
SMTDFunctions.CreateJobInfoFile JobInfoFile  
                            
local initialArgs="\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+"\" " 
SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission



)--end script

-------------------------------------------------------

SetSelectFilter 5

RenderPath = getdirectories (@"\\CGISERVER\BDWRenderC\CGIRender\" + _UserSelected + @"\*")
RenderPathUI = #()

for i =1 to RenderPath.count do
	(
		RenderPathUI[i] = (filterstring RenderPath[i] @"\")[5]
		
		)
		
print RenderPathUI

global Cams = for i in cameras collect i.name



try(destroydialog _AnimCRTL)catch()		
rollout _AnimCRTL "Animation Control Panel"
(

on _AnimCRTL open do
	(
		if framerate != 25 then (messagebox "your scene is not set to 25 FPS!!")
		)
	
	
	
progressbar SubmissionProg color:green
edittext FolderName "Add Folder" text:"name" across:2 align:#left width:100
button _ADD "Add"across:2 align:#right
listbox _PRJ "Project Selector" height:RenderPath.count items:RenderPathUI
checkbox Manual "M" across:3
spinner StartFr "" type:#integer across:3 width:50 range:[0,2000,0]
spinner EndFr "" type:#integer	 across:3 width:50 range:[0,2000,0]
	on _ADD pressed do
		(
			NewFolder = FolderName.text
			_PRJ.items = append _PRJ.items (NewFolder as string)
			makedir (@"\\CGISERVER\BDWRenderC\CGIRender\" + _UserSelected + @"\" + NewFolder)
			::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\03-RENDER CONTROL PANEL_Batch+Lightdependecy.ms"
			
			
			)
	

	on _PRJ rightClick do
	(
		OpenDIR = RenderPath[_PRJ.selection]
	
		shelllaunch OpenDIR ""
		
		)
spinner _PriorS "Job Priority" range:[0,99,50] type:#integer across:2  width:110 align:#Left 
checkbox SUSP "S" across:2 align:#Right 

	
spinner _IrrMode "Irradiance Presset" type:#integer range:[0,4,4] align:#left width:90
spinner _LCSubdivs "Light Cache" type:#integer range:[500,4500,1500] align:#left width:125 across:2
checkbox _LightLink "LL" align:#Right  across:2 
edittext _nameString "Name Suffix" 
button _FTPP "Flythrough" width:150
		on _FTPP pressed do
		(
			escapeEnable = true
			SubmissionProg.value = 0
			LoopState = 0
			global _Dep = ""
			global JobNameGRP = #()
			global JobIDGrp = #()
			-----------------------------------------------------------------------
			
			-- VRAY SETTINGS
			
			if renderSceneDialog.isopen() == true then renderSceneDialog.close() -- Close render Dialog
			
			
	Temp = (selection as array)	
	
		if Temp.count == 0 then 
			(
				messagebox "Select Cameras for Submission"
-- 				try(Destroydialog _AnimCRTL)catch()
			)
							
	for i in Temp do 
		(	
						if _LightLink.state == true then
							(
						for i in lights where classof i == VRaylight and i.type == 1 do
							(
								i.on = false
								
								)
						for i in lights where classof i == VRaySun do
						(
							i.enabled = false
							)	
						
						select i --Select Camera
						-----------------
						--LIGHT DEPENDENCY
						
						CC = i.name
						CCC = "*" + CC + "*"
						
						
						LightsCam = (lights as array)
						
						for b in LightsCam  where matchpattern b.name pattern:CCC and classof b == VRaySun do
							(
		-- 						append LightsCam o
								b.enabled = true
														)
														
						for o in LightsCam  where matchpattern o.name pattern:CCC and classof o == VRaylight do
							(
		-- 						append LightsCam o
								o.on = true
								global BG = o.texmap
														)
														
								environmentMap = BG	
					)
				
				-----------------
			
					
				select i
				viewport.setType #view_camera --Set Viewport to camera
				-- Sort Keyframes
					if Manual.state == false then
						(
				num_keys = numkeys $.position.controller 
					if num_keys != -1 then(
				StartKey = getkeytime $.position.controller 1
				EndKey = StartKey
	
				for i = 1 to num_keys do
					(key_time = getkeytime $.position.controller i
						if key_time > EndKey then
						EndKey = key_time))
				else(
					Startkey = $.pos.controller[2].percent.keys[1].time
					Endkey = $.pos.controller[2].percent.keys[2].time
					)
						)else
						(
						Startkey = StartFr.value
						EndKey = EndFr.Value
						)
						
				rendStart = Startkey
				rendEnd = Endkey
										
				animationRange = interval StartKey EndKey
						
				vr = renderers.current -- Set Vray As current Render
	
				vr.gi_on = true 
				vr.gi_primary_type = 0
				vr.gi_secondary_type = 3
				
				rendTimeType = 1
				rendSaveFile = false
				vr.options_dontRenderImage = true
				vr.gi_irradmap_preset = _IrrMode.value
				vr.adv_irradmap_mode = 0
				vr.adv_irradmap_autoSave = true
				vr.gi_irradmap_multipleViews = true
				
				vr.lightcache_subdivs = _LCSubdivs.value
				vr.lightcache_multipleViews = true
				vr.lightcache_mode = 0
				--
						
				CamName = i.name + "_" + _nameString.text --Camera Name 
				RenDIR = RenderPath[_PRJ.selection] --Render Directory
				RenCamDir = RenDIR + CamName  -- Render Output 
						
						
				IRMapName = CamName + ".vrmap"	
				IRMapDir =RenCamDir + @"\" + IRMapName
				vr.adv_irradmap_autoSaveFileName = IRMapDir --Irradiance Map Directory
						
				print RenCamDir
				makedir RenCamDir
						
								
-- 				clearselection()
				
				JobName = (_PRJ.selected + "_Prepass_") + CamName	
				Print JobName
				
				PriorSVal = (_PriorS.value + 1)
				SuspVal = SUSP.state
				
				JobNameGRP[1] = JobName

				_Dep = False
				submitTDDep JobName SuspVal PriorSVal  _Dep -- Submit to Deadline Prepass
				
				SMTDFunctions.GetJobIDFromMessage (SMTDFunctions.GetRenderMessage())
				JobIDGrp[1] = SMTDSettings.DeadlineSubmissionLastJobID 
					



			---------------------------------------------------------------------------------------------------------
-- 			ANIMATION SUBMISSION
			---------------------------------------------------------------------------------------------------------			
			
		
				
								
				rendTimeType = 3
				rendSaveFile = true
				
				vr.options_dontRenderImage = False
				vr.gi_on = true
				vr.gi_primary_type = 0
				vr.gi_secondary_type = 0
					
				vr.gi_irradmap_preset = _IrrMode.value
				vr.adv_irradmap_mode = 2		
				--
						
				CamName = i.name + "_" + _nameString.text--Camera Name
				RenDIR = RenderPath[_PRJ.selection]  --Render Directory
				RenCamDir = RenDIR + CamName -- Render Output 
						
						
				IRMapName = CamName + ".vrmap"	
				IRMapDir =RenCamDir + @"\" + IRMapName
				

				fopenexr.SetCompression 7 
				fopenexr.setSaveScanline false 
				fopenexr.setSaveRegion false	
-- 				vr.output_getsetsfrommax =true
-- 				vr.output_splitRGB =true
-- 				vr.output_splitAlpha =true
-- 				vr.output_rawExrUseHalf = true
					
					
				rendoutputfilename = RenCamDir + @"\" + CamName + "_" + ".exr"-- Filename + Format

				vr.adv_irradmap_loadFileName = IRMapDir		 --Irradiance Map Directory					
				vr.gi_irradmap_multipleViews = true

				JobName = (_PRJ.selected + "_Animation_") + CamName	
				Print JobName
				
				--------------------------------
-- 				if renderSceneDialog.isopen() == true then renderSceneDialog.close()
					global Rout = rendOutputFilename 
					global Rout_path_array = undefined
					global Rout_path = undefined
					global Rout_fileName = undefined
					global Rout_fileExt = undefined

					if Rout != "" then
					(
						Rout_path = getFilenamePath Rout
						Rout_fileName = getFilenameFile Rout
					) else messagebox "Please set the render path first"
						
					re = maxOps.GetCurRenderElementMgr()

					NmElements = re.NumRenderElements()

					if ((NmElements > 0) and (Rout != "")) then
					(
					for x = 0 to (NmElements - 1) do
					(
						DirfileNameType = getFilenameType (re.GetRenderElementFilename x)
							
						path3 = re.GetRenderElement x
						ElementfileName2 = path3.elementname
						ElementfileName3 = Rout_fileName + "_" + ElementfileName2 + "_" + DirfileNameType 
						
						makedir (Rout_path+ElementfileName2)
						re.SetRenderElementFilename x (Rout_path+ElementfileName2+"\\"+ElementfileName3)
						
					)

					)
-- 					else 
-- 						(
-- 							
-- 							if NmElements == 0 then (messageBox "Please add some render elemens first")
-- 						)
				
				--------------------------------
					
					
				SuspVal = SUSP.state
				PriorSVal = _PriorS.Value
				_Dep = true
			
				submitTDDep JobName SuspVal PriorSVal _Dep   -- Submit to Deadline Prepass
			
			
	
	LoopState = LoopState + 1
	SubmissionProg.value = 100*LoopState/Temp.count		
			
			
				
			
				
		)
			
	)
	

button _FTA "Animations" width:150
		on _FTA pressed do
		(
			escapeEnable = true
			SubmissionProg.value = 0
			LoopState = 0
			global _Dep = ""
			global JobNameGRP = #()
			global JobIDGrp = #()
			-----------------------------------------------------------------------
			
			-- VRAY SETTINGS
			
			if renderSceneDialog.isopen() == true then renderSceneDialog.close() -- Close render Dialog

			
			-----------------------------------------------------------------------
			Temp = (selection as array)	
				if Temp.count == 0 then 
					(
						messagebox "Select Cameras for Submission"
-- 						try(Destroydialog _AnimCRTL)catch()
						)
					
			for i in Temp do 
			(	
				
				
				
				
				if _LightLink.state == true then
							(
						for i in lights where classof i == VRaylight and i.type == 1 do
							(
								i.on = false
								
								)
						for i in lights where classof i == VRaySun do
						(
							i.enabled = false
							)	
						
						select i --Select Camera
						-----------------
						--LIGHT DEPENDENCY
						
						CC = i.name
						CCC = "*" + CC + "*"
						
						
						LightsCam = (lights as array)
						
						for b in LightsCam  where matchpattern b.name pattern:CCC and classof b == VRaySun do
							(
		-- 						append LightsCam o
								b.enabled = true
														)
														
						for o in LightsCam  where matchpattern o.name pattern:CCC and classof o == VRaylight do
							(
		-- 						append LightsCam o
								o.on = true
								global BG = o.texmap
														)
														
								environmentMap = BG	
					)	
												
												
				select i								
				viewport.setType #view_camera --Set Viewport to camera
				-- Sort Keyframes
				num_keys = numkeys $.position.controller 
				StartKey = getkeytime $.position.controller 1
				EndKey = StartKey
	
				for i = 1 to num_keys do
					(key_time = getkeytime $.position.controller i
						if key_time > EndKey then
						EndKey = key_time)
						
				rendStart = Startkey
				rendEnd = Endkey
										
				animationRange = interval StartKey EndKey
						
				vr = renderers.current -- Set Vray As current Render
				vr.gi_on = true 
				rendSaveFile = false
				vr.gi_primary_type = 0
				vr.gi_secondary_type = 3
				
				
				rendTimeType = 3
				vr.output_saveRawFile = false
				vr.options_dontRenderImage = true
				vr.gi_irradmap_preset = _IrrMode.value
				vr.adv_irradmap_mode = 6
				

				vr.options_dontRenderImage = true
				vr.adv_irradmap_autoSave = true
				vr.gi_irradmap_multipleViews = true
				
				vr.lightcache_subdivs = _LCSubdivs.value
				vr.lightcache_multipleViews = False
				vr.lightcache_mode = 0		
				--
						
				CamName = i.name + "_" + _nameString.text  --Camera Name
				RenDIR = RenderPath[_PRJ.selection] --Render Directory
				RenCamDir = RenDIR + CamName -- Render Output 
						
						
				IRMapName = CamName + ".vrmap"	
				IRMapDir =RenCamDir + @"\" + IRMapName
				vr.adv_irradmap_autoSaveFileName = IRMapDir --Irradiance Map Directory
						
				print RenCamDir
				makedir RenCamDir
						
								
-- 				clearselection()
				
				JobName = (_PRJ.selected + "_Prepass_") + CamName	
				Print JobName
				
				PriorSVal = (_PriorS.value + 1)
				SuspVal = SUSP.state
				
				JobNameGRP[1] = JobName

				_Dep = False
				submitTDDep JobName SuspVal PriorSVal  _Dep -- Submit to Deadline Prepass
				
				SMTDFunctions.GetJobIDFromMessage (SMTDFunctions.GetRenderMessage())
				JobIDGrp[1] = SMTDSettings.DeadlineSubmissionLastJobID 
					



			---------------------------------------------------------------------------------------------------------
-- 			ANIMATION SUBMISSION
			---------------------------------------------------------------------------------------------------------			
			
						
				rendTimeType = 3
				rendSaveFile = true
			
				vr.options_dontRenderImage = False
				vr.gi_on = true
				vr.gi_primary_type = 0
				vr.gi_secondary_type = 0
					
				vr.gi_irradmap_preset = _IrrMode.value
				vr.adv_irradmap_mode = 7		
				--
						
				CamName = i.name + "_" + _nameString.text --Camera Name
				RenDIR = RenderPath[_PRJ.selection] --Render Directory
				RenCamDir = RenDIR + CamName -- Render Output 
						
						
				IRMapName = CamName + ".vrmap"	
				IRMapDir =RenCamDir + @"\" + IRMapName
				
				
				fopenexr.SetCompression 7 
				fopenexr.setSaveScanline false 
				fopenexr.setSaveRegion false	
-- 				vr.output_getsetsfrommax =true
-- 				vr.output_splitRGB =true
-- 				vr.output_splitAlpha =true
-- 				vr.output_rawExrUseHalf = true
					
					
				rendoutputfilename = RenCamDir + @"\" + CamName + "_" + ".exr"-- Filename + Format

				vr.adv_irradmap_loadFileName = IRMapDir		 --Irradiance Map Directory					
				vr.gi_irradmap_multipleViews = true

				JobName = (_PRJ.selected + "_Animation_") + CamName	
				Print JobName
				
				--------------------------------
-- 				if renderSceneDialog.isopen() == true then renderSceneDialog.close()
					global Rout = rendOutputFilename 
					global Rout_path_array = undefined
					global Rout_path = undefined
					global Rout_fileName = undefined
					global Rout_fileExt = undefined

					if Rout != "" then
					(
						Rout_path = getFilenamePath Rout
						Rout_fileName = getFilenameFile Rout
					) else messagebox "Please set the render path first"
						
					re = maxOps.GetCurRenderElementMgr()

					NmElements = re.NumRenderElements()

					if ((NmElements > 0) and (Rout != "")) then
					(
					for x = 0 to (NmElements - 1) do
					(
						DirfileNameType = getFilenameType (re.GetRenderElementFilename x)
							
						path3 = re.GetRenderElement x
						ElementfileName2 = path3.elementname
						ElementfileName3 = Rout_fileName + "_" + ElementfileName2 + "_" + DirfileNameType 
						
						makedir (Rout_path+ElementfileName2)
						re.SetRenderElementFilename x (Rout_path+ElementfileName2+"\\"+ElementfileName3)
						
					)

					)
-- 					else 
-- 						(
-- 							
-- 							if NmElements == 0 then (messageBox "Please add some render elemens first")
-- 						)
				
				--------------------------------
				SuspVal = SUSP.state
				PriorSVal = _PriorS.Value
				_Dep = true
			
				submitTDDep JobName SuspVal PriorSVal _Dep   -- Submit to Deadline Prepass
				
				LoopState = LoopState + 1
				SubmissionProg.value = 100*LoopState/Temp.count		
			
			SetSelectFilter 1
			
			
				
-- 			)
				
		)
	)

	
	
	
	
	on _USERSEL moved pos do setDialogPos _AnimCRTL (pos+[0,_USERSEL.height+60])
)

createdialog _AnimCRTL width:165 pos:[(getDialogpos _USERSEL)[1],(getDialogPos _USERSEL)[2]+_USERSEL.height+60]
-- createdialog _AnimCRTL width:165



