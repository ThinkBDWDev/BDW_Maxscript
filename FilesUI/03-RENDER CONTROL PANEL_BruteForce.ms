

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



try(destroydialog _AnimCRTLBF)catch()		
rollout _AnimCRTLBF "Animation Control Panel"
(


progressbar SubmissionProg color:green
edittext FolderName "Add Folder" text:"name" across:2 align:#left width:100
button _ADD "Add"across:2 align:#right
listbox _PRJ "Project Selector" height:RenderPath.count items:RenderPathUI
	
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

	
spinner _IrrMode "Brute Force Samples" type:#integer range:[0,64,24] align:#left width:90
spinner _LCSubdivs "Light Cache" type:#integer range:[500,4500,1500] align:#left width:125 across:2
checkbox _LightLink "LL" align:#Right  across:2 
edittext _nameString "Name Suffix" 

	

button _FTA "Brute Force Animations" width:150
		on _FTA pressed do
		(
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
				vr.gi_primary_type = 2
				vr.gi_secondary_type = 3

				rendTimeType = 3
				vr.output_saveRawFile = false
				vr.options_dontRenderImage = False
				
				vr.dmcgi_subdivs = _IrrMode.value
				vr.lightcache_subdivs = _LCSubdivs.value
				vr.lightcache_multipleViews = True
				vr.lightcache_mode = 0		

				CamName = i.name + "_" + _nameString.text  --Camera Name
				RenDIR = RenderPath[_PRJ.selection] --Render Directory
				RenCamDir = RenDIR + CamName -- Render Output 

						
				print RenCamDir
				makedir RenCamDir

				
				JobName = (_PRJ.selected + "_Prepass_") + CamName	
				Print JobName
				
				PriorSVal = (_PriorS.value + 1)
				SuspVal = SUSP.state
				

						
				rendTimeType = 3
				rendSaveFile = true
				rendoutputfilename = RenCamDir + @"\" + CamName + "_" + ".exr"-- Filename + Format

				JobName = (_PRJ.selected + "_Animation_") + CamName	
				Print JobName
				
				--------------------------------
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

				--------------------------------
				SuspVal = SUSP.state
				PriorSVal = _PriorS.Value
				_Dep = False
			
				submitTD JobName SuspVal PriorSVal   -- Submit to Deadline Prepass
				
				LoopState = LoopState + 1
				SubmissionProg.value = 100*LoopState/Temp.count		
			
			SetSelectFilter 1
			
			
				
-- 			)
				
		)
	)

	
	
	
	
	on _USERSEL moved pos do setDialogPos _AnimCRTL (pos+[0,_USERSEL.height+60])
)

createdialog _AnimCRTLBF width:165 pos:[(getDialogpos _USERSEL)[1],(getDialogPos _USERSEL)[2]+_USERSEL.height+60]
-- createdialog _AnimCRTL width:165



