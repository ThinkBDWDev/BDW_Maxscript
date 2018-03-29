--macroScript SubmitToDeadline category:"ThinkBDW" --BOBO: Remove the remark to create a MacroScript that can be added to toolbars, menus, quadmenus, keyboard shortcuts...
(--BOBO: open a bracket to start a new local scope and hide all other variables from the global scope

global SMTDSettings --BOBO: It is a good idea to pre-declare these as global before loading their definition from SubmitMaxToDeadline_Functions.ms
global SMTDFunctions 
	
local DLR = @"\\cgiserver\repository\" 
if SMTDSettings == undefined OR SMTDFunctions == undefined do --BOBO: If SMTDSettings and SMTDFunctions are already loaded, do not waste time loading them again
(
	Filein (DLR + @"\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms")
)

global Deadline_Think_BDW --BOBO: pre-declare the variable to hold the submitter dialog
try(destroyDialog Deadline_Think_BDW)catch() --BOBO: try to close the dialog in case it is open from previous session
	
rollout Deadline_Think_BDW "Submit To Deadline" --BOBO: This is the new UI
(
	group "Basic Job Settings"
	(
		spinner spn_priority "Job Priority:" range:[1,100,SMTDSettings.Priority] type:#integer fieldwidth:50 align:#right --BOBO: a spinner to set the priority
	)
	group "Advanced Job Settings"
	(
		checkbox chk_TileRendering "Single Frame Tile Rendering" across:2 checked:(SMTDSettings.RegionRenderingMode == #singleFrameTiles)
		spinner spn_TilesInX "Tiles In X:" range:[1,64,SMTDSettings.TilesInX] type:#integer fieldwidth:50 align:#right
		spinner spn_TilesInY "Tiles In Y:" range:[1,48,SMTDSettings.TilesInY] type:#integer fieldwidth:50 align:#right
	)
	button btn_submit "SUBMIT JOB TO DEADLINE" width:392 height:30
	
	--Submit Job
	fn submitJob =
	(
		--Define job properties
		local CamName = "" -- BOBO: Assume the viewport is not a camera
		local theCamera = viewport.getCamera() -- BOBO: get the camera from the current viewport
		if isValidNode theCamera do CamName = "_" + theCamera.name  -- BOBO: if it is an actual object, then set the CamName to its name
		
		SMTDSettings.JobName = getFilenameFile maxfilename + CamName -- BOBO: Build the job name from scene name and camera name, if any
		SMTDSettings.Priority = spn_priority.value -- BOBO: set the Priority using the spinner value
		SMTDSettings.username = "Simon" -- BOBO: Set the user name (you can use  sysinfo.username  if your users are named on Deadline like their local user names!)
		SMTDSettings.IncludeLocalPaths = true
		if chk_TileRendering.state then -- BOBO: If Tile rendering was requested, 
		(
			SMTDSettings.RegionRenderingMode=#singleFrameTiles -- BOBO: enable it and set the tile counts...
			SMTDSettings.TilesInX = spn_TilesInX.value
			SMTDSettings.TilesInY = spn_TilesInY.value
			SMTDSettings.TilesPadding = 0 --BOBO: This could be exposed to the artist, but it is up to you. Just add a spinner and set to its value,,,
			
			--BOBO: The following settings are also related to single frame tile rendering, you can expose them to the user if you want, or set them up as you want them 
			SMTDSettings.SingleTileJobDependent = true --BOBO: Should be True
			SMTDSettings.SingleTileJobCleanup = true --BOBO: Delete the tiles after assembly (normally it is False)
			SMTDSettings.SingleTileJobDraft = true --BOBO: Should be True to use Draft, False to use the old tile assembler. Keep it True.
			SMTDSettings.SingleTileJobDraftErrorOnMissing = true --BOBO: Defaults to True, should be left at True. If False, running the Draft Assembly 
		)
		else
		(
			SMTDSettings.RegionRenderingMode=#none --when no tiling is requested, set to #none to disable
		)
		-- SMTDSettings.SubmitAsSuspended = true

		MaxFileToSubmit = SMTDPaths.tempdir + maxfilename
		if maxFileName == "" do --BOBO: If the scene has not been saved yet,...
		(
			messagebox "Please SAVE the current scene to provide a valid Filename!" title:"Cannot Submit:" --BOBO: Let the user know he needs to save first! SMTD itself allows untitled scenes to be submitter, but it might be a bad practice
			return false --BOBO: Exit the function without submitting
		)
			
		SMTDFunctions.saveMaxFileCopy MaxFileToSubmit
		 
		SubmitInfoFile = SMTDPaths.tempDir + "Max_Submit_info.job" --BOBO: The @ symbol is only needed when dealing with backspace paths, e.g. @"C:\Temp\Test.max" would not work without @ because \T is an escape sequence for Tab character. "C:\\Temp\\Test.max" would work as \\ means "one backspace, and not \T"
		JobInfoFile = SMTDPaths.tempDir + "Max_Job_info.job"

		SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
		SMTDFunctions.CreateJobInfoFile JobInfoFile

		SubmitString = "\"" + SubmitInfoFile + "\" \"" + JobInfoFile +  "\"  \""+MaxFileToSubmit+ "\" "
		--SMTDFunctions.WaitForCommandToComplete SubmitString 200 --BOBO: Tile rendering requires A LOT of additional processing, so we cannot use this simple call
		local result = SMTDFunctions.SubmitJobFromUI() --BOBO: We need to call the main SMTD submission function instead
		format "%\n" result --BOBO: Output the result of the function to the MAXScript Listener for reference...
		messagebox result title:"Submit To Deadline:" --BOBO: Show the result of the function as a message box (you can remark this line if the MAXScript Listener output is enough)
	)
	
	on btn_submit pressed do submitJob() --BOBO: When the Submit button is pressed, call the submit function
)
createDialog Deadline_Think_BDW 400 155 --BOBO: Create a dialog from the rollout. First argument is the width, the height is the second number
Deadline_Think_BDW.title = "Submit To Deadline ["+ DLR +"]" --BOBO: Set the title bar to show the Repository path
OK
)--BOBO: End of local scope