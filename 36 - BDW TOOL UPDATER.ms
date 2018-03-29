
fn ClearFiles = 
(
MacrosFiles = #()
MacrosFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Macros BDW\*.mcr")

MacrosMCRFileNames = #()
for i=1 to MacrosFiles.count do
(
MacrosMCRFileNames[i] = (filterstring MacrosFiles[i] @"\")[7]
)

MacrosDir = (getdir #userMacros ) + @"\"

for i=1 to MacrosFiles.count do
	(
	
	print (MacrosDir + MacrosMCRFileNames[i])
-- 	::filein MacrosFiles[i]			
	)
	
	
	
	
StartupFiles = #()
StartupFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Macros BDW\Installer\*.ms")

StartupFileNames = #()
for i=1 to StartupFiles.count do
(
StartupFileNames[i] = (filterstring StartupFiles[i] @"\")[8]
)

StartupDir = (getdir #userStartupScripts ) + @"\"

for i=1 to StartupFiles.count do
	(
	
	print (StartupDir + StartupFileNames[i])
-- 	::filein MacrosFiles[i]			
	)	
)
ClearFiles()

fn MacrosGather =
	(
	rollout Progress "UPDATING"
	(
			progressbar UpdateProg "" color:green
				
				
			
		on Progress open do
		(
		clearlistener()
			
			
		-- ###### -- mcr to scripts folder	
			
		MacrosFiles = #()
		MacrosFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Macros BDW\*.mcr")
-- 		MacrosFiles = getfiles (@"X:\08_Scripts & Tools\WIPs\Macros\*.mcr")
		
		for i=1 to MacrosFiles.count do
			(
				::filein MacrosFiles[i]			
				)
		
				-- ###### -- Icon Files
				
				
		IconFiles = #()
		IconFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Macros BDW\icons\*.bmp")
			
		IconsDIR  = getdir #usericons + @"\"		
				
				-- ###### -- ms to startup folder
		
		for i=1 to IconFiles.count do
			(
				
				IconName = getfileNameFile IconFiles[i] + ".bmp"
				NewDir = (IconsDIR + IconName)
				copyfile IconFiles[i]  NewDir
				UpdateProg.value = 100.*i/IconFiles.count
			)
			
		StartupDir = (getdir #userStartupScripts ) + @"\"

		FilestoCopy = getfiles @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Macros BDW\Installer\*.ms"




for i=1 to FilestoCopy.count do
(
	getfileNameFile FilestoCopy[i]
	ScriptFilename = getfileNameFile FilestoCopy[i]
	
	copyfile FilestoCopy[i] (StartupDir + ScriptFilename + ".ms")
	
	)	
			
			
		)
	)createdialog Progress
		
		
	Try(destroydialog Progress)catch()	
		
		
		
		
		
		)

MacrosGather()
