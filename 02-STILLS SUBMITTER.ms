/*

Select Path for output (Root)

Set Outputpath for RE based on RGB output path

turn off VRFB

Launch SMTD 

V 1.0

Rodri G.

*/
try(destroydialog _Psetup) catch()
rollout _Psetup "Path Setup"
(
	button _AutoPath "Auto Path" width: 100 height: 50
	on _AutoPath pressed do
	(
				
			if DIR == undefined then
			
			(
		
			global DIR = getSavePath initialDir:"//CGISERVER/BDWRenderC/CGIRender/"
-- 			global selectedPath = getSavePath initialDir:"//CGISERVER/BDWRenderC/CGIRender/"
-- 			persistent global X = selectedPath
-- 			messagebox (X as string)
			print DIR
				)
			
			
				if renderSceneDialog.isopen() == true then renderSceneDialog.close()
				
				actionMan.executeAction 0 "40068"
				global curcam = try(getActiveCamera()) catch()
				if curcam != undefined do select curcam
				global CamName = curcam.name
				global RenderDir = DIR + "/" + CamName
				clearselection()
				Messagebox RenderDir
				
				if querybox ("Create " +  RenderDir + " Directory?") beep:true then
				(
				makedir RenderDir
				)
			
			rendSaveFile = true -- Enable File Save
			rendoutputfilename = RenderDir + @"\" + CamName + "_" + ".exr"-- Filename + Format
			
				renderSceneDialog.open()		
-- 			else
-- 				(
-- 								if renderSceneDialog.isopen() == true then renderSceneDialog.close()
-- 								actionMan.executeAction 0 "40068"
-- 								global curcam = try(getActiveCamera()) catch()
-- 								if curcam != undefined do select curcam
-- 								global CamName = curcam.name
-- 								global RenderDir = X + "/" + CamName
-- 								makedir RenderDir
-- 									)	
		)
		
	button _UpdateRE "Update RE" width: 100 height: 50
		on _UpdateRE pressed do
			
		(
			function setUpRenderElements =
				(  
					if renderSceneDialog.isopen() == true then renderSceneDialog.close()
					MainSavePath = getFileNamePath rendOutputFilename
					print MainSavePath
				 
					re = maxOps.GetCurRenderElementMgr()
					numb = re.numrenderelements() 
				 
					for i=0 to (numb-1) do
					(
						el = re.getrenderelement i
						currentFileName = (fileNameFromPath (re.GetRenderElementFileName i))
				--  		newDirectory = MainSavePath+"\\"+el.elementname
				-- 		if re.GetElementsActive() then makeDir newDirectory
							
						RelemName = (trimright rendOutputFilename ".exr")
						newFileName = RelemName + "_" + el.elementname +  ".exr"
						re.SetRenderElementFileName i newFileName 
					)
				)
				setUpRenderElements()
				renderSceneDialog.open()		
			)
		
	button _LDS "Launch Deadline 7" width: 100 height: 50
			on _LDS pressed do
				(
					local sttotal = timestamp()

	global SMTD_AutoLoadSuccessful
	global SMTD_TilesRendering
	global SMTD_RegionRendering
	global SMTD_StartupDialog_Rollout 
	try(destroyDialog SMTD_StartupDialog_Rollout )catch()
	local fullSuccess = false
	local messageTitle = "SMTD 7"
	local goOn = true
	local deadlinePath = systemTools.getEnvVariable( "DEADLINE_PATH" )

	if deadlinePath == undefined do
	(
		messagebox "The system environment variable DEADLINE_PATH is not defined on this computer. Please re-run Deadline client installer or set it manually." title:messageTitle
		goOn = false
	)
	
	if ::RPMDeadline6DataStruct != undefined do
	(
		messagebox "SMTD submission scripts have already been loaded by RPM.\n\nTo use SMTD outside of RPM, please\nrestart 3ds Max and open SMTD without launching RPM." title:messageTitle 
		goOn = false
	)
	
	rollout SMTD_StartupDialog_Rollout "Submit Max To Deadline Loading..."
	(
		progressbar prg_loading color:green height:20 width:280
		label lbl_progress "Startup..."
	)
	
	if goOn then
	(
		createDialog SMTD_StartupDialog_Rollout 300 50
		
		
		SMTD_StartupDialog_Rollout.prg_loading.value = 15.0
		SMTD_StartupDialog_Rollout.lbl_progress.text = "Looking for Network Root..."
		local theNetworkRoot = ""
		local st = timestamp()
		-- call DeadlineCommand to find the network root (assume it is in the path)
		try
		(
			local result = -2
				
			local submitOutputFile = sysInfo.tempdir + "submitOutput.txt"
			local submitExitCodeFile = sysInfo.tempdir + "submitExitCode.txt"
			
			deleteFile submitOutputFile
			deleteFile submitExitCodeFile
					
			local commandArguments = "-outputfiles \"" + submitOutputFile + "\" \"" + submitExitCodeFile + "\" -getrepositoryroot"
			local deadlineCommandBG = deadlinePath + "\\deadlinecommandbg.exe"
			ShellLaunch deadlineCommandBG commandArguments
					
			local startTimeStamp = timestamp()
			local ready = false
			while not ready do
			(
				sleep 0.15
				if doesFileExist submitExitCodeFile do
				(
					local theFile = openFile submitExitCodeFile
					try(result = readValue theFile)catch(result = -2)
					try(close theFile)catch()
					ready = true
				)	
				if timestamp() - startTimeStamp > 10000 then 
				(
					result = -3
					ready = true
				)	
			)
			
			if( result == 0 ) then
			(
				local resultFile = OpenFile submitOutputFile
				local resultMsg = ""
				if (resultFile != undefined) do
				(
					try(resultMsg = readLine resultFile)catch()
					try(close resultFile)catch()
				)
				
				theNetworkRoot = resultMsg
			)
			else
			(
				if result == -3 then
					messageBox "Timed out getting Repository Root from Deadline Command. (error code: 1003)" title:messageTitle
				else
					messageBox "Failed to get Repository Root from Deadline Command. (error code: 1004)" title:messageTitle
			)
		)
		catch
		(
			format "Unable to find Repository root\nThe exception thrown was \"%\"\n" (getCurrentException())
		
			local errorMessage = "Error calling Deadline Command to get Repository Root. (error code: 1005)\n"
			errorMessage += "\n"
			errorMessage += "This may be caused by:\n"
			errorMessage += "- The Deadline Client package not being installed\n"
			errorMessage += "- The DEADLINE_PATH environment variable not being set\n"
			errorMessage += "- DeadlineCommand being unable to run\n"
			errorMessage += "\n"
			errorMessage += "See the listener window for more details\n"

			messageBox errorMessage title:messageTitle
		)

		format "Resolving Network Path: %ms\n" (timestamp()-st)
		
		fn getFileInfoDotNet theFileName =
		(
			local fileLookup = dotnetobject "System.IO.DirectoryInfo" (getFileNamePath theFileName)
			local allMatchingFiles = #()
			try (
				allMatchingFiles = fileLookup.getFiles (filenamefrompath theFileName) 
			) catch()
			if allMatchingFiles.count == 1 then
			(
				local dotNetFile = allMatchingFiles[1]
				local fname = dotNetFile.FullName
				local date_ = dotNetFile.lastWriteTime.ToString()
				local size_ = dotNetFile.length
				#(fname, date_, size_)
			)
			else
				#()
		)	
		
		local theFilesToLoad = #(
			--#(1: File Name, 2: Base Error Code, 3: target folder, 4: fatal error, 5:autoload off if file was missing  6:load this file  7:force loading even if file was local )
			#("RegionManipulator.ms", 1040, #userStartupScripts,false,false,true),
			#("TileManipulator.ms", 1042, #userStartupScripts,false,false,true),
			#("SubmitMaxToDeadline_Functions.ms", 1004, #userScripts, true,false,true,true),
			#("SubmitMaxToDeadline_SanityCheck_Private.ms", 1024, #userScripts,false,true,true),
			#("SubmitMaxToDeadline_SanityCheck_General.ms", 1020, #userScripts,false,true,true),
			#("SubmitMaxToDeadline_SanityCheck.ms", 1022, #userScripts,false,false,true),
			#("SubmitMaxToDeadline.ms", 1030, #userScripts,true,false,false),
			#("SubmitMaxToDeadline_Defaults.ini", 1101, #userScripts,false,false,false),
			#("SubmitMaxToDeadline_StickySettings.ini", 1102, #userScripts,false,false,false)
		)
		
		local theLocalLauncherFilename = (GetDir #userStartupScripts + "\\SMTD_Loader.ms")
		local localLauncherExists = doesFileExist theLocalLauncherFilename
		format "SMTD_AutoLoadSuccessful = %\n" ::SMTD_AutoLoadSuccessful
		
		for i = 1 to theFilesToLoad.count do
		(
			local st = timestamp()
			SMTD_StartupDialog_Rollout.prg_loading.value = 10 + (90.0*i/theFilesToLoad.count)
			SMTD_StartupDialog_Rollout.lbl_progress.text = "Loading File [" + theFilesToLoad[i][1] + "]"
			try(windows.processPostedMessages())catch() --Max 2011 and higher
			try( 
				local theScript = theNetworkRoot + "\\submission\\3dsmax\\Main\\" + theFilesToLoad[i][1]
				local theTarget = (GetDir theFilesToLoad[i][3] + "\\" + theFilesToLoad[i][1])
				format "Running submission script \"%\"\n" theScript
				if doesFileExist theScript then
				(
					local theInfo1 = getFileInfoDotNet theScript
					local theInfo2 = #("","","")
					if doesFileExist theTarget do
						theInfo2 = getFileInfoDotNet theTarget
					--format "Info1 = %\n" theInfo1
					--format "Info2 = %\n" theInfo2
					
					if theInfo1[2] != theInfo2[2] or theInfo1[3] != theInfo2[3] then
					(
						deleteFile theTarget
						copyFile theScript theTarget
						if theFilesToLoad[i][6] == true do fileIn theTarget quiet:true		
						if theFilesToLoad[i][5] == true do SMTD_AutoLoadSuccessful = false
					)
					else
					(
						if theFilesToLoad[i][7] == true then 
							fileIn theTarget quiet:true
						else if not localLauncherExists or SMTD_AutoLoadSuccessful != true do 
							if theFilesToLoad[i][6] == true do fileIn theTarget quiet:true
					)
				)	
				else
				(
					messageBox ("Failed To Find the file ["+theFilesToLoad[i][1]+"] in Deadline Repository. (error code: "+ theFilesToLoad[i][2] as string  +")") title:messageTitle
					if theFilesToLoad[i][4] == true do
					(
						local goOn = false
						exit
					)				
				)
			)
			catch
			(
				messageBox ("Failed To Load the file ["+theFilesToLoad[i][1]+"] from Deadline Repository. (error code: "+(theFilesToLoad[i][2]+1) as string+")") title:messageTitle
				if theFilesToLoad[i][4] == true do
				(
					local goOn = false
					exit
				)			
			)
			format "Loading %: %ms\n" theFilesToLoad[i][1] (timestamp()-st)
		)
		
		local theLocalLauncher = createFile theLocalLauncherFilename
		format "global SMTD_AutoLoadSuccessful = true\n" to:theLocalLauncher
		for i in theFilesToLoad where i[3] != #userStartupScripts and i[6] == true do
		(
			format "try(fileIn (getDir % + \"/%\") quiet:true )catch(::SMTD_AutoLoadSuccessful = false)\n" i[3] i[1] to:theLocalLauncher
		)
		close theLocalLauncher
		
		SMTD_StartupDialog_Rollout.prg_loading.value = 100.0
		SMTD_StartupDialog_Rollout.lbl_progress.text = "Launching Submit Max To Deadline..."
		
		try(destroyDialog SMTD_StartupDialog_Rollout )catch()
		
		if goOn do 
		(
			::SMTD_AutoLoadSuccessful = true
			fileIn (getDir #userScripts+ "\\SubmitMaxToDeadline.ms")
			--macros.run "Thinkbox Software" "SubmitMaxToDeadline"
		)
		format "Total SMTD Launcher Time: %ms\n" (timestamp()-sttotal)	
	)
					)
		
		
		)
createdialog _Psetup width: 110 height: 170

			
				
			
				
				
			
				
				