PathT = @"\\192.168.0.16\CGI_Renders\Think_BDW\Script_Test\Test" 
clearlistener()
fn VersionChecker PathT =
(
PathT = @"\\192.168.0.16\CGI_Renders\Think_BDW\Script_Test\Test" --Path to Test
PathHolder = PathT
For i=1 to 20 while doesFileExist PathHolder do
	(	
		Global Version = "_V00" + (i as string)
		(PathHolder = (PathT + Version))
		
		Global Ver = i
-- 		print PathT
-- 		Print Ver
		Print PathHolder
		Global VerNumber = i
		)

		VersionPath = PathT + Version
		
		MSG = "Folder already exists" + "\n" + "New Version for Files Created" + "\n" + "----------------------" + "\n" + "Version No " + Version
		
		If VerNumber > 0 do
			(messagebox MSG)
)
VersionChecker PathT