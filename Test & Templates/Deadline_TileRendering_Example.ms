(
global SMTDSettings
global SMTDFunctions

local theResultFile = getDir #temp + "\\_result.txt"
local theCommandLine = ("deadlinecommand.exe -getrepositoryroot > \""+theResultFile +"\"")
hiddenDosCommand theCommandLine startpath:"c:\\"
local theFileHandle = openFile theResultFile
local theNetworkRoot = @"\\CGISERVER\Repository"
close theFileHandle

global SimpleDeadlineSubmitter_Rollout
try(destroyDialog SimpleDeadlineSubmitter_Rollout)catch()

rollout SimpleDeadlineSubmitter_Rollout "Simple Deadline Submitter"
(
spinner spn_priority "Priority:" range:[1,100,SMTDSettings.Priority] type:#integer fieldwidth:50
spinner spn_chunkSize "Frames Per Task:" range:[1,100,SMTDSettings.ChunkSize] type:#integer fieldwidth:50
checkbox chk_limitEnabled "" across:2 checked:SMTDSettings.LimitEnabled
spinner spn_machineLimit "Machine Limit:" range:[1,100,SMTDSettings.MachineLimit] type:#integer fieldwidth:50
button btn_submit "SUBMIT SCENE..."width:190 height:30 align:#center
on btn_submit pressed do
(
local theNetworkRoot = @"\\CGISERVER\Repository"
local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"    
local localScript = getDir #userscripts + "\\SubmitMaxToDeadline_Functions.ms"
if doesFileExist remoteScript do
(
if SMTDFunctions == undefined do
(
deleteFile localScript
copyFile remoteScript localScript
fileIn localScript
)

SMTDFunctions.loadSettings()
SMTDSettings.JobName = maxFileName + " [SIMPLE MXS TILE SUBMISSION]"
SMTDSettings.Comment = "Testing Tile Submission And Draft Assembly."
SMTDSettings.Priority = spn_priority.value
SMTDSettings.ChunkSize = spn_chunkSize.value
SMTDSettings.LimitEnabled = chk_limitEnabled.checked
SMTDSettings.MachineLimit = spn_machineLimit.value

local maxFileToSubmit = SMTDPaths.tempdir + maxFileName
SMTDFunctions.SaveMaxFileCopy maxFileToSubmit

-- NEW CODE STARTS HERE

-- Set up Single Frame Tile Rendering
SMTDSettings.RegionRenderingMode = #singleFrameTiles
SMTDSettings.SingleTileJobDraft = true
SMTDSettings.SingleTileJobCleanup = true
SMTDSettings.SingleTileJobDependent = true
SMTDSettings.TilesInY = 10
SMTDSettings.TilesInX = 10

-- Call the function that submits the Max scene and the Assembly Job as dependent:
local tileResult = SMTDFunctions.spawnTileJobs forceMaxFile:maxFileToSubmit batchName:(maxFileName+ " Tiles") 

-- The function returns true on success, false on failure, so we translate that into the result name value 
if tileResult then result = #success else result = #tileFailure
   
-- NEW CODE ENDS HERE

local renderMsg = SMTDFunctions.getRenderMessage()
SMTDFunctions.getJobIDFromMessage renderMsg

if result == #success then
(
format "Submitted successfully as Job %.\n\n%\n\n" \
SMTDSettings.DeadlineSubmissionLastJobID renderMsg
)
else
format "Job Submission FAILED.\n\n%" renderMsg
)--end if
)--end on button pressed
)--end rollout
createDialog SimpleDeadlineSubmitter_Rollout width:200
)--end script
