(
	global SMTD_MainRollout				--contains the main rollout (dialog)
	global SMTDFunctions				--contains the structure of functions 
	global SMTDPaths					--contains the structure of paths
	global SMTDSettings 				--contains the structure of settings
	global SMTDSettingsFactory 			--the factory defaults structure
	global SMTD_SceneMaterials = #()	--used to collect all scene materials for custom shader rendering
	global SMTD_LastMessage = ""
	global SMTD_objsToBake
	global SMTD_StateSetsTree = #()
	global SMTD_StateSetsTreeForSubmission = #()
	global sfs -- makes sure the brazil structure is predefined
	
	--Shotgun settings that are sticky per scene file
	persistent global pg_SGDraftTemplate
	persistent global pg_SGVersion
	persistent global pg_SGDescription
	persistent global pg_SGTask
	persistent global pg_SGEntity
	persistent global pg_SGUser
	persistent global pg_SGProject
	persistent global pg_SGDisplayInfo
	persistent global pg_SGJobSettings
	persistent global pg_SGCreateMovie
	persistent global pg_SGCreateFilmStrip

	--Ftrack settings that are sticky per scene file
	persistent global pg_FTDescription
	persistent global pg_FTTask
	persistent global pg_FTAsset
	persistent global pg_FTUser
	persistent global pg_FTProject
	persistent global pg_FTDisplayInfo
	persistent global pg_FTJobSettings	
	
	try(destroyDialog SMTD_MainRollout)catch() --make sure the SMTD UI is closed before reinitializing all structures
	
	struct SMTDPathsStruct --the structure of system paths used by the submitter
	(
		HomeDir,
		UserHomeDir,
		BinDir,
		LogsDir,
		TempDir,
		SettingsDir,
		DeadlineExec,
		DeadlineBGExec,
		SubmitInfoFile,
		JobInfoFile,
		DraftConfigFile,
		ResultFile,
		BitmapList,
		RestoreTempMaxFile,
		SubmitOutput ,
		SubmitExitCode,
		IniFile,
		ImsqVbscriptFile,
		NetworkRoot,
		submitSubFolder
	)
	
	SMTDPaths = SMTDPathsStruct() --the global instance of the paths structure storing the actual paths.
	
	SMTDPaths.BinDir = systemTools.getEnvVariable( "DEADLINE_PATH" ) + "\\"
	
	SMTDPaths.HomeDir = getDir #temp
	try
	(
		local result = -2
			
		local submitOutputFile = sysInfo.tempdir + "submitOutput.txt"
		local submitExitCodeFile = sysInfo.tempdir + "submitExitCode.txt"
		
		deleteFile submitOutputFile
		deleteFile submitExitCodeFile
				
		local commandArguments = "-outputfiles \"" + submitOutputFile + "\" \"" + submitExitCodeFile + "\" -gethomedirectory"
		local deadlineCommandBG = SMTDPaths.BinDir + "deadlinecommandbg.exe"
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
			
			SMTDPaths.HomeDir = resultMsg + "\\"
		)
	) catch ()
	
	SMTDPaths.UserHomeDir = getDir #temp --default to temp folder in case the following code fails
	try
	(
		local result = -2
			
		local submitOutputFile = sysInfo.tempdir + "submitOutput.txt"
		local submitExitCodeFile = sysInfo.tempdir + "submitExitCode.txt"
		
		deleteFile submitOutputFile
		deleteFile submitExitCodeFile
				
		local commandArguments = "-outputfiles \"" + submitOutputFile + "\" \"" + submitExitCodeFile + "\" -GetCurrentUserHomeDirectory"
		local deadlineCommandBG = SMTDPaths.BinDir + "deadlinecommandbg.exe"
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
			
			SMTDPaths.UserHomeDir = resultMsg + "\\"
		)
	) catch ()
	
	SMTDPaths.TempDir = SMTDPaths.UserHomeDir + "temp\\"
	SMTDPaths.LogsDir = SMTDPaths.UserHomeDir + "logs\\"
	SMTDPaths.SettingsDir = SMTDPaths.UserHomeDir + "settings\\"
	
	SMTDPaths.DeadlineExec = SMTDPaths.BinDir + "deadlinecommand.exe"
	SMTDPaths.DeadlineBGExec = SMTDPaths.BinDir + "deadlinecommandbg.exe"
	SMTDPaths.SubmitInfoFile = SMTDPaths.TempDir + "max_submit_info.job"
	SMTDPaths.JobInfoFile = SMTDPaths.TempDir + "max_job_info.job"
	SMTDPaths.ResultFile = SMTDPaths.TempDir + "max_output.txt"
	SMTDPaths.BitmapList = SMTDPaths.TempDir + "max_sceneBitmaps.txt"
	SMTDPaths.RestoreTempMaxFile = SMTDPaths.TempDir + "max_backup_file.mx"
	SMTDPaths.DraftConfigFile = SMTDPaths.TempDir + "draft_tile_config.txt"
	
	SMTDPaths.SubmitOutput = sysInfo.tempdir + "submitOutput.txt"
	SMTDPaths.SubmitExitCode = sysInfo.tempdir + "submitExitCode.txt"
	
	SMTDPaths.submitSubFolder = sysInfo.tempdir
	
	SMTDPaths.InIFile = GetDir #plugcfg + "\\SubmitMaxToDeadline.ini"
	SMTDPaths.ImsqVbscriptFile = SMTDPaths.TempDir+ "copyImsq.py"
	SMTDPaths.NetworkRoot = ""
	
	global SMTDExternalRefsArray
	struct SMTDExternalRefsArrayStruct 
	(
		totalSubsArray = #(),
		storeBitmapPath = #(),
		storeHdriPath = #(),
		StoreSceneXRefs = #(),
		StoreObjectXRefs = #(),
		StoreSceneVrayProxies = #(),
		StoreSceneCoronaProxies = #(),
		StoreSceneMRProxies = #(),
		StoreRendererPaths = #(),
		StoreBrazilv2RendererPaths = #()		
	)
	SMTDExternalRefsArray = SMTDExternalRefsArrayStruct()
	
	
	struct SMTD_ColorPaletteStruct 
	(
		orangeColor, blueColor, redColor, greenColor, grayColor, lightGrayColor, lightBlueColor, highlightBgColor, textColor, maxBgColor, blackColor
	)
	global SMTD_ColorPalette = SMTD_ColorPaletteStruct()
	
	fn defineDotNetColors =
	(
		SMTD_ColorPalette.textColor = ( ((colorman.getcolor #text) as color)*255)
		SMTD_ColorPalette.maxBgColor = (((colorman.getcolor #window)) as color)*255
		SMTD_ColorPalette.blackColor = (dotNetClass "System.Drawing.Color").fromARGB SMTD_ColorPalette.textColor.r SMTD_ColorPalette.textColor.g SMTD_ColorPalette.textColor.b
		if SMTD_ColorPalette.maxBgColor.v >= 160 then
		(
			SMTD_ColorPalette.redColor = (dotNetClass "System.Drawing.Color").fromARGB 192 0 0
			SMTD_ColorPalette.orangeColor = (dotNetClass "System.Drawing.Color").fromARGB 240 160 0
			SMTD_ColorPalette.greenColor = (dotNetClass "System.Drawing.Color").fromARGB 0 128 0
			SMTD_ColorPalette.blueColor = (dotNetClass "System.Drawing.Color").fromARGB 0 0 128
			SMTD_ColorPalette.lightBlueColor = (dotNetClass "System.Drawing.Color").fromARGB 90 128 160
			SMTD_ColorPalette.grayColor = (dotNetClass "System.Drawing.Color").fromARGB 128 128 128
			SMTD_ColorPalette.lightGrayColor = (dotNetClass "System.Drawing.Color").fromARGB 160 160 160
			SMTD_ColorPalette.highlightBgColor = (dotNetClass "System.Drawing.Color").fromARGB 180 190 200
		)
		else
		(
			SMTD_ColorPalette.redColor = (dotNetClass "System.Drawing.Color").fromARGB 255 128 128
			SMTD_ColorPalette.orangeColor = (dotNetClass "System.Drawing.Color").fromARGB 255 180 50
			SMTD_ColorPalette.greenColor = (dotNetClass "System.Drawing.Color").fromARGB 128 255 128
			SMTD_ColorPalette.blueColor = (dotNetClass "System.Drawing.Color").fromARGB 170 200 255
			SMTD_ColorPalette.lightBlueColor = (dotNetClass "System.Drawing.Color").fromARGB 128 160 255
			SMTD_ColorPalette.grayColor = (dotNetClass "System.Drawing.Color").fromARGB 192 192 192
			SMTD_ColorPalette.lightGrayColor = (dotNetClass "System.Drawing.Color").fromARGB 160 160 160
			SMTD_ColorPalette.highlightBgColor = (dotNetClass "System.Drawing.Color").fromARGB 20 40 60
		)				
	)		
	defineDotNetColors()
	
	--The global structure of settings
	--This structure holds ALL settings needed by the submit function,
	--thus there is no need for the actual UI to be ever opened in order to submit a Max scene job
	--Just set the desired settings in this structure or keep the defaults and call the submit function.
	struct SMTDSettingsStructure 						
	(
		VersionString = "7.2",
		JobName = "3ds Max Deadline Job",
		Comment = "",
		UserName = sysinfo.username,
		Department = "",
		Group = "none",
		Groups = #(),
		
		Category = "", --obsolete, left for backwards compatibility 
		Categories = #(), --obsolete, left for backwards compatibility 
		
		theIniFiles = #(),
		theIniFilenames = #(),
		
		RepositoryList = #("DISABLED"),
		RepositoryListActual = #(),
		
		CurrentRepository = "",
		CurrentRepository2 = "",
		Pools = #(),
		PoolExclusive = false,
		PoolName = "none",
		Pool2Name = "",
		
		SubmitScene = true,
		SubmitSceneMode = #reposave, --#reposave, #networkuse, #networksave, #globalnetworksave, #networksaveanduse, #networkremap
		SubmitSceneBasePath = "",
		SubmitSceneGlobalBasePath = "",
		SubmitSceneNetworkLocation = "",
		SubmitSceneNetworkReuseLocation = false, --when true, the submission will use the already saved file from SubmitSceneNetworkLocation. Mainly for State Sets submission  
		
		ExternalFilesWarningOn = false,
		ExternalFilesWarningCount = 100,
		ExternalFilesWarningMB = 1024,		

		OneCpuPerTask = false,
		LocalRendering = true,
		PoolsSort = false, --obsolete, left for backwards compatibility
		MaximumPriority = -1,
		Priority = 50,
		LimitEnabled = false,
		MachineLimit = 1,
		RenderOutOfOrder = false,
		OutOfOrderMethod = #normal,
		OutOfOrderStep = 10,
		SubmitAsSuspended = false,
		SubmitAsDependent = false,
		AutoDelete = false,
		OnComplete = "Nothing",
		ChunkSize = 1,
		SequentialJob = false,
		MaxVersionToForce = "none",
		MaxVersionToForceSticky = false,
		
		OverrideFailOnExistingMaxProcess = false,
		FailOnExistingMaxProcess = false,
		
		DisableProgressUpdateTimeout = false,
		SkipRender = false,
		JobIsInterruptible = false,
		
		MaxTasksPerSlave = 1,
		LimitTasksToNumberOfCpus = true,
		
		JobsArray = #(),
		FullJobsArray = #(),
		PreviousJobsArray = #(),
		DependencyJobItems = #{},
		ResumeOnDeletedDependencies = false,
		DependOnPreviousJobMode = #previous,

		AssemblerOverride = false,
		AssemblerPoolName = "none",
		AssemblerPool2Name = "",
		AssemblerGroup = "none",
		AssemblerPriority = 50,
		
		TilesInX = 1,
		TilesInY = 1,
		TilesRendering = false, --deprecated, see RegionRenderingMode
		TileBlowupMode = false,
		SingleTileJob = true,  --deprecated, see RegionRenderingMode
		SingleTileJobDependent = true,
		SingleTileJobCleanup = false,
		SingleTileJobDraft = true,
		SingleTileJobDraftErrorOnMissing = true,
		SingleTileJobLeft = "",
		SingleTileJobRight = "",
		SingleTileJobTop = "",
		SingleTileJobBottom = "",
		SingleTileJobFilename = "",
		SingleTileJobReFilename = "",
		SingleTileJobTileCount = 0,
		SingleTileJobFrameList = "",
		--TilesSubmissionMode = #local,
		TilesPadding = 0,
		TilesSubmissionJobIDs = #(),
		RegionRendering = false,
		RegionLeft = 0,
		RegionTop = 0,
		RegionRight = 100,
		RegionBottom = 100,
		RegionType = 1, --1 = Region (NOCROP)  2 = CROP  3 = BLOWUP  used only if RegionRendering is True
		RegionUseMaxValues = true,
		CustomTiles = #(),
		UseCustomTiles = false,
		CustomTilesPreviewWidth = 640,
		CustomTilesPreviewHeight = 480,	
		MultiRegionData = #(),
		MultiRegionRendering = false,
		MultiRegionBackground = #off,
		MultiRegionBackgroundImage = "",
		MultiRegionCopyDraftConfig = false,
		MultiRegionFitPadding = 10.0,
		--MachineLimitTileJobs = false,
		
		RawBufferFileName = "",
		RawBufferFile = "",
		SplitBufferFileName = "",
		SplitBufferFile = "",
		
		DBR = false,
		DBRServers = 5,
		
		RegionRenderingMode = #none, --#none, #singleFrameMultiRegion, #animationMultiRegion, #singleFrameTiles, #animationTiles, #maxRegion
		
		UseSubmissionQueue = false,
		
		LimitGroups = #(),
		LimitGroupsToUse = #(),
		LimitGroupAutoBrazil = false,
		LimitGroupAutoVRay = false,
		LimitGroupAutoCorona = false,
		LimitGroupAutoKrakatoa = false,
		LimitGroupAutoFinalRender = false,
		LimitGroupAutoMaxwell = false,
		LimitGroupAutoWorkstation = false,
				
		DropSubmission = false,
		BgSubmission = false,
		UseJpegOutput = false,
		JpegOutputPath = "",
		AlternateEmails = "",
		NotificationNote = "",
		
		TransferPool = "none",
		TransferGroup = "none",
		TransferPriority = 50,
		TransferDeleteOnComplete = true,
		TransferJobAsSuspended = false,
		TransferCompressed = true,
		
		UseAltPluginIni = false,
		AutoSuggestIni = false,
		AltINISelection = 1, 
		AltPluginIni = "",
		AltIniPath = "c:\\",
		
		EnableFailOnBlackFrames = false,
		BlackPixelPercentage = 1,
		BlackPixelThreshold = 0.1,
		BlackFramesCheckRenderElements = false,
		
		RemovePadding = false,
		
		GammaCorrection = false,
		GammaInput = 1.0,
		GammaOutput = 1.0,
		
		IgnoreMissingExternalFiles = true,
		IgnoreMissingUVWs = true,
		IgnoreMissingXREFs = true,
		IgnoreMissingDLLs = false,
		DisableMultipass = false,
		MergeXRefsOnSubmission = false,
		MergeSceneXRefsOnSubmission = false,
		
		ForceWorkstationMode = false,
		UseSilentMode = true,
		PopupHandling = true,
		
		RestartRenderer = false,
		StrictOutput = false,
		ShowFrameBuffer = true,

		ShowRendererFrameBufferOverride = false,
		ShowRendererFrameBuffer = true,
		
		OverrideBitmapPager = false,
		BitmapPager = false,
		
		SubmitExternalFiles = false,
		SubmitExternalFilesMode = 1,
		
		PerformSanityCheck = true,
		DeadlineSubmissionSuccessful = false,
		DeadlineSubmissionLastJobID = "none",
		
		DependOnPreviousJobID = "",
		DependOnPreviousJob = false,
		
		CloseAfterSubmission = false,
		SubmitVisibleObjectsOnly = false,
		
		CopyVbscriptFile = false,
		CreateImsqFile = false,
		CopyImsqFile = false,
		ImsqOutputPath = "",
		
		UsePathConfigFile = false,
		MergePathConfigFile = false,
		PathConfigFile = "",
		IncludeLocalPaths = false,
		
		RunPreLoadScript = false,
		RunPostLoadScript = false,
		RunPreFrameScript = false,
		RunPostFrameScript = false,
		
		PreLoadScriptFile = "",
		PostLoadScriptFile = "",
		PreFrameScriptFile = "",
		PostFrameScriptFile = "",
		
		RunPreJobScript = false,
		RunPostJobScript = false,
		RunPreTaskScript = false,
		RunPostTaskScript = false,
		
		PreJobScriptFile = "",
		PostJobScriptFile = "",
		PreTaskScriptFile = "",
		PostTaskScriptFile = "",
		
		SubmitAsMXSJob = false,
		MAXScriptFile = "",
		SingleTaskJob = false,
		
		UseCustomShader = false,
		CustomShaderMode = 1,
		--AutoSuggestCategory = true,
		
		UseBatchRender = false,
		BatchRenderMode = 1,
		
		RenderFramesPreviewJob = false,
		PreviewJobFrameCount  = 3,
		PreviewJobPriorityOffset = 1,
		PreviewJobSecondJobDependentOnFirst = true,
		
		RenderElementsUpdatePaths = true,
		RenderElementsUpdateFilenames = true,
		RenderElementsIncludeNameInPath = true,
		RenderElementsIncludeTypeInPath = true,
		RenderElementsIncludeNameInFileName = false,
		RenderElementsIncludeTypeInFilename = true,
		RenderElementsPermanentChanges = true,
		RebuildRenderElements = false,
		IgnoreRenderElements = false,
		Delimiter = ".", --"_" --use the "SubmitMaxToDeadline_Defaults.ini" file to configure the Delimiter to another character such as Delimiter="" (blank) under [RenderingOptions] category.
		PurifyFilenames = false,
		PurifyCharacterCodes = #(33,35,42,63), --#("#","!","?","*"),
		ForceLowerCaseFilenames = false,
		ReplaceOutputFilenameWithUserPattern = false,
		OutputFilenameUserPattern = "", --the pattern should be defined under [RenderingOptions] category, OutputFilenameUserPattern key of the repository file "SubmitMaxToDeadline_Defaults.ini".
		RenderElementNamesPermanentChanges = true,
		OriginalRenderElementNames = #(),
		
		QuicktimeGenerate = false,
		QuicktimeSettingsFile = "",
		QuicktimePoolName = "none",
		QuicktimeGroupName = "none",
		QuicktimeFilenameMode = 1,
		QuicktimeCustomFilename = "quicktime_animation",
		QuicktimesToGenerate = #(),
		
		Slaves = #(),
		SlavesList = #(),
		SlavesBlackList = true,
		SlavesNamedSet = "",
		SlaveSettingsSticky = true,
		SlaveInfo = #(),
		SlaveInfoCollected = false,
		
		TimeoutSubmission = 3600,
		TimeoutQTSubmission = 120,
		TimeoutCollectData = 60,
		
		AutomaticallyUpdateJobName = false,
		OverrideLowPriorityThread = true,
		MeditMaterialsStorage = #(),
		ClearMaterialEditorOnSubmission = true,
		UnlockMEditRenderer = false,
		
		ExportAdvancedRenderOutputFiles = true,
		ExportAdvancedRenderInfoScanline = true,
		ExportAdvancedRenderInfoMentalRay = true,
		ExportAdvancedRenderInfoBrazil = true,
		ExportAdvancedRenderInfoBrazil2 = true,
		ExportAdvancedRenderInfoVRay = true,
		ExportAdvancedRenderInfoVRayRT = true,
		ExportAdvancedRenderInfoKrakatoa = true,
		ExportAdvancedRenderInfoAmaretto = true,
		ExportAdvancedRenderInfoFinalRender = true,
		ExportAdvancedRenderInfoMaxwell = true,
		ExportAdvancedRenderInfoQuicksilver = true,
		ExportAdvancedRenderInfoIRay = true,
		ExportAdvancedRenderInfoCorona = true,
		
		DumpFileProperties = false,
		MissingFiles = #(),
		WarnAboutMissingExternalFiles = true,
		
		OverrideLanguage = false,
		Language = 0,
		LanguageArray = #("English", "French", "German", "Japanese", "Korean", "Simplified Chinese"),
		LanguageCodeArray = #("ENU", "FRA", "DEU", "JPN", "KOR", "CHS" ),
		
		ScheduledType = #none,  --None/Once/Daily
		ScheduledDays = 1,
		ScheduledStartDateTime = "", --dd/MM/yyyy HH:mm
		
		TaskTimeoutEnabled = false,
		TaskTimeout = 0,
		AutoTaskTimeout = false,
		RestartMax = false,
		
		IsBakeJob = false,
		BakeJobOneObjectPerTask = true,
		
		ExtraInfo0 = "",
		ExtraInfo1 = "",
		ExtraInfo2 = "",
		ExtraInfo3 = "",
		ExtraInfo4 = "",
		ExtraInfo5 = "",
		ExtraInfo6 = "",
		ExtraInfo7 = "",
		ExtraInfo8 = "",
		ExtraInfo9 = "",
		ExtraInfoKeyValues = #(),	--populate this array from your own scripts with key/value sub-arrays in the form #( #(KeyName, KeyValue), #(KeyName, KeyValue) ... #(KeyName, KeyValue)) The indexing will be handled automatically

		EnvironmentKeyValues = #(),	--populate this array from your own scripts with kay/value sub-arrays in the form #( #(KeyName, KeyValue), #(KeyName, KeyValue) ... #(KeyName, KeyValue)) The indexing will be handled automatically
		IncludeEnvironment = false,
		UseJobEnvironmentOnly = false,

		ProjectManagement = "Shotgun",

		SGDraftTemplate = "",
		SGVersion= "",
		SGDescription = "",
		SGTask = "", 
		SGEntity = "",
		SGUser = "",
		SGProject = "",
		SGUpdate = false,
		SGDisplayInfo = #(),
		SGJobSettings = #(),
		SGCreateMovie = false,
		SGCreateFilmStrip = false,

		FTAsset = "",
		FTDescription = "",
		FTTask = "",
		FTUser = "",
		FTProject = "",
		FTUpdate = false,
		FTDisplayInfo = #(),
		FTJobSettings = #(),
		
		DraftQuick = false,
		DraftFormats = #(),
		DraftFormatsDict = dotNetObject "System.Collections.Hashtable",
		DraftFormat = "",
		DraftResolutions = #(),
		DraftResolutionsDict = dotNetObject "System.Collections.Hashtable",
		DraftResolution = "",
		DraftCodecsDict = dotNetObject "System.Collections.Hashtable",
		DraftCodec = "",
		DraftFrameRates = #(),
		DraftFrameRate = "24",
		DraftQuality = 85,
		DraftRestrictions = #(),
		DraftRestrictionsDict = dotNetObject "System.Collections.Hashtable",
		DraftTemplate = "",
		DraftSubmitJob = false,
		DraftShotgunUpload = true,
		DraftUser = "",
		DraftEntity = "",
		DraftVersion = "",
		DraftExtraArgs = "",

		DeleteEmptyStateSets = false,
		StateSetsSubmit = false,
		StateSetsList = #{},
		StateSetToRender = 0,
		StateSetName = "",
		StateSetInfo = "",
		StateSetRenameOutput = false,
		
		StereoCameraMode = #left, -- #all = if active view is any stereo sub-camera, submit #left, #right and #center jobs; #leftright = if the view is any stereo sub-camera, submit #left and #rgith; #left = submit left eye only; #right = submit right eye only, #center = submit center camera only
		LeftEyeTag = "LE",
		RightEyeTag = "RE",
		CenterEyeTag = "CE",
		StereoCameraPriorityOrder = #none, --#lrc, #rlc, #clr, #crl, #lcr, #rcl
		
		OverrideJobFailureDetection = false, 	-- If true, the job will ignore the global Job Failure Detection settings and instead use its own (default = false).
		FailureDetectionJobErrors = 0,  		-- If OverrideJobFailureDetection is true, this sets the number of errors before the job fails. If set to 0, job failure detection will be disabled.
		OverrideTaskFailureDetection = false,  	-- If true, the job will ignore the global Task Failure Detection settings and instead use its own (default = false).
		FailureDetectionTaskErrors = 0,  		-- If OverrideTaskFailureDetection is true, this sets the number of errors before a task for the job fails. If set to 0, task failure detection will be disabled.
		--IgnoreBadJobDetection = false,  		-- If true, slaves will never mark the job as bad for themselves. This means that they will continue to make attempts at jobs that often report errors until the job is complete, or until it fails (default = false).
		SendJobErrorWarning = true, 				-- If the job should send warning notifications when it reaches a certain number of errors (default = false).		
		
		nonFatalErrorsCount = 0
	)
	::SMTDSettingsFactory = SMTDSettingsStructure()
	::SMTDSettings = SMTDSettingsStructure()
	
	--Increase heal size to 64 MB just in case.
	if heapSize < 67108864 do heapSize = 67108864
	
	struct SMTDFunctions
	(
		--Returns the name of the plugin to use based on the current max version
		fn getPluginToUse =
		(
			--if( ((maxVersion())[1]/1000 as integer) == 10 ) then
			--	"3dsmax2008"
			--else
			--	"3dsmax" + (((maxVersion())[1]/1000 as integer) as string)
			
			"3dsmax"
		),
		
		fn getMaxVersion =
		(
			if( ((maxVersion())[1]/1000 as integer) > 9 ) then
				((((maxVersion())[1]/1000 as integer) + 1998) as string)
			else
				(((maxVersion())[1]/1000 as integer) as string)
		),
		
		fn getMaxVersionAsInteger =
		(
			if( ((maxVersion())[1]/1000 as integer) > 9 ) then
				(((maxVersion())[1]/1000 as integer) + 1998)
			else
				((maxVersion())[1]/1000 as integer)
		),
		
		fn IsSettingSticky theCategory theKey =
		( 
			local theStickyFile = getDir #userScripts + "\\SubmitMaxToDeadline_StickySettings.ini"  
			local theLocalStickyFile = SMTDPaths.SettingsDir + "\\SubmitMaxToDeadline_StickySettings.ini"  
			local isSticky = true --If INI key is not set, we assume the setting is sticky
			local theValue = (getINISetting theStickyFile theCategory theKey) 
			--if there is such a global entry, see whether it is false or not. 
			if theValue != "" do isSticky = theValue != "false"
			--if there is such a local entry, see whether it is false or not
			local theValue = (getINISetting theLocalStickyFile theCategory theKey)
			if theValue != "" do isSticky = theValue != "false"
			isSticky 
		),
		
		fn getGlobalDefault  theCategory  theKey theDefault executeIt:true =
		(
			local theDefaultFile = getDir #userScripts + "\\SubmitMaxToDeadline_Defaults.ini"  --this is the global defaults file.
			local theKeys = getIniSetting theDefaultFile theCategory  --get all keys from the category in the file
			local result = theDefault --initialize the result to the factory default
			if findItem theKeys theKey > 0 do --if a global default exists, 
			(
				local theResult = getIniSetting theDefaultFile theCategory theKey  --get the value from the file
				if executeIt then --if necessary, convert to MAXScript value
				(
					result = try(execute theResult)catch(OK)  
					if result == OK do result = theDefault 	 --if conversion failed, use the factory default.	
				)
				else
					result = theResult --if no conversion necessary, use the result as is - it will remain a string
			)
			result  --return the global default
		),
		
		fn getStickyCaption  theCategory theKey theCaption =
		(
			if not (SMTDFunctions.IsSettingSticky theCategory theKey) then
			(
				theCaption
				theCaption[theCaption.count] = "*"
			)
			theCaption
		),
		
		--Returns the value of the specified category and key, or the default value if the key is empty.
		--If the executeIt optional keyword is passed as false, the result will be returned as string
		--If true or not specified, the value will be converted to a MAXScript value via execute() call, for example for Integers, Booleans etc.
		fn getINI theCategory theKey theDefault executeIt:true useStickyFile:true isSticky:true=
		(
			local theDefault = SMTDFunctions.getGlobalDefault theCategory theKey theDefault executeIt:executeIt --set the default to global if available
			local result = theDefault
			local isSticky = isSticky
			if useStickyFile do isSticky = SMTDFunctions.IsSettingSticky theCategory theKey isSticky:isSticky
			if isSticky do --to disable stickyness, enter "false" for the given key. 
			(
				if executeIt then
				(
					result = try(execute (getIniSetting SMTDPaths.InIFile theCategory theKey))catch(OK) --if sticky, try to load from local file.
					if result == OK do result = theDefault --if the value was not in the local file, assume default.
				)
				else 
				(
					result = (getIniSetting SMTDPaths.IniFile theCategory theKey) --if sticky, load from local file without executing.
				)	
			)	
			result
		),

		
		fn getSettingsList =
		(
			#(
				--  1:INI Category				 2:Prop.Name							3:Struct Prop.Name							4:exec	5:UI Section											6: UI Name or Description		7:use sticky file 8:is sticky
				#("JobSettings",				"JobName", 								#JobName, 									false, 	"Job Description", 										"Job Name" ),
				#("JobSettings",				"Comment", 								#Comment, 									false, 	"Job Description", 										"Comment" ),
				#("JobSettings",				"Department", 							#Department, 								false, 	"Job Description", 										"Department" ),
				
				#("JobSettings",				"PoolName", 							#PoolName, 									false, 	"Pool, Group and Priority",								"Pool" ),
				#("JobSettings",				"Pool2Name", 							#Pool2Name, 								false, 	"Pool, Group and Priority",								"Secondary Pool" ),
				
				#("JobSettings",				"Group", 								#Group,		 								false, 	"Pool, Group and Priority",								"Group" ),
				#("JobSettings",				"Priority", 							#Priority, 									true, 	"Pool, Group and Priority", 							"Priority" ),
				
				#("UserOptions",				"SubmitSceneMode", 						#SubmitSceneMode, 							false, 	"Scene File Submission Options",						"Scene File Submission Mode" ),
				#("UserOptions",				"SubmitSceneBasePath", 					#SubmitSceneBasePath,		 				false, 	"Scene File Submission Options", 						"Scene File Base Path" ),
				#("UserOptions",				"SubmitSceneGlobalBasePath", 			#SubmitSceneGlobalBasePath, 				false, 	"Scene File Submission Options", 						"Scene File Global Base Path" ),

				#("UserOptions",				"PerformSanityCheck", 					#PerformSanityCheck, 						true, 	"Sanity Check",											"Run Sanity Check Automatically Before Submission" ),
				
				#("JobSettings",				"LimitEnabled", 						#LimitEnabled, 								true, 	"Job Options",											"Limit Number Of Machines Rendering Concurrently" ),
				#("JobSettings",				"MachineLimit", 						#MachineLimit, 								true, 	"Job Options",											"Machines" ),
				#("JobSettings",				"RenderOutOfOrder", 					#RenderOutOfOrder, 							true, 	"Job Options",											"Render Out Of Order" ),
				#("JobSettings",				"OutOfOrderMethod",						#OutOfOrderMethod, 							false, 	"Job Options",											"Out Of Order Method" ),
				#("JobSettings",				"OutOfOrderStep", 						#OutOfOrderStep,							true, 	"Job Options",											"Nth Frame" ),
				
				#("JobSettings",				"ChunkSize", 							#ChunkSize, 								true, 	"Job Options",											"Chunk Size" ),
				#("JobSettings",				"RenderFramesPreviewJob", 				#RenderFramesPreviewJob, 					true, 	"Job Options",											"Render Frames Preview Job" ),
				#("JobSettings",				"PreviewJobFrameCount", 				#PreviewJobFrameCount, 						true, 	"Job Options",											"Preview Job Frame Count" ),
				#("JobSettings",				"PreviewJobPriorityOffset", 			#PreviewJobPriorityOffset, 					true, 	"Job Options",											"Preview Job Priority Offset" ),
				#("JobSettings",				"PreviewJobSecondJobDependentOnFirst", 	#PreviewJobSecondJobDependentOnFirst, 		true, 	"Job Options",											"Preview Job Second Job Dependent On First" ),
								
				#("JobSettings",				"SequentialJob", 						#SequentialJob, 							true, 	"Job Options",											"Enforce Sequential Rendering" ),
				#("JobSettings",				"SubmitVisibleObjectsOnly", 			#SubmitVisibleObjectsOnly, 					true, 	"Job Options",											"Submit Visible Objects Only" ),

				#("JobSettings",				"MaxTasksPerSlave", 					#MaxTasksPerSlave, 							true, 	"Job Options",											"Concurrent Tasks" ),
				#("JobSettings",				"LimitTasksToNumberOfCpus", 			#LimitTasksToNumberOfCpus, 					true, 	"Job Options",											"Limit Tasks To Number Of Cpus" ),
	
				#("JobSettings",				"OnComplete", 							#OnComplete, 								false, 	"Job Options",											"On Job Completion" ),
				#("JobSettings",				"SubmitAsSuspended", 					#SubmitAsSuspended, 						true, 	"Job Options",											"Submit As Suspended" ),
					
				#("JobSettings",				"TaskTimeoutEnabled",					#TaskTimeoutEnabled,						true, 	"Job Options",											"Task Timeout On" ),
				#("JobSettings",				"TaskTimeout", 							#TaskTimeout,								true, 	"Job Options",											"Task Timeout In Seconds" ),
				#("JobSettings",				"AutoTaskTimeout", 						#AutoTaskTimeout,							true, 	"Job Options",											"Auto Task Timeout On" ),
				#("JobSettings",				"RestartMax", 							#RestartMax, 								true, 	"Job Options",											"Restart 3ds Max Between Tasks" ),
				#("JobSettings",				"MaxVersionToForce", 					#MaxVersionToForce, 						false, 	"Job Options",											"Force 3ds Max Build" ),
				#("JobSettings",				"StereoCameraMode", 					#StereoCameraMode, 						false, 	"Job Options",								"Stereo Camera Job Submission Mode" ),
				#("JobSettings",				"StereoCameraPriorityOrder", 			#StereoCameraPriorityOrder, 				false, 	"Job Options",								"Stereo Camera Job Priority Mode" ),
				
				
				
				#("JobSettings",				"LeftEyeTag", 								#LeftEyeTag, 									false, 	"Job Options",								"Stereo Camera Left Eye Tag", false, false ),
				#("JobSettings",				"RightEyeTag", 							#RightEyeTag, 								false, 	"Job Options",								"Stereo Camera Right Eye Tag", false, false ),
				#("JobSettings",				"CenterEyeTag", 							#CenterEyeTag, 								false, 	"Job Options",								"Stereo Camera Center Eye Tag", false, false ),
				
				
				#("JobSettings",				"MaxVersionToForceSticky", 				#MaxVersionToForceSticky, 					true, 	"Job Options",											"Make Force 3ds Max Build Sticky" ),
				#("JobSettings",				"OverrideJobFailureDetection",			#OverrideJobFailureDetection, 				true, 	"Job Failure Detection",								"Override Job Error Limit" ),
				#("JobSettings",				"FailureDetectionJobErrors", 			#FailureDetectionJobErrors, 				true, 	"Job Failure Detection",								"Job Error Limit" ),
				#("JobSettings",				"OverrideTaskFailureDetection",			#OverrideTaskFailureDetection,				true, 	"Job Failure Detection",								"Override Task Error Limit" ),
				#("JobSettings",				"FailureDetectionTaskErrors", 			#FailureDetectionTaskErrors, 				true, 	"Job Failure Detection",								"Task Error Limit" ),
				#("JobSettings",				"SendJobErrorWarning", 					#SendJobErrorWarning, 						true, 	"Job Failure Detection",								"Send Job Error Warning" ),

				#("RemoteSubmission",			"DropSubmission", 						#DropSubmission, 							true, 	"Remote Submission",									"Drop Submission" ),
				#("RemoteSubmission",			"BgSubmission", 						#BgSubmission, 								true, 	"Remote Submission",									"Background Submission" ),
				#("RemoteSubmission",			"TransferPool", 						#TransferPool, 								false, 	"Remote Submission",									"Transfer Pool" ),
				#("RemoteSubmission",			"TransferGroup", 						#TransferGroup, 							false, 	"Remote Submission",									"Transfer Group" ),
				#("RemoteSubmission",			"TransferPriority", 					#TransferPriority, 							true, 	"Remote Submission",									"Transfer Priority" ),
				#("RemoteSubmission",			"TransferDeleteOnComplete",		 		#TransferDeleteOnComplete, 					true, 	"Remote Submission",									"Delete On Complete" ),
				#("RemoteSubmission",			"TransferJobAsSuspended", 				#TransferJobAsSuspended, 					true, 	"Remote Submission",									"Transfer Job As Suspended" ),
				#("RemoteSubmission",			"TransferCompressed", 					#TransferCompressed, 						true, 	"Remote Submission",									"Transfer Compressed" ),

				#("RenderingOptions",			"UseAltPluginIni", 						#UseAltPluginIni, 							true, 	"3ds Max Rendering",									"Use Alternate Plugin.ini" ),
				#("RenderingOptions",			"AutoSuggest", 							#AutoSuggestIni, 							true, 	"3ds Max Rendering",									"Auto-Detect ini For Current Renderer" ),
				#("RenderingOptions",			"AltPluginIni", 						#AltPluginIni, 								false, 	"3ds Max Rendering",									"Alternate Plugin.ini" ),

				#("RenderingOptions",			"EnableFailOnBlackFrames", 				#EnableFailOnBlackFrames,					true, 	"3ds Max Rendering",									"Fail On Black Frames" ),
				#("RenderingOptions",			"BlackPixelPercentage", 				#BlackPixelPercentage,						true, 	"3ds Max Rendering",									"Black Pixel Percentage" ),
				#("RenderingOptions",			"BlackPixelThreshold", 					#BlackPixelThreshold,						true, 	"3ds Max Rendering",									"Black Pixel Threshold" ),
				#("RenderingOptions",			"BlackFramesCheckRenderElements",		#BlackFramesCheckRenderElements,			true,	"3ds Max Rendering",									"Fail On Black Frames" ),
				
				#("RenderingOptions",			"OverrideBitmapPager", 					#OverrideBitmapPager,						true, 	"3ds Max Rendering",									"Override Bitmap Pager Setting While Rendering" ),
				#("RenderingOptions",			"BitmapPager", 							#BitmapPager,								true, 	"3ds Max Rendering",									"Bitmap Pager Enabled" ),
				
				#("RenderingOptions",			"GammaCorrection", 						#GammaCorrection,							true, 	"3ds Max Rendering",									"Enable Gamma Correction" ),
				#("RenderingOptions",			"GammaInput", 							#GammaInput,								true, 	"3ds Max Rendering",									"Gamma Input" ),
				#("RenderingOptions",			"GammaOutput", 							#GammaOutput,								true, 	"3ds Max Rendering",									"Gamma Output" ),
				
				#("RenderingOptions",			"SubmitExternalFilesMode", 				#SubmitExternalFilesMode,					true, 	"3ds Max Rendering",									"Submit External Files Mode" ),
				#("RenderingOptions",			"MergeXRefsOnSubmission", 				#MergeXRefsOnSubmission,					true, 	"3ds Max Rendering",									"Merge Object XRefs" ),
				#("RenderingOptions",			"MergeSceneXRefsOnSubmission", 			#MergeSceneXRefsOnSubmission,				true, 	"3ds Max Rendering",									"Merge Scene XRefs On Submission" ),
				#("RenderingOptions",			"ForceWorkstationMode", 				#ForceWorkstationMode,						true, 	"3ds Max Rendering",									"Force Workstation Mode" ),
				#("RenderingOptions",			"UseSilentMode", 						#UseSilentMode,								true, 	"3ds Max Rendering",									"Enable Silent Mode" ),
				#("RenderingOptions",			"IgnoreMissingExternalFiles", 			#IgnoreMissingExternalFiles,				true, 	"3ds Max Rendering",									"Ignore Missing External File Errors" ),
				#("RenderingOptions",			"IgnoreMissingUVWs", 					#IgnoreMissingUVWs,							true, 	"3ds Max Rendering",									"Ignore Missing UVW Errors" ),
				#("RenderingOptions",			"IgnoreMissingXREFs", 					#IgnoreMissingXREFs,						true, 	"3ds Max Rendering",									"Ignore Missing XREF Errors" ),
				#("RenderingOptions",			"IgnoreMissingDLLs", 					#IgnoreMissingDLLs,							true, 	"3ds Max Rendering",									"Ignore Missing DLL Errors" ),

				#("RenderingOptions",			"IgnoreRenderElements", 				#IgnoreRenderElements,						true, 	"3ds Max Rendering",									"Do Not Save Render Element Files" ),
				#("RenderingOptions",			"ShowFrameBuffer", 						#ShowFrameBuffer,							true, 	"3ds Max Rendering",									"Show Virtual Frame Buffer" ),
				#("RenderingOptions",			"ShowRendererFrameBufferOverride",		#ShowRendererFrameBufferOverride,			true,	"3ds Max Rendering",									"Override Renderer Frame Buffer Visibility" ),
				#("RenderingOptions",			"ShowRendererFrameBuffer",				#ShowRendererFrameBuffer,					true,	"3ds Max Rendering",									"Show Renderer Frame Buffer" ),

				#("RenderingOptions",			"DisableProgressUpdateTimeout", 		#DisableProgressUpdateTimeout,				true, 	"3ds Max Rendering",									"Disable Progress Update Timeout" ),
				#("RenderingOptions",			"SkipRender",						 	#SkipRender,								true, 	"3ds Max Rendering",									"Disable Frame Rendering" ),
				#("RenderingOptions",			"DisableMultipass", 					#DisableMultipass,							true, 	"3ds Max Rendering",									"Disable Multipass" ),

				#("RenderingOptions",			"ForceRestartRenderer", 				#none,										true, 	"Defaults INI File Only",								"Force Restart for mental ray, Brazil and V-Ray", false, false ),
				#("RenderingOptions",			"RestartRenderer", 						#RestartRenderer,							true, 	"3ds Max Rendering",									"Restart Renderer" ),

				#("RenderingOptions",			"JobIsInterruptible", 					#JobIsInterruptible,						true, 	"3ds Max Rendering",									"Job Is Interruptible" ),
				#("RenderingOptions",			"UseCustomShader", 						#UseCustomShader,							true, 	"3ds Max Rendering",									"Apply Custom Material To Scene" ),
				#("RenderingOptions",			"CustomShaderMode", 					#CustomShaderMode,							true, 	"3ds Max Rendering",									"Custom Material Mode" ),

				#("RenderingOptions",			"RemovePadding", 						#RemovePadding,								true, 	"3ds Max Pathing Options",								"Remove Filename Padding" ),
				#("RenderingOptions",			"StrictOutput", 						#StrictOutput,								true, 	"3ds Max Pathing Options",								"Force Strict Output Naming" ),
				#("RenderingOptions",			"Delimiter",							#Delimiter,									false,	"3ds Max Pathing Options",								"Filename Delimiter Symbol (not exposed to UI)", false, false ), --cannot ever be sticky, even if Repo Sticky INI file says it is, since we have no UI. Uses either factory default Period, or a global value from Repo Defaults INI. Taken As String.
				#("RenderingOptions",			"PurifyFilenames",						#PurifyFilenames,							true,	"3ds Max Pathing Options",								"Purify Filenames" ), --false, false ), 
				#("RenderingOptions",			"PurifyCharacterCodes",					#PurifyCharacterCodes,						true,	"3ds Max Pathing Options",								"Purify Characters ASCII List (not exposed to UI)", false, false ),
				#("RenderingOptions",			"ForceLowerCaseFilenames", 				#ForceLowerCaseFilenames,					true, 	"3ds Max Pathing Options",								"Force Lower-Case Filenames" ),
				#("RenderingOptions",			"RenderElementsUpdatePaths", 			#RenderElementsUpdatePaths,					true, 	"3ds Max Pathing Options",								"Update Render Elements' Paths" ),
				#("RenderingOptions",			"RenderElementsUpdateFilenames",		#RenderElementsUpdateFilenames,				true, 	"3ds Max Pathing Options",								"Auto-Update Render Elements' Filenames" ),
				#("RenderingOptions",			"RenderElementsIncludeNameInPath",		#RenderElementsIncludeNameInPath,			true, 	"3ds Max Pathing Options",								"Include RE Type Paths" ),
				#("RenderingOptions",			"RenderElementsIncludeTypeInPath",		#RenderElementsIncludeTypeInPath,			true, 	"3ds Max Pathing Options",								"Include RE Type Filenames" ),
				#("RenderingOptions",			"RenderElementsIncludeNameInFileName",	#RenderElementsIncludeNameInFileName,		true, 	"3ds Max Pathing Options",								"Include RE Name In Paths" ),
				#("RenderingOptions",			"RenderElementsIncludeTypeInFilename",	#RenderElementsIncludeTypeInFilename,		true, 	"3ds Max Pathing Options",								"Include RE Name In Filenames" ),
				#("RenderingOptions",			"RenderElementsPermanentChanges",		#RenderElementsPermanentChanges,			true, 	"3ds Max Pathing Options",								"Permanent Render Element Path Changes" ),
				#("RenderingOptions",			"RenderElementNamesPermanentChanges",	#RenderElementNamesPermanentChanges,		true, 	"3ds Max Pathing Options",								"Permanent Render Element Name Changes" ),
				
				#("RenderingOptions",			"RebuildRenderElements", 				#RebuildRenderElements,						true, 	"3ds Max Pathing Options",								"Rebuild Render Elements" ),
				#("RenderingOptions",			"IncludeLocalPaths", 					#IncludeLocalPaths,							true, 	"3ds Max Pathing Options",								"Include Local Paths With Job" ),

				#("RenderingOptions",			"UsePathConfigFile", 					#UsePathConfigFile,							true, 	"3ds Max Pathing Options",								"Use Alternate Paths File" ),
				#("RenderingOptions",			"MergePathConfigFile", 					#MergePathConfigFile,						true, 	"3ds Max Pathing Options",								"Merge Paths File" ),
				#("RenderingOptions",			"PathConfigFile", 						#PathConfigFile,							false, 	"3ds Max Pathing Options",								"Paths Configuration File" ),

				#("RenderingOptions",			"OutputFilenameUserPattern", 			#OutputFilenameUserPattern,					false, 	"3ds Max Pathing Options",								"Override Output Filename By Global Pattern", false, false ),
				#("RenderingOptions",			"ReplaceOutputFilenameWithUserPattern",	#ReplaceOutputFilenameWithUserPattern,		false,	"3ds Max Pathing Options", 								"Output Filename Global Pattern", false, false ), --this is never sticky, set to true if pattern exists, can be overridden temporarily for current session!
			
				#("RenderingOptions",			"ImsqOutputPath", 						#ImsqOutputPath,							false, 	"Render Output and Autodesk ME Image Sequence (IMSQ) Creation",	"Image Sequence Filename" ),
				#("RenderingOptions",			"CreateImsqFile", 						#CreateImsqFile,							true, 	"Render Output and Autodesk ME Image Sequence (IMSQ) Creation",	"Create Image Sequence (IMSQ) File" ),
				#("RenderingOptions",			"CopyImsqFile", 						#CopyImsqFile,								true, 	"Render Output and Autodesk ME Image Sequence (IMSQ) Creation",	"Use Alternate Paths File" ),

				#("StateSets",					"StateSetsSubmit", 						#StateSetsSubmit,							true, 	"State Sets",											"Submit Checked State Sets" ),
				#("StateSets",					"StateSetRenameOutput", 				#StateSetRenameOutput,						true, 	"State Sets",											"Add State Set Name to Output Filename" ),
						
				#("Scripts",					"RunPreJobScript", 						#RunPreJobScript,							true, 	"Run Python Scripts",									"Run Pre-Job Script" ),
				#("Scripts",					"PreJobScriptFile", 					#PreJobScriptFile,							false, 	"Run Python Scripts",									"Pre-Job Script File" ),
				#("Scripts",					"RunPostJobScript", 					#RunPostJobScript,							true, 	"Run Python Scripts",									"Run Post-Job Script" ),
				#("Scripts",					"PostJobScriptFile", 					#PostJobScriptFile,							false, 	"Run Python Scripts",									"Post-Job Script File" ),
				#("Scripts",					"RunPreTaskScript", 					#RunPreTaskScript,							true, 	"Run Python Scripts",									"Run Pre-Task Script" ),
				#("Scripts",					"PreTaskScriptFile", 					#PreTaskScriptFile,							false, 	"Run Python Scripts",									"Pre-Task Script File" ),
				#("Scripts",					"RunPostTaskScript", 					#RunPostTaskScript,							true, 	"Run Python Scripts",									"Run Post-Task Script" ),
				#("Scripts",					"PostTaskScriptFile", 					#PostTaskScriptFile,						false, 	"Run Python Scripts",									"Post-Task Script File" ),
			
				#("Scripts",					"RunPreLoadScript", 					#RunPreLoadScript,							true, 	"Run MAXScript Scripts",								"Run Pre-Load Script" ),
				#("Scripts",					"PreLoadScriptFile", 					#PreLoadScriptFile,							false, 	"Run MAXScript Scripts",								"Pre-Load Script File" ),
				#("Scripts",					"RunPostLoadScript", 					#RunPostLoadScript,							true, 	"Run MAXScript Scripts",								"Run Post-Load Script" ),
				#("Scripts",					"PostLoadScriptFile", 					#PostLoadScriptFile,						false, 	"Run MAXScript Scripts",								"Post-Load Script File" ),
				#("Scripts",					"RunPreFrameScript", 					#RunPreFrameScript,							true, 	"Run MAXScript Scripts",								"Run Pre-Frame Script" ),
				#("Scripts",					"PreFrameScriptFile", 					#PreFrameScriptFile,						false, 	"Run MAXScript Scripts",								"Pre-Frame Script File" ),
				#("Scripts",					"RunPostFrameScript", 					#RunPostFrameScript,						true, 	"Run MAXScript Scripts",								"Run Post-Load Script" ),
				#("Scripts",					"PostFrameScriptFile", 					#PostFrameScriptFile,						false, 	"Run MAXScript Scripts",								"Post-Load Script File" ),
			
				#("UserOptions",				"LocalRendering", 						#LocalRendering,							true, 	"User Options",											"Enable Local Rendering" ),
				#("UserOptions",				"OneCpuPerTask", 						#OneCpuPerTask,								true, 	"User Options",											"One CPU Per Task" ),
				#("UserOptions",				"AutomaticallyUpdateJobName", 			#AutomaticallyUpdateJobName,				true, 	"User Options",											"Automatically Update Job Name" ),
				#("UserOptions",				"OverrideLowPriorityThread", 			#OverrideLowPriorityThread,					true, 	"User Options",											"Override Renderer's Low Priority Thread Option (Brazil r/s, V-Ray)" ),
				#("UserOptions",				"ClearMaterialEditorOnSubmission", 		#ClearMaterialEditorOnSubmission,			true, 	"User Options",											"Clear Material Editor In The Submitted File" ),
				#("UserOptions",				"UnlockMEditRenderer", 					#UnlockMEditRenderer,						true, 	"User Options",											"Unlock Material Editor Renderer" ),
				#("UserOptions",				"DeleteEmptyStateSets",					#DeleteEmptyStateSets,						true,	"User Options",											"Delete Empty State Sets In The Submitted File"),
				#("UserOptions",				"DumpFileProperties",					#DumpFileProperties,						true,	"User Options",											"Dump Scene File Properties to Job Log Report"),
				
				#("UserOptions",				"WarnAboutMissingExternalFiles", 		#WarnAboutMissingExternalFiles,				true, 	"User Options",											"Warn About Missing External Files On Submission" ),

				#("UserOptions",				"ExternalFilesWarningOn", 				#ExternalFilesWarningOn,					true, 	"3ds Max Rendering",									"Warn About Submit External Files" ),
				#("UserOptions",				"ExternalFilesWarningCount", 			#ExternalFilesWarningCount,					true, 	"3ds Max Rendering",									"External Files Count Warning Threshold" ),
				#("UserOptions",				"ExternalFilesWarningMB", 				#ExternalFilesWarningMB,					true, 	"3ds Max Rendering",									"External Files MB Warning Threshold" ),

				#("UserOptions",				"OverrideLanguage",						#OverrideLanguage,							true,	"User Options",											"Override 3ds Max Language" ),
				
				#("UserOptions",				"ExportAdvancedRenderOutputFiles",		#ExportAdvancedRenderOutputFiles,			true,	"Export Renderer Specific Advanced Settings",			"Export Renderer Caching Output Files" ),
				#("UserOptions",				"ExportAdvancedRenderInfoScanline",		#ExportAdvancedRenderInfoScanline,			true,	"Export Renderer Specific Advanced Settings",			"3ds Max Scanline" ),
				#("UserOptions",				"ExportAdvancedRenderInfoQuicksilver",	#ExportAdvancedRenderInfoQuicksilver,		true,	"Export Renderer Specific Advanced Settings",			"3ds Max Quicksilver" ),
				#("UserOptions",				"ExportAdvancedRenderInfoIRay",			#ExportAdvancedRenderInfoIRay,				true,	"Export Renderer Specific Advanced Settings",			"NVidia iray" ),
				
				#("UserOptions",				"ExportAdvancedRenderInfoVRay",			#ExportAdvancedRenderInfoVRay,				true,	"Export Renderer Specific Advanced Settings",			"Chaos Group V-Ray" ),
				#("UserOptions",				"ExportAdvancedRenderInfoVRayRT",		#ExportAdvancedRenderInfoVRayRT,			true,	"Export Renderer Specific Advanced Settings",			"Chaos Group V-Ray RT" ),
				#("UserOptions",				"ExportAdvancedRenderInfoMentalRay",	#ExportAdvancedRenderInfoMentalRay,			true,	"Export Renderer Specific Advanced Settings",			"NVidia Mental Ray" ),
				#("UserOptions",				"ExportAdvancedRenderInfoBrazil",		#ExportAdvancedRenderInfoBrazil,			true,	"Export Renderer Specific Advanced Settings",			"SplutterFish Brazil r/s 1.x" ),
				#("UserOptions",				"ExportAdvancedRenderInfoBrazil2",		#ExportAdvancedRenderInfoBrazil2,			true,	"Export Renderer Specific Advanced Settings",			"SplutterFish Brazil r/s 2.x" ),

				#("UserOptions",				"ExportAdvancedRenderInfoKrakatoa",		#ExportAdvancedRenderInfoKrakatoa,			true,	"Export Renderer Specific Advanced Settings",			"Thinkbox Krakatoa MX" ),
				#("UserOptions",				"ExportAdvancedRenderInfoAmaretto",		#ExportAdvancedRenderInfoAmaretto,			true,	"Export Renderer Specific Advanced Settings",			"Thinkbox Amaretto" ),
				#("UserOptions",				"ExportAdvancedRenderInfoFinalRender",	#ExportAdvancedRenderInfoFinalRender,		true,	"Export Renderer Specific Advanced Settings",			"Cebas finalRender" ),
				#("UserOptions",				"ExportAdvancedRenderInfoMaxwell",		#ExportAdvancedRenderInfoMaxwell,			true,	"Export Renderer Specific Advanced Settings",			"Next Limit Maxwell" ),
				#("UserOptions",				"ExportAdvancedRenderInfoCorona",		#ExportAdvancedRenderInfoCorona,			true,	"Export Renderer Specific Advanced Settings",			"Render Legion Corona" ),

				#("UserOptions",				"TimeoutSubmission", 					#TimeoutSubmission,							true, 	"Submission Timeouts",									"Job Submission Timeout in seconds" ),
				#("UserOptions",				"TimeoutQTSubmission", 					#TimeoutQTSubmission,						true, 	"Submission Timeouts",									"Quicktime Submission Timeout in seconds" ),
				#("UserOptions",				"TimeoutCollectData", 					#TimeoutCollectData,						true, 	"Submission Timeouts",									"Data Collection Timeout in seconds" ),

				#("LimitGroups",				"LimitGroups", 							#LimitGroups,								true, 	"Limits",												"Limits" ),
				#("LimitGroups",				"LimitGroupsToUse", 					#LimitGroupsToUse,							true, 	"Limits",												"Limits To Use" ),
				#("LimitGroups",				"LimitGroupAutoBrazil",					#LimitGroupAutoBrazil,						true, 	"Limits",												"Automatically set 'Brazil' Limit when rendering with Brazil r/s." ),
				#("LimitGroups",				"LimitGroupAutoVRay", 					#LimitGroupAutoVRay,						true, 	"Limits",												"Automatically set 'VRay' Limit when rendering with Chaos Group V-Ray." ),
				#("LimitGroups",				"LimitGroupAutoCorona",					#LimitGroupAutoCorona,						true,	"Limits",												"Automatically set 'Corona' Limit when rendering with Render Legion Corona." ),
				#("LimitGroups",				"LimitGroupAutoKrakatoa",				#LimitGroupAutoKrakatoa,					true, 	"Limits",												"Automatically set 'Krakatoa' Limit when rendering with Thinkbox Krakatoa MX." ),
				#("LimitGroups",				"LimitGroupAutoFinalRender",			#LimitGroupAutoFinalRender,					true, 	"Limits",												"Automatically set 'FinalRender' Limit when rendering with Cebas finalRender." ),
				#("LimitGroups",				"LimitGroupAutoMaxwell", 				#LimitGroupAutoMaxwell,						true, 	"Limits",												"Automatically set 'Maxwell' Limit when rendering with NextLimit Maxwell." ),
				#("LimitGroups",				"LimitGroupAutoWorkstation", 			#LimitGroupAutoWorkstation,					true, 	"Limits",												"Automatically set '3dsmaxWorkstation' Limit for Workstation Mode." ),

				#("AssemblerSettings",			"AssemblerOverride",					#AssemblerOverride,							true,	"Multi-Region Rendering",								"Assembler Override" ),
				#("AssemblerSettings",			"AssemblerPoolName",					#AssemblerPoolName,							false,	"Multi-Region Rendering",								"Assembler Pool" ),
				#("AssemblerSettings",			"AssemblerPool2Name",					#AssemblerPool2Name,						false,	"Multi-Region Rendering",								"Assembler Secondary Pool" ),
				#("AssemblerSettings",			"AssemblerGroup",						#AssemblerGroup,							false,	"Multi-Region Rendering",								"Assembler Group" ),
				#("AssemblerSettings",			"AssemblerPriority",					#AssemblerPriority,							true,	"Multi-Region Rendering",								"Assembler Priority" ),

				--#("MultiRegionRendering",		"MultiRegionRendering", 				#MultiRegionRendering,						true, 	"Multi-Region Rendering",								"Enable Time Rendering", false,false ),
				#("MultiRegionRendering",		"RegionRenderingMode",					#RegionRenderingMode,						false,	"Multi-Region Rendering", 								"Multi-Region/Tile Rendering Mode", true, false, true),
				#("MultiRegionRendering",		"MultiRegionCopyDraftConfig", 			#MultiRegionCopyDraftConfig,				true, 	"Multi-Region Rendering",								"Copy Draft Config Files To Output Folder" ),
				#("MultiRegionRendering",		"MultiRegionBackground",				#MultiRegionBackground,						true, 	"Multi-Region Rendering",								"Assemble Over Background Mode" ),
				#("MultiRegionRendering",		"MultiRegionBackgroundImage",			#MultiRegionBackgroundImage,				false, 	"Multi-Region Rendering",								"User-Defined Background Image" ),
				#("MultiRegionRendering",		"MultiRegionFitPadding",				#MultiRegionFitPadding,						true, 	"Multi-Region Rendering",								"Fit Region Padding Percentage", false, true ),  --always sticky
				
				--#("TilesRendering",			"SingleTileJob", 						#SingleTileJob,								true, 	"Tile Rendering",										"Submit All Tiles As a Single Job" ),
				#("TilesRendering",				"TilesPadding", 						#TilesPadding,								true, 	"Tile Rendering",										"Pixel Padding" ),
				#("TilesRendering",				"SingleTileJobCleanup", 				#SingleTileJobCleanup,						true, 	"Tile Rendering",										"Cleanup Tiles After Assembly" ),
				#("TilesRendering",				"SingleTileJobDraftErrorOnMissing", 	#SingleTileJobDraftErrorOnMissing,			true, 	"Tile Rendering",										"Draft Assembly Job Error On Missing Tile" ),
				--#("TilesRendering",			"TilesRendering", 						#TilesRendering,							true, 	"Tile Rendering",										"Enable Tile Rendering" ),
				#("TilesRendering",				"TilesInX", 							#TilesInX,									true, 	"Tile Rendering",										"Tiles In X" ),
				#("TilesRendering",				"TilesInY", 							#TilesInY,									true, 	"Tile Rendering",										"Tiles In Y" ),
				#("TilesRendering",				"TileBlowupMode", 						#TileBlowupMode,							true, 	"Tile Rendering",										"Enable Blowup Mode" ),
				#("TilesRendering",				"SingleTileJobDependent", 				#SingleTileJobDependent,					true, 	"Tile Rendering",										"Submit Dependent Assembly Job" ),
				#("TilesRendering",				"SingleTileJobDraft", 					#SingleTileJobDraft,						true, 	"Tile Rendering",										"Use Draft Assembly Job" ),
				--#("TilesRendering",			"MachineLimitTileJobs", 				#MachineLimitTileJobs,						true, 	"Tile Rendering",										"Split Machine Limit Between Tile Jobs" ),
				#("TilesRendering",				"CustomTilesPreviewWidth", 				#CustomTilesPreviewWidth,					true, 	"Tile Rendering",										"Width of the Custom Tiles Preview Image" ),
				#("TilesRendering",				"CustomTilesPreviewHeight",				#CustomTilesPreviewHeight,					true, 	"Tile Rendering",										"Height of the Custom Tiles Preview Image" ),
				
				#("TilesRendering",				"RegionType", 							#RegionType,								true, 	"Region Rendering",										"Region Type: 1=Region 2=Crop 3=Blowup" ),
				#("TilesRendering",				"RegionUseMaxValues", 					#RegionUseMaxValues,						true, 	"Region Rendering",										"Use 3ds Max Region Values" ),

				#("DBROptions",					"DBRServers", 							#DBRServers,								true, 	"DBR Options",											"Number of Slaves for DBR" ),

				#("QuickTime",					"Generate", 							#QuicktimeGenerate,							true, 	"Quicktime Generation From Rendered Frame Sequence",	"Generate Quicktime .MOV File" ),
				#("QuickTime",					"QuicktimePoolName", 					#QuicktimePoolName,							false, 	"Quicktime Generation From Rendered Frame Sequence",	"Quicktime Pool" ),
				#("QuickTime",					"QuicktimeGroupName",					#QuicktimeGroupName,						false, 	"Quicktime Generation From Rendered Frame Sequence",	"Quicktime Group" ),
				#("QuickTime",					"FilenameMode",							#QuicktimeFilenameMode,						true, 	"Quicktime Generation From Rendered Frame Sequence",	"Use Template" ),
				#("QuickTime",					"CustomFilename",						#QuicktimeCustomFilename,					false, 	"Quicktime Generation From Rendered Frame Sequence",	"Template Filename" ),
				#("QuickTime",					"QuicktimeSettingsFile",				#QuicktimeSettingsFile,						false, 	"Quicktime Generation From Rendered Frame Sequence",	"Quicktime Settings File" ),
				
				#("Blacklist",					"SlaveSettingsSticky", 					#SlaveSettingsSticky,						true, 	"Blacklist/Whitelist Slaves",							"Make Blacklist Settings Sticky", false, true ),
				#("Blacklist",					"BlackOrWhite", 						#SlavesBlackList,							true, 	"Blacklist/Whitelist Slaves",							"Blacklist", false, true ),
				#("Blacklist",					"SlavesList", 							#SlavesList,								true, 	"Blacklist/Whitelist Slaves",							"Slaves List", false, true ),
				#("Blacklist",					"SlavesNamedSet", 						#SlavesNamedSet,							false, 	"Blacklist/Whitelist Slaves",							"Slaves Selection Set", false, true ),
				
				#("DraftSettings",				"DraftSubmitJob", 						#DraftSubmitJob,							true, 	"Deadline Draft Post-Render Processing",				"Submit Dependent Draft Job" ),
				#("DraftSettings",				"DraftShotgunUpload", 					#DraftShotgunUpload,						true, 	"Deadline Draft Post-Render Processing",				"Upload to Shotgun" ),
				#("DraftSettings",				"DraftQuick", 							#DraftQuick,								true, 	"Deadline Draft Post-Render Processing",				"Quick" ),
				#("DraftSettings",				"DraftFormat", 							#DraftFormat,								false, 	"Deadline Draft Post-Render Processing",				"Draft Format" ),
				#("DraftSettings",				"DraftCodec", 							#DraftCodec,								false, 	"Deadline Draft Post-Render Processing",				"Draft Codec" ),
				#("DraftSettings",				"DraftResolution", 						#DraftResolution,							false, 	"Deadline Draft Post-Render Processing",				"Draft Resolution" ),
				#("DraftSettings",				"DraftQuality", 						#DraftQuality,								true, 	"Deadline Draft Post-Render Processing",				"Draft Quality" ),
				#("DraftSettings",				"DraftFrameRate", 						#DraftFrameRate,							false, 	"Deadline Draft Post-Render Processing",				"Draft Frame Rate" ),
				#("DraftSettings",				"DraftTemplate", 						#DraftTemplate,								false, 	"Deadline Draft Post-Render Processing",				"Template" ),
				#("DraftSettings",				"DraftUser", 							#DraftUser,									false, 	"Deadline Draft Post-Render Processing",				"User" ),
				#("DraftSettings",				"DraftEntity", 							#DraftEntity,								false, 	"Deadline Draft Post-Render Processing",				"Entity" ),
				#("DraftSettings",				"DraftVersion", 						#DraftVersion,								false, 	"Deadline Draft Post-Render Processing",				"Version" ),
				
				#("ExtraInfo",					"ExtraInfo0",							#ExtraInfo0,								false,	"Extra Info", 											"Extra Info 0", true, false),
				#("ExtraInfo",					"ExtraInfo1",							#ExtraInfo1,								false,	"Extra Info", 											"Extra Info 1", true, false),
				#("ExtraInfo",					"ExtraInfo2",							#ExtraInfo2,								false,	"Extra Info", 											"Extra Info 2", true, false),
				#("ExtraInfo",					"ExtraInfo3",							#ExtraInfo3,								false,	"Extra Info", 											"Extra Info 3", true, false),
				#("ExtraInfo",					"ExtraInfo4",							#ExtraInfo4,								false,	"Extra Info", 											"Extra Info 4", true, false),
				#("ExtraInfo",					"ExtraInfo5",							#ExtraInfo5,								false,	"Extra Info", 											"Extra Info 5", true, false),
				#("ExtraInfo",					"ExtraInfo6",							#ExtraInfo6,								false,	"Extra Info", 											"Extra Info 6", true, false),
				#("ExtraInfo",					"ExtraInfo7",							#ExtraInfo7,								false,	"Extra Info", 											"Extra Info 7", true, false),
				#("ExtraInfo",					"ExtraInfo8",							#ExtraInfo8,								false,	"Extra Info", 											"Extra Info 8", true, false),
				#("ExtraInfo",					"ExtraInfo9",							#ExtraInfo9,								false,	"Extra Info", 											"Extra Info 9", true, false),

				#("IncludeEnvironment",			"IncludeEnvironment",					#IncludeEnvironment,						false,	"Include Environment",									"Include Environment", false, false),
				#("UseJobEnvironmentOnly",		"UseJobEnvironmentOnly",				#UseJobEnvironmentOnly,						false,	"Use Job Environment Only",								"Use Job Environment Only", false, false),

				#("RTT", 						"IsBakeJob",					 		#IsBakeJob,									true,	"Render to Texture", 									"Submit as Render to Texture Job", true, false),
				#("RTT", 						"BakeJobOneObjectPerTask", 				#BakeJobOneObjectPerTask,					true,	"Render to Texture", 									"One Object Per Task"),

				#("BatchRender",				"UseBatchRender", 						#UseBatchRender, 							true,	"Batch Submission", 									"Use Data from 3ds Max Batch Render" ),
				#("BatchRender",				"BatchRenderMode",						#BatchRenderMode, 							true,	"Batch Submission", 									"Batch Render Mode - Local / Master Batch" )
			)
		),
		
		fn getSettingsListAsTree =
		(
			local theSettingsList = SMTDFunctions.getSettingsList()
			local theCategories = #()
			local theLeafs = #()
			for i in theSettingsList do appendIfUnique theCategories i[5]
			for i in theSettingsList do
			(
				theIndex = findItem theCategories i[5]
				if theLeafs[theIndex] == undefined do theLeafs[theIndex] = #()
				append theLeafs[theIndex] i
			)
			#(theCategories,theLeafs)
		),
		
		--This function loads the STICKY settings from the local INI file and stuffs them into the SMTDSettings structure.
		--After calling this function, all settings that are not marked with * in the UI will be set to the last settings from the UI
		--If you are calling the submit function from an outside script without the UI, you might want to call this function first to
		--replace the factory defaults with the user defaults before submitting...
		fn loadSettings =
		(
			SMTDFunctions.GetNetworkRoot()
			local theSettingsList = SMTDFunctions.getSettingsList()
			
			for i in theSettingsList where i[3] != #none do
			(
				theDefault = getProperty SMTDSettings i[3]
				theValue = SMTDFunctions.getInI i[1] i[2] theDefault executeIt:i[4] useStickyFile:(not (i[7]==false)) isSticky:(not (i[8]==false))
					
				--format "% theDefault=% theValue=%\n" i[3] theDefault theValue
					
				if findItem #("RegionRenderingMode") i[2] > 0 do
				(
					if findItem #("none", "singleframemultiregion", "animationmultiregion", "singleframetiles", "animationtiles", "maxregion") (tolower (theValue as string)) == 0 do theValue = "none"
					theValue = theValue as name	
				)
				if findItem #("SubmitSceneMode") i[2] > 0 do 
				(
					if theValue == "" do theValue = "reposave"
					theValue = theValue as name
				)
				if findItem #("StereoCameraMode") i[2] > 0 do 
				(
					if theValue == "" do theValue = "left"
					theValue = theValue as name
				)
				if findItem #("StereoCameraPriorityOrder") i[2] > 0 do 
				(
					if theValue == "" do theValue = "none"
					theValue = theValue as name
				)				
				if findItem #("LeftEyeTag") i[2] > 0 do 
				(
					if theValue == "" do theValue = "LE"
				)
				if findItem #("RightEyeTag") i[2] > 0 do 
				(
					if theValue == "" do theValue = "RE"
				)
				if findItem #("CenterEyeTag") i[2] > 0 do 
				(
					if theValue == "" do theValue = "CE"
				)				
				--prevent non-existing INI file values from setting the value to "" if there is a factory default already:
				if findItem #("DraftFormat","DraftCodec","DraftResolution","DraftFrameRate")  i[2] > 0 and theValue == "" do 
				(
					theValue = theDefault
				)
				
				setProperty SMTDSettings i[3] theValue
			)
			
			if SMTDSettings.JobName == "" or SMTDSettings.AutomaticallyUpdateJobName then
			(
				if getfilenamefile maxfilename != "" then
					SMTDSettings.JobName = getfilenamefile maxfilename
				else
					SMTDSettings.JobName = "Untitled 3ds Max Job"
			)
				
			if SMTDSettings.OutOfOrderMethod == "" then
				SMTDSettings.OutOfOrderMethod = #normal
			else	
				SMTDSettings.OutOfOrderMethod = SMTDSettings.OutOfOrderMethod as name		

			if not SMTDSettings.MaxVersionToForceSticky then
				if is64bitApplication() then
					SMTDSettings.MaxVersionToForce = "64bit"
				else
					SMTDSettings.MaxVersionToForce = "32bit"
			
			local rendererID = case (renderers.current.classid as string) of
			(
				"#(1, 0)": "scanline"
				"#(1387076610, 288174012)": "brazil"
				"#(95494396, 474502030)": "brmax"
				"#(1492548972, 1338981315)": "mentalray"
				"#(1941615238, 2012806412)": "vray"
				"#(1770671000, 1323107829)": "vrayrt"
				"#(-1204370534, -399920359)": "krakatoa"
				"#(1121714582, 90602926)": "amaretto"
				"#(217131703, 58075251)": "finalrender"
				"#(272052741, 712862621)": "maxwell"
				"#(268839321, 1854680990)": "quicksilver"
				"#(1048411834, 348141227)": "iray"
				"#(1655201228, 1379677700)": "corona"
				default: ""
			)
			
			if (SMTDFunctions.getInI "RenderingOptions" "ForceRestartRenderer" true useStickyFile:false isSticky:false) do
			(
				if rendererID == "mentalray" or rendererID == "brazil" or rendererID == "vray" or rendererID == "brmax" or rendererID == "corona" then
					SMTDSettings.RestartRenderer = true 
			)
			
			if SMTDSettings.OutputFilenameUserPattern != "" do SMTDSettings.ReplaceOutputFilenameWithUserPattern = true
				
			SMTDSettings.LimitGroups = for i in SMTDSettings.LimitGroups where i != "" collect i --clear empty names
			SMTDSettings.LimitGroupsToUse = for i in SMTDSettings.LimitGroupsToUse where i != "" collect i --clear empty names
				
			if not SMTDSettings.SlaveSettingsSticky then --if settings are sticky, load the last settings
			(
				setIniSetting SMTDPaths.InIFile "Blacklist"  "SlavesNamedSet"  SMTDSettings.SlavesNamedSet 
				setIniSetting SMTDPaths.InIFile "Blacklist"  "BlackOrWhite" (SMTDSettings.SlavesBlackList as string) 
				setIniSetting SMTDPaths.InIFile "Blacklist"  "SlavesList" "#()" 
			)		
			

			SMTDFunctions.loadIntegrationPersistentGlobals()
			SMTDFunctions.ReadInDraftOptions()
		),
		
		fn loadIntegrationPersistentGlobals =
		(
			--SHOTGUN (loading from persistent globals)
			if pg_SGDraftTemplate != undefined do SMTDSettings.SGDraftTemplate = pg_SGDraftTemplate
			if pg_SGVersion != undefined do SMTDSettings.SGVersion= pg_SGVersion
			if pg_SGDescription != undefined do SMTDSettings.SGDescription = pg_SGDescription
			if pg_SGTask != undefined do SMTDSettings.SGTask = pg_SGTask
			if pg_SGEntity != undefined do SMTDSettings.SGEntity = pg_SGEntity
			if pg_SGUser != undefined do SMTDSettings.SGUser = pg_SGUser
			if pg_SGProject != undefined do SMTDSettings.SGProject = pg_SGProject
			if pg_SGDisplayInfo != undefined do SMTDSettings.SGDisplayInfo = pg_SGDisplayInfo
			if pg_SGJobSettings != undefined do SMTDSettings.SGJobSettings = pg_SGJobSettings
			if pg_SGCreateMovie != undefined do SMTDSettings.SGCreateMovie = pg_SGCreateMovie
			if pg_SGCreateFilmStrip != undefined do SMTDSettings.SGCreateFilmStrip = pg_SGCreateFilmStrip

			--FTrack (loading from persistent globals)
			if pg_FTDescription != undefined do SMTDSettings.FTDescription = pg_FTDescription
			if pg_FTTask != undefined do SMTDSettings.FTTask = pg_FTTask
			if pg_FTAsset != undefined do SMTDSettings.FTAsset = pg_FTAsset
			if pg_FTUser != undefined do SMTDSettings.FTUser = pg_FTUser
			if pg_FTProject != undefined do SMTDSettings.FTProject = pg_FTProject
			if pg_FTDisplayInfo != undefined do SMTDSettings.FTDisplayInfo = pg_FTDisplayInfo
			if pg_FTJobSettings != undefined do SMTDSettings.FTJobSettings = pg_FTJobSettings			
		),

		fn getRendererIdString =
		(
			case (renderers.current.classid as string) of
			(
				"#(1, 0)": "scanline"
				"#(1387076610, 288174012)": "brazil"
				"#(95494396, 474502030)": "brmax"
				"#(1492548972, 1338981315)": "mentalray"
				"#(1941615238, 2012806412)": "vray"
				"#(1770671000, 1323107829)": "vrayrt"
				"#(-1204370534, -399920359)": "krakatoa"
				"#(1121714582, 90602926)": "amaretto"
				"#(217131703, 58075251)": "finalrender"
				"#(272052741, 712862621)": "maxwell"
				"#(268839321, 1854680990)": "quicksilver"
				"#(1048411834, 348141227)": "iray"
				"#(1655201228, 1379677700)": "corona"
				default: ""
			)
		),
		
		fn ReadInFormatsFile filename=
		(
			SMTDSettings.DraftFormatsDict = dotNetObject "System.Collections.Hashtable"
			local results = #()
			local resultFile = OpenFile filename
			if resultFile  != undefined then
			(
			try(
				while not eof resultFile do
				(
					local theLine = readline resultFile
					local words = filterString theLine ", "
					
					local theName = words[2] + " (" + words[1] + ")"
					append results theName
					
					SMTDSettings.DraftFormatsDict.Add theName #(words[1],words[3])
				)
				close resultFile
			)catch ( try(SMTD_MainRollout.Ui_report ("--QuickDraft Formats: Problem Reading File ["+filename+"]"))catch())
			)else (	try(SMTD_MainRollout.Ui_report ("--QuickDraft Formats: File Not Found ["+filename+"]"))catch() )	
			results
		),
		
		fn ReadInResolutionsFile filename=
		(
			SMTDSettings.DraftResolutionsDict = dotNetObject "System.Collections.Hashtable"

			local results = #()
			local resultFile = OpenFile filename
			if resultFile != undefined then
			(
				try
				(
					while not eof resultFile do
					(
						local theLine = readline resultFile
						local words = filterString theLine ", "
						append results words[2]
						SMTDSettings.DraftResolutionsDict.Add words[2] words[1]
					)
					close resultFile
				)catch ( try(SMTD_MainRollout.Ui_report ("--QuickDraft Resolutions: Problem Reading File ["+filename+"]"))catch() )
			)else (	try(SMTD_MainRollout.Ui_report ("--QuickDraft Resolutions: File Not Found ["+filename+"]"))catch() )	
			results
		),
		
		fn ReadInFile filename=
		(
			local results = #()
			local resultFile = OpenFile filename
			if resultFile != undefined then
			(
				try
				(
					while not eof resultFile do
					(
						local theLine = readline resultFile
						theLine = trimright theLine
						theLine = trimleft theLine
						append results theLine
					)
					close resultFile
				)catch (	try(SMTD_MainRollout.Ui_report ("--QuickDraft ReadInFile: Problem reading file ["+filename+"]"))catch() )
			)else (	try(SMTD_MainRollout.Ui_report ("--QuickDraft ReadInFile: File Not Found ["+filename+"]"))catch() )	
			results
		),

		fn ReadInCodecsFile filename=
		(
			local theFile = OpenFile filename
			if theFile != undefined then
			(
				try
				(
					while not eof theFile do
					(
						local theLine = readline theFile
						local formatAndCodecs = filterString theLine ":"

						local format = formatAndCodecs[1]
						format = trimleft (trimright format)

						local codecs = (filterString formatAndCodecs[2] ",")
						for i = 1 to codecs.count do
						(
							codecs[i] = trimleft (trimright codecs[i])
						)

						SMTDSettings.DraftCodecsDict.Add format codecs
					)
				)catch ( try(SMTD_MainRollout.Ui_report ("--QuickDraft Codecs: Problem Reading File ["+filename+"]"))catch() )
				close theFile
			)else ( try(SMTD_MainRollout.Ui_report ("--QuickDraft Codecs: File Not Found ["+filename+"]"))catch() )
		),

		fn ReadInRestrictionsFile filename=
		(
			SMTDSettings.DraftRestrictionsDict = dotNetObject "System.Collections.Hashtable"
			local results = #()
			local resultFile = OpenFile filename
			if resultFile != undefined then
			(
				try
				(
					while not eof resultFile do
					(
						local theLine = readline resultFile
						local words = filterString theLine ":"
						local theName = words[1]
						theName = trimleft (trimright theName)
						local restriction = filterString words[2] "="
						restriction[1] = trimright restriction[1]
						local restrictionType = trimleft restriction[1]
						local restrictionList = filterString restriction[2] ", "
						if (findItem results theName == 0) then
						(
							append results theName
							local currentDict = dotNetObject "System.Collections.Hashtable"
							SMTDSettings.DraftRestrictionsDict.Add theName currentDict
						)
						SMTDSettings.DraftRestrictionsDict.Item[theName].Add restrictionType restrictionList
					)
				)catch ( try(SMTD_MainRollout.Ui_report ("--QuickDraft Restrictions: Problem reading file ["+filename+"]"))catch()	)
			)else (	try(SMTD_MainRollout.Ui_report ("--QuickDraft Restrictions: File Not Found ["+filename+"]"))catch() )	
			results
		),
		
		fn ReadInDraftOptions =
		(
			try(SMTD_MainRollout.Ui_report ">Loading QuickDraft Settings...")catch()
			local mainDraftFolder = SMTDPaths.NetworkRoot + "/submission/Draft/Main"
			SMTDSettings.DraftFormats = SMTDFunctions.ReadInFormatsFile (mainDraftFolder +"/formats.txt")
			SMTDSettings.DraftResolutions = SMTDFunctions.ReadInResolutionsFile (mainDraftFolder + "/resolutions.txt")
			SMTDFunctions.ReadInCodecsFile (mainDraftFolder + "/codecs.txt")
			SMTDSettings.DraftFrameRates = SMTDFunctions.ReadInFile (mainDraftFolder + "/frameRates.txt")
			SMTDSettings.DraftRestrictions = SMTDFunctions.ReadInRestrictionsFile (mainDraftFolder + "/restrictions.txt")
			try(SMTD_MainRollout.Ui_report ">Ready.")catch()
		),
		

		fn getRenderDimensions =
		(
			local m_renderWidth = renderWidth
			local m_renderHeight = renderHeight
			local m_renderPixelAspect = renderPixelAspect

			local rendererID = SMTDFunctions.getRendererIdString()
			if rendererID == "vray" do
			(
				vr = renderers.current
				if vr.output_on == true AND vr.output_getsetsfrommax == false do
				(
					m_renderWidth = vr.output_width
					m_renderHeight = vr.output_height
					m_renderPixelAspect = vr.output_aspect
				)
			)
			#(m_renderWidth,m_renderHeight,m_renderPixelAspect)
		),
		
		fn AnimateLastSubmissionState =
		(
			try
			(
				SMTD_MainRollout.sld_lastSubmissionState.value += 1 
				if SMTD_MainRollout.sld_lastSubmissionState.value >= 100 do SMTD_MainRollout.sld_lastSubmissionState.value = 50
			)catch()
		),
		
		fn purifyFileName theFileName =
		(
			for i = 1 to theFileName.count do
				if findItem SMTDSettings.PurifyCharacterCodes (bit.charAsInt theFileName[i]) > 0 do theFileName[i] = "_"
			theFileName	
		),
		
		fn purifyRenderElementName theName =
		(
			for i = 1 to theName.count do
				if findItem #(" ", "#") theName[i] > 0 do theName[i] = "_"
			theName	
		),	
		
		fn storeRenderElementNames =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			SMTDSettings.OriginalRenderElementNames = #()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
				(
					if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do
					(
						local theElement = reManager.GetRenderElement i
						SMTDSettings.OriginalRenderElementNames[i+1] = theElement.elementName 
					)
				)
			)
		),
		
		fn restoreRenderElementNames =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
				(
					if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do
					(
						local theElement = reManager.GetRenderElement i
						local theName = SMTDSettings.OriginalRenderElementNames[i+1]
						if theName != undefined do theElement.elementName = theName
					)
				)
			)
		),

		fn fixRenderElementNames =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
				(
					if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do
					(
						local theElement = reManager.GetRenderElement i
						theElement.elementName = SMTDFunctions.purifyRenderElementName theElement.elementName 
					)
				)
			)
		),
		
		fn GetNetworkRoot =
		(
			--SMTDPaths.NetworkRoot = ""
			--try 
			--(
			--	local fileHandle = openFile( "c:/deadline/deadline.ini" )
			--	if fileHandle != undefined then
			--	(
			--		while not eof fileHandle do
			--		(
			--			local fileLine = readLine fileHandle 
			--			local index = findString fileLine "NetworkRoot="
			--			if index == 1 do SMTDPaths.NetworkRoot = (substring fileLine 13 (fileLine.count-1)) 
			--		)
			--		close fileHandle 
			--	)
			--) catch()
			--SMTDPaths.NetworkRoot
			
			if SMTDPaths.NetworkRoot == "" do
			(
				try
				(
					local result = SMTDFunctions.waitForCommandToComplete "-getrepositoryroot" 10
					if result == #success then
					(
						local resultFile = OpenFile submitOutputFile
						local resultMsg = ""
						if (resultFile != undefined) do
						(
							try(resultMsg = readLine resultFile)catch()
							try(close resultFile)catch()
						)
					
						SMTDPaths.NetworkRoot = resultMsg
					)
				) catch()
			)
			SMTDPaths.NetworkRoot
		),		
		
		--This function calls the deadline executable with the supplied parameters and waits for a specified time in SECONDS for the execution to complete
		--If the result is not returned in the given time, a #timeout result is returned.
		fn waitForCommandToComplete params timeOutInSec paramIsFile:false dontWait:false =
		(
			local result = -2
			deleteFile SMTDPaths.SubmitExitCode
			deleteFile SMTDPaths.SubmitOutput
			
			if paramIsFile then
				ShellLaunch SMTDPaths.DeadlineBGExec params
			else
				ShellLaunch SMTDPaths.DeadlineBGExec (" -outputfiles \""+SMTDPaths.SubmitOutput+"\" \""+SMTDPaths.SubmitExitCode+"\" " + params)
			
			if dontWait do return #queued
			
			local startTimeStamp = timestamp()
			local ready = false
			while not ready do
			(
				sleep 0.15
				SMTDFunctions.AnimateLastSubmissionState()
				try(windows.processPostedMessages())catch()
				if doesFileExist SMTDPaths.SubmitExitCode do
				(
					local theFile = openFile SMTDPaths.SubmitExitCode
					try(result = readValue theFile)catch(result = -2)
					try(close theFile)catch()
					ready = true
				)	
				if timestamp() - startTimeStamp > timeOutInSec*1000 then 
				(
					result = -3
					ready = true
				)	
			)				
			return case result of
			(
				0: #success
				(-1): #failed
				(-2): #readerror
				(-3): #timeout
			)	
		),

		--This function reads the content of a file into the supplied array.
		fn ReadFileIntoArray theFilename theArray =
		(
			local theFile = OpenFile theFilename 
			local result = #failure
			if theFile != undefined then
			(
				try 
				(
					while not eof theFile do 
						append theArray (ReadLine theFile )
					result = #success
				)
				catch()
				close theFile 
			)
			else
				result = #fileNotFound
			result
		),
	
		--Reads the list of available repositories.
		fn getRepositoryList =
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Repository Networks..."))catch()
			
			local result = #success
			local tempArray = #("DISABLED")
			--SMTDFunctions.ReadFileIntoArray "Y:\\Winnipeg\\Deadline\\RemoteSubmissionRepositories.ini" tempArray
			--SMTDFunctions.ReadFileIntoArray "V:\\deadline_synch\\RemoteSubmissionRepositories.ini" tempArray
			SMTDFunctions.ReadFileIntoArray "Z:\\assets\\scripts\\mxs\\RemoteSubmissionRepositories.ini" tempArray
			
			local tempRepositoryList = #()
			local tempRepositoryListActual = #()
			for i in tempArray do
			(
				local parts = filterString i ","
				append tempRepositoryList parts[1]
				append tempRepositoryListActual parts[2]
			)
			SMTDSettings.RepositoryList = tempRepositoryList
			SMTDSettings.RepositoryListActual = tempRepositoryListActual
			result
		),
		
		fn getRepositoryListFilename =
		(
			local path = GetNetworkRoot() + "\\submission\\3dsmax\\Main\\RemoteSubmissionRepositories.ini"
			path
		),
		

		
		fn getZeros theNumber count:4=
		(
			local theStr = theNumber as string
			local theCount = count-(theStr.count)
			if theCount < 1 then "" else substring "00000000000" 1 theCount					
		),
		
		--Reads in maximum priority
		fn GetMaximumPriority =
		(
			try(SMTD_MainRollout.Ui_report (">Querying Maximum Priority..."))catch()
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-getmaximumpriority " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			if  result == #success then			
			(
				local theFile = openFile SMTDPaths.SubmitOutput
				try(SMTDSettings.MaximumPriority = readValue theFile)catch()
				try(close theFile)catch()
				try(SMTD_MainRollout.Ui_report ("+Maximum Priority Queried in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
				
				-- Just in case this ends up being undefined.
				if SMTDSettings.MaximumPriority == undefined do
					SMTDSettings.MaximumPriority = 100
			)
			else
			(
				SMTDSettings.MaximumPriority = 100
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Query Maximum Priority in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Query Maximum Priority."))catch()
			)
			result
		),
		
		--Reads the list of available pools
		fn CollectPools =
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Pools..."))catch()
			--local tempArray = #("")
			local tempArray = #()
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-pools " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			if  result == #success then			
			(
				SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
				SMTDSettings.Pools = tempArray
				try(SMTD_MainRollout.Ui_report ("+"+ tempArray.count as string +" Pools Collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Pools in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Pools."))catch()
			result 	
		),
		
		--Reads the list of available slaves
		fn CollectSlaves=
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Slaves..."))catch()
			local tempArray = #("")
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-slaves " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			if  result == #success then			
			(
				SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
				SMTDSettings.Slaves = for i in tempArray where i != "" collect i
				try(SMTD_MainRollout.Ui_report ("+"+ SMTDSettings.Slaves.count as string +" Slaves Collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
				try(SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slaves in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slaves."))catch()
			result 	
		),	

		--Reads the slave info
		fn CollectSlaveInfo theSlaveName =
		(
			try(SMTD_MainRollout.Ui_report (">Getting Slave Info for [" + theSlaveName + "]"))catch()
			local tempArray = #("")
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-getslave "+ theSlaveName +" "+ SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			if  result == #success then			
			(
				SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
				SMTDSettings.SlaveInfo = for i in tempArray where i != "" collect i
				try(SMTD_MainRollout.Ui_report ("+"+ tempArray.count as string +" Slave Info collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
				try(SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slave Info in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slave Info."))catch()
			result 	
		),		
		
		fn CollectSlavesInfo =
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Info on all Slaves"))catch()
			local st = timestamp()	
			local result = SMTDFunctions.waitForCommandToComplete ("-getslaves true "+ SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			if  result == #success then			
			(
				local theSlaveInfoFile = (SMTDPaths.SettingsDir + "slaveselectionsets\\slavesinfo.ini" )
				deleteFile theSlaveInfoFile
				copyFile SMTDPaths.SubmitOutput theSlaveInfoFile
				try(SMTD_MainRollout.Ui_report ("+Slave Info collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
				try(SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
			)				
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slaves Info in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Slaves Info."))catch()
			result 		
		),
				
		fn unregisterCallbacks =
		(
			callbacks.removeScripts id:#SubmitMaxToDeadline
		),
		
		fn registerAutoSuggestCallbacks =
		(
			SMTDFunctions.unregisterCallbacks()
			callbacks.addScript #FilePostOpen "try(SMTDFunctions.SuggestAltIni())catch()" id:#SubmitMaxToDeadline
			if (maxVersion())[1]/1000 >= 6 do
				callbacks.addScript #PostRendererChange "try(SMTDFunctions.SuggestAltIni())catch()" id:#SubmitMaxToDeadline
		),
		
		fn CollectAltIni =
		(
			try
			(
				/*
				fileHandle = openFile("c:/deadline/deadline.ini" )
				if fileHandle != undefined then
				(
					while not eof fileHandle do
					(
						fileLine = readLine fileHandle
						index = findString fileLine "NetworkRoot="
						if index == 1 then
						(
							SMTDSettings.AltIniPath = (substring fileLine 13 (fileLine.count-1)) + "\\plugins\\" + SMTDFunctions.getPluginToUse()
							SMTDSettings.theIniFiles = getFiles (SMTDSettings.AltIniPath+ "\\plugin*.ini")
							sort SMTDSettings.theIniFiles
							theFileNames = for i in SMTDSettings.theIniFiles collect getFileNameFile i
							insertItem  "[Default]" theFileNames 1
							SMTDSettings.theIniFilenames = theFileNames
						)
					)
				)
				close fileHandle
				*/
				
				if SMTDPaths.NetworkRoot != "" then
				(
					SMTDSettings.AltIniPath = SMTDPaths.NetworkRoot + "\\plugins\\" + SMTDFunctions.getPluginToUse()
					SMTDSettings.theIniFiles = getFiles (SMTDSettings.AltIniPath+ "\\plugin*.ini")
					sort SMTDSettings.theIniFiles
					theFileNames = for i in SMTDSettings.theIniFiles collect getFileNameFile i
					insertItem  "[Default]" theFileNames 1
					SMTDSettings.theIniFilenames = theFileNames
				)
			) 
			catch
			(
				format "Error Collecting Alternative Plugin.Ini\n"
				SMTDSettings.theIniFiles = #()
				SMTDSettings.theIniFilenames = #("[Default]")
			)
		),

		fn SuggestAltIni =
		(
			SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[1] 
			case SMTDFunctions.getRendererIdString() of
			(
				"scanline" : SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[1] 
				"brmax" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*brazil*"  do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"finalrender" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*fr*" != undefined or matchPattern SMTDSettings.theIniFilenames[i] pattern:"*final*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"iray" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*iray*" != undefined do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"mentalray" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*mr*" or matchPattern SMTDSettings.theIniFilenames[i] pattern:"*mental*"  do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"vray" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*vray*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"vrayrt" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*vrrt*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"maxwell" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*maxwell*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"krakatoa" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*krak*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"corona" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*corona*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				"quicksilver" : for i = 2 to SMTDSettings.theIniFilenames.count where matchPattern SMTDSettings.theIniFilenames[i] pattern:"*quick*" do SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[i]
				default: SMTDSettings.AltPluginIni = SMTDSettings.theIniFilenames[1]
			)
		),

		--Reads the list of existing jobs and their IDs.
		fn CollectJobs userOnly:false=
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Jobs - This operation can take a long time..."))catch()
			local st = timestamp()
			local tempArray= #()
			local result 
			if userOnly then
				result = SMTDFunctions.waitForCommandToComplete ("-getjobs -user "+SMTDSettings.UserName ) SMTDSettings.TimeoutCollectData
			else	
				result = SMTDFunctions.waitForCommandToComplete ("-getjobs" ) SMTDSettings.TimeoutCollectData
			try(SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
			if  result == #success then			
			(
				try
				(
					theFile = openFile SMTDPaths.SubmitOutput 
					while not eof theFile do
					(
						theName = theID = thePlugin = theUser = theDept = theGroup = theStatus = ""
						str = readLine theFile
						if str != "" do
						(
							while str != "" do
							(
								if matchPattern str pattern:"Name=*" do theName = substring str 6 -1
								if matchPattern str pattern:"JobID=*" do theID = substring str 7 -1
								if matchPattern str pattern:"PluginName=*" do thePlugin = substring str 12 -1
								if matchPattern str pattern:"UserName=*" do theUser = substring str 10 -1
								if matchPattern str pattern:"Department=*" do theDept= substring str 12 -1
								if matchPattern str pattern:"Group=*" do theGroup = substring str 7 -1
								if matchPattern str pattern:"Status=*" do theStatus= substring str 8 -1
								str = readLine theFile
							)
							append tempArray #(theName,theID,thePlugin,theUser,theDept,theGroup, theStatus)
						)
					)
					close theFile
				)catch()	
				SMTDSettings.JobsArray = tempArray	
				try(SMTD_MainRollout.Ui_report ("+"+ tempArray.count as string +" Jobs Collected in " + ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Jobs in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Jobs."))catch()
			result 	
		),
				
		-- Returns the current user in the deadline.ini file
		fn GetDeadlineUser =
		(
			local user = "";
			try
			(
				--fileHandle = openFile("c:/deadline/deadline.ini" )
				deadlineIniFile = SMTDPaths.UserHomeDir + "deadline.ini"
				fileHandle = openFile( deadlineIniFile )
				if fileHandle != undefined then
				(
					while not eof fileHandle do
					(
						fileLine = readLine fileHandle 
						index = findString fileLine "User="
						if index == 1 then
						user = (substring fileLine 6 (fileLine.count-1))
					)
				)
				close fileHandle 
			)
			catch
			(
				user = ""
			)
						
			user
		),
		
		fn collectSubAnims theObj =
		(
			local theSubsArray = #()
			for i = 1 to theObj.numsubs do
			(
				append theSubsArray (subAnim = theObj[i])
				local theClass = try(classof subAnim.object)catch(undefined)
				if theClass != Unwrap_UVW AND theClass != Master_Point_Controller do
					join SMTDExternalRefsArray.totalSubsArray (SMTDFunctions.collectSubAnims subAnim)
			)	
			theSubsArray
		),

		/*
		fn collectSubAnims theObj =
		(
			local theSubsArray = #()
			append SMTDExternalRefsArray.totalSubsArray theObj
			for i = 1 to theObj.numsubs do
			(
				append theSubsArray (theSubAnim = theObj[i])
				local theClass = try(classof theSubAnim.object)catch(undefined)
				if theClass != Unwrap_UVW AND theClass != Master_Point_Controller do 
					join SMTDExternalRefsArray.totalSubsArray (SMTDFunctions.collectSubAnims theSubAnim)
				if theClass == VRayBump2Normal do
					join SMTDExternalRefsArray.totalSubsArray (SMTDFunctions.collectSubAnims theSubAnim.object.bump_map) 
				if theClass == Unwrap_UVW do 
					for j in theSubAnim.object.texMapList do 
						join SMTDExternalRefsArray.totalSubsArray (SMTDFunctions.collectSubAnims j) 
			)	
			theSubsArray
		),
		*/
		
		--Reads the list of available LimitGroups
		fn CollectLimitGroups =
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Limits...Please wait."))catch()
			local tempArray = #("")
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-limitgroups " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			try(SMTD_MainRollout.sld_lastSubmissionState.value = 100)catch()
			if  result == #success then			
			(
				SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
				SMTDSettings.LimitGroups = for i in tempArray where i != "" collect i
				theString = "#("
				for i in SMTDSettings.LimitGroups do (theString += "\"" + i as string + "\",")
				theString += "\"\")"
				setIniSetting SMTDPaths.iniFile "LimitGroups" "LimitGroups" theString 
				
				try(SMTD_MainRollout.Ui_report ("+"+ tempArray.count as string +" Limits Collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Limits  in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Limits."))catch()
			result 	
		),		
		
		fn CollectCategories = (), --obsolete, left for backwards compatibility

		
		fn CollectGroups =
		(
			try(SMTD_MainRollout.Ui_report (">Collecting Groups..."))catch()
			--local tempArray = #("")
			local tempArray = #()
			local st = timestamp()
			local result = SMTDFunctions.waitForCommandToComplete ("-groups " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
			try(SMTD_MainRollout.sld_lastSubmissionState.value = 100)catch()		
			if  result == #success then			
			(
				SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
				SMTDSettings.Groups = tempArray
				try(SMTD_MainRollout.Ui_report ("+"+ tempArray.count as string +" Groups Collected in "+ ((timestamp()-st)/1000.0) as string +" sec. " ))catch()
			)
			else
				if result == #timeout then
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Groups in " + SMTDSettings.TimeoutCollectData as string + " seconds.\nConsider Increasing the Data Collection Timeout in the User Options tab."))catch()
				else
					try(SMTD_MainRollout.Ui_report ("--Failed To Collect Groups."))catch()
			result 	
		),
		
		fn collectMissingFile o = 
		(
			append SMTDSettings.MissingFiles o
		),	
		
		fn checkForMissingMaps =
		(
			SMTDSettings.MissingFiles = #()
			enumerateFiles SMTDFunctions.collectMissingFile #missing
		),

		fn IsLocalPath thePath =
		(
			local localDrives = "abcdefABCDEF"
			if classof thePath == String and thePath.count > 0 then --fixing for VRay Proxy which can have $.filename == undefined which is BAD!
			(
				not (pathIsNetworkPath thePath)
			)
			else
				false
		),

		fn convertPathToLocal TextureCacheFolder thePath =
		(
			local newName = copy thePath
			if pathConfig.isUncPath thePath then
			(
				newName[1] = "_"
				newName[2] = "_"
			)
			else
				newName = substituteString newName ":" "_"
			TextureCacheFolder + newName
		),
		
		fn convertPathToRemote TextureCacheFolder thePath =
		(
			local newName = copy thePath 
			newName = substring newName (TextureCacheFolder.count+1) -1
			if newName[1] != "_" and newName[2] == "_" then 
				newName[2] = ":"
			else if newName[1] == "_" and newName[2] == "_" do
			(
				newName[1] = "\\"
				newName[2] = "\\"
			)		
			newName
		),		
		
		fn isPathInLocalCache TextureCacheFolder thePath =
		(
			matchPattern thePath pattern:(TextureCacheFolder+"*")		
		),		

		fn isPropertyOKForSubmissionToRepository thePropName =
		(
			local result = false
			--VRay properties:
			if (renderers.current.classid as string == "#(1941615238, 2012806412)") do
			(
				vr = renderers.current
				if thePropName == #adv_irradmap_loadFileName AND vr.gi_primary_type == 0 AND vr.adv_irradmap_mode == 2 do result = true
				if thePropName == #caustics_loadFileName AND vr.caustics_on == true AND vr.caustics_mode == 1 do result = true
				if thePropName == #photonMap_loadFileName AND (vr.gi_primary_type == 1 OR vr.gi_secondary_type == 1) AND vr.photonMap_mode == 1 do result = true
				if thePropName == #lightcache_loadFileName AND (vr.gi_primary_type == 3 OR vr.gi_secondary_type == 3) AND vr.lightcache_mode == 2 do result = true
			)
			--Corona properties:
			if (renderers.current.classid as string == "#(1655201228, 1379677700)") do
			(
				cr = renderers.current
				if thePropName == #gi_hdCache_file AND (cr.gi_hdCache_precalcMode == 1 OR cr.gi_hdCache_precalcMode == 2) AND (cr.shading_secondarySolver == 3 OR cr.shading_secondarySolver == 4) do result = true
			)
			--Mental Ray properties:
			if (renderers.current.classid as string == "#(1492548972, 1338981315)") do 
			(
				mr = renderers.current
				if thePropName == #FinalGatherFilename AND mr.UseFinalGatherFile == true AND mr.FinalGatherFreeze == true do result = true
				--Max2010+ only feature: mr.PhotonFreeze
				if (maxVersion())[1]/1000 >= 12 then
					(if thePropName == #PhotonMapFilename AND (mr.CausticsEnable == true OR mr.GlobalIllumEnable == true) AND mr.PhotonMapUseFile  == true AND mr.PhotonFreeze  == true do result = true)
				else
					(if thePropName == #PhotonMapFilename AND (mr.CausticsEnable == true OR mr.GlobalIllumEnable == true) AND mr.PhotonMapUseFile  == true do result = true)
				if thePropName == #ShadowMapFilename AND mr.EnableShadowMaps  == true AND mr.UseShadowMapFile == true AND mr.ShadowMapRebuild == false do result = true
			)
			--Brazil v1 properties:
			if (renderers.current.classid as string == "#(1387076610, 288174012)") do
			(
				br = renderers.current
				if thePropName == #global_path_filename AND br.global_active == true AND br.global_file_mode == 2 do result = true
				if thePropName == #caustic_path_filename AND br.caustic_active == true AND br.caustic_file_mode == 2 do result = true
			)
			--Brazil 2 properties:
			if (renderers.current.classid as string == "#(95494396, 474502030)") do
			(
				local brazilRenderer = ::sfs.b2_lib.getActiveB2() --Force global scope to access SplutterFish Script libraries!
				local blockNames = #("System_Options_Parameter_Block_Holder","Sampling_Parameter_Block_Holder","Motion_Blur_Parameter_Block_Holder","Ray_Server_Parameter_Block_Holder","Luma_Server_Parameter_Block_Holder","Render_Cache_Parameter_Block_Holder","Photon_Server_Parameter_Block_Holder","Render_Pass_Parameter_Block_Holder")
				if thePropName == #user_filename and brazilRenderer["Render_Cache_Parameter_Block_Holder"].file_mode == 2 do result = true
			)
			result
		),

		fn returnAllBitmaps =
		(
			--print "Collecting Bitmaps..."
			local allBitmaps = #()
			local bitmapsArray = #()
			local hdriArray = #()
			local theMaterials = #()

			SMTDExternalRefsArray.totalSubsArray = #()
			SMTDExternalRefsArray.storeBitmapPath = #()
			SMTDExternalRefsArray.storeHdriPath = #()
			SMTDExternalRefsArray.StoreObjectXRefs = #()
			SMTDExternalRefsArray.StoreSceneXRefs = #()
			SMTDExternalRefsArray.StoreSceneVrayProxies = #()
			SMTDExternalRefsArray.StoreSceneCoronaProxies = #()
			SMTDExternalRefsArray.StoreSceneMRProxies = #()
			SMTDExternalRefsArray.StoreRendererPaths = #()
			SMTDExternalRefsArray.StoreBrazilv2RendererPaths = #()

			local collisions = 0
			local fileNamesForCollisionCheck = #()
			local pathNamesForCollisionCheck = #()
			
			st1 = timestamp()
			for o in objects do 
			(
				SMTDFunctions.collectSubAnims o
			)	
			try(SMTD_MainRollout.Ui_report ("+Traversed " + objects.count as string +" Objects and Collected "+ SMTDExternalRefsArray.totalSubsArray.count as string +" SubAnims in "+ ((timestamp()-st1)/1000.0) as string  + " sec."))catch()
			
			local theRenderer = renderers.current
			local theProps = try(getPropNames theRenderer)catch(#())

			--DEALING WITH RENDERER PROPERTIES FOR BRAZIL 2:
			if theRenderer.classid as string == "#(95494396, 474502030)" then
			(
				local brCounter = 0
				SMTDExternalRefsArray.StoreRendererPaths = #()
				local brazilRenderer = ::sfs.b2_lib.getActiveB2() --Force global scope to access SplutterFish Script libraries!
				local blockNames = #("System_Options_Parameter_Block_Holder","Sampling_Parameter_Block_Holder","Motion_Blur_Parameter_Block_Holder","Ray_Server_Parameter_Block_Holder","Luma_Server_Parameter_Block_Holder","Render_Cache_Parameter_Block_Holder","Photon_Server_Parameter_Block_Holder","Render_Pass_Parameter_Block_Holder")
				for blockName in blockNames do
				(
					local theBlock = brazilRenderer[blockName]
					if theBlock != undefined then
					(
						local propNames = getPropNames theBlock.object
						if propNames != undefined then
						(
							for p in propNames do
							(
								local theProp = (getProperty theBlock.object p)
								if superclassof theProp == TextureMap do
								(
									append theMaterials theProp
									brCounter += 1
								)
							)
						)
					)
				)--end blockName loop
				try(SMTD_MainRollout.Ui_report "")catch()
				case brCounter of
				(
					default: try(SMTD_MainRollout.Ui_report ("+Found "+ brCounter as string+ " Populated Brazil r/s v2 Texture Map Slots.") )catch()
					0: try(SMTD_MainRollout.Ui_report ("--No Populated Brazil r/s v2 Texture Map Slots Found."))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Found One Populated Brazil r/s v2 Texture Map Slot."))catch()
				)					
				
				
				theProp = brazilRenderer["Render_Cache_Parameter_Block_Holder"].user_filename
				if doesFileExist theProp and brazilRenderer["Render_Cache_Parameter_Block_Holder"].file_mode == 2 do 
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 and SMTDFunctions.IsLocalPath theProp) or (SMTDSettings.SubmitExternalFilesMode == 3) do 
					(
						append SMTDExternalRefsArray.StoreRendererPaths #(theProp, theProp)
						append SMTDExternalRefsArray.StoreBrazilv2RendererPaths #(brazilRenderer["Render_Cache_Parameter_Block_Holder"], #user_filename, theProp)
					)
				)	

				theProp = brazilRenderer["Photon_Server_Parameter_Block_Holder"].gi_user_filename
				if doesFileExist theProp and brazilRenderer["Photon_Server_Parameter_Block_Holder"].gi_file_mode == 2 do 
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 and SMTDFunctions.IsLocalPath theProp) or (SMTDSettings.SubmitExternalFilesMode == 3) do 
					(
						append SMTDExternalRefsArray.StoreRendererPaths #(theProp, theProp)
						append SMTDExternalRefsArray.StoreBrazilv2RendererPaths #(brazilRenderer["Photon_Server_Parameter_Block_Holder"], #gi_user_filename, theProp)
					)
				)	
				
				theProp = brazilRenderer["Photon_Server_Parameter_Block_Holder"].cst_user_filename
				if doesFileExist theProp and brazilRenderer["Photon_Server_Parameter_Block_Holder"].cst_file_mode == 2 do 
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 and SMTDFunctions.IsLocalPath theProp) or (SMTDSettings.SubmitExternalFilesMode == 3) do 
					(
						append SMTDExternalRefsArray.StoreRendererPaths #(theProp, theProp)
						append SMTDExternalRefsArray.StoreBrazilv2RendererPaths #(brazilRenderer["Photon_Server_Parameter_Block_Holder"], #cst_user_filename, theProp)
					)
				)	
				
			)
			else --DEALING WITH RENDERER PROPERTIES FOR VRAY, CORONA, MENTAL RAY, BRAZIL V1
			(
				SMTDExternalRefsArray.StoreRendererPaths = for p in theProps collect 
				(
					local theProp = try(getProperty theRenderer p)catch(undefined)
					if (p != undefined) AND (classof theProp == String and doesFileExist theProp) AND (SMTDFunctions.isPropertyOKForSubmissionToRepository p) then
					(
						if SMTDSettings.SubmitExternalFilesMode == 2 then --if locals only, check and append if local.
							if SMTDFunctions.IsLocalPath theProp then #(p, theProp) else dontcollect
						else
							#(p, theProp)
					)
					else dontcollect
				)

				for p in SMTDExternalRefsArray.StoreRendererPaths do
				(
					append SMTDExternalRefsArray.storeBitmapPath #(undefined, p[2], filenameFromPath p[2])
					setProperty theRenderer p[1] (filenameFromPath p[2]) --remove the path
				)
			)
			
			local theRendererName = case theRenderer.classid as string of
			(
				default: (classof theRenderer) as string
				"#(1, 0)": "Default Scanline Renderer"
				"#(95494396, 474502030)": "Brazil r/s v2 Renderer"
				"#(1492548972, 1338981315)": "Mental Ray Renderer"
				"#(1941615238, 2012806412)": "V-Ray Renderer"
				"#(1655201228, 1379677700)": "Corona Renderer"
				"#(-1204370534, -399920359)": "Krakatoa Renderer"
			)
			local thePathType = case SMTDSettings.SubmitExternalFilesMode of
			(
				default: "Path"
				2: "Local Path"
			)
			try(SMTD_MainRollout.Ui_report "")catch()
			if SMTDExternalRefsArray.StoreRendererPaths.count == 0 then
				try(SMTD_MainRollout.Ui_report ("--No "+ theRendererName + " " + thePathType + "s Collected." ))catch()
			else
				try(SMTD_MainRollout.Ui_report ("+Collected "+ SMTDExternalRefsArray.StoreRendererPaths.count as string + " "+ theRendererName + " " + thePathType + (if SMTDExternalRefsArray.StoreRendererPaths.count != 1 then "s." else ".")  ))catch()
			for o in SMTDExternalRefsArray.StoreRendererPaths do	
				try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[2] +"]") LogFileOnly:true )catch()

			for p in theProps where \
				(try(superclassof (getProperty theRenderer p) == textureMap)catch(false)) OR \
				(try(superclassof (getProperty theRenderer p) == material)catch(false)) \
				do append theMaterials (getProperty theRenderer p)
			for m in theMaterials do SMTDFunctions.collectSubAnims m

			for o in SMTDExternalRefsArray.totalSubsArray do
			(
				if classof o == Point_Cache do ( continue )
				if classof o == VRayProxy do ( continue )
				if classof o == CProxy do ( continue )
				if classof o == mr_Proxy do ( continue )
				if classof o == Point_CacheSpacewarpModifier do ( continue )
				
				if classof o.object == Point_Cache do ( continue )
				if classof o.object == Point_CacheSpacewarpModifier do ( continue )
				
				if (isProperty o #filename or isProperty o.object #filename) and findItem bitmapsArray o.object == 0 do
					append bitmapsArray o.object
				if (isProperty o #HDRIMapName or isProperty o.object #HDRIMapName) and findItem hdriArray o.object == 0 do
					append hdriArray o.object
			)
			
			for m in theMaterials where isProperty m #filename and findItem bitmapsArray m == 0 do append bitmapsArray m
			
			--now go through all bitmaps and collect unique bitmaps and IFL contents for copying
			local bitmapsArrayToProcess = #()
			for o in bitmapsArray do
			(
				if o.filename != undefined AND findItem allBitmaps o.filename == 0 do  --if not on the list yet,
				(
					if SMTDSettings.SubmitExternalFilesMode == 2 then --if locals only, check and append if local.
					(
						if SMTDFunctions.IsLocalPath o.filename do 
						(
							append allBitmaps o.filename
							append bitmapsArrayToProcess o
						)	
					)	
					else
					(
						append allBitmaps o.filename --if all, append every single one
						append bitmapsArrayToProcess o
					)
				)
				if o.filename != undefined AND matchPattern (getFileNameType o.filename) pattern:"*IFL" do
				(
					local thePath = getFileNamePath o.filename
					goOn = SMTDFunctions.IsLocalPath o.filename
					if SMTDSettings.SubmitExternalFilesMode >= 3 do goOn = true
					if goOn do
					(
						local theIFLFile = openFile o.filename	
						if theIFLFile != undefined do
						(
							while not eof theIFLFile do
							(
								local theLine = readline theIFLFile
								if getFileNamePath theLine == ""  then theLine = thePath + theLine
								if findItem allBitmaps theLine == 0 do 
								(
									append allBitmaps theLine 
								)
								append SMTDExternalRefsArray.storeBitmapPath #(undefined, theLine, fileNameFromPath theLine)
								if findItem fileNamesForCollisionCheck (fileNameFromPath theLine) == 0 do 
									append fileNamesForCollisionCheck (fileNameFromPath theLine)
							)
							close theIFLFile
						)	
					)	
				)
			)
			
			local hdriArrayToProcess = #()
			for o in hdriArray do
			(
				if o.HDRIMapName != undefined AND findItem allBitmaps o.HDRIMapName == 0 do  --if not on the list yet,
				(
					if SMTDSettings.SubmitExternalFilesMode == 2 then --if locals only, check and append if local.
					(
						if SMTDFunctions.IsLocalPath o.HDRIMapName do 
						(
							append allBitmaps o.HDRIMapName
							append hdriArrayToProcess o
						)	
					)	
					else
					(
						append allBitmaps o.HDRIMapName --if all, append every single one
						append hdriArrayToProcess o
					)
				)
				if o.HDRIMapName != undefined AND matchPattern (getFileNameType o.HDRIMapName) pattern:"*IFL" do
				(
					local thePath = getFileNamePath o.HDRIMapName
					goOn = SMTDFunctions.IsLocalPath o.HDRIMapName
					if SMTDSettings.SubmitExternalFilesMode >= 3 do goOn = true
					if goOn do
					(
						local theIFLFile = openFile o.HDRIMapName	
						if theIFLFile != undefined do
						(
							while not eof theIFLFile do
							(
								local theLine = readline theIFLFile
								if getFileNamePath theLine == ""  then theLine = thePath + theLine
								if findItem allBitmaps theLine == 0 do 
								(
									append allBitmaps theLine 
								)
								append SMTDExternalRefsArray.storeBitmapPath #(undefined, theLine, fileNameFromPath theLine)
								if findItem fileNamesForCollisionCheck (fileNameFromPath theLine) == 0 do 
									append fileNamesForCollisionCheck (fileNameFromPath theLine)
							)
							close theIFLFile
						)	
					)	
				)
			)

			local TextureCacheFolder = (dotnetclass "System.Environment").GetFolderPath (dotnetclass "System.Environment+SpecialFolder").CommonApplicationData + "\\PF_LocalVFXCache\\LocalTexturesCache\\"

			--Store original texture object and filename, then reset to filename only, no path:
			for o in bitmapsArrayToProcess do
			(
				local theTargetFilename = o.filename
				local theFilename = filenameFromPath theTargetFilename 
				local theIndex1 = findItem fileNamesForCollisionCheck theFilename 
				local theIndex2 = findItem pathNamesForCollisionCheck o.filename

				if theIndex1 > 0 and theIndex2 == 0 then --if the file name exists on the list but the whole path does not, we can assume this is a collision!
				(
					collisions += 1
					theTargetFilename = getFileNameFile theTargetFilename + "_" + collisions as string + getFileNameType theTargetFilename 
				)
				
				if theIndex1 == 0 and theIndex2 == 0 then --if both don't know the file, then it must be new, add it to both lists!
				(
					append fileNamesForCollisionCheck theFilename 
					append pathNamesForCollisionCheck o.filename
				)
				
				append SMTDExternalRefsArray.storeBitmapPath #(o, o.filename, fileNameFromPath theTargetFilename)
				if SMTDSettings.SubmitExternalFilesMode > 1 and SMTDSettings.SubmitExternalFilesMode < 4 do o.filename = fileNameFromPath theTargetFilename
				if SMTDSettings.SubmitExternalFilesMode == 4 do o.filename = SMTDFunctions.convertPathToLocal TextureCacheFolder theTargetFilename
			)
			
			for o in hdriArrayToProcess do
			(
				local theTargetFilename = o.HDRIMapName
				local theFilename = filenameFromPath theTargetFilename 
				local theIndex1 = findItem fileNamesForCollisionCheck theFilename 
				local theIndex2 = findItem pathNamesForCollisionCheck o.HDRIMapName

				if theIndex1 > 0 and theIndex2 == 0 then --if the file name exists on the list but the whole path does not, we can assume this is a collision!
				(
					collisions += 1
					theTargetFilename = getFileNameFile theTargetFilename + "_" + collisions as string + getFileNameType theTargetFilename 
				)
				
				if theIndex1 == 0 and theIndex2 == 0 then --if both don't know the file, then it must be new, add it to both lists!
				(
					append fileNamesForCollisionCheck theFilename 
					append pathNamesForCollisionCheck o.HDRIMapName
				)
				
				append SMTDExternalRefsArray.storeHdriPath #(o, o.HDRIMapName, fileNameFromPath theTargetFilename)
				if SMTDSettings.SubmitExternalFilesMode > 1 and SMTDSettings.SubmitExternalFilesMode < 4 do o.HDRIMapName = fileNameFromPath theTargetFilename
				if SMTDSettings.SubmitExternalFilesMode == 4 do o.HDRIMapName = SMTDFunctions.convertPathToLocal TextureCacheFolder theTargetFilename
			)
			
			--Report the result of the collection
			try(SMTD_MainRollout.Ui_report "")catch()
			local theLocalString = if SMTDSettings.SubmitExternalFilesMode == 2 then " Local" else ""
			case (bitmapsArrayToProcess.count + hdriArrayToProcess.count) of
			(
				default: try(SMTD_MainRollout.Ui_report ("+Collected "+ (bitmapsArrayToProcess.count + hdriArrayToProcess.count) as string+ theLocalString +" Scene Bitmaps with " + pathNamesForCollisionCheck.count as string + " unique "+(if pathNamesForCollisionCheck.count == 1 then "filename" else "filenames")+" and "+ collisions as string + " file name "+(if collisions == 1 then "collision." else "collisions.")  ))catch()
				0: try(SMTD_MainRollout.Ui_report ("--No"+ theLocalString+" Scene Bitmaps Collected."))catch()
				1: try(SMTD_MainRollout.Ui_report ("+Collected One"+theLocalString+" Scene Bitmap."))catch()
			)
			
			--Dump All Bitmap Names to the Log File
			for o in SMTDExternalRefsArray.storeBitmapPath do 
				try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
			for o in SMTDExternalRefsArray.storeHdriPath do 
				try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
				
			/*
			for o in SMTDExternalRefsArray.storeBitmapPath do 
				try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
			*/
			
			for o in SMTDExternalRefsArray.StoreBrazilv2RendererPaths do
			(
				append SMTDExternalRefsArray.storeBitmapPath #(undefined, o[3], filenameFromPath o[3])
				setProperty o[1] o[2] (filenameFromPath o[3])
			)
			
			-- Collect VRay Proxy Objects
			if VRayProxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 and (theRenderer.classid) as string == "#(1941615238, 2012806412)" do
			(
				SMTDExternalRefsArray.StoreSceneVrayProxies = #()
				local uniqueVRayProxyFiles = #()
				local uniqueVRayProxyPaths = #()
				local VRaycollisions = 0
				for o in getClassInstances VRayProxy do
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 AND SMTDFunctions.IsLocalPath o.filename) OR SMTDSettings.SubmitExternalFilesMode == 3 do 
					(
						local theTargetFilename = o.filename
						local theFilename = filenameFromPath theTargetFilename 
						local theIndex1 = findItem uniqueVRayProxyFiles theFilename
						local theIndex2 = findItem uniqueVRayProxyPaths o.filename
						if theIndex1 > 0 and theIndex2 == 0 then --if the file name appears on the file list but not on the paths list, then it is a duplicate with different path = collision!
						(
							VRaycollisions += 1
							theTargetFilename = getFileNameFile theTargetFilename + "_" + VRaycollisions as string + "_" + getFileNameType theTargetFilename 
							append allBitmaps o.filename
							append uniqueVRayProxyPaths o.filename
							append SMTDExternalRefsArray.StoreSceneVrayProxies #(o, o.filename, theTargetFilename)
						)
						else if theIndex1 == 0 and theIndex2 == 0 then --if it is on neither lists, then it is a new unique path to add
						(
							append uniqueVRayProxyFiles theFilename 
							append uniqueVRayProxyPaths o.filename
							append allBitmaps o.filename
							append SMTDExternalRefsArray.StoreSceneVrayProxies #(o, o.filename, theFilename)
						)
						else --if it is not a new or a collision, it is existing already, but we have to collect the file name for restoring 
						(
							append SMTDExternalRefsArray.StoreSceneVrayProxies #(o, o.filename, o.filename)
						)
						--append SMTDExternalRefsArray.storeBitmapPath #(o, o.filename, fileNameFromPath theTargetFilename)
						o.filename = fileNameFromPath theTargetFilename
					)--end copy to repository
					if SMTDSettings.SubmitExternalFilesMode == 4 do
					(
						theNetworkFileName = if SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename then
							SMTDFunctions.convertPathToRemote TextureCacheFolder o.filename
						else
							o.filename
						if findItem allBitmaps theNetworkFileName == 0 do append allBitmaps theNetworkFileName
						if not (SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename) do 
						(
							local theLocalPath = SMTDFunctions.convertPathToLocal TextureCacheFolder o.filename
							append SMTDExternalRefsArray.StoreSceneVrayProxies #(o, o.filename, theLocalPath)
							o.filename = theLocalPath 
						)
					)--end local cache on slave
				)--end o loop
				try(SMTD_MainRollout.Ui_report "")catch()
				case uniqueVRayProxyPaths.count of
				(
					0:	try(SMTD_MainRollout.Ui_report ("--No"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "V-Ray Proxies Collected." ))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Collected One"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "V-Ray Proxy." ))catch()
					default: try(SMTD_MainRollout.Ui_report ("+Collected "+ uniqueVRayProxyPaths.count as string + " Unique" + (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "V-Ray Proxies from "+ SMTDExternalRefsArray.StoreSceneVrayProxies.count as string +" Proxy Objects."  ))catch()
				)
				for o in SMTDExternalRefsArray.StoreSceneVrayProxies do	
					try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
			)

			-- Collect Corona Proxy Objects
			if CProxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 and (theRenderer.classid) as string == "#(1655201228, 1379677700)" do
			(
				SMTDExternalRefsArray.StoreSceneCoronaProxies = #()
				local uniqueCoronaProxyFiles = #()
				local uniqueCoronaProxyPaths = #()
				local Coronacollisions = 0
				for o in getClassInstances CProxy do
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 AND SMTDFunctions.IsLocalPath o.filename) OR SMTDSettings.SubmitExternalFilesMode == 3 do 
					(
						local theTargetFilename = o.filename
						local theFilename = filenameFromPath theTargetFilename 
						local theIndex1 = findItem uniqueCoronaProxyFiles theFilename
						local theIndex2 = findItem uniqueCoronaProxyPaths o.filename
						if theIndex1 > 0 and theIndex2 == 0 then --if the file name appears on the file list but not on the paths list, then it is a duplicate with different path = collision!
						(
							Coronacollisions += 1
							theTargetFilename = getFileNameFile theTargetFilename + "_" + Coronacollisions as string + "_" + getFileNameType theTargetFilename 
							append allBitmaps o.filename
							append uniqueCoronaProxyPaths o.filename
							append SMTDExternalRefsArray.StoreSceneCoronaProxies #(o, o.filename, theTargetFilename)
						)
						else if theIndex1 == 0 and theIndex2 == 0 then --if it is on neither lists, then it is a new unique path to add
						(
							append uniqueCoronaProxyFiles theFilename
							append uniqueCoronaProxyPaths o.filename
							append allBitmaps o.filename
							append SMTDExternalRefsArray.StoreSceneCoronaProxies #(o, o.filename, theFilename)
						)
						else --if it is not a new or a collision, it is existing already, but we have to collect the file name for restoring 
						(
							append SMTDExternalRefsArray.StoreSceneCoronaProxies #(o, o.filename, o.filename)
						)
						--append SMTDExternalRefsArray.storeBitmapPath #(o, o.filename, fileNameFromPath theTargetFilename)
						o.filename = fileNameFromPath theTargetFilename
					)--end copy to repository
					if SMTDSettings.SubmitExternalFilesMode == 4 do
					(
						theNetworkFileName = if SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename then
							SMTDFunctions.convertPathToRemote TextureCacheFolder o.filename
						else
							o.filename
						if findItem allBitmaps theNetworkFileName == 0 do append allBitmaps theNetworkFileName
						if not (SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename) do 
						(
							local theLocalPath = SMTDFunctions.convertPathToLocal TextureCacheFolder o.filename
							append SMTDExternalRefsArray.StoreSceneCoronaProxies #(o, o.filename, theLocalPath)
							o.filename = theLocalPath 
						)
					)--end local cache on slave
				)--end o loop
				try(SMTD_MainRollout.Ui_report "")catch()
				case uniqueCoronaProxyPaths.count of
				(
					0:	try(SMTD_MainRollout.Ui_report ("--No"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "Corona Proxies Collected." ))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Collected One"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "Corona Proxy." ))catch()
					default: try(SMTD_MainRollout.Ui_report ("+Collected "+ uniqueCoronaProxyPaths.count as string + " Unique" + (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "V-Ray Proxies from "+ SMTDExternalRefsArray.StoreSceneCoronaProxies.count as string +" Proxy Objects."  ))catch()
				)
				for o in SMTDExternalRefsArray.StoreSceneCoronaProxies do	
					try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
			)

			-- Collect Mental Ray Proxy Objects
			if mr_Proxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 and (theRenderer.classid) as string == "#(1492548972, 1338981315)" do
			(
				SMTDExternalRefsArray.StoreSceneMRProxies = #()
				local uniqueMRProxyFiles = #()
				local uniqueMRProxyPaths = #()
				local mrcollisions = 0
				for o in getClassInstances mr_Proxy do
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 AND SMTDFunctions.IsLocalPath o.filename) OR SMTDSettings.SubmitExternalFilesMode == 3 do 
					(
						local theTargetFilename = o.filename
						local theFilename = filenameFromPath theTargetFilename 
						local theIndex1 = findItem uniqueMRProxyFiles theFilename
						local theIndex2 = findItem uniqueMRProxyPaths o.filename
						if theIndex1 > 0 and theIndex2 == 0 then --if the file name appears on the file list but not on the paths list, then it is a duplicate with different path = collision!
						(
							mrcollisions += 1
							theTargetFilename = getFileNameFile theTargetFilename + "_" + mrcollisions as string + "_" + getFileNameType theTargetFilename 
							if o.animated == true then
							(
								local theAnimationFiles = SMTDFunctions.GetAnimationFiles o.filename
								for f in theAnimationFiles do
								(
									append allBitmaps f
									append uniqueMRProxyPaths f
								)
								append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, theTargetFilename)
							)
							else
							(
								append allBitmaps o.filename
								append uniqueMRProxyPaths o.filename
								append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, theTargetFilename)
							)
						)
						else if theIndex1 == 0 and theIndex2 == 0 then --if it is on neither lists, then it is a new unique path to add
						(
							if o.animated == true then
							(
								local theAnimationFiles = SMTDFunctions.GetAnimationFiles o.filename
								for f in theAnimationFiles do
								(
									append uniqueMRProxyFiles (filenameFromPath f) 
									append uniqueMRProxyPaths f
									append allBitmaps f
								)
								append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, theFilename)
							)
							else
							(
								append uniqueMRProxyFiles theFilename 
								append uniqueMRProxyPaths o.filename
								append allBitmaps o.filename
								append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, theFilename)
							)
						)
						else --if it is not a new or a collision, it is existing already, but we have to collect the file name for restoring 
						(
							append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, o.filename)
						)
						o.filename = fileNameFromPath theTargetFilename
					)--end copy to repository
					if SMTDSettings.SubmitExternalFilesMode == 4 do
					(
						theNetworkFileName = if SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename then
							SMTDFunctions.convertPathToRemote TextureCacheFolder o.filename
						else
							o.filename
						if findItem allBitmaps theNetworkFileName == 0 do append allBitmaps theNetworkFileName
						if not (SMTDFunctions.isPathInLocalCache TextureCacheFolder o.filename) do 
						(
							local theLocalPath = SMTDFunctions.convertPathToLocal TextureCacheFolder o.filename
							append SMTDExternalRefsArray.StoreSceneMRProxies #(o, o.filename, theLocalPath)
							o.filename = theLocalPath 
						)
					)--end local cache on slave
				)--end o loop
				try(SMTD_MainRollout.Ui_report "")catch()
				case uniqueMRProxyPaths.count of
				(
					0:	try(SMTD_MainRollout.Ui_report ("--No"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "mental ray Proxy Files Collected." ))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Collected One"+ (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "mental ray Proxy File." ))catch()
					default: try(SMTD_MainRollout.Ui_report ("+Collected "+ uniqueMRProxyPaths.count as string + " Unique" + (if SMTDSettings.SubmitExternalFilesMode == 2 then " Local " else " ")+ "mental ray Proxy Files from "+ SMTDExternalRefsArray.StoreSceneMRProxies.count as string +" Proxy Objects."  ))catch()
				)
				for o in SMTDExternalRefsArray.StoreSceneMRProxies do	
					try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> ["+ fileNameFromPath o[3] +"]") LogFileOnly:true )catch()
			)		

			--Do the same for XRefs
			SMTDExternalRefsArray.StoreSceneXRefs = #()
			if not SMTDSettings.MergeSceneXRefsOnSubmission then
			(
				for i = 1 to (xrefs.getXRefFileCount()) do
				(
					o = (xrefs.getXRefFile i)
					local shouldBeCollected = (not o.disabled) AND (doesfileexist o.filename) AND ((SMTDSettings.SubmitExternalFilesMode == 2 AND SMTDFunctions.IsLocalPath o.filename) OR SMTDSettings.SubmitExternalFilesMode == 3)
					append SMTDExternalRefsArray.StoreSceneXRefs #(o, o.filename, fileNameFromPath o.filename, shouldBeCollected)
					if shouldBeCollected do --only collect if not disabled and the Scene XREF actually exists!
					(
						append allBitmaps o.filename
						o.filename = fileNameFromPath o.filename
					)
				)
				try(SMTD_MainRollout.Ui_report "")catch()
				local activeXRefsCount = (for o in SMTDExternalRefsArray.StoreSceneXRefs where o[4] collect o).count
				case activeXRefsCount of
				(
					default: try(SMTD_MainRollout.Ui_report ("+Collected "+ activeXRefsCount as string +" Scene XREFs."))catch()
					0: try(SMTD_MainRollout.Ui_report ("--No Scene XREFs Collected."))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Collected One Scene XREF."))catch()
				)

				for o in SMTDExternalRefsArray.StoreSceneXRefs where o[4] do
					try(SMTD_MainRollout.Ui_report ("\t["+o[2]+"] >> "+"["+o[3]+"]") LogFileOnly:true )catch()
			)
			else
				try(SMTD_MainRollout.Ui_report ("--Merge Scene XREF Requested, Collecting Skipped."))catch()
			
			if not SMTDSettings.MergeXRefsOnSubmission then 
			(
				SMTDExternalRefsArray.StoreObjectXRefs = #()
				for o in (objXrefs.getAllXRefObjects()) do
				(
					if (SMTDSettings.SubmitExternalFilesMode == 2 AND SMTDFunctions.IsLocalPath o.filename) OR SMTDSettings.SubmitExternalFilesMode == 3 do --if local and locals only, or if all paths wanted
					(
						append SMTDExternalRefsArray.StoreObjectXRefs #(o, o.filename, fileNameFromPath o.filename)
						o.filename = fileNameFromPath o.filename
					)
				)	
				
				local uniquePaths = #()
				for o in SMTDExternalRefsArray.StoreObjectXRefs where findItem uniquePaths o[2] == 0 do append uniquePaths o[2]
				for o in uniquePaths do append allBitmaps o
				
				try(SMTD_MainRollout.Ui_report "")catch()
				case SMTDExternalRefsArray.StoreObjectXRefs.count of
				(
					default: (
						if uniquePaths.count != 1 then
							try(SMTD_MainRollout.Ui_report ("+Collected "+ SMTDExternalRefsArray.StoreObjectXRefs.count as string +" Object XREFs with "+ uniquePaths.count as string + " Unique Paths."))catch()
						else
							try(SMTD_MainRollout.Ui_report ("+Collected "+ SMTDExternalRefsArray.StoreObjectXRefs.count as string +" Object XREFs with One Unique Path."))catch()
					)
					0: try(SMTD_MainRollout.Ui_report ("--No Object XREFs Collected."))catch()
					1: try(SMTD_MainRollout.Ui_report ("+Collected One Object XREF."))catch()
				)
				
				for o in uniquePaths do
				(
					try(SMTD_MainRollout.Ui_report ("\t["+o+"] >> ["+fileNameFromPath o +"]") LogFileOnly:true )catch()
					for i in SMTDExternalRefsArray.StoreObjectXRefs where i[2] == o do
						try(
							SMTD_MainRollout.Ui_report ("\t\t["+i[1].objectName +"]") LogFileOnly:true 
						)catch()
				)
			)
			else
				try(SMTD_MainRollout.Ui_report ("--Merge Object XREF Requested, Collecting Skipped."))catch()
			try(SMTD_MainRollout.Ui_report "")catch()
					
			allBitmaps
		),
		
		fn restoreExternalReferencePaths =
		(
			--Restore Bitmaps
			for o in SMTDExternalRefsArray.storeBitmapPath where o[1] != undefined do o[1].filename = o[2]
			for o in SMTDExternalRefsArray.storeHdriPath where o[1] != undefined do o[1].HDRIMapName = o[2]
			
			--Restore Scene XRefs
			for i = 1 to (xrefs.getXRefFileCount()) do
			(
				local o = (xrefs.getXRefFile i)
				o.filename = SMTDExternalRefsArray.StoreSceneXRefs[i][2]
			)
			
			--Restore Object XRefs
			for o in SMTDExternalRefsArray.StoreObjectXRefs do o[1].filename = o[2]
			
			--Restore VRay Proxies
			if VRayProxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 do
				for o in SMTDExternalRefsArray.StoreSceneVrayProxies do o[1].filename = o[2]

			--Restore Corona Proxies
			if CProxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 do
				for o in SMTDExternalRefsArray.StoreSceneCoronaProxies do o[1].filename = o[2]			

			--Restore mr Proxies
			if mr_Proxy != undefined and SMTDSettings.SubmitExternalFilesMode > 1 do
				for o in SMTDExternalRefsArray.StoreSceneMRProxies do o[1].filename = o[2]
				
			--Restore Renderer Paths
			for o in SMTDExternalRefsArray.StoreRendererPaths do
				try(setProperty renderers.current o[1] o[2])catch()
			
			--Restore Brazil 2 Paths
			for o in SMTDExternalRefsArray.StoreBrazilv2RendererPaths do
			(
				setProperty o[1] o[2] o[3]
			)			
		),
		
		fn createExternalFilesList allBitmaps=
		(
			local ExternalFilesListName = getFileNamePath SMTDPaths.JobInfoFile + "\\ExternalFilesList.txt"
			local theListOfExternalFiles = createFile ExternalFilesListName
			for aFile in allBitmaps do
			(
				format "%\n" aFile to:theListOfExternalFiles 
			)
			close theListOfExternalFiles
			ExternalFilesListName
		),
		
		fn GetAnimationBaseCount theBaseName =
		(
			local lastDigit = 0
			for i = theBaseName.count to 1 by -1 do
			(
				if findString "1234567890" theBaseName[i] == undefined do 
				(
					lastDigit = i
					exit
				)
			)--end i loop
			lastDigit
		),
		
		fn GetAnimationFiles theFilePath =
		(
			local theBaseName = getFileNameFile theFilePath 
			local lastDigit = SMTDFunctions.GetAnimationBaseCount theBaseName
			getFiles (thePathPattern = getFileNamePath theFilePath + substring theBaseName 1 lastDigit + "*" + getFileNameType theFilePath)
		),
		
		fn RenameTargetAnimationFile theSource theTarget =
		(
			local theBaseName1 = getFileNameFile theSource 
			local lastDigit1 = SMTDFunctions.GetAnimationBaseCount theBaseName1
			local theBaseName2 = getFileNameFile theTarget 
			local lastDigit2 = SMTDFunctions.GetAnimationBaseCount theBaseName2
			local theNumber = if lastDigit1 < theBaseName1.count then 
				(substring theBaseName1 (lastDigit1+1) -1 )
			else 
				""
			getFileNamePath theTarget + (substring theBaseName2 1 lastDigit2)  + theNumber + getFileNameType theTarget
		),		
		
		--Returns the frame sequence string
		fn GetSequenceString frameNumbers =
		(
			local seqString = StringStream ""
			local curIndex = 1
			while (curIndex <= frameNumbers.count) do
			(
				local baseNumber = frameNumbers[curIndex]
				local baseIndex = curIndex
				local runLen = 1
				while (curIndex < frameNumbers.count) and (baseNumber+runLen) == frameNumbers[curIndex+1] do 
				(
					runLen += 1
					curIndex += 1
				)
				case runLen of
				(
					1:		format "%" frameNumbers[curIndex] to:seqString
					2:		format "%,%" frameNumbers[baseIndex] frameNumbers[curIndex] to:seqString
					default:	format "%-%" frameNumbers[baseIndex] frameNumbers[curIndex] to:seqString
				)
				if (curIndex != frameNumbers.count) do format "," to:seqString
				curIndex += 1
			)
			--try(SMTD_MainRollout.Ui_report ">Sequence String:" )catch()
			--try(SMTD_MainRollout.Ui_report (seqString as string) )catch()
			seqString as string
		),
		
		--Returns the out of order sequence
		fn outOfOrderSequence theFramesArray mode:#both =
		(
			local startArray = #()
			
			local step = if mode != #both then
				1.0*(theFramesArray.count-1) / (SMTDSettings.PreviewJobFrameCount - 1)
			else
				SMTDSettings.outOfOrderStep
				
			for i = 1 to theFramesArray.count by step do
				append startArray theFramesArray[i]
			local endArray = for i = 1 to theFramesArray.count where findItem startArray theFramesArray[i] == 0 collect theFramesArray[i]
			case mode of
			(
				#both: startArray + endArray 
				#nth: startArray 
				#rest: endArray 
			)	
		),
		
		fn outOfOrderMethod theFramesArray theMethod:#normal =
		(
			case theMethod of
			(
				default: theFramesArray
				#normal: theFramesArray
				#reverse: for i = theFramesArray.count to 1 by -1 collect theFramesArray[i]
				#lastAndFirst:
				(
					if theFramesArray.count < 3 then
						theFramesArray
					else
					(
						local temp = #()
						append temp theFramesArray[1]
						append temp theFramesArray[theFramesArray.count]
						for i = 2 to (theFramesArray.count - 1) do
							append temp theFramesArray[i]
						temp
					)
				)
				#nth:
				(
					local startArray = #()
					local theStep = SMTDSettings.outOfOrderStep
					for i = 1 to theFramesArray.count by theStep do
						append startArray theFramesArray[i]
					local endArray = for i = 1 to theFramesArray.count where findItem startArray theFramesArray[i] == 0 collect theFramesArray[i]
					startArray + endArray 
				)
				#fromBothEnds: 
				(
					local temp = #()
					for i = 1 to theFramesArray.count / 2 do 
					(
						append temp theFramesArray[i]
						append temp theFramesArray[theFramesArray.count - i + 1]
					)	
					for i in theFramesArray where findItem temp i == 0 do append temp i --make sure nothing was left behind
					temp
				)
				#fromBothEndsAndCenter:
				(
					local temp = #()
					for i = 1 to theFramesArray.count / 4 do 
					(
						append temp theFramesArray[i]
						append temp theFramesArray[theFramesArray.count - i + 1]
						append temp theFramesArray[theFramesArray.count / 2 - i + 1]
						append temp theFramesArray[theFramesArray.count / 2 + i]
					)	
					for i in theFramesArray where findItem temp i == 0 do append temp i --make sure nothing was left behind
					temp
				)
				#fromCenter:
				(
					local temp = #()
					for i = theFramesArray.count / 2 to 1 by -1 do 
					(
						append temp theFramesArray[i]
						append temp theFramesArray[theFramesArray.count - i + 1]
					)	
					for i in theFramesArray where findItem temp i == 0 do append temp i --make sure nothing was left behind
					temp					
				)
				#NthBlock: 
				(
					local temp = #()
					theStep = SMTDSettings.outOfOrderStep
					theBlockSize = theFramesArray.count/theStep
					for i = 1 to theBlockSize do
						for j = 0 to theStep-1  do
							append temp theFramesArray[i+j*theBlockSize]
					for i in theFramesArray where findItem temp i == 0 do append temp i --make sure nothing was left behind	
					temp 
				)
				#NthRasterRefine:
				(
					local temp = #()
					local theStep = SMTDSettings.outOfOrderStep
					while theStep > 1 do
					(
						for i = 1 to theFramesArray.count by theStep where findItem temp theFramesArray[i] == 0 do
							append temp theFramesArray[i]
						theStep /=	 2
					)		
					for i = 1 to theFramesArray.count where findItem temp theFramesArray[i] == 0 do append temp theFramesArray[i]
					temp 
				)
				#random:
				(
					local temp = #()
					local temp2 = for i in theFramesArray collect i
					--seed 12345
					while temp2.count > 0 do 
					(
						theIndex = random 1 temp2.count
						append temp temp2[theIndex]
						deleteItem temp2 theIndex
					)
					temp
				)
			)--end case
		),

		fn DeleteEmptyStateSets = 
		(
			if not SMTDSettings.StateSetsSubmit do
			(
				try
				(
					local ssP = try(dotNetObject "Autodesk.Max.StateSets.Plugin")catch(undefined)
					if ssP == undefined do ssP = try(dotNetObject "Ephere.Plugins.Autodesk.Max.Zookeeper.Plugin")catch(undefined)
					if ssP != undefined then
					(
						local ssPi = ssP.Instance
						StateSetsRootEntry = ssPi.EntityManager.RootEntity
						if StateSetsRootEntry.Children.count > 0 then
						(
							-- 3dsmax 2015 added the boolean parameter to GetDescendantStateSetPaths()
							StateSetsChildren = #()
							if( ((maxVersion())[1]/1000 as integer) >= 17 ) then
								StateSetsChildren = StateSetsRootEntry.Children.Item[0].GetDescendantStateSetPaths(false)
							else
								StateSetsChildren = StateSetsRootEntry.Children.Item[0].GetDescendantStateSetPaths()
							
							EmptySS = (for i in 1 to StateSetsChildren.count where (StateSetsChildren.Item[i-1][1].IsEmpty == True) collect n).count == StateSetsChildren.count

							if EmptySS do
							(
								-- hide & reset State Sets dialog
								ssPi.HideMainFrame()
								with quiet on ssPi.ResetAndDelete()
								try(SMTD_MainRollout.Ui_report ("+Empty State Sets have been Deleted"))catch()
							)
						)
					)
				)catch()
			)
		),

		fn SaveMaxFileCopy destFileName useMaxHold:false =
		(
			try(SMTD_MainRollout.sld_lastSubmissionState.value = 50)catch()

			if not SMTDSettings.StateSetsSubmit AND SMTDSettings.DeleteEmptyStateSets do SMTDFunctions.DeleteEmptyStateSets()
			
			if useMaxHold then
			(
				local holdMaxDir = (GetDir #autoback) + "\\"
				local holdFileName = if maxOps.productAppID == #max then --still works in Max2016 after Design has been retired
					holdMaxDir + "maxhold.mx"
				else
					holdMaxDir + "vizhold.mx"
		
				local holdTempFileName = holdMaxDir + "maxhold.tmp"
				local holdExists = doesFileExist holdFileName
				
				if holdExists then 
				(
					deleteFile holdTempFileName
					renameFile holdFileName holdTempFileName
				)
		
				holdMaxFile()
				
				if not (doesFileExist holdFileName) do 
					return ("Saving the file as ["+ holdFileName +"] via hold() did not work.")
				
				if not (renameFile holdFileName destFileName) do
				(
					if not (copyFile holdFileName destFileName) do
					(
						return ("Could not copy the saved scene file to " + destFileName)
					)
				)
				
				if holdExists do
				(
					deleteFile holdFileName
					renameFile holdTempFileName holdFileName
				)				
			)
			else
			(
				saveMaxFile destFileName clearNeedSaveFlag:false useNewFile:false quiet:true
				if not (doesFileExist destFileName) do return ("Saving the file as ["+ destFileName +"] did not work.")
			)
			return undefined
		),

		fn RestoreMaxFileCopy sourceFileName =
		(
			local holdMaxDir = (GetDir #autoback) + "/"
			local holdFileName = if maxOps.productAppID == #max then --still works in Max2016 after Design has been retired
				holdMaxDir + "maxhold.mx"
			else
				holdMaxDir + "vizhold.mx"			
			local holdTempFileName = holdMaxDir + "maxhold.tmp"
			local holdExists = doesFileExist holdFileName
			
			if holdExists then
			(
				deleteFile holdTempFileName
				renameFile holdFileName holdTempFileName
			)
			
			renameFile sourceFileName holdFileName
			if not (doesFileExist holdFileName) do return "Restoring the file via fetch() did not work." 
			
			fetchMaxFile quiet:true
			
			if holdExists do
			(
				deleteFile holdFileName
				renameFile holdTempFileName holdFileName
			)
			return undefined
		),	
		
		fn collectSceneMaterials =
		(
			try(SMTD_MainRollout.Ui_report (">Enumerating Scene Objects and Materials"))catch()
			SMTD_SceneMaterials = for o in objects collect #(o, o.material, o.colorByLayer)
		),
		
		fn assignCustomShaders =
		(
			case SMTDSettings.CustomShaderMode of
			(
				1: (
					objects.material = standard()
					shaderType = "Standard Grayscale Shader"
				)	
				2: (
					objects.material = undefined
					shaderType = "Object Wireframe Colors"
				)
				3: (
					objects.material = undefined
					objects.colorByLayer = true
					shaderType = "Layer Colors"
				)	
				4: (
					if superclassof meditmaterials[1] == Material then 
					(
						objects.material = meditmaterials[1] 
						shaderType = "Material Editor Slot 1"
					)
					else 
					(
						objects.material = standard()
						shaderType = "Standard Grayscale Material Instead Of Medit Slot 1"
					)	
				)	
			)	
			try(SMTD_MainRollout.Ui_report ("+Assigned "+ shaderType +" To Scene Objects"))catch()
		),
		
		fn restoreSceneMaterials =
		(
			for o in SMTD_SceneMaterials do 
			(
				o[1].material = o[2]
				o[1].colorByLayer = o[3]
			)	
			SMTD_SceneMaterials =#()
			try(SMTD_MainRollout.Ui_report ("+Restored Materials Of Scene Objects"))catch()
		),
		fn clearMaterialEditor =
		(
			global SMTDSettings_MeditMaterialsStorage = for i = 1 to 24 collect meditMaterials[i]
			for i = 1 to 24 do meditMaterials[i] = standard()
		),
		
		fn restoreMaterialEditor =
		(
			for i = 1 to 24 do try(meditMaterials[i] = SMTDSettings_MeditMaterialsStorage[i])catch()
		),
		
		fn HasActiveSceneXRefs =
		(
			theCount = xrefs.getXRefFileCount()
			(for i = 1 to theCount where not (xrefs.getXRefFile i).disabled collect i).count > 0
		),
		
		fn SaveMaxFileVisibleOnly destFileName =
		(
			try(SMTD_MainRollout.sld_lastSubmissionState.value = 50)catch()
			if not SMTDSettings.StateSetsSubmit AND SMTDSettings.DeleteEmptyStateSets do SMTDFunctions.DeleteEmptyStateSets()
			--COLLECT ALL GEOMETRY THAT IS VISIBLE TO CAMERA OR REFLECTIONS
			local theNodesToSave = for o in objects where findItem geometryClass.classes (classof o) > 0 AND (not o.isHiddenInVpt and o.renderable and (o.primaryVisibility or o.secondaryVisibility)) collect o
			format "Submitting % Geometry Object(s)\n" theNodesToSave.count
			--ADD ALL LIGHTS,CAMERAS, HELPERS AND NODES ENABLED AS BONES
			join theNodesToSave (for o in objects where findItem Light.classes (classof o) > 0 OR findItem Camera.classes (classof o) > 0 OR findItem Helper.classes (classof o) > 0 or o.boneEnable == true collect o)

			--ADD RENDERABLE SHAPES 
			join theNodesToSave (for o in objects where findItem Shape.classes (classof o) > 0 AND (try(o.baseobject.renderable)catch(true)) collect o)

			format "Submitting TOTAL: % of %\n" theNodesToSave.count objects.count
			--SAVE THE COLLECTED OBJECTS - ANY DEPENDENTS WILL ALSO BE SAVED AUTOMATICALLY
			saveNodes theNodesToSave destFileName
			if doesFileExist destFileName then 
				undefined 
			else 
				"Saving Of Visible Objects Only Failed."
		),
		
		fn RenderElementsStoreVrayVFB =
		(
			global SMTD_RenderElementVrayVFB = #()
			
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
				(
					local reCurr = (reManager.GetRenderElement i)
					if classof reCurr != Missing_Render_Element_Plug_in AND hasProperty reCurr "vrayVFB" then
						SMTD_RenderElementVrayVFB[i+1] = reCurr.vrayVFB
					else
						SMTD_RenderElementVrayVFB[i+1] = false --Just a place holder!
				)
			)
		),
		
		fn RenderElementsUpdateVrayVFB =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				if reManager.GetElementsActive() then 
				(
					local reCount = reManager.NumRenderElements()
					for i = 0 to reCount - 1 do
					(
						local reCurr = (reManager.GetRenderElement i)
						if classof reCurr != Missing_Render_Element_Plug_in AND hasProperty reCurr "vrayVFB" do
						(
							if reCurr.vrayVFB do
							(
								try(SMTD_MainRollout.Ui_report ("+Disabling V-Ray Frame Buffer for render element " + reCurr.elementName))catch()
								reCurr.vrayVFB = false
							)
						)
					)
				)
			)
		),
		
		fn RenderElementsRestoreVrayVFB =
		(
			if classof SMTD_RenderElementVrayVFB == Array do
			(
				local reManager = maxOps.GetCurRenderElementMgr()
				if reManager != undefined do
				(
					local reCount = reManager.NumRenderElements()
					for i = 0 to reCount - 1 do
					(
						local reCurr = (reManager.GetRenderElement i)
						if classof reCurr != Missing_Render_Element_Plug_in AND hasProperty reCurr "vrayVFB" do
						(
							local currVrayVFB = SMTD_RenderElementVrayVFB[i+1]
							if currVrayVFB == true do
							(
								try(SMTD_MainRollout.Ui_report ("+Reenabling V-Ray Frame Buffer for render element " + reCurr.elementName))catch()
								reCurr.vrayVFB = true
							)
						)
					)
				)
			)
		),
		
		fn RenderElementsStorePaths =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				global SMTD_RenderElementPaths = #()
				for i = 0 to reCount - 1 do
				(
					if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do
						SMTD_RenderElementPaths[i+1] = reManager.GetRenderElementFilename i
				)
			)
		),		
		
		fn RenderElementsUpdatePaths =
		(
			local processedNames = #()
			local processedNamesUsage = #()
			outputFilename = rendOutputFilename
			-- only update RE paths if the output filename isn't empty
			if (outputFilename != undefined and outputFilename != "" and rendSaveFile) then
			(
				if ( renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on ) then
				(
					--do nothing if renderer is vray
				)
				else
				(
					local reManager = maxOps.GetCurRenderElementMgr()
					if reManager != undefined do
					(
						if reManager.GetElementsActive() then
						(
							local reCount = reManager.NumRenderElements()
							for i = 0 to reCount - 1 do
							(
								if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do
								(
									local reFilename = reManager.GetRenderElementFilename i
									
									--Prefix render element with State Set name if not prefixed yet
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*")  do
										reFilename = getFileNamePath reFilename + SMTDSettings.StateSetName +"_"+(getFilenameFile reFilename) + (getFilenameType reFilename)
									
									local theElement = reManager.GetRenderElement i
									if SMTDSettings.RenderElementsUpdateFilenames then
									(
										local theIndex = findItem processedNames theElement.elementName
										if theIndex == 0 then
										(
											append processedNames theElement.elementName 
											append processedNamesUsage 1
										)
										else
										(
											processedNamesUsage[theIndex] += 1
											theElement.elementName += processedNamesUsage[theIndex] as string
										)
									)
									
									local theElementFolder = ""
									
									-- If including both RE type and name in the folder, then separate with an underscore
									if SMTDSettings.RenderElementsIncludeNameInPath and SMTDSettings.RenderElementsIncludeTypeInPath then
										theElementFolder = theElement.elementName + "_" + (classof theElement) as string 
									else
									(
										-- See if either the RE type or name is stored in the folder.
										if SMTDSettings.RenderElementsIncludeNameInPath do
											theElementFolder = theElement.elementName
										if SMTDSettings.RenderElementsIncludeTypeInPath do
											theElementFolder = (classof theElement) as string
									)
									
									-- Build up the new path, and only include the element folder if it's been set above
									local newPath = (getFileNamePath outputFilename)
									if theElementFolder != "" do
										newPath += theElementFolder
									
									if SMTDSettings.purifyFilenames do newPath = SMTDFunctions.purifyFilename newPath 
									if SMTDSettings.ForceLowerCaseFilenames do newPath = toLower newPath
									
									if theElement.enabled do
										makeDir newPath all:true
									
									if SMTDSettings.RenderElementsUpdateFilenames then
									(
										local theNewFileName = (newPath +"\\" + getFileNameFile outputFilename)
										
										 -- See if either the RE type or name is stored in the file name.
										if SMTDSettings.RenderElementsIncludeNameInFileName do
											theNewFileName += ("_" + theElement.elementName)
										if SMTDSettings.RenderElementsIncludeTypeInFilename do
											theNewFileName += ("_" + ((classof theElement) as string))
											
										local theNewExtension = (getFileNameType reFilename)
										if theNewExtension == undefined or theNewExtension == "" do
											theNewExtension += (getFileNameType outputFilename)
										theNewFileName += theNewExtension
										
										if SMTDSettings.purifyFilenames do theNewFileName = SMTDFunctions.purifyFilename theNewFileName 
										if SMTDSettings.ForceLowerCaseFilenames do theNewFileName = toLower theNewFileName
										reManager.SetRenderElementFilename i theNewFileName
									)
									else
									(
										local theNewFileName = if reFilename != undefined and reFilename != "" then
											(newPath +"\\" + getFileNameFile reFilename + getFileNameType reFilename)
										else
											 (newPath +"\\" + theElement.elementName + "_" + ((classof theElement) as string) + getFileNameType outputFilename)
										
										if SMTDSettings.purifyFilenames do theNewFileName = SMTDFunctions.purifyFilename theNewFileName
										if SMTDSettings.ForceLowerCaseFilenames do theNewFileName = toLower theNewFileName
										reManager.SetRenderElementFilename i theNewFileName
									)
								)--end if not missing element
							)--end i loop
						)--end if
					)--end if reManager undefined
				)--end else
				
			)
			/*
			else
			(
				-- if output file is empty, check if rendering with vray and saving a raw image, and clear RE paths if so
				if (renderers.current.classid as string == "#(1941615238, 2012806412)") and renderers.current.output_on and renderers.current.output_saveRawFile then
				(
					local reManager = maxOps.GetCurRenderElementMgr()
					if reManager.GetElementsActive() then 
					(
						local reCount = reManager.NumRenderElements()
						for i = 0 to reCount - 1 do
						(
							reManager.SetRenderElementFilename i ""
						)
					)
				)
			)
			*/
		),
		
		fn RenderElementsRestorePaths =
		(
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				if classof SMTD_RenderElementPaths == Array do
				(
					for i = 0 to reCount - 1 do
					(
						if classof (reManager.GetRenderElement i) != Missing_Render_Element_Plug_in do					
						(
							if SMTD_RenderElementPaths[i+1] == undefined or SMTD_RenderElementPaths[i+1] == "" then
								reManager.SetRenderElementFilename i ""
							else
								reManager.SetRenderElementFilename i (SMTD_RenderElementPaths[i+1])
						)
					)
				)
			)--end if undefined
		),

		fn RebuildRenderElements = 
		(
			if RendOutputFilename != undefined or RendOutputFilename != "" do
			(
				local reManager = maxOps.GetCurRenderElementMgr()
				if reManager != undefined do
				(
					local AR_Elements = #()
					local AR_ElementProps = #()
					local AR_ElementFilenames = #()
					local AR_Elementnames = #()
					for i = 1 to reManager.numrenderelements() do
					(
						local theelement = reManager.getrenderelement (i - 1)
						if classof theelement != Missing_Render_Element_Plug_in do
						(
							append AR_Elements (classof theelement)
							local a = #()
							for prop in (getPropNames theelement) do
								try(append a (getproperty theelement prop))catch(append a "")
							append AR_ElementProps a
							append AR_ElementNames theelement.elementname
							append AR_ElementFilenames (reManager.GetRenderElementFilename (i - 1))
						)
					)
					reManager.RemoveAllRenderElements()
					for i = 1 to AR_Elements.count do
					(
						reManager.addrenderelement (execute((AR_Elements[i] as string) + "()"))
						local theelement = reManager.getrenderelement (i - 1)

						for j = 1 to (getPropNames theelement).count do
							try(setproperty theelement (getPropNames theelement)[j] AR_elementProps[i][j])catch()
						if AR_ElementFilenames[i] == undefined or AR_ElementFilenames[i] == "" then
							reManager.SetRenderElementFilename (i-1) ""
						else
							reManager.SetRenderElementFilename (i - 1) (getFilenamePath AR_ElementFilenames[i] + getFilenameFile AR_ElementFilenames[i] + getFilenameType RendOutputFilename)
						theelement.elementname = AR_ElementNames[i]
					)
				)--end if undefined
			)
		),

		fn IsSettingSticky theCategory theKey isSticky:true =
		( 
			local theStickyFile = getDir #userScripts + "\\SubmitMaxToDeadline_StickySettings.ini"
			local theLocalStickyFile = SMTDPaths.SettingsDir + "\\SubmitMaxToDeadline_StickySettings.ini"
			local isSticky = isSticky --If INI key is not set, we set to true if the property does not override its own stickiness via the array element 8
			local theValue = (getINISetting theStickyFile theCategory theKey) 
			--if there is such a global entry, see whether it is false or not. 
			if theValue != "" then isSticky = theValue != "false"
			--if there is such a local entry, see whether it is false or not
			local theValue = (getINISetting theLocalStickyFile theCategory theKey)
			if theValue != "" then isSticky = theValue != "false"
			isSticky 
		),
		
		fn FormatJobName currJobName =
		(
			local nameFormats = #()
			
			-- if a local version of the file exists, use that instead
			local nameFormatFilename = SMTDPaths.SettingsDir + "\\SubmitMaxToDeadline_NameFormats.ini"
			if not doesFileExist nameFormatFilename then
				nameFormatFilename = SMTDPaths.NetworkRoot + "\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_NameFormats.ini"
			
			local nameFormatFile = openFile nameFormatFilename
			if (nameFormatFile != undefined) then
			(
				try
				(
					while not eof nameFormatFile do
					(
						local fileLine = readLine nameFormatFile 
						local index = findString fileLine "="
						if (index != undefined and index < fileLine.count) then
						(
							nameFormats = append nameFormats #( (substring fileLine 1 (index-1)), (substring fileLine (index+1) -1) )
						)
					)
				)
				catch ()
				try(close nameFormatFile)catch()
			)
			
			for currNameFormat in nameFormats do
			(
				local searchVars = findstring currJobName currNameFormat[1]   
				if searchVars != undefined do
					currJobName = replace currJobName searchVars currNameFormat[1].count (execute currNameFormat[2])
			)
			currJobName
		),
		
		fn FormatComment currComment =
		(
			local commentFormats = #()
			
			-- if a local version of the file exists, use that instead
			local commentFormatFilename = SMTDPaths.SettingsDir + "\\SubmitMaxToDeadline_CommentFormats.ini"
			if not doesFileExist commentFormatFilename then
				commentFormatFilename = SMTDPaths.NetworkRoot + "\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_CommentFormats.ini"
			
			local commentFormatFile = openFile commentFormatFilename
			if (commentFormatFile != undefined) then
			(
				try
				(
					while not eof commentFormatFile do
					(
						local fileLine = readLine commentFormatFile 
						local index = findString fileLine "="
						if (index != undefined and index < fileLine.count) then
						(
							commentFormats = append commentFormats #( (substring fileLine 1 (index-1)), (substring fileLine (index+1) -1) )
						)
					)
				)
				catch ()
				try(close commentFormatFile)catch()
			)
			
			for currCommentFormat in commentFormats do
			(
				local searchVars = findstring currComment currCommentFormat[1]   
				if searchVars != undefined do
					currComment = replace currComment searchVars currCommentFormat[1].count (execute currCommentFormat[2])
			)
			currComment
		),

		fn FormatExtraInfo currExtraInfo =
		(
			local extraInfoFormats = #()
			
			-- if a local version of the file exists, use that instead
			local extraInfoFormatFilename = SMTDPaths.SettingsDir + "\\SubmitMaxToDeadline_ExtraInfoFormats.ini"
			if not doesFileExist extraInfoFormatFilename then
				extraInfoFormatFilename = SMTDPaths.NetworkRoot + "\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_ExtraInfoFormats.ini"
			
			local extraInfoFormatFile = openFile extraInfoFormatFilename
			if (extraInfoFormatFile != undefined) then
			(
				try
				(
					while not eof extraInfoFormatFile do
					(
						local fileLine = readLine extraInfoFormatFile 
						local index = findString fileLine "="
						if (index != undefined and index < fileLine.count) then
						(
							extraInfoFormats = append extraInfoFormats #( (substring fileLine 1 (index-1)), (substring fileLine (index+1) -1) )
						)
					)
				)
				catch ()
				try(close extraInfoFormatFile)catch()
			)
			
			for currExtraInfoFormat in extraInfoFormats do
			(
				local searchVars = findstring currExtraInfo currExtraInfoFormat[1]   
				if searchVars != undefined do
					currExtraInfo = replace currExtraInfo searchVars currExtraInfoFormat[1].count (execute currExtraInfoFormat[2])
			)
			currExtraInfo
		),

		fn QTCreateSubmitInfoFile filename outputFileName batchName:"" DependenciesArray:#() =
		(
			local formattedJobName = (SMTDFunctions.FormatJobName SMTDSettings.JobName)
			local formattedComment = (SMTDFunctions.FormatComment SMTDSettings.Comment)

			local formattedExtraInfo0 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo0)
			local formattedExtraInfo1 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo1)
			local formattedExtraInfo2 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo2)
			local formattedExtraInfo3 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo3)
			local formattedExtraInfo4 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo4)
			local formattedExtraInfo5 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo5)
			local formattedExtraInfo6 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo6)
			local formattedExtraInfo7 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo7)
			local formattedExtraInfo8 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo8)
			local formattedExtraInfo9 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo9)
			
			--if rendNthFrame == 1
			local submitInfoFile = CreateFile filename
			if (submitInfoFile != undefined) then
			(
				StartFrame = EndFrame = 0
				case rendTimeType of
				(
					2: (
						StartFrame = animationRange.start.frame as integer
						EndFrame = animationRange.end.frame as integer
					)	
					3: (
						StartFrame = rendStart.frame as integer
						EndFrame = rendEnd.frame as integer
					)	
				)
				
				format "Plugin=Quicktime\n" to:submitInfoFile
				
				
				/*
				if SMTDSettings.RegionRenderingMode != #none and SMTDSettings.RegionRenderingMode != #maxRegion then --if tile or multi-region rendering
				(
					if SMTDSettings.TilesSubmissionJobIDs.count > 0 do
					(
						local theDependencies = ""
						for i = 1 to SMTDSettings.TilesSubmissionJobIDs.count-1 do theDependencies+= SMTDSettings.TilesSubmissionJobIDs[i] + ","
						theDependencies+= SMTDSettings.TilesSubmissionJobIDs[SMTDSettings.TilesSubmissionJobIDs.count] 
						format "JobDependencies=%\n" 	theDependencies  to:submitInfoFile
						format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:submitInfoFile
					)	
				)
				else
				(
					format "JobDependencies=%\n" 	SMTDSettings.DeadlineSubmissionLastJobID  to:submitInfoFile
					format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:submitInfoFile
				)	
				*/
				
				local theDependencies = ""
				for i = 1 to DependenciesArray.count-1 do theDependencies+= DependenciesArray[i] + ","
				theDependencies+= DependenciesArray[DependenciesArray.count] 
				format "JobDependencies=%\n" 	theDependencies  to:submitInfoFile
				format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:submitInfoFile
				
				format "Priority=%\n" 			SMTDSettings.Priority 	 					to:submitInfoFile
				format "Pool=%\n" 				SMTDSettings.QuicktimePoolName				to:submitInfoFile
				format "Group=%\n" 				SMTDSettings.QuicktimeGroupName				to:submitInfoFile
				
				format "Name=% [%]\n" 			formattedJobName (filenameFromPath outputFileName)	to:submitInfoFile
				format "BatchName=%\n"		  	batchName									to:submitInfoFile
				format "UserName=%\n"			SMTDSettings.UserName						to:submitInfoFile
				format "Comment=%\n" 			formattedComment							to:submitInfoFile
				
				format "Department=%\n" 		SMTDSettings.Department 					to:submitInfoFile				
				format "Frames=%\n" ((StartFrame as string) + "-" + (EndFrame as string))	to:submitInfoFile
				format "ChunkSize=100000\n" 												to:submitInfoFile

				format "OutputDirectory0=%\n" (getFileNamePath outputFileName) 				to:submitInfoFile
				format "OutputFilename0=%\n" (filenameFromPath outputFileName) 				to:submitInfoFile

				format "ExtraInfo0=%\n" 		formattedExtraInfo0							to:submitInfoFile
				format "ExtraInfo1=%\n" 		formattedExtraInfo1							to:submitInfoFile
				format "ExtraInfo2=%\n" 		formattedExtraInfo2							to:submitInfoFile
				format "ExtraInfo3=%\n" 		formattedExtraInfo3							to:submitInfoFile
				format "ExtraInfo4=%\n" 		formattedExtraInfo4							to:submitInfoFile
				format "ExtraInfo5=%\n" 		formattedExtraInfo5							to:submitInfoFile
				format "ExtraInfo6=%\n" 		formattedExtraInfo6							to:submitInfoFile
				format "ExtraInfo7=%\n" 		formattedExtraInfo7							to:submitInfoFile
				format "ExtraInfo8=%\n" 		formattedExtraInfo8							to:submitInfoFile
				format "ExtraInfo9=%\n" 		formattedExtraInfo9							to:submitInfoFile

				close submitInfoFile
				true
			)
			else
				false
		),
		
		fn QTCreateJobInfoFile filename inputImages outputFileName =
		(
			local JobInfoFile = CreateFile filename
			if (JobInfoFile != undefined) then
			(
			
				StartFrame = EndFrame = 0
				case rendTimeType of
				(
					2: (
						StartFrame = animationRange.start.frame as integer
						EndFrame = animationRange.end.frame as integer
					)	
					3: (
						StartFrame = rendStart.frame as integer
						EndFrame = rendEnd.frame as integer
					)	
				)
			
				theBaseFile = getFileNameFile inputImages
				/*
				theSource = if superclassof (try(execute (substring theBaseFile (theBaseFile.count-3) 4))catch()) == Number then
					inputImages 
				else*/
				if matchPattern inputImages pattern:"*####*" then
				(
					inputImages = substituteString inputImages "####" (SMTDFunctions.getZeros StartFrame + StartFrame as string)
					theSource = inputImages --getFileNamePath inputImages + theBaseFile + SMTDSettings.Delimiter +  + getFileNameType inputImages 
				)
				else
					theSource = getFileNamePath inputImages + theBaseFile + (SMTDFunctions.getZeros StartFrame + StartFrame as string) + getFileNameType inputImages 
				
				format "InputImages=%\n" theSource  to:JobInfoFile
				format "OutputFile=%\n" outputFileName to:JobInfoFile
				format "FrameRate=%\n" FrameRate to:JobInfoFile
				
				Close JobInfoFile
				true
			)
			else
				false
		),

		fn AutomaticQuicktimeGeneration = --overrideOutputPath:"" overrideInput:"" batchName:"" =
		(
			local goOn = true

			/*
			local theInputPath = if overrideInput == "" then
				rendOutputFilename 
			else
				overrideInput
			*/

			if SMTDSettings.QuicktimesToGenerate.count == 0 do goOn = false
				
			if rendTimeType == 1 do (goOn = false; try(SMTD_MainRollout.Ui_report "--No Automatic Quicktime Generation for Single Frames.\n")catch() )
			if rendTimeType == 4 do (goOn = false; try(SMTD_MainRollout.Ui_report "--No Automatic Quicktime Generation for User Frames because of potential gaps in frame numbering.\n")catch() )

			if SMTDSettings.SubmitAsMXSJob do (goOn = false; try(SMTD_MainRollout.Ui_report "--No Automatic Quicktime Generation for MAXScript Jobs.\n")catch() )
			if SMTDSettings.UseBatchRender and SMTDSettings.BatchRenderMode == 2 do (goOn = false; try(SMTD_MainRollout.Ui_report "--No Automatic Quicktime Generation for Batch Rendering Jobs.\n")catch() )
			
			if goOn then
			(
				try(SMTD_MainRollout.Ui_report ">Submitting Quicktime Jobs...")catch()
				
				for aQTJob in SMTDSettings.QuicktimesToGenerate do
				(
					if matchPattern (getFileNameType aQTJob[1]) pattern:".EXR" do continue

					SMTDFunctions.createSubmissionFolderAndUpdatePaths()
					local submitInfo = SMTDPaths.submitSubFolder  + "QT_max_submit_info.job"
					local jobInfo = SMTDPaths.submitSubFolder + "QT_max_job_info.job"
					
					local theMOVfile = getFileNameFile aQTJob[1] + ".mov"
					theMOVfile = substituteString theMOVfile "####" ""
					theMOVfile = substituteString theMOVfile ".." "."
					theMOVfile = getFileNamePath aQTJob[1] + theMOVfile
					
					/*
					local theMOVfile = if overrideOutputPath == "" then
						getFileNamePath rendOutputFilename 
					else	
						overrideOutputPath
					
					if overrideInput == "" then
					(
						theMOVfile += case SMTDSettings.QuicktimeFilenameMode of
						(
							1: getFileNameFile rendOutputFilename 
							2: SMTDSettings.JobName
							3: SMTDSettings.QuicktimeCustomFilename
						)	
					)
					else
					(
						theMOVfile+= getFileNameFile overrideInput
					)
					theMOVfile +=  ".mov"
					*/
					
					SMTDFunctions.QTCreateSubmitInfoFile submitInfo theMOVfile batchName:aQTJob[2] DependenciesArray:aQTJob[3] 
					SMTDFunctions.QTCreateJobInfoFile jobinfo aQTJob[1] theMOVfile
					local initialArgs = ""
					initialArgs += "\"" + submitInfo + "\" \"" + jobInfo + "\""
					initialArgs += " \"" + SMTDPaths.SettingsDir + "qt\\" + SMTDSettings.QuicktimeSettingsFile + ".xml\" "			
					local retCode = SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutQTSubmission
					if retCode == #success then
					(
						renderMsg = SMTDFunctions.getRenderMessage()				
						try(SMTD_MainRollout.Ui_report ("Quicktime Job submitted successfully.\n\n" + renderMsg))catch()					
						try(SMTD_MainRollout.sld_lastSubmissionState.color = green)catch()		
					)	
					else	
					(
						try(SMTD_MainRollout.sld_lastSubmissionState.color = red*0.7)catch()
						if result == #timeout then
							try(SMTD_MainRollout.Ui_report ("--Failed To Submit Quicktime Job in " + SMTDSettings.TimeoutQTSubmission as string + " seconds.\nConsider Increasing the Quicktime Submission Timeout in the User Options tab."))catch()
						else	
							try(SMTD_MainRollout.Ui_report ("--Failed To Submit Quicktime Job."))catch()
					)
				)--end for loop			
			)	
		),
		
		fn getPickupFramesAsArray =
		(
			local theList = rendPickupFrames
			local theFrames = #()
			for i in filterString theList "," do 
			(
					local theArray = filterString i "-"
					if theArray.count == 2 then
					(
						theArray[1] = execute theArray[1]
						theArray[2] = execute theArray[2]
						sort theArray
						for j = theArray[1] to theArray[2] do appendIfUnique theFrames j
					)
					else
						appendIfUnique theFrames (execute i)
			)
			theFrames
		),			
		
		fn GetFrameSequenceString frameMode:#both =
		(
			case rendTimeType of
			(
				1: SMTDFunctions.GetSequenceString #(currentTime.frame as integer)
				2: (
					local currentSequence = for t in animationRange.start to animationRange.end by rendNthFrame collect (t.frame as integer)
					if frameMode == #both then 
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					else	
					(
						currentSequence = SMTDFunctions.outOfOrderSequence currentSequence mode:frameMode
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					)	
					SMTDFunctions.GetSequenceString currentSequence 
				)	
				3: (
					local currentSequence = for t in rendStart to rendEnd by rendNthFrame collect (t.frame as integer)
					if frameMode == #both then 
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					else	
					(
						currentSequence = SMTDFunctions.outOfOrderSequence currentSequence mode:frameMode
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					)	
					SMTDFunctions.GetSequenceString currentSequence 
				)	
				4: (
						rendPickupFrames
						/*
						--explicit list
						with PrintAllElements on local val = (SMTDFunctions.getPickupFramesAsArray()) as string
						val = substring val 3 (val.count-3)
						*/
				)
			)
		),		
		
		fn GetFrameSequenceArray frameMode:#both =
		(
			case rendTimeType of
			(
				1: #(currentTime.frame as integer)
				2: (
					local currentSequence = for t in animationRange.start to animationRange.end by rendNthFrame collect (t.frame as integer)
					if frameMode == #both then 
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					else	
					(
						currentSequence = SMTDFunctions.outOfOrderSequence currentSequence mode:frameMode
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					)	
					currentSequence 
				)	
				3: (
					local currentSequence = for t in rendStart to rendEnd by rendNthFrame collect (t.frame as integer)
					if frameMode == #both then 
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					else	
					(
						currentSequence = SMTDFunctions.outOfOrderSequence currentSequence mode:frameMode
						currentSequence = SMTDFunctions.outOfOrderMethod currentSequence theMethod:SMTDSettings.outOfOrderMethod
					)	
					currentSequence 
				)	
				4: (SMTDFunctions.getPickupFramesAsArray())
			)
		),			
		
		-- NOTE: includeBothOutputs is no longer used, but it's left here for legacy purposes.
		fn CreateSubmitInfoFile filename customPlugin: customOutputFile: includeBothOutputs:false frameMode:#both customFrameSequence:"" batchName:"" currentTileString:"" stereoCameraLabel:"" =
		(
			local overrideExtraInfo = false
			local oldJobName = SMTDSettings.JobName
			
			if SMTDSettings.StateSetsSubmit do
			(
				SMTDSettings.Comment = "State Set: " + SMTDSettings.StateSetName
				SMTDSettings.JobName = oldJobName + " [STATE SET '"+SMTDSettings.StateSetName+"']"
			)
			
			local formattedJobName = (SMTDFunctions.FormatJobName SMTDSettings.JobName )
			local formattedComment = (SMTDFunctions.FormatComment SMTDSettings.Comment)
			SMTDSettings.JobName = oldJobName
			
			local submitInfoFile = CreateFile filename
			if (submitInfoFile != undefined) then
			(
				if customPlugin == unsupplied then 
				(
					local pluginToUse = SMTDFunctions.getPluginToUse()
					format "Plugin=%\n" pluginToUse to:submitInfoFile
				)
				else 
				(
					format "Plugin=%\n" customPlugin to:submitInfoFile
				)
				
				if SMTDSettings.CurrentRepository != "" then  
					format "NetworkRoot=%\n" SMTDSettings.CurrentRepository  to:submitInfoFile
				else
				(
					if SMTDSettings.CurrentRepository2 != "" do
					(
						--format "TransferJobToRepository=%\n" SMTDSettings.CurrentRepository2  to:submitInfoFile
						--format "TransferJobAsSuspended=%\n" SMTDSettings.TransferJobAsSuspended to:submitInfoFile
						
						format "NotificationEmails=%\n" SMTDSettings.AlternateEmails to:submitInfoFile
						
						local notificationNote = substituteString SMTDSettings.NotificationNote "\r" ""
						notificationNote = substituteString notificationNote "\n" "[EOL]"
						format "NotificationNote=%\n" notificationNote to:submitInfoFile
					)
				)

				if SMTDSettings.SlavesList.count > 0 do
				(
					local theKeyword = if SMTDSettings.SlavesBlackList then "Blacklist" else "Whitelist"
					local theSlaveListString = ""
					for i = 1 to SMTDSettings.SlavesList.count-1 do 
						theSlaveListString += SMTDSettings.SlavesList[i] + ","
					theSlaveListString += SMTDSettings.SlavesList[SMTDSettings.SlavesList.count]
					format "%=%\n" theKeyword theSlaveListString to:submitInfoFile
				)

				local depJobIds = ""
				if SMTDSettings.SubmitAsDependent and (frameMode != #rest OR SMTDSettings.PreviewJobSecondJobDependentOnFirst == false) do
				(
					local theJobs = SMTDSettings.DependencyJobItems as array
					local currentJobsArray = case SMTDSettings.DependOnPreviousJobMode of
					(
						default: deepCopy SMTDSettings.JobsArray
						#previous: deepCopy SMTDSettings.PreviousJobsArray
						#last: 
						(
							if SMTDSettings.PreviousJobsArray.count > 0 then
								#(SMTDSettings.PreviousJobsArray[SMTDSettings.PreviousJobsArray.count])
							else
								#()
						)
					)
					for i = 1 to theJobs.count do
					(
						depJobIds += currentJobsArray[theJobs[i]][2] 
						if i < theJobs.count do depJobIds += ","
					)	
				)	
				if SMTDSettings.PreviewJobSecondJobDependentOnFirst == true AND frameMode == #rest do
				(
					depJobIds += SMTDSettings.DeadlineSubmissionLastJobID	
				)

				if rpmdata != undefined and RPMDataNet != undefined and RPMDataNet.CustomSubmitStruct != undefined do --only if RPM is active
				(
					--MODIFIED by grant
					-- first we collect the job dependencies based on our UI settings:
					-- we are getting this data again - rather then store it in the struct (as it shouldn't be stored restored) lets just grab it again as it is lightweight
					previouslysubmittedJobs = rpmdata.getcustglobstorage 10002 -- array of submitted jobs in this submission session
					doPassDependency = rpmdata.getcustglobstorage 10000
					passDependencyList = rpmdata.getcustglobstorage 10001
					if previouslysubmittedJobs == undefined do previouslysubmittedJobs = #()
					if doPassDependency == undefined do doPassDependency = False
					if passDependencyList == undefined do passDependencyList = #()
					if doPassDependency == true do
					(
						for i in 1 to previouslysubmittedJobs.count do
						(
							passIndex = rpmcaptureprops.getpassindexfromnumb previouslysubmittedJobs[i][2]
							if passDependencyList[passIndex] == true do
							(
								if depJobIds.count != 0 do depJobIds += ","
								depJobIds += previouslysubmittedJobs[i][1]
							)
						)
					)
				)
				
				if depJobIds.count > 0 do
				(
					format "JobDependencies=%\n" depJobIds  to:submitInfoFile
					format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:submitInfoFile
				)				
						
				if SMTDSettings.submitAsSuspended OR SMTDSettings.CurrentRepository2 != "" do --OR (SMTDSettings.SubmitExternalFilesMode > 1 AND SMTDSettings.SubmitExternalFilesMode < 4 )
					format "InitialStatus=Suspended\n" to:submitInfoFile	
				
				if SMTDSettings.SequentialJob do
					format "Sequential=1\n" to:submitInfoFile	
				
				if SMTDSettings.IsBakeJob and SMTDSettings.BakeJobOneObjectPerTask then
				(
					local framesSS = "" as stringStream
					for i = 1 to SMTD_objsToBake.count-1 do format "%," i to:framesSS
					format "%" SMTD_objsToBake.count to:framesSS	
					local frames = framesSS as string
					format "Frames=%\n" frames 	to:submitInfoFile
					format "ChunkSize=1\n" to:submitInfoFile					
				)
				else
				(
					local frames = SMTDFunctions.GetFrameSequenceString frameMode:frameMode
					--if SMTDSettings.TilesRendering AND SMTDSettings.TilesSubmissionMode == #deadline do frames = "1"
					if SMTDSettings.SubmitAsMXSJob AND SMTDSettings.SingleTaskJob do frames = "1"
					if SMTDSettings.UseBatchRender AND SMTDSettings.BatchRenderMode == 2 do frames = "1"
						
					if customFrameSequence != "" do frames = customFrameSequence
					
					--SINGLE FRAME TILE OR MULTI-REGION RENDERING
					if findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0 then
					(
						--if SMTDSettings.UseCustomTiles then
						--	format "Frames=%\n"			SMTDSettings.SingleTileJobFrameList			to:submitInfoFile
						--else
						--	format "Frames=0-%\n" 		(SMTDSettings.SingleTileJobTileCount-1)		to:submitInfoFile
						--format "ChunkSize=1\n"														to:submitInfoFile
						
						format "TileJob=True\n"														to:submitInfoFile
						format "TileJobFrame=%\n"		(currentTime.frame as integer)				to:submitInfoFile
						
						-- SINGLE FRAME MULTI-REGION
						if findItem #(#singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0 then
						(
							local totalRegions = 0
							for i in SMTDSettings.MultiRegionData where i[1] do totalRegions += i[6]*i[7]
							format "TileJobTilesInX=%\n"	totalRegions to:submitInfoFile
							format "TileJobTilesInY=1\n"	 											to:submitInfoFile
						)
						-- SINGLE FRAME TILE
						else
						(
							format "TileJobTilesInX=%\n"	SMTDSettings.TilesInX						to:submitInfoFile
							format "TileJobTilesInY=%\n"	SMTDSettings.TilesInY						to:submitInfoFile
						)
						
						--Only do this if rendering single frame custom tiles
						if SMTDSettings.UseCustomTiles and SMTDSettings.RegionRenderingMode == #singleFrameTiles do
							format "InitialUncompletedTaskIds=%\n"			SMTDSettings.SingleTileJobFrameList			to:submitInfoFile
					)
					else
					(
						local chunkSize = SMTDSettings.ChunkSize
					
						if SMTDSettings.DBR do
						(
							local rendererID = SMTDFunctions.getRendererIdString()
							if (rendererID == "mentalray") or (rendererID == "vray") or (rendererID == "vrayrt") do
							(
								frames = "0-" + ((SMTDSettings.DBRServers-1) as string)
								chunkSize = 1
							)
						)
					
						format "Frames=%\n" 			frames 								to:submitInfoFile
						format "ChunkSize=%\n" 		SMTDSettings.ChunkSize		to:submitInfoFile
					)
				)--end not Bake Texture
				
				--format "ReorderFrames=%\n" 			(rendTimeType == 4)			to:submitInfoFile
				format "Priority=%\n" 				SMTDSettings.Priority 	 		to:submitInfoFile
				format "Pool=%\n" 					SMTDSettings.PoolName		to:submitInfoFile
				if SMTDSettings.Pool2Name != "" do
					format "SecondaryPool=%\n" 		SMTDSettings.Pool2Name		to:submitInfoFile
				
				
				if SMTDSettings.TaskTimeoutEnabled then
					format "TaskTimeoutSeconds=%\n" 		SMTDSettings.TaskTimeout 		to:submitInfoFile
				else
					format "TaskTimeoutSeconds=0\n" 									to:submitInfoFile
				format "EnableAutoTimeout=%\n"			SMTDSettings.AutoTaskTimeout				to:submitInfoFile
				
				--format "ForceReloadPlugin=false\n" to:submitInfoFile
				format "ForceReloadPlugin=%\n"			SMTDSettings.RestartMax						to:submitInfoFile

				format "MaxTasksPerSlave=%\n" 			SMTDSettings.MaxTasksPerSlave				to:submitInfoFile
				format "LimitTasksToNumberOfCpus=%\n" 	SMTDSettings.LimitTasksToNumberOfCpus		to:submitInfoFile
				
				local theSpecialLabel = ""
				if SMTDSettings.SubmitAsMXSJob then
				(
					theSpecialLabel = " [MAXSCRIPT]"
					if SMTDSettings.IsBakeJob do 
					(
						theSpecialLabel += " [RTT "+ SMTD_objsToBake.count as string 
						theSpecialLabel += (if SMTD_objsToBake.count == 1 then " Object" else " Objects")
						if SMTDSettings.BakeJobOneObjectPerTask then theSpecialLabel += ", One Per Task]" else theSpecialLabel +="]"
					)
				)
				else
				(
					case SMTDSettings.RegionRenderingMode of
					(
						#animationMultiRegion: --if SMTDSettings.MultiRegionRendering and not SMTDSettings.SingleTileJob then
						(
								local totalRegions = 0
								for i in SMTDSettings.MultiRegionData where i[1] do totalRegions += i[6]*i[7]
								local activeRegions = (for i in SMTDSettings.MultiRegionData where i[1] collect i).count
								theSpecialLabel = " [Multi-Frame - " + activeRegions as string + " Region"+(if activeRegions == 1 then ", " else "s, ") +totalRegions as string+" Sub-Region"+(if totalRegions == 1 then "]" else "s]")
						)
						
						#singleFrameMultiRegion: --if SMTDSettings.MultiRegionRendering then
						(
							local totalRegions = 0
							for i in SMTDSettings.MultiRegionData where i[1] do totalRegions += i[6]*i[7]
							local activeRegions = (for i in SMTDSettings.MultiRegionData where i[1] collect i).count
							theSpecialLabel = " [Frame " + ((currentTime.frame as integer) as string) + " - " + activeRegions as string + " Region"+(if activeRegions == 1 then ", " else "s, ") +totalRegions as string+" Sub-Region"+(if totalRegions == 1 then "]" else "s]")
						)					
						
						#singleFrameTiles:  --if SMTDSettings.TilesRendering then
						(
							--if SMTDSettings.SingleTileJob then
							theSpecialLabel = " [Frame " + ((currentTime.frame as integer) as string) + " - " + ((SMTDSettings.TilesInX * SMTDSettings.TilesInY) as string) + " Tiles]"
						)
						
						default: --anything else
						(
							if SMTDSettings.UseBatchRender and SMTDSettings.BatchRenderMode == 2 then
								theSpecialLabel = " [BATCH MASTER]"
							else
								theSpecialLabel = case frameMode of
								(
									#both: ""
									#nth: " [PREVIEW FRAMES]" 
									#rest: " [REST OF FRAMES]" 	
								)
						)
					)--end case
				)
				
				local stereoCameraNameToken = if stereoCameraLabel == "" then "" else " ["+stereoCameraLabel+"]"
				local stereoCameraToken = if stereoCameraLabel == "" then "" else stereoCameraLabel+"_"
				
				format "Name=%%%\n" 				formattedJobName stereoCameraNameToken theSpecialLabel 	to:submitInfoFile
				format "UserName=%\n"				SMTDSettings.UserName		to:submitInfoFile
				format "Comment=%\n" 				formattedComment			to:submitInfoFile
				
				format "Department=%\n" 			SMTDSettings.Department 		to:submitInfoFile				
				format "Group=%\n" 				SMTDSettings.Group 			to:submitInfoFile				
				
				if SMTDSettings.RunPreJobScript do
					format "PreJobScript=%\n" SMTDSettings.PreJobScriptFile to:submitInfoFile
				if SMTDSettings.RunPostJobScript do
					format "PostJobScript=%\n" SMTDSettings.PostJobScriptFile to:submitInfoFile
				if SMTDSettings.RunPostTaskScript then
					format "PostTaskScript=%\n" SMTDSettings.PostTaskScriptFile to:submitInfoFile
				if SMTDSettings.RunPreTaskScript do
					format "PreTaskScript=%\n" SMTDSettings.PreTaskScriptFile to:submitInfoFile
				
				case SMTDSettings.ScheduledType of
				(
					#None: (format "ScheduledType=None\n" to:submitInfoFile	)
					#Once: 
					(
						format "ScheduledType=Once\n" to:submitInfoFile	
						format "ScheduledStartDateTime=%\n" SMTDSettings.ScheduledStartDateTime to:submitInfoFile	
					)
					#Daily: 
					(
						format "ScheduledType=Daily\n" to:submitInfoFile	
						format "ScheduledDays=%\n" SMTDSettings.ScheduledDays to:submitInfoFile	
						format "ScheduledStartDateTime=%\n" SMTDSettings.ScheduledStartDateTime to:submitInfoFile	
					)
				)

				--MONITOR RC RENDER OUTPUT DIRECTORIES & FILENAMES
				--If an output filename is specified, include it in the submit info file for accessing through the Monitor's RC Menu
				local outputFilenameIndex = 0
				local outputDirectoryIndex = 0

				local theRenderOutput = rendOutputFilename

				--MONITOR RC - "CUSTOM" OUTPUT DIRECTORIES & FILENAMES
				if customOutputFile != unsupplied then
				(
					theRenderOutput = customOutputFile

					if SMTDSettings.purifyFilenames do theRenderOutput = SMTDFunctions.purifyFilename theRenderOutput				
					if SMTDSettings.ForceLowerCaseFilenames do theRenderOutput = toLower theRenderOutput
					if SMTDSettings.SubmitSceneMode == #networkremap do theRenderOutput = ::SMTD_RemapLocalToNetworkPath theRenderOutput

					format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath theRenderOutput) to:submitInfoFile
					outputDirectoryIndex += 1

					-- Need to watch out for the special case where the output filename already ends in 4 digits.
					-- In this case, we need to strip the 4 digits before adding the "####" part.
					filenameOnly = getFilenameFile theRenderOutput
					filenameOnly = stereoCameraToken + filenameOnly
					if rendTimeType != 1 and filenameOnly.count > 4 and filenameOnly[filenameOnly.count] != "." then
					(
						try
						(
							padding = (substring filenameOnly (filenameOnly.count - 3) -1) as integer
							if padding != undefined then
								filenameOnly = substring filenameOnly 1 (filenameOnly.count - 4)
						)
						catch()
					)

					local paddingString = "####"
					if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
					(
						paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
					)

					case SMTDSettings.RegionRenderingMode of
					(
						#animationTiles:
						(
							local tempFile = ""
							local basePath = (getFilenamePath theRenderOutput)
							local baseName = (getFilenameFile theRenderOutput)
							local baseType = (getFilenameType theRenderOutput)
							tempFile = basePath +stereoCameraToken + baseName + currentTileString + SMTDSettings.Delimiter + paddingString + baseType

							format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
						)
						#animationMultiRegion:
						(
							local tempFile = ""
							local basePath = (getFilenamePath theRenderOutput)
							local baseName = (getFilenameFile theRenderOutput)
							local baseType = (getFilenameType theRenderOutput)
							tempFile = basePath + stereoCameraToken + baseName + currentTileString + SMTDSettings.Delimiter + paddingString + baseType

							format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
						)
						#singleFrameMultiRegion:
						(
							local theIndex = 0
							for aData in SMTDSettings.MultiRegionData where aData[1] == True do
							(
								for y2 = 1 to aData[7] do
								(
									for x2 = 1 to aData[6] do
									(
										local regionString = "_region_" + theIndex as string + "_"
										local tempFile = ""
										local basePath = (getFilenamePath theRenderOutput)
										local baseName = (getFilenameFile theRenderOutput)
										local baseType = (getFilenameType theRenderOutput)

										local delimiter = SMTDSettings.Delimiter
										if SMTDSettings.RemovePadding do paddingString = ""
										if paddingString == "" do delimiter = ""

										tempFile = basePath + stereoCameraToken + baseName + regionString + delimiter + paddingString + baseType

										format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
										theIndex += 1
									)
								)
							)
						)
						#singleFrameTiles:
						(
							local theIndex = 0
							for y = 1 to SMTDSettings.TilesInY do
							(
								for x = 1 to SMTDSettings.TilesInX do
								(
									local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
									local tempFile = ""
									local basePath = (getFilenamePath theRenderOutput)
									local baseName = (getFilenameFile theRenderOutput)
									local baseType = (getFilenameType theRenderOutput)

									local delimiter = SMTDSettings.Delimiter
									if SMTDSettings.RemovePadding do paddingString = ""
									if paddingString == "" do delimiter = ""

									tempFile = basePath + stereoCameraToken + baseName + tileString + delimiter + paddingString + baseType

									format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
									theIndex += 1
								)
							)
						)
						default: --anything else
						(
							local delimiter = SMTDSettings.Delimiter
							if SMTDSettings.RemovePadding do paddingString = ""
							if paddingString == "" do delimiter = ""
							format "OutputFilename%=%\n" outputFilenameIndex (filenameOnly + delimiter + paddingString + (getFilenameType theRenderOutput)) to:submitInfoFile
						)
					)
					outputFilenameIndex += 1					
				)--if not "custom" file

				--MONITOR RC - "STANDARD" RENDER OUTPUT DIRECTORIES & FILENAMES
				else 
				(
					if rendSaveFile and theRenderOutput != undefined and theRenderOutput != "" then
					(
						if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do
						(
							theRenderOutput = getFileNamePath theRenderOutput + SMTDSettings.StateSetName +"_"+(getFilenameFile theRenderOutput) + (getFilenameType theRenderOutput)
							try(SMTD_MainRollout.Ui_report (">State Set Rename Output Requested. New Output File is:"))catch()
							try(SMTD_MainRollout.Ui_report ("  ["+theRenderOutput+"]"))catch()
						)
				
						if SMTDSettings.purifyFilenames do theRenderOutput = SMTDFunctions.purifyFilename theRenderOutput				
						if SMTDSettings.ForceLowerCaseFilenames do theRenderOutput = toLower theRenderOutput
						if SMTDSettings.SubmitSceneMode == #networkremap do theRenderOutput = ::SMTD_RemapLocalToNetworkPath theRenderOutput
				
						format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath theRenderOutput) to:submitInfoFile
						outputDirectoryIndex += 1

						-- Need to watch out for the special case where the output filename already ends in 4 digits.
						-- In this case, we need to strip the 4 digits before adding the "####" part.
						filenameOnly = getFilenameFile theRenderOutput
						filenameOnly = stereoCameraToken + filenameOnly
						if rendTimeType != 1 and filenameOnly.count > 4 and filenameOnly[filenameOnly.count] != "." then
						(
							try
							(
								padding = (substring filenameOnly (filenameOnly.count - 3) -1) as integer
								if padding != undefined then
									filenameOnly = substring filenameOnly 1 (filenameOnly.count - 4)
							)
							catch()
						)
						
						local paddingString = "####"
						if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
						(
							paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
						)

						case SMTDSettings.RegionRenderingMode of
						(
							#animationTiles:
							(
								local tempFile = ""
								local basePath = (getFilenamePath theRenderOutput)
								local baseName = (getFilenameFile theRenderOutput)
								local baseType = (getFilenameType theRenderOutput)
								tempFile = basePath + stereoCameraToken+ baseName + currentTileString + SMTDSettings.Delimiter + paddingString + baseType

								format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
							)
							#animationMultiRegion:
							(
								local tempFile = ""
								local basePath = (getFilenamePath theRenderOutput)
								local baseName = (getFilenameFile theRenderOutput)
								local baseType = (getFilenameType theRenderOutput)
								tempFile = basePath + stereoCameraToken + baseName + currentTileString + SMTDSettings.Delimiter + paddingString + baseType

								format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
							)
							#singleFrameMultiRegion:
							(
								local theIndex = 0
								for aData in SMTDSettings.MultiRegionData where aData[1] == True do
								(
									for y2 = 1 to aData[7] do
									(
										for x2 = 1 to aData[6] do
										(
											local regionString = "_region_" + theIndex as string + "_"
											local tempFile = ""
											local basePath = (getFilenamePath theRenderOutput)
											local baseName = (getFilenameFile theRenderOutput)
											local baseType = (getFilenameType theRenderOutput)

											local delimiter = SMTDSettings.Delimiter
											if SMTDSettings.RemovePadding do paddingString = ""
											if paddingString == "" do delimiter = ""

											tempFile = basePath + stereoCameraToken + baseName + regionString + delimiter + paddingString + baseType

											format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
											theIndex += 1
										)
									)
								)
							)
							#singleFrameTiles:
							(
								local theIndex = 0
								for y = 1 to SMTDSettings.TilesInY do
								(
									for x = 1 to SMTDSettings.TilesInX do
									(
										local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
										local tempFile = ""
										local basePath = (getFilenamePath theRenderOutput)
										local baseName = (getFilenameFile theRenderOutput)
										local baseType = (getFilenameType theRenderOutput)

										local delimiter = SMTDSettings.Delimiter
										if SMTDSettings.RemovePadding do paddingString = ""
										if paddingString == "" do delimiter = ""

										tempFile = basePath + stereoCameraToken + baseName + tileString + delimiter + paddingString + baseType

										format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
										theIndex += 1
									)
								)
							)
							default: --anything else
							(
								local delimiter = SMTDSettings.Delimiter
								if SMTDSettings.RemovePadding do paddingString = ""
								if paddingString == "" do delimiter = ""
								format "OutputFilename%=%\n" outputFilenameIndex (filenameOnly + delimiter + paddingString + (getFilenameType theRenderOutput)) to:submitInfoFile
							)
						)
						outputFilenameIndex += 1
					)--end if save valid file
				)--if not "standard" file
				
				--Optionally add Renderer specific caching files as Deadline Monitor Output Paths
				if SMTDSettings.ExportAdvancedRenderOutputFiles do
				(
					--Show any additional mental ray paths like light maps and other caches as outputs in the Deadline Monitor for exploring
					--MENTAL RAY RENDERER PATHS
					if renderers.current.classid as string == "#(1492548972, 1338981315)" do
					(
						local theFilenameProps = #()
						
						if (isProperty renderers.current #Export_On_Render) and (getProperty renderers.current #Export_On_Render) do
							append theFilenameProps #Export_Filename
						
						if (isProperty renderers.current #FinalGatherEnable2) and (getProperty renderers.current #FinalGatherEnable2) and (isProperty renderers.current #UseFinalGatherFile) and (getProperty renderers.current #UseFinalGatherFile) then
						(
							if (isProperty renderers.current #FinalGatherFreeze) and (not getProperty renderers.current #FinalGatherFreeze) do --only if writing (not reading) fgm files
								append theFilenameProps #FinalGatherFilename
						)
						
						if ((isProperty renderers.current #GlobalIllumEnable) and (getProperty renderers.current #GlobalIllumEnable)) or ((isProperty renderers.current #CausticsEnable) and (getProperty renderers.current #CausticsEnable)) then
						(
							if (isProperty renderers.current #PhotonMapUseFile) and (getProperty renderers.current #PhotonMapUseFile) then
							(
								if (isProperty renderers.current #PhotonFreeze) and (not getProperty renderers.current #PhotonFreeze) do --only if writing (not reading) pmap (Photon/Caustics) files
									append theFilenameProps #PhotonMapFilename
							)
						)
						
						local alreadyExported = #()
						for p in theFilenameProps where (isProperty renderers.current p) do
						(
							local reFilename = getProperty renderers.current p
							if ( reFilename != undefined AND reFilename != "" ) do
							(
								if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
								if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
								if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames do setProperty renderers.current p reFilename
								if findItem alreadyExported reFilename == 0 do
								(
									if (getFilenamePath reFilename) != "" do --skip if non-rooted path
									(
										--calculate padding if required
										local paddingString = "####"
										if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
											paddingString = formattedPrint (currentTime.frame as integer) format:"04i"

										--incremental mi files
										if p == #Export_Filename AND (isProperty renderers.current #Incremental_Echo) AND (not getProperty renderers.current #Incremental_Echo) do
											reFilename = (getFilenamePath reFilename) + (getFilenameFile reFilename) + paddingString + (getFilenameType reFilename)

										--incremental fgm files
										if p == #FinalGatherFilename AND (isProperty renderers.current #IlluminationCacheMode) AND ((getProperty renderers.current #IlluminationCacheMode) > 0) do
											reFilename = (getFilenamePath reFilename) + (getFilenameFile reFilename) + paddingString + (getFilenameType reFilename)

										--incremental photon/caustics files
										if p == #PhotonMapFilename AND (isProperty renderers.current #IlluminationCacheMode) AND ((getProperty renderers.current #IlluminationCacheMode) > 0) do
											reFilename = (getFilenamePath reFilename) + (getFilenameFile reFilename) + paddingString + (getFilenameType reFilename)

										format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
										outputDirectoryIndex += 1

										format "OutputFilename%=%\n" outputFilenameIndex (filenameFromPath reFilename) to:submitInfoFile --need to get the filename only!
										outputFilenameIndex += 1

										append alreadyExported reFilename
									)
								)
							)--end if
						)--end p loop
					)--end if MENTAL RAY RENDERER PATHS

					--Show any additional corona paths like hdCache maps as outputs in the Deadline Monitor for exploring
					--CORONA RENDERER PATHS
					if renderers.current.classid as string == "#(1655201228, 1379677700)" do
					(
						
						--Check Corona version. Version's earlier than Alpha v6 are NOT supported and are no longer available from Corona Renderer website.
						coronaVersion = try(CoronaRenderer.CoronaFp.getCoronaVersion())catch(undefined)

						local theFilenameProps = #()

						if coronaVersion == undefined then --assume Corona Alpha v6 FREE VERSION / NO UPDATES / NO SUPPORT
						(
							if (isProperty renderers.current #renderer) and ((getProperty renderers.current #renderer == 0) or (getProperty renderers.current #renderer == 2)) do
							(
								if (isProperty renderers.current #GI_solver) and (getProperty renderers.current #GI_solver == 1) do
								(
									if (isProperty renderers.current #GI_secondary_solver) and (getProperty renderers.current #GI_secondary_solver == 3) do
										append theFilenameProps #Secondary_GI_filename
								)
							)
						)
						else if coronaVersion == "Alpha v7.2" then --Corona Alpha v7.2
						(
							if (isProperty renderers.current #GI_solver) and (getProperty renderers.current #GI_solver == 1) do
							(
								if (isProperty renderers.current #GI_secondary_solver) and (getProperty renderers.current #GI_secondary_solver == 3) do
								(
									if (isProperty renderers.current #HD_cache_precalculation_mode) and (getProperty renderers.current #HD_cache_precalculation_mode == 2) do
									(
										if (isProperty renderers.current #HD_cache_save) and (getProperty renderers.current #HD_cache_save) do
											append theFilenameProps #HD_cache_dump_filename
									)
								)
							)
						)
						else --Production Release of Corona v1.0 onwards
						(
							if (isProperty renderers.current #shading_secondarySolver) AND ((getProperty renderers.current #shading_secondarySolver == 3) OR (getProperty renderers.current #shading_secondarySolver == 4)) do
							(
								if ((isProperty renderers.current #gi_hdCache_precalcMode) AND (getProperty renderers.current #gi_hdCache_precalcMode == 2)) OR ((getProperty renderers.current #gi_hdCache_save) AND (getProperty renderers.current #gi_hdCache_save)) do
									append theFilenameProps #gi_hdCache_file
							)
						)

						local alreadyExported = #()
						for p in theFilenameProps where (isProperty renderers.current p) do
						(
							local reFilename = getProperty renderers.current p
							if ( reFilename != undefined and reFilename != "" ) do
							(
								if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
								if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
								if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames do setProperty renderers.current p reFilename
								if findItem alreadyExported reFilename == 0 do
								(
									if (getFilenamePath reFilename) != "" do --skip if non-rooted path
									(
										format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
										outputDirectoryIndex+=1

										format "OutputFilename%=%\n" outputFilenameIndex (filenameFromPath reFilename) to:submitInfoFile
										outputFilenameIndex += 1

										append alreadyExported reFilename
									)
								)
							)--end if
						)--end p loop
					)--end if CORONA RENDERER PATHS
					
					--Show any additional vray paths like light maps and other caches as outputs in the Deadline Monitor for exploring
					--VRAY RENDERER PATHS
					if renderers.current.classid as string == "#(1941615238, 2012806412)" do
					(
						--NON-IMAGE RENDERER FILE PROPERTIES
						local theFilenameProps = #()
						
						if (isProperty renderers.current #gi_on) and (getProperty renderers.current #gi_on) do
						(
							if ((isProperty renderers.current #gi_primary_type) and (getProperty renderers.current #gi_primary_type == 0)) do
							(
								--ignore if "From file", "Bucket mode" or "Animation (rendering)" is selected (reading instead of writing vrmap file)
								if (isProperty renderers.current #adv_irradmap_mode) and (getProperty renderers.current #adv_irradmap_mode != 2) and (getProperty renderers.current #adv_irradmap_mode != 5) and (getProperty renderers.current #adv_irradmap_mode != 7) do
								(
									if (isProperty renderers.current #adv_irradmap_autoSave) and (getProperty renderers.current #adv_irradmap_autoSave) do -- only if irr map autosave enabled
										append theFilenameProps #adv_irradmap_autoSaveFileName
								)
							)
							
							if ((isProperty renderers.current #gi_primary_type) and (getProperty renderers.current #gi_primary_type == 1)) OR ((isProperty renderers.current #gi_secondary_type) and (getProperty renderers.current #gi_secondary_type == 1)) do
							(
								if (isProperty renderers.current #photonMap_mode) and (getProperty renderers.current #photonMap_mode == 0) do --only if writing Photon map 
								(
									if (isProperty renderers.current #photonMap_autoSave) and (getProperty renderers.current #photonMap_autoSave) do --only if Photon map autosave enabled
										append theFilenameProps #photonMap_autoSaveFileName
								)
							)

							if ((isProperty renderers.current #gi_primary_type) and (getProperty renderers.current #gi_primary_type == 3)) OR ((isProperty renderers.current #gi_secondary_type) and (getProperty renderers.current #gi_secondary_type == 3)) do
							(
								if (isProperty renderers.current #lightcache_mode) and (getProperty renderers.current #lightcache_mode != 2) do --only if writing lightcache map
								(
									if (isProperty renderers.current #lightcache_autoSave) and (getProperty renderers.current #lightcache_autoSave) do --only if lightcache autosave enabled
										append theFilenameProps #lightcache_autoSaveFileName
								)
							)
						)
						
						if (isProperty renderers.current #caustics_on) and (getProperty renderers.current #caustics_on) do
						(
	 						if (isProperty renderers.current #caustics_mode) and (getProperty renderers.current #caustics_mode == 0) do --only if writing Caustics map
	 						(
								if (isProperty renderers.current #caustics_autoSave) and (getProperty renderers.current #caustics_autoSave) do --only if Caustics map autosave enabled
									append theFilenameProps #caustics_autoSaveFileName
							)
						)

						local alreadyExported = #()
						for p in theFilenameProps where (isProperty renderers.current p) do
						(
							local reFilename = getProperty renderers.current p
							if ( reFilename != undefined and reFilename != "" ) do
							(
								if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
								if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
								if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames do setProperty renderers.current p reFilename
								if findItem alreadyExported reFilename == 0 do
								(
									if (getFilenamePath reFilename) != "" do --skip if non-rooted path
									(
										--calculate padding if required
										local paddingString = "####"
										if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
											paddingString = formattedPrint (currentTime.frame as integer) format:"04i"

										--incremental vrmap files during "Animation (prepass)"
										if p == #adv_irradmap_autoSaveFileName AND (isProperty renderers.current #adv_irradmap_mode) AND (getProperty renderers.current #adv_irradmap_mode == 6) do
											reFilename = (getFilenamePath reFilename) + (getFilenameFile reFilename) + paddingString + (getFilenameType reFilename)

										format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
										outputDirectoryIndex+=1
										
										format "OutputFilename%=%\n" outputFilenameIndex (filenameFromPath reFilename) to:submitInfoFile
										outputFilenameIndex += 1
										
										append alreadyExported reFilename
									)
								)
							)--end if
						)--end p loop

						--V-RAY RAW FILE SPECIFIC CODE -- RENDERER IMAGE FILE PROPERTIES
						local theFilenameProps = #()

						if (isProperty renderers.current #output_on) and (getProperty renderers.current #output_on) do
						(
							if (isProperty renderers.current #output_saveRawFile) and (getProperty renderers.current #output_saveRawFile) do
								append theFilenameProps #output_rawFileName
						)

						local alreadyExported = #()
						for p in theFilenameProps where (isProperty renderers.current p) do
						(
							local reFilename = getProperty renderers.current p
							if ( reFilename != undefined and reFilename != "" ) do
							(
								if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
								if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
								if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames do setProperty renderers.current p reFilename
								if findItem alreadyExported reFilename == 0 do
								(
									format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
									outputDirectoryIndex+=1
									
									local theFile = ""
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*") do
										theFile = SMTDSettings.StateSetName + "_"
									theFile += getFileNameFile reFilename
									theFile = stereoCameraToken + theFile
									if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile

									--When V-Ray RAW File being saved, V-Ray will always add a "0000" to the end of the filename, so don't try to strip it!
									--If [single frame tile] or [single frame jigsaw tile] render then force frame number instead of #### padding
									paddingString = "####"
									if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
									(
										paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
									)

									case SMTDSettings.RegionRenderingMode of
									(
										#animationTiles:
										(
											local tempFile = ""
											tempFile = theFile + currentTileString + SMTDSettings.Delimiter + paddingString + (getFileNameType reFilename)
											format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
										)
										#animationMultiRegion:
										(
											local tempFile = ""
											tempFile = theFile + currentTileString + SMTDSettings.Delimiter + paddingString + (getFileNameType reFilename)
											format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
										)
										#singleFrameMultiRegion:
										(
											local theIndex = 0
											for aData in SMTDSettings.MultiRegionData where aData[1] == True do
											(
												for y2 = 1 to aData[7] do
												(
													for x2 = 1 to aData[6] do
													(
														local regionString = "_region_" + theIndex as string + "_"
														local tempFile = ""

														local delimiter = SMTDSettings.Delimiter
														if SMTDSettings.RemovePadding do delimiter = ""

														tempFile = theFile + regionString + delimiter + paddingString + (getFileNameType reFilename)
														format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
														theIndex += 1
													)
												)
											)
										)
										#singleFrameTiles:
										(
											local theIndex = 0
											for y = 1 to SMTDSettings.TilesInY do
											(
												for x = 1 to SMTDSettings.TilesInX do
												(
													local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
													local tempFile = ""

													local delimiter = SMTDSettings.Delimiter
													if SMTDSettings.RemovePadding do delimiter = ""

													tempFile = theFile + tileString + delimiter + paddingString + (getFileNameType reFilename)
													format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
													theIndex += 1
												)
											)
										)
										default: --anything else
										(										
											local delimiter = SMTDSettings.Delimiter
											if SMTDSettings.RemovePadding do delimiter = "" --do not remove paddingString as VFB will always add #### to end of RAW FileName
											format "OutputFilename%=%\n" outputFilenameIndex (theFile + delimiter + paddingString + getFileNameType reFilename) to:submitInfoFile
										)
									)

									outputFilenameIndex += 1
									append alreadyExported reFilename
								)
							)--end if
						)--end p loop (VRAY RAW FILE ONLY)
					)--end if VRAY RENDERER PATHS
				)

				-- VRAY SPECIFIC RE HANDLING CODE
				-- VRay renderer & VRay VFB ENABLED
				if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on) then
				(
					-- VRay "Separate Render Channels" is ENABLED
					if renderers.current.output_splitgbuffer do
					(
						local reFilename = renderers.current.output_splitfilename

						if ( reFilename != undefined and reFilename != "" ) do
						(
							if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
							if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
							if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames  do setProperty renderers.current #output_splitfilename reFilename
							if SMTDSettings.SubmitSceneMode == #networkremap do reFilename = ::SMTD_RemapLocalToNetworkPath reFilename

							reFilenameOnly = getFilenameFile reFilename
							reExtension = getFilenameType reFilename

							--When V-Ray Split Render Channels is used, V-Ray will always add a ".0000" to the end of the filename, so don't try to strip it!
							paddingString = "####"
							if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
							(
								paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
							)

							--splitRGB monitor output path
							if renderers.current.output_splitRGB then
							(
								format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
								outputDirectoryIndex += 1

								local theFile = ""
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (getFilenameFile reFilenameOnly) pattern:(SMTDSettings.StateSetName +"_*") do
									theFile = SMTDSettings.StateSetName + "_"
								theFile += getFileNameFile reFilenameOnly
								theFile = stereoCameraToken + theFile
								if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile

								case SMTDSettings.RegionRenderingMode of
								(
									#animationTiles:
									(
										local tempFile = ""
										tempFile = theFile + currentTileString + ".RGB_color." + paddingString + reExtension
										format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
									)
									#animationMultiRegion:
									(
										local tempFile = ""
										tempFile = theFile + currentTileString + ".RGB_color." + paddingString + reExtension
										format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
									)
									#singleFrameMultiRegion:
									(
										local theIndex = 0
										for aData in SMTDSettings.MultiRegionData where aData[1] == True do
										(
											for y2 = 1 to aData[7] do
											(
												for x2 = 1 to aData[6] do
												(
													local regionString = "_region_" + theIndex as string + "_"
													local tempFile = ""
													tempFile = theFile + regionString + ".RGB_color." + paddingString + reExtension
													format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
													theIndex += 1
												)
											)
										)
									)
									#singleFrameTiles:
									(
										local theIndex = 0
										for y = 1 to SMTDSettings.TilesInY do
										(
											for x = 1 to SMTDSettings.TilesInX do
											(
												local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
												local tempFile = ""
												tempFile = theFile + tileString + ".RGB_color." + paddingString + reExtension
												format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
												theIndex += 1
											)
										)
									)
									default: --anything else
									(
										format "OutputFilename%=%\n" outputFilenameIndex ( theFile + ".RGB_color." + paddingString + reExtension) to:submitInfoFile
									)
								)

								outputFilenameIndex += 1
							)
							
							--splitAlpha monitor output path
							if renderers.current.output_splitAlpha then
							(
								format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
								outputDirectoryIndex += 1

								local theFile = ""
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile reFilenameOnly) pattern:(SMTDSettings.StateSetName +"_*") do
									theFile = SMTDSettings.StateSetName + "_"
								theFile += getFileNameFile reFilenameOnly
								theFile = stereoCameraToken + theFile 
								if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile

								case SMTDSettings.RegionRenderingMode of
								(
									#animationTiles:
									(
										local tempFile = ""
										tempFile = theFile + currentTileString + ".Alpha." + paddingString + reExtension
										format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
									)
									#animationMultiRegion:
									(
										local tempFile = ""
										tempFile = theFile + currentTileString + ".Alpha." + paddingString + reExtension
										format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
									)
									#singleFrameMultiRegion:
									(
										local theIndex = 0
										for aData in SMTDSettings.MultiRegionData where aData[1] == True do
										(
											for y2 = 1 to aData[7] do
											(
												for x2 = 1 to aData[6] do
												(
													local regionString = "_region_" + theIndex as string + "_"
													local tempFile = ""
													tempFile = theFile + regionString + ".Alpha." + paddingString + reExtension
													format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
													theIndex += 1
												)
											)
										)
									)
									#singleFrameTiles:
									(
										local theIndex = 0
										for y = 1 to SMTDSettings.TilesInY do
										(
											for x = 1 to SMTDSettings.TilesInX do
											(
												local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
												local tempFile = ""
												tempFile = theFile + tileString + ".Alpha." + paddingString + reExtension
												format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
												theIndex += 1
											)
										)
									)
									default: --anything else
									(
										format "OutputFilename%=%\n" outputFilenameIndex (theFile + ".Alpha." + paddingString + reExtension) to:submitInfoFile
									)
								)

								outputFilenameIndex += 1
							)

							--"Separate Render Channels" RE monitor output paths
							local reManager = maxOps.GetCurRenderElementMgr()
							if reManager != undefined do
							(
								if reManager.GetElementsActive() then --only write paths if the Render Elements are globally enabled
								(
									local reCount = reManager.NumRenderElements()
									for i = 0 to reCount - 1 do
									(
										reObject = reManager.GetRenderElement i
										if classof reObject != Missing_Render_Element_Plug_in do
										(
											if hasProperty reObject "vrayVFB" and reObject.vrayVFB do
											(
												reFilenameOnly = getFilenameFile reFilename
												reExtension = getFilenameType reFilename
								
												--When V-Ray Split Render Channels is used, V-Ray will always add a ".0000" to the end of the filename, so don't try to strip it!
												paddingString = "####"
												if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
												(
													paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
												)

												format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
												outputDirectoryIndex += 1

												local theFile = ""
												if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile reFilenameOnly) pattern:(SMTDSettings.StateSetName +"_*") do
													theFile = SMTDSettings.StateSetName + "_"
												theFile += getFileNameFile reFilenameOnly
												theFile = stereoCameraToken + theFile
												if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile

												case SMTDSettings.RegionRenderingMode of
												(
													#animationTiles:
													(
														local tempFile = ""
														tempFile = theFile + currentTileString + SMTDSettings.Delimiter + reObject.elementName + SMTDSettings.Delimiter + paddingString + reExtension
														format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
													)
													#animationMultiRegion:
													(
														local tempFile = ""
														tempFile = theFile + currentTileString + SMTDSettings.Delimiter + reObject.elementName + SMTDSettings.Delimiter + paddingString + reExtension
														format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
													)
													#singleFrameMultiRegion:
													(
														local theIndex = 0
														for aData in SMTDSettings.MultiRegionData where aData[1] == True do
														(
															for y2 = 1 to aData[7] do
															(
																for x2 = 1 to aData[6] do
																(
																	local regionString = "_region_" + theIndex as string + "_"
																	local tempFile = ""
																	tempFile = theFile + regionString + SMTDSettings.Delimiter + reObject.elementName + SMTDSettings.Delimiter + paddingString + reExtension
																	format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
																	theIndex += 1
																)
															)
														)
													)
													#singleFrameTiles:
													(
														local theIndex = 0
														for y = 1 to SMTDSettings.TilesInY do
														(
															for x = 1 to SMTDSettings.TilesInX do
															(
																local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
																local tempFile = ""
																tempFile = theFile + tileString + SMTDSettings.Delimiter + reObject.elementName + SMTDSettings.Delimiter + paddingString + reExtension
																format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
																theIndex += 1
															)
														)
													)
													default: --anything else
													(
														format "OutputFilename%=%\n" outputFilenameIndex (theFile + SMTDSettings.Delimiter + reObject.elementName + SMTDSettings.Delimiter + paddingString + reExtension) to:submitInfoFile
													)
												)

												outputFilenameIndex += 1
											)--end if enabled
										)--end if not missing RE
									)--end i loop
								)--end if REs active
							)--end if reManager undefined
						)--end if reFilename
					)--end if splitgbuffer

				)--end if not vray
				else
				(
					elementsToSkip = #()
					
					-- if this is 3dsmax 2011 or later, check to see if we're rendering to the new adsk exr format
					if ((maxVersion())[1]/1000 as integer) >= 13 do
					(
						if rendSaveFile and rendOutputFilename != undefined do
						(
							rend_type = getFileNameType rendOutputFilename
							is_exr = matchPattern rend_type pattern:".exr" ignoreCase:true
							is_fxr = matchPattern rend_type pattern:".fxr" ignoreCase:true
							
							-- If we are, we need to tell Deadline which render elements are to be embedded in the exr file so that it doesn't save them separately
							if (is_exr or is_fxr) and (fopenexr != undefined) do
							(
								if fopenexr.isAutoAddRenderElements() then
								(
									--The elements are being added automatically, so check the re manager.
									local reManager = maxOps.GetCurRenderElementMgr()
									if reManager != undefined do
									(
										if reManager.GetElementsActive() then 
										(
											local reCount = reManager.NumRenderElements()
											for i = 0 to reCount - 1 do
											(
												local theElement = reManager.GetRenderElement i
												if classof theElement != Missing_Render_Element_Plug_in do	
													if theElement.enabled do
														append elementsToSkip theElement.elementName
											)
										)
									)--end if reManager undefined
								)
								else
								(
									--The elements are manually specified, so check the layers in the exr itself
									for i = 0 to fopenexr.numLayers() do
									(
										if (fopenexr.getLayerType i) == 1 then
											append elementsToSkip (fopenexr.getLayerName i)
									)
								)
							)
						)
					)
					
					-- generic loop to dump all RE's to OutputFilename# if applicable
					local reManager = maxOps.GetCurRenderElementMgr()
					if reManager != undefined do
					(
						if reManager.GetElementsActive() then --only write paths if the Render Elements are globally enabled
						(
							local reCount = reManager.NumRenderElements()
							for i = 0 to reCount - 1 do
							(
								reObject = reManager.GetRenderElement i
								if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
								(
									if (findItem elementsToSkip reObject.elementName) == 0 do
									(
										local reFilename = reManager.GetRenderElementFilename i

										if ( reFilename != undefined and reFilename != "" ) do
										(
											if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename
											if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
											if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames  do reManager.SetRenderElementFilename i reFilename
											if SMTDSettings.SubmitSceneMode == #networkremap do reFilename = ::SMTD_RemapLocalToNetworkPath reFilename

											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*") do
											(
												reFilename = getFileNamePath reFilename + SMTDSettings.StateSetName +"_"+(getFilenameFile reFilename) + (getFilenameType reFilename)
											)

											format "OutputDirectory%=%\n" outputDirectoryIndex (getFilenamePath reFilename) to:submitInfoFile
											outputDirectoryIndex+=1 

											reFilenameOnly = (getFilenameFile reFilename)
											reFilenameOnly = stereoCameraToken + reFilenameOnly
											if rendTimeType != 1 and reFilenameOnly.count > 4 and reFilenameOnly[reFilenameOnly.count] != "."  then
											(
												try
												(
													padding = (substring reFilenameOnly (reFilenameOnly.count - 3) -1) as integer
													if padding != undefined then
														reFilenameOnly = substring reFilenameOnly 1 (reFilenameOnly.count - 4)
												)
												catch()
											)
											
											local paddingString = "####"
											if rendTimeType == 1 OR (findItem #(#singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do
											(
												paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
											)
											
											case SMTDSettings.RegionRenderingMode of
											(
												#animationTiles:
												(
													local tempFile = ""
													tempFile = (reFilenameOnly + currentTileString + SMTDSettings.Delimiter + paddingString + (getFilenameType reFilename))
													format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
												)
												#animationMultiRegion:
												(
													local tempFile = ""
													tempFile = (reFilenameOnly + currentTileString + SMTDSettings.Delimiter + paddingString + (getFilenameType reFilename))
													format "OutputFilename%=%\n" outputFilenameIndex tempFile to:submitInfoFile
												)
												#singleFrameMultiRegion:
												(
													local theIndex = 0
													for aData in SMTDSettings.MultiRegionData where aData[1] == True do
													(
														for y2 = 1 to aData[7] do
														(
															for x2 = 1 to aData[6] do
															(
																local regionString = "_region_" + theIndex as string + "_"
																local tempFile = ""

																local delimiter = SMTDSettings.Delimiter
																if SMTDSettings.RemovePadding do paddingString = ""
																if paddingString == "" do delimiter = ""

																tempFile = (reFilenameOnly + regionString + delimiter + paddingString + (getFilenameType reFilename))
																format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
																theIndex += 1
															)
														)
													)
												)
												#singleFrameTiles:
												(
													local theIndex = 0
													for y = 1 to SMTDSettings.TilesInY do
													(
														for x = 1 to SMTDSettings.TilesInX do
														(
															local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
															local tempFile = ""

															local delimiter = SMTDSettings.Delimiter
															if SMTDSettings.RemovePadding do paddingString = ""
															if paddingString == "" do delimiter = ""

															tempFile = (reFilenameOnly + tileString + delimiter + paddingString + (getFilenameType reFilename))
															format "OutputFilename%Tile%=%\n" outputFilenameIndex theIndex tempFile to:submitInfoFile
															theIndex += 1
														)
													)
												)
												default: --anything else
												(
													delimiter = SMTDSettings.Delimiter
													if SMTDSettings.RemovePadding do paddingString = ""
													if paddingString == "" do delimiter = ""
													format "OutputFilename%=%\n" outputFilenameIndex (reFilenameOnly + delimiter + paddingString + (getFilenameType reFilename)) to:submitInfoFile

												)
											)
											outputFilenameIndex += 1
										)
									)
								)--end if enabled	
							)--end i loop
						)--end if REs active
					)--end if reManager undefined
				)-- end else loop

				local rendererClassString = (classOf renderers.current) as string --get the class of the current renderer as string
				local limitGroups = ""	--initialize Limits to empty string
				local limitGroupsToUseArray = for i in SMTDSettings.LimitGroupsToUse collect i

				--if the renderer is mental ray and Max is a version below 8, or if the workstation mode is forced, add the limit group for the current plugin
				if SMTDSettings.LimitGroupAutoWorkstation == true do
				(
					if SMTDSettings.forceWorkstationMode OR SMTDSettings.SubmitAsMXSJob do  
						append limitGroupsToUseArray (pluginToUse + (SMTDFunctions.getMaxVersion()) + "Workstation")
				)

				--if the renderer is X, add the X limit group to the string
				local rendID = SMTDFunctions.getRendererIdString()
				if SMTDSettings.LimitGroupAutoBrazil==true AND (rendID == "brazil" OR rendID == "brmax") AND findItem limitGroupsToUseArray "Brazil" == 0 do  append limitGroupsToUseArray "Brazil"
				if SMTDSettings.LimitGroupAutoVray==true AND (rendID == "vray")  AND findItem limitGroupsToUseArray "VRay" == 0 do append limitGroupsToUseArray "VRay"
				if SMTDSettings.LimitGroupAutoCorona==true AND (rendID == "corona") AND findItem limitGroupsToUseArray "Corona" == 0 do append limitGroupsToUseArray "Corona"
				if SMTDSettings.LimitGroupAutoKrakatoa==true AND rendID == "krakatoa" AND findItem limitGroupsToUseArray "Krakatoa" == 0 do  append limitGroupsToUseArray "Krakatoa"				
				if SMTDSettings.LimitGroupAutoFinalRender==true AND rendID == "finalrender" AND findItem limitGroupsToUseArray "FinalRender" == 0 do  append limitGroupsToUseArray "FinalRender"				
				if SMTDSettings.LimitGroupAutoMaxwell==true AND rendID == "maxwell" AND findItem limitGroupsToUseArray "maxwell" == 0 do  append limitGroupsToUseArray "Maxwell"

				for i = 1 to limitGroupsToUseArray.count do
				(
					limitGroups += limitGroupsToUseArray [i] 
					if i < limitGroupsToUseArray.count do limitGroups += ","
				)	

				--if any Limits have been collected, output them						
				if limitGroups != "" do format "LimitGroups=%\n" limitGroups to:submitInfoFile

				--if limit is requested, set it, otherwise output 0 (no limit)
				if SMTDSettings.limitEnabled then
					format "MachineLimit=%\n" SMTDSettings.machineLimit to:submitInfoFile
				else	
					format "MachineLimit=0\n" to:submitInfoFile

				--format "DeleteOnComplete=%\n" SMTDSettings.autoDelete to:submitInfoFile
				format "OnJobComplete=%\n" SMTDSettings.OnComplete to:submitInfoFile

				format "Interruptible=%\n" SMTDSettings.JobIsInterruptible to:submitInfoFile

				if SMTDSettings.CopyVbscriptFile do
					--format "PostJobScript=c:/deadline/slave/jobsData/copyImsq.vbs\n" to:submitInfoFile
					format "PostJobScript=copyImsq.py\n" to:submitInfoFile

				format "OverrideJobFailureDetection=%\n"  SMTDSettings.OverrideJobFailureDetection to:submitInfoFile	
				format "FailureDetectionJobErrors=%\n" SMTDSettings.FailureDetectionJobErrors to:submitInfoFile  
				format "OverrideTaskFailureDetection=%\n"SMTDSettings.OverrideTaskFailureDetection to:submitInfoFile  
				format "FailureDetectionTaskErrors=%\n" SMTDSettings.FailureDetectionTaskErrors to:submitInfoFile  
				format "SendJobErrorWarning=%\n" SMTDSettings.SendJobErrorWarning  to:submitInfoFile 

				local kvpIndex = 0
				if ( SMTDSettings.ProjectManagement == "Shotgun" and SMTDSettings.SGUpdate ) then
				(
					-- If using shotgun, then override the extra info properties
					overrideExtraInfo = true
					
					for line in SMTDSettings.SGJobSettings do
					(
						if (findString line "=") != undefined then
						(
							format "ExtraInfoKeyValue%=%\n" kvpIndex line to:submitInfoFile
							kvpIndex += 1
						)
					)
					
					format "ExtraInfo0=%\n" SMTDSettings.SGTask to:submitInfoFile
					format "ExtraInfo1=%\n" SMTDSettings.SGProject to:submitInfoFile
					format "ExtraInfo2=%\n" SMTDSettings.SGEntity to:submitInfoFile
					format "ExtraInfo3=%\n" SMTDSettings.SGVersion to:submitInfoFile
					format "ExtraInfo4=%\n" SMTDSettings.SGDescription to:submitInfoFile
					format "ExtraInfo5=%\n" SMTDSettings.SGUser to:submitInfoFile
					
					local groupBatch = false
					if SMTDSettings.SGCreateMovie then
					(
						format "ExtraInfoKeyValue%=Draft_CreateSGMovie=True\n" kvpIndex to:submitInfoFile
						kvpIndex += 1
						groupBatch = True
					)
					
					if SMTDSettings.SGCreateFilmStrip then
					(
						format "ExtraInfoKeyValue%=Draft_CreateSGFilmstrip=True\n" kvpIndex to:submitInfoFile
						kvpIndex += 1
						groupBatch = True
					)
					if groupBatch and batchName == "" then
					(
						batchName = formattedJobName
					)
				)
				else if ( SMTDSettings.ProjectManagement == "FTrack" and SMTDSettings.FTUpdate ) then
				(
					overrideExtraInfo = true

					for line in SMTDSettings.FTJobSettings do
					(
						if (findstring line "=") != undefined then
						(
							format "ExtraInfoKeyValue%=%\n" kvpIndex line to:submitInfoFile
							kvpIndex += 1
						)
					)

					format "ExtraInfo0=%\n" SMTDSettings.FTTask to:submitInfoFile
					format "ExtraInfo1=%\n" SMTDSettings.FTProject to:submitInfoFile
					format "ExtraInfo2=%\n" SMTDSettings.FTAsset to:submitInfoFile
					format "ExtraInfo4=%\n" SMTDSettings.FTDescription to:submitInfoFile
					format "ExtraInfo5=%\n" SMTDSettings.FTUser to:submitInfoFile
					
					local groupBatch = false
					if SMTDSettings.SGCreateMovie then
					(
						format "ExtraInfoKeyValue%=Draft_CreateFTMovie=True\n" kvpIndex to:submitInfoFile
						kvpIndex += 1
						groupBatch = True
					)
					if groupBatch and batchName == "" then
					(
						batchName = formattedJobName
					)
				)
				
				if ( SMTDSettings.DraftSubmitJob ) then
				(
					if (SMTDSettings.DraftQuick) then
					(
						format "ExtraInfoKeyValue%=SubmitQuickDraft=True\n" kvpIndex to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftExtension=%\n" kvpIndex SMTDSettings.DraftFormatsDict.Item[SMTDSettings.DraftFormat][1] to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftType=%\n" kvpIndex SMTDSettings.DraftFormatsDict.Item[SMTDSettings.DraftFormat][2] to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftResolution=%\n" kvpIndex SMTDSettings.DraftResolutionsDict.Item[SMTDSettings.DraftResolution] to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftCodec=%\n" kvpIndex SMTDSettings.DraftCodec to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftQuality=%\n" kvpIndex SMTDSettings.DraftQuality to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftFrameRate=%\n" kvpIndex SMTDSettings.DraftFrameRate to:submitInfoFile
						kvpIndex += 1
					)
					else
					(
						format "ExtraInfoKeyValue%=DraftTemplate=%\n" kvpIndex SMTDSettings.DraftTemplate to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftUsername=%\n" kvpIndex SMTDSettings.DraftUser to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftEntity=%\n" kvpIndex SMTDSettings.DraftEntity to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftVersion=%\n" kvpIndex SMTDSettings.DraftVersion to:submitInfoFile
						kvpIndex += 1
						renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)
						format "ExtraInfoKeyValue%=DraftFrameWidth=%\n" kvpIndex renderDimensions[1] to:submitInfoFile
						kvpIndex += 1
						format "ExtraInfoKeyValue%=DraftFrameHeight=%\n" kvpIndex renderDimensions[2] to:submitInfoFile
						kvpIndex += 1
					)
					if ( SMTDSettings.DraftShotgunUpload ) then
						format "ExtraInfoKeyValue%=DraftUploadToShotgun=True\n" kvpIndex to:submitInfoFile
					else
						format "ExtraInfoKeyValue%=DraftUploadToShotgun=False\n" kvpIndex to:submitInfoFile
					kvpIndex += 1
					
					format "ExtraInfoKeyValue%=DraftExtraArgs=%\n" kvpIndex SMTDSettings.DraftExtraArgs to:submitInfoFile
					kvpIndex += 1
					
				)
				
				if (not overrideExtraInfo) then
				(					
					local formattedExtraInfo0 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo0)
					local formattedExtraInfo1 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo1)
					local formattedExtraInfo2 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo2)
					local formattedExtraInfo3 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo3)
					local formattedExtraInfo4 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo4)
					local formattedExtraInfo5 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo5)

					format "ExtraInfo0=%\n" formattedExtraInfo0 to:submitInfoFile
					format "ExtraInfo1=%\n" formattedExtraInfo1 to:submitInfoFile
					format "ExtraInfo2=%\n" formattedExtraInfo2 to:submitInfoFile
					format "ExtraInfo3=%\n" formattedExtraInfo3 to:submitInfoFile
					format "ExtraInfo4=%\n" formattedExtraInfo4 to:submitInfoFile
					format "ExtraInfo5=%\n" formattedExtraInfo5 to:submitInfoFile
				)
				local formattedExtraInfo6 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo6)
				local formattedExtraInfo7 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo7)
				local formattedExtraInfo8 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo8)
				local formattedExtraInfo9 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo9)

				format "ExtraInfo6=%\n" formattedExtraInfo6 to:submitInfoFile
				format "ExtraInfo7=%\n" formattedExtraInfo7 to:submitInfoFile
				format "ExtraInfo8=%\n" formattedExtraInfo8 to:submitInfoFile
				format "ExtraInfo9=%\n" formattedExtraInfo9 to:submitInfoFile				

				--ExtraInfoKeyValues
				for kvi in SMTDSettings.ExtraInfoKeyValues do
				(
					try
					(
						format "ExtraInfoKeyValue%=%=%\n" kvpIndex kvi[1] kvi[2] to:submitInfoFile		
						kvpIndex += 1
					)catch()
				)

				--EnvironmentKeyValues
				local kvpIndex = 0
				for kvi in SMTDSettings.EnvironmentKeyValues do
				(
					try
					(
						format "EnvironmentKeyValue%=%=%\n" kvpIndex kvi[1] kvi[2] to:submitInfoFile
						kvpIndex += 1
					)catch()
				)
				format "IncludeEnvironment=%\n" SMTDSettings.IncludeEnvironment to:submitInfoFile
				format "UseJobEnvironmentOnly=%\n" SMTDSettings.UseJobEnvironmentOnly to:submitInfoFile

				format "BatchName=%\n" batchName to:submitInfoFile
				
				close submitInfoFile
				true
			)
			else
				false
		),

		
		fn getDelimiterToken =
		(
			--Decide once on delimiters and stereo labels, then reuse for all filenames below
			local delimiter = SMTDSettings.Delimiter
			if SMTDSettings.RemovePadding AND (findItem #(#none, #maxRegion, #singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do delimiter = ""
			delimiter 
		),
		
		fn getRendOutputFilename renderOutputOverride:"" tileString:"" forceCamera:"" stereoCameraLabel:"" =
		(
			local delimiter = SMTDFunctions.getDelimiterToken()
			local stereoCameraToken = if stereoCameraLabel == "" then "" else stereoCameraLabel+"_"
			if matchPattern (getFileNameFile renderOutputOverride) pattern:(stereoCameraToken+"*") do stereoCameraToken = ""
		
			local filenameToRender = rendOutputFilename
			if renderOutputOverride != "" do filenameToRender = renderOutputOverride

			--If main 3dsmax render output is undefined or empty, then skip
			if filenameToRender != undefined and filenameToRender != "" then
			(
				if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do
				(
					filenameToRender = getFileNamePath filenameToRender + SMTDSettings.StateSetName +"_"+(getFilenameFile filenameToRender) + (getFilenameType filenameToRender)
					try(SMTD_MainRollout.Ui_report (">State Set Rename Output Requested. New Output File is:"))catch()
					try(SMTD_MainRollout.Ui_report ("  ["+filenameToRender+"]"))catch()
				)				
				
				filenameToRender = getFileNamePath filenameToRender + stereoCameraToken  + filenameFromPath filenameToRender
				if SMTDSettings.purifyFilenames do filenameToRender = SMTDFunctions.purifyFilename filenameToRender				
				if SMTDSettings.ForceLowerCaseFilenames do filenameToRender = toLower filenameToRender
				if SMTDSettings.SubmitSceneMode == #networkremap do filenameToRender = ::SMTD_RemapLocalToNetworkPath filenameToRender
				
				((getFileNamePath filenameToRender) + (getFileNameFile filenameToRender) + delimiter + (getFilenameType filenameToRender))
			)
			else
				""
		),		
		
		--THIS IS NOW CALLED PLUGIN INFO FILE!
		fn CreateJobInfoFile filename renderOutputOverride:"" tileString:"" forceCamera:"" stereoCameraLabel:"" =
		(
			local JobInfoFile = CreateFile filename
			if (JobInfoFile != undefined) then
			(
				local maxVersionToUse = SMTDFunctions.getMaxVersion()
				format "Version=%\n" maxVersionToUse to:JobInfoFile
				
				try
				(
					local VersionInfo = dotnetclass "System.Diagnostics.FileVersionInfo"
					local MyMax = VersionInfo.GetVersionInfo (pathConfig.appendPath (pathConfig.GetDir #maxroot) "3dsmax.exe")
					format "SubmittedFromVersion=%\n" MyMax.FileVersion to:JobInfoFile	
				)catch()
				
				-- Design edition retired in Max 2016.
				if( SMTDFunctions.getMaxVersionAsInteger() >= 2010 and SMTDFunctions.getMaxVersionAsInteger() < 2016 ) then
					if( maxOps.productID == #3dsMaxDesign ) then
						format "IsMaxDesign=1\n" to:JobInfoFile
					else
						format "IsMaxDesign=0\n" to:JobInfoFile
				else
					format "IsMaxDesign=0\n" to:JobInfoFile
				
				case SMTDSettings.SubmitSceneMode of
				(
					default: ()
					#networksave:
					(
						format "SceneFile=%\n" (SMTDSettings.SubmitSceneNetworkLocation) to:JobInfoFile
					)
					#globalnetworksave:
					(
						format "SceneFile=%\n" (SMTDSettings.SubmitSceneNetworkLocation) to:JobInfoFile
					)
					#networkuse:
					(
						format "SceneFile=%\n" (maxFilePath + maxFileName) to:JobInfoFile
					)
					#networksaveanduse:
					(
						format "SceneFile=%\n" (maxFilePath + maxFileName) to:JobInfoFile
					)
					#networkremap:
					(
						local theCurrentPath = (maxFilePath + maxFileName)
						global SMTD_RemapLocalToNetworkPath
						fn SMTD_RemapLocalToNetworkPath thepath = (thepath)
						local theScriptFile = (SMTDPaths.NetworkRoot + "\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_RemapLocalToNetworkPath.ms"  )
						if doesFileExist theScriptFile do try(fileIn theScriptFile)catch()
						theCurrentPath = ::SMTD_RemapLocalToNetworkPath theCurrentPath
						format "SceneFile=%\n" theCurrentPath to:JobInfoFile
					)					
				)

				--Store Current Scene Selection
				local theSelectionArray = for o in selection collect o.inode.handle
				with PrintAllElements on format "SceneSelection=%\n" theSelectionArray to:JobInfoFile

				format "Padding=%\n" 4 to:JobInfoFile
				format "RemovePadding=%\n" (if SMTDSettings.RemovePadding and rendTimeType == 1 then 1 else 0) to:JobInfoFile
				
				format "IgnoreMissingExternalFiles=%\n" (if SMTDSettings.IgnoreMissingExternalFiles then 1 else 0) to:JobInfoFile
				format "IgnoreMissingUVWs=%\n" (if SMTDSettings.IgnoreMissingUVWs then 1 else 0) to:JobInfoFile
				format "IgnoreMissingDLLs=%\n" (if SMTDSettings.IgnoreMissingDLLs then 1 else 0) to:JobInfoFile
				format "IgnoreMissingXREFs=%\n" (if SMTDSettings.IgnoreMissingXREFs then 1 else 0) to:JobInfoFile
				format "DisableMultipass=%\n" (if SMTDSettings.DisableMultipass then 1 else 0) to:JobInfoFile
				format "LocalRendering=%\n" (if SMTDSettings.LocalRendering then 1 else 0) to:JobInfoFile
				format "OneCpuPerTask=%\n" (if SMTDSettings.OneCpuPerTask then 1 else 0) to:JobInfoFile
				format "DumpFileProperties=%\n" (if SMTDSettings.DumpFileProperties then true else false) to:JobInfoFile

				if SMTDFunctions.getMaxVersionAsInteger() >= 2013 then
				(
					if SMTDSettings.OverrideLanguage then
					(
						local theIndex = SMTDSettings.Language
						if theIndex == 0 do
						(
							local languageInfo = sysinfo.GetMaxLanguage()
							local languageCode = languageInfo[3] 
							theIndex = findItem SMTDSettings.LanguageCodeArray languageCode
						)
					
						if theIndex > 0 then
							format "Language=%\n" SMTDSettings.LanguageCodeArray[theIndex] to:JobInfoFile
						else
							format "Language=Default\n" to:JobInfoFile
					)
					else
						format "Language=Default\n" to:JobInfoFile
				)
				
				local rendererClassString = (classOf renderers.current) as string --get the class of the current renderer as string
				if SMTDSettings.forceWorkstationMode OR (SMTDSettings.UseBatchRender AND SMTDSettings.BatchRenderMode == 2) then
				(
					format "UseSlaveMode=0\n" to:JobInfoFile
					if SMTDSettings.UseSilentMode then
						format "UseSilentMode=1\n" to:JobInfoFile
					else
						format "UseSilentMode=0\n" to:JobInfoFile
				)
				else
				(
					format "UseSlaveMode=1\n" to:JobInfoFile
					format "UseSilentMode=0\n" to:JobInfoFile
				)
				
				if SMTDSettings.PopupHandling then
					format "PopupHandling=1\n" to:JobInfoFile
				else
					format "PopupHandling=0\n" to:JobInfoFile
				
				if SMTDSettings.UsePathConfigFile then
				(
					if SMTDSettings.SubmitSceneMode == #reposave then
					(
						format "PathConfigFile=%\n" (FileNameFromPath SMTDSettings.PathConfigFile) to:JobInfoFile
					)
					else
						format "PathConfigFile=%\n" SMTDSettings.PathConfigFile to:JobInfoFile

					if SMTDSettings.MergePathConfigFile then
						format "MergePathConfigFile=1\n" to:JobInfoFile
					else
						format "MergePathConfigFile=0\n" to:JobInfoFile
				)
				
				if SMTDSettings.IncludeLocalPaths then
				(
					format "IncludeLocalPaths=1\n" to:JobInfoFile
					local pathCount = pathConfig.mapPaths.count()
					format "LocalMapPathsCount=%\n" pathCount to:JobInfoFile
					for j = 1 to pathCount do 
						format "LocalMapPath%=%\n" j (pathConfig.mapPaths.get j) to:JobInfoFile
				)
				else
					format "IncludeLocalPaths=0\n" to:JobInfoFile
				
				
				if SMTDSettings.StateSetsSubmit and SMTDSettings.SubmitSceneMode != #reposave then
				(
					format "RenderStateSet=1\n" to:JobInfoFile
					format "StateSetToRender=%\n" SMTDSettings.StateSetToRender to:JobInfoFile
				)
				else
					format "RenderStateSet=0\n" to:JobInfoFile			

				if rendTimeType == 2 or rendTimeType == 3 then
					format "FrameNumberBase=%\n" rendFileNumberBase to:JobInfoFile
				
				format "RestartRendererMode=%\n" ( if SMTDSettings.RestartRenderer then 1 else 0 ) to:JobInfoFile
				format "DisableProgressUpdateTimeout=%\n" ( if SMTDSettings.DisableProgressUpdateTimeout then 1 else 0 ) to:JobInfoFile
				format "SkipRender=%\n" ( if SMTDSettings.SkipRender then 1 else 0 ) to:JobInfoFile

				if SMTDSettings.MaxTasksPerSlave > 1 then 
				(
					format "OverrideFailOnExistingMaxProcess=true\n" to:JobInfoFile
					format "FailOnExistingMaxProcess=false\n" to:JobInfoFile
				)
				else
				(
					format "OverrideFailOnExistingMaxProcess=%\n" SMTDSettings.OverrideFailOnExistingMaxProcess to:JobInfoFile
					format "FailOnExistingMaxProcess=%\n" SMTDSettings.FailOnExistingMaxProcess to:JobInfoFile				
				)				
				  
				if SMTDSettings.IsBakeJob then
				(
					bakeString = "BakeObjs="
					
					for o in SMTD_objsToBake do 
						bakeString += o.name + ","
					
					bakeString[bakestring.count] = "\n"
					
					format bakeString to:JobInfoFile
					
					if SMTDSettings.BakeJobOneObjectPerTask == true then
						format "BakeObjsOnePerTask=true\n" to:JobInfoFile
					else
						format "BakeObjsOnePerTask=false\n" to:JobInfoFile
				)
				
				if SMTDSettings.DBR then
				(
					local rendererID = SMTDFunctions.getRendererIdString()
					if (rendererID == "mentalray") do
						format "MentalRayDBRJob=true\n" to:JobInfoFile
					if (rendererID == "vray") do
						format "VRayDBRJob=true\n" to:JobInfoFile
					if (rendererID == "vrayrt") do
						format "VRayRtDBRJob=true\n" to:JobInfoFile
						
					local dbrFrame = SMTDFunctions.GetSequenceString #(currentTime.frame as integer)
					format "DBRJobFrame=%\n" dbrFrame to:JobInfoFile
				)
				
				local theCam = viewport.getCamera() --get viewport camera
				if forceCamera == "" then --no forced camera
				(
					if isValidNode theCam then --if it is valid, output it
						format "Camera=%\n" (theCam.name) to:JobInfoFile
					else					
						format "Camera=\n" to:JobInfoFile --if viewport is not a camera, output no camera.
				)	
				else	
					format "Camera=%\n" forceCamera to:JobInfoFile --if camera was supplied, force output to it.
				
				format "Camera0=\n" to:JobInfoFile

				--Write out all cameras found in the current scene:								
				local theCameras = for c in objects where findItem Camera.classes (classof c) > 0 collect c
				for c = 1 to theCameras.count do
					format "Camera%=%\n" c theCameras[c].name to:JobInfoFile
				--If the current view is not a camera (it could be a light for example), make sure it is added to the list, otherwise the list would be invalid
				if isValidNode theCam AND findItem theCameras theCam == 0 do
					format "Camera%=%\n" (theCameras.count+1) theCam.name to:JobInfoFile
				
				if SMTDSettings.RunPreLoadScript do
					format "PreLoadScript=%\n" (FileNameFromPath SMTDSettings.PreLoadScriptFile) to:JobInfoFile
				if SMTDSettings.RunPostLoadScript do
					format "PostLoadScript=%\n" (FileNameFromPath SMTDSettings.PostLoadScriptFile) to:JobInfoFile
				if SMTDSettings.RunPostFrameScript then
					format "PostFrameScript=%\n" (FileNameFromPath SMTDSettings.PostFrameScriptFile) to:JobInfoFile
				if SMTDSettings.RunPreFrameScript do
					format "PreFrameScript=%\n" (FileNameFromPath SMTDSettings.PreFrameScriptFile) to:JobInfoFile
				
				format "MaxVersionToForce=%\n" SMTDSettings.MaxVersionToForce to:JobInfoFile
				format "MaxVersionToForce0=none\n" to:JobInfoFile
				format "MaxVersionToForce1=32bit\n" to:JobInfoFile
				format "MaxVersionToForce2=64bit\n" to:JobInfoFile
				
				if SMTDSettings.UseJpegOutput do
				(
					format "UseJpegOutput=1\n" to:JobInfoFile
					format "JpegOutputPath=%\n" SMTDSettings.JpegOutputPath to:JobInfoFile
				)
				
				if SMTDSettings.UseAltPluginIni and SMTDSettings.AltPluginIni != "" and SMTDSettings.AltPluginIni != "[Default]" do
					format "OverridePluginIni=%.ini\n" SMTDSettings.AltPluginIni to:JobInfoFile
				
				if SMTDSettings.enableFailOnBlackFrames then
					format "FailOnBlackFrames=1\n" to:JobInfoFile
				else
					format "FailOnBlackFrames=0\n" to:JobInfoFile
				format "BlackPixelPercentage=%\n" SMTDSettings.blackPixelPercentage to:JobInfoFile
				format "BlackPixelThreshold=%\n" SMTDSettings.blackPixelThreshold to:JobInfoFile
				if SMTDSettings.BlackFramesCheckRenderElements then
					format "BlackFramesCheckRenderElements=1\n" to:JobInfoFile
				else
					format "BlackFramesCheckRenderElements=0\n" to:JobInfoFile
				
				if SMTDSettings.GammaCorrection then
					format "GammaCorrection=1\n" to:JobInfoFile
				else
					format "GammaCorrection=0\n" to:JobInfoFile
				format "GammaInput=%\n" SMTDSettings.GammaInput to:JobInfoFile
				format "GammaOutput=%\n" SMTDSettings.GammaOutput to:JobInfoFile
				
				-- if output file is empty, check if rendering with vray and saving a raw image, and ignore render elements if so
				--if (renderers.current.classid as string == "#(-1204370534, -399920359)") or (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_rawFileName != undefined and renderers.current.output_rawFileName != "" ) then
				--if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and ((renderers.current.output_rawFileName != undefined and renderers.current.output_rawFileName != "") or (renderers.current.output_splitfilename != undefined and renderers.current.output_splitfilename != "")) ) then
				--	format "IgnoreRenderElements=1\n" to:JobInfoFile
				--else
				--	format "IgnoreRenderElements=%\n" (if SMTDSettings.IgnoreRenderElements then 1 else 0) to:JobInfoFile
				format "IgnoreRenderElements=%\n" (if SMTDSettings.IgnoreRenderElements then 1 else 0) to:JobInfoFile
				
				-- If this is 3dsmax 2011 or later, check to see if we're rendering to the new exr format
				if ((maxVersion())[1]/1000 as integer) >= 13 do
				(
					if rendSaveFile and rendOutputFilename != undefined do
					(
						rend_type = getFileNameType rendOutputFilename
						is_exr = matchPattern rend_type pattern:".exr" ignoreCase:true
						is_fxr = matchPattern rend_type pattern:".fxr" ignoreCase:true
						
						-- If we are, we need to tell Deadline which render elements are to be embedded in the exr file so that it doesn't save them separately
						if (is_exr or is_fxr) and (fopenexr != undefined) do
						(
							elementIndex = 0
							if fopenexr.isAutoAddRenderElements() then
							(
								--The elements are being added automatically, so check the re manager.
								local reManager = maxOps.GetCurRenderElementMgr()
								if reManager != undefined do
								(
									if reManager.GetElementsActive() then 
									(
										local reCount = reManager.NumRenderElements()
										for i = 0 to reCount - 1 do
										(
											local theElement = reManager.GetRenderElement i
											if classof theElement != Missing_Render_Element_Plug_in AND theElement.enabled do
											(
												format "IgnoreRenderElementsByName%=%\n" elementIndex theElement.elementName to:JobInfoFile
												elementIndex += 1
											)
										)
									)
								)--end if reManager undefined
							)
							else
							(
								--The elements are manually specified, so check the layers in the exr itself
								for i = 0 to fopenexr.numLayers() do
								(
									if (fopenexr.getLayerType i) == 1 then
									(
										format "IgnoreRenderElementsByName%=%\n" elementIndex (fopenexr.getLayerName i) to:JobInfoFile
										elementIndex += 1
									)
								)
							)
						)
					)
				)
				
				
				local filenameToRender = SMTDFunctions.getRendOutputFilename renderOutputOverride:renderOutputOverride tileString:tileString forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
				local delimiter  = SMTDFunctions.getDelimiterToken()
				local stereoCameraToken = if stereoCameraLabel == "" then "" else stereoCameraLabel+"_"
				
				--If main 3dsmax render output is undefined or empty, then skip
				if filenameToRender != undefined and filenameToRender != "" then
				(					
					format "RenderOutput=%\n" filenameToRender to:JobInfoFile
					format "SaveFile=%\n" rendSaveFile to:JobInfoFile
				)
				else
				(
					--Add default entries to JobInfoFile so they are available via the 3dsmax.options post-submission for users
					format "RenderOutput=\n" to:jobInfoFile
					format "SaveFile=false\n" to:JobInfoFile
				)

				if SMTDSettings.RegionRenderingMode != #none do
					format "RenderElementTiles=1\n" to:JobInfoFile
				
				-- If any render elements are specified, include them
				local includeRenderElementPaths = true
				if includeRenderElementPaths do
				(
					local reManager = maxOps.GetCurRenderElementMgr()
					local outputFilenameIndex = 0
					if reManager != undefined do
					(
						if reManager.GetElementsActive() then 
						(
							local reCount = reManager.NumRenderElements()
							for i = 0 to reCount - 1 do
							(
								reObject = reManager.GetRenderElement i
								if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
								(
									reFilename = reManager.GetRenderElementFilename i
									
									if reFilename != undefined and reFilename != "" then
									(
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do
										(
											if renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != "" then
												if not matchPattern (getFilenameFile renderers.current.output_splitfilename) pattern:(SMTDSettings.StateSetName +"_*") do
													reFilename = getFileNamePath renderers.current.output_splitfilename + SMTDSettings.StateSetName +"_"+(getFilenameFile renderers.current.output_splitfilename) + (getFilenameType reFilename)
											else
												if not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*") do
													reFilename = getFileNamePath reFilename + SMTDSettings.StateSetName +"_"+(getFilenameFile reFilename) + (getFilenameType reFilename)

											try(SMTD_MainRollout.Ui_report (">State Set Rename Output Requested. New Render Element Output File is:"))catch()
											try(SMTD_MainRollout.Ui_report ("  ["+reFilename+"]"))catch()
										)	
										
										reFilename = getFilenamePath reFilename + stereoCameraToken + filenameFromPath reFilename
										
										if SMTDSettings.purifyFilenames do reFilename = SMTDFunctions.purifyFilename reFilename				
										if SMTDSettings.ForceLowerCaseFilenames do reFilename = toLower reFilename
										if SMTDSettings.purifyFilenames or SMTDSettings.ForceLowerCaseFilenames do reManager.SetRenderElementFilename i reFilename
										if SMTDSettings.SubmitSceneMode == #networkremap do reFilename = ::SMTD_RemapLocalToNetworkPath reFilename

										--local delimiter = SMTDSettings.Delimiter
										--if SMTDSettings.RemovePadding AND (findItem #(#none, #maxRegion, #singleFrameTiles, #singleFrameMultiRegion) SMTDSettings.RegionRenderingMode > 0) do delimiter = ""

										--If a tile string is passed as argument, we have to update render elements' filenames to include tile info
										if tileString != "" then
										(
											--Override reFilename if renderer is VRay, VFB is enabled, "Separate render channels" is enabled and splitfilename != ""
											if renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != "" then
											(
												format "RenderElementOutputFilename%=%\n" outputFilenameIndex ((getFileNamePath reFilename) + (getFilenameFile reFilename) + SMTDSettings.Delimiter + reObject.elementName + tileString + delimiter + (getFileNameType reFilename)) to:JobInfoFile
											)
											else
												format "RenderElementOutputFilename%=%\n" outputFilenameIndex ((getFilenamePath reFilename) + (getFilenameFile reFilename) + tileString + delimiter + (getFilenameType reFilename)) to:JobInfoFile
										)
										else
											--Override reFilename if renderer is VRay, VFB is enabled, "Separate render channels" is enabled and splitfilename != ""
											if renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != "" then
											(
												format "RenderElementOutputFilename%=%\n" outputFilenameIndex ((getFileNamePath reFilename) + (getFilenameFile reFilename) + SMTDSettings.Delimiter + reObject.elementName + delimiter + (getFileNameType reFilename)) to:JobInfoFile
											)
											else
												format "RenderElementOutputFilename%=%\n" outputFilenameIndex ((getFilenamePath reFilename) + (getFilenameFile reFilename) + delimiter + (getFilenameType reFilename)) to:JobInfoFile
											
										outputFilenameIndex = outputFilenameIndex + 1
									)
									else
										try(SMTD_MainRollout.Ui_report ("!!Skipping as Standard 3dsMax Render Element Output Filename is undefined."))catch()
								)--end if enabled	
							)--end i loop
						)--end if REs active
					)--end if reManager undefined
				)

				-- If the V-Ray frame buffer is on, then disable the max frame buffer
				if renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on then
					format "ShowFrameBuffer=0\n" to:JobInfoFile
				else
					format "ShowFrameBuffer=%\n" SMTDSettings.ShowFrameBuffer to:JobInfoFile

				-- If V-Ray or Corona renderer
				if renderers.current.classid as string == "#(1941615238, 2012806412)" or renderers.current.classid as string == "#(1655201228, 1379677700)" do
					format "ShowRendererFrameBufferOverride=%\n" SMTDSettings.ShowRendererFrameBufferOverride to:JobInfoFile
					format "ShowRendererFrameBuffer=%\n" SMTDSettings.ShowRendererFrameBuffer to:JobInfoFile

				format "OverrideBitmapPager=%\n" SMTDSettings.OverrideBitmapPager to:JobInfoFile
				format "BitmapPager=%\n" SMTDSettings.BitmapPager to:JobInfoFile

				--if (SMTDSettings.TilesRendering AND SMTDSettings.TilesSubmissionMode == #deadline )or SMTDSettings.SubmitAsMXSJob or SMTDSettings.UseBatchRender do
				if SMTDSettings.SubmitAsMXSJob or (SMTDSettings.UseBatchRender AND SMTDSettings.BatchRenderMode == 2) do
					format "MAXScriptJob=1\n" to:JobInfoFile
				
				--REGION RENDERING SETTINGS EXPORT STARTS HERE:
				local regionMode = SMTDSettings.RegionRenderingMode --SMTDFunctions.GetTileOrRegionMode()
				local tilesRendering = findItem #(#animationTiles, #singleFrameTiles) regionMode > 0
				local multiRegionRendering = findItem #(#singleFrameMultiRegion, #animationMultiRegion) regionMode > 0
				local singleFrameRendering = findItem #(#singleFrameTiles, #singleFrameMultiRegion) regionMode > 0
				local AssemblyMode = #draft --default to draft, unless...
				if (regionMode == #singleFrameTiles AND SMTDSettings.SingleTileJobDependent) do AssemblyMode = #tile --use old assembly when single frame is requested, and when an assembly job is requested explicitly
				if (regionMode == #animationTiles OR (regionMode == #singleFrameTiles AND NOT SMTDSettings.SingleTileJobDependent)) do AssemblyMode = #mxs --use old assembler via post-render script if no dependent job was requested for single frame tiles, or multi-frame tiles are used
				
				try(SMTD_MainRollout.Ui_report (">Region Mode: " + regionMode as string+" | Assembler Mode: "+ AssemblyMode as string))catch()
				
				local renderingModesEnums = #(#none, #singleFrameMultiRegion, #animationMultiRegion, #singleFrameTiles, #animationTiles, #maxRegion)

				--if #maxRegion or #none
				if (findItem renderingModesEnums regionMode > 0) AND (regionMode == #maxRegion OR regionMode == #none) do
				--if (findItem renderingModesEnums regionMode > 0) do
				(
					if ( renderers.current.classid as string == "#(1941615238, 2012806412)" AND renderers.current.output_on ) do
					(
						--SPLIT RENDER CHANNELS
						if (renderers.current.output_splitgbuffer AND renderers.current.output_splitfilename != undefined AND renderers.current.output_splitfilename != "") do
						(
							SMTDSettings.SplitBufferFile = "SplitBufferFile="+(renderers.current.output_splitgbuffer as string)+"\n"
							local splitName = renderers.current.output_splitfilename
							local splitPath = (getFilenamePath splitName)
							local splitBaseName = (getFilenameFile splitName)
							local splitOutputType = (getFilenameType splitName)
							local theFile = splitPath 
							theFile += stereoCameraToken
							if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
							theFile += splitBaseName + splitOutputType --any reason not to inject delimiter here?
							if SMTDSettings.purifyFilenames do theFile = SMTDFunctions.purifyFilename theFile				
							if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile							
							SMTDSettings.SplitBufferFilename = "SplitBufferFilename0="+theFile+"\n"
						)

						local delimiter = SMTDSettings.Delimiter
						if SMTDSettings.RemovePadding do delimiter = ""

						--RAW FILE
						if (renderers.current.output_saveRawFile AND renderers.current.output_rawfilename != undefined AND renderers.current.output_rawfilename != "") then
						(
							SMTDSettings.RawBufferFile = "RawBufferFile="+(renderers.current.output_saveRawFile as string)+"\n"
							local rawName = renderers.current.output_rawfilename
							local rawBaseName = (getFilenameFile rawName)
							local rawOutputType = (getFilenameType rawName)
							local rawPath = (getFilenamePath rawName)
							local theFile = rawPath 
							theFile += stereoCameraToken
							if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
							theFile += rawBaseName + delimiter + rawOutputType
							if SMTDSettings.purifyFilenames do theFile = SMTDFunctions.purifyFilename theFile				
							if SMTDSettings.ForceLowerCaseFilenames do theFile = toLower theFile							
							SMTDSettings.RawBufferFilename = "RawBufferFilename0="+theFile+"\n"
						)
					)--end if vray renderer
				)--end if #maxRegion or #none

				--if (findItem renderingModesEnums regionMode > 0) do
				if (findItem renderingModesEnums regionMode > 0) AND regionMode != #none do
				(
					format "RegionRendering=1\n" to:JobInfoFile
					if ( renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on ) do
					(

						format "%" SMTDSettings.SplitBufferFile to:JobInfoFile
						format "%" SMTDSettings.SplitBufferFilename to:JobInfoFile
						format "%" SMTDSettings.RawBufferFile to:JobInfoFile
						format "%" SMTDSettings.RawBufferFilename to:JobInfoFile

						if renderers.current.output_splitgbuffer then
						(
							local splitChannelCount = 0
							local splitChannelNames = ""
							if renderers.current.output_splitRGB then
							(
								splitChannelNames += "SplitChannelNames"+(splitChannelCount as string)+"=RGB_color\n"
								splitChannelCount += 1
							)
							if renderers.current.output_splitAlpha then
							(
								splitChannelNames += "SplitChannelNames"+(splitChannelCount as string)+"=Alpha\n"
								splitChannelCount += 1
							)
							
							if reManager.GetElementsActive() then
							(
								local reCount = reManager.NumRenderElements()
								for i = 0 to reCount - 1 do
								(
									local reObject = reManager.GetRenderElement i
									if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
									(									
										local reName = reObject.elementName
										splitChannelNames += "SplitChannelNames"+(splitChannelCount as string)+"="+reName+"\n"
										splitChannelCount += 1
									)
								)
							)
							format "%" splitChannelNames to:JobInfoFile
						)--end if splitChannels enabled
					)--end if VRay is renderer & VFB enabled
					
					if (regionMode == #animationTiles)  then --multi-frame tile rendering or not use Max region values in Max mode
					(
						format "RegionLeft=%\n" (SMTDSettings.RegionLeft as integer) to:JobInfoFile
						format "RegionTop=%\n" (SMTDSettings.RegionTop as integer) to:JobInfoFile
						format "RegionRight=%\n" (SMTDSettings.RegionRight as integer) to:JobInfoFile
						format "RegionBottom=%\n" (SMTDSettings.RegionBottom as integer) to:JobInfoFile
					)
					if regionMode == #maxRegion then 
					(
						local useMaxRegion = SMTDSettings.RegionUseMaxValues
						if not (isKindOf SMTDSettings.RegionLeft Number) do useMaxRegion = true --ensure the value in the region is a number (it could be an array left over from MF/MR)
						if useMaxRegion then
						(
							if viewport.activeViewport > 0 then 
							(
								local theRect;
								if SMTDSettings.RegionType == 3 then
									theRect = viewport.getBlowupRect (viewport.activeViewport)
								else
									theRect = viewport.getRegionRect (viewport.activeViewport)
								tempLeft = theRect.x
								tempTop = theRect.y
								tempRight = theRect.x + theRect.w
								tempBottom = theRect.y + theRect.h
							)
							else
							(
								tempLeft = 0
								tempTop = 0
								renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)
								tempRight = renderDimensions[1]
								tempBottom = renderDimensions[2]
							)			
							format "RegionLeft=%\n" tempLeft to:JobInfoFile
							format "RegionTop=%\n" tempTop to:JobInfoFile
							format "RegionRight=%\n" tempRight to:JobInfoFile
							format "RegionBottom=%\n" tempBottom to:JobInfoFile
						)
						else --this  is only for UI-less submissions where the SMTDSettings.RegionLeft etc. were set by a script. Normally, the Max region values and the SMTD values should match anyway
						(
							format "RegionLeft=%\n" (SMTDSettings.RegionLeft as integer) to:JobInfoFile
							format "RegionTop=%\n" (SMTDSettings.RegionTop as integer) to:JobInfoFile
							format "RegionRight=%\n" (SMTDSettings.RegionRight as integer) to:JobInfoFile
							format "RegionBottom=%\n" (SMTDSettings.RegionBottom as integer) to:JobInfoFile
						)
						format "RegionPadding=0\n" to:JobInfoFile
						format "RegionType=%\n" #("NOCROP","CROP","BLOWUP")[SMTDSettings.RegionType] to:JobInfoFile
					)
					else
					(
						format "RegionPadding=%\n" SMTDSettings.TilesPadding to:JobInfoFile
						if SMTDSettings.TileBlowupMode and tilesRendering  then --SMTDSettings.TilesRendering
							format "RegionType=BLOWUP\n" to:JobInfoFile
						else
							format "RegionType=CROP\n" to:JobInfoFile
					)
					
					if AssemblyMode == #mxs do
						format "PostFrameScript=\"maxTileAssemblerCommand.ms\"\n"  to:JobInfoFile
					
					if regionMode == #singleFrameMultiRegion or regionMode == #singleFrameTiles then
					(
						try(SMTD_MainRollout.Ui_report (">Single Frame Regions or Tiles..."))catch()
						--format "RegionSingleJob=True\n" to:JobInfoFile
						--format "RegionSingleFrame=%\n" (currentTime.frame as integer) to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobLeft to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobTop to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobRight to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobBottom to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobFilename to:JobInfoFile
						format "%" SMTDSettings.SingleTileJobReFilename to:JobInfoFile
					)
					else
						try(SMTD_MainRollout.Ui_report (">NOT Single Frame Regions or Tiles..."))catch()
					
					if regionMode == #animationMultiRegion do
					(
						format "RegionAnimation=1\n" to:JobInfoFile
						with PrintAllElements on 
						(
							local txt1 = substring (SMTDSettings.RegionLeft as string) 3 -1
							txt1 = substring txt1 1 (txt1.count-1)
							local txt2 = substring (SMTDSettings.RegionTop as string) 3 -1
							txt2 = substring txt2 1 (txt2.count-1)
							local txt3 = substring (SMTDSettings.RegionRight as string) 3 -1
							txt3 = substring txt3 1 (txt3.count-1)
							local txt4 = substring (SMTDSettings.RegionBottom as string) 3 -1
							txt4 = substring txt4 1 (txt4.count-1)
						)
						format "RegionLeft=%\n" txt1  to:JobInfoFile
						format "RegionTop=%\n" txt2 to:JobInfoFile
						format "RegionRight=%\n" txt3 to:JobInfoFile
						format "RegionBottom=%\n" txt4 to:JobInfoFile							
					)
				)--end in some region mode
				
				renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

				if regionMode != #none then
				(
					-- Only include the render width/height in blowup mode, because we don't want to allow people to change
					-- the resolution for normal tile jobs. However, if the job is tile/region/jigsaw, then include AssembledRenderWidth/Height
					-- for reference purposes only.
					if SMTDSettings.TileBlowupMode then
					(
						format "RenderWidth=%\n" ((floor (1.0*renderDimensions[1]/SMTDSettings.TilesInX)) as integer) to:JobInfoFile
						format "RenderHeight=%\n" ((floor (1.0*renderDimensions[2]/SMTDSettings.TilesInY)) as integer) to:JobInfoFile
						format "renderPixelAspect=%\n" renderDimensions[3] to:JobInfoFile
					)
					else
					(
						format "AssembledRenderWidth=%\n" renderDimensions[1] to:JobInfoFile
						format "AssembledRenderHeight=%\n" renderDimensions[2] to:JobInfoFile
					)
				)
				else
				(
					format "RenderWidth=%\n" renderDimensions[1] to:JobInfoFile
					format "RenderHeight=%\n" renderDimensions[2] to:JobInfoFile
					format "renderPixelAspect=%\n" renderDimensions[3] to:JobInfoFile
				)
				--REGION RENDERING SETTINGS EXPORT ENDS HERE
				
				--SCENE STATES
				/*
				format "SceneState=\n" to:JobInfoFile
				format "SceneState0=\n" to:JobInfoFile
				for i = 1 to sceneStateMgr.GetCount() do
					format "SceneState%=\n" i (sceneStateMgr.getSceneState i) to:JobInfoFile
				*/

				format "rendAtmosphere=%\n" rendAtmosphere to:JobInfoFile
				format "renderEffects=%\n" renderEffects to:JobInfoFile
				format "renderDisplacements=%\n" renderDisplacements to:JobInfoFile
				format "rendSimplifyAreaLights=%\n" rendSimplifyAreaLights to:JobInfoFile
				format "rendForce2Side =%\n" rendForce2Side to:JobInfoFile
				format "rendHidden=%\n" rendHidden to:JobInfoFile
				format "rendColorCheck=%\n" rendColorCheck to:JobInfoFile
				format "rendSuperBlack =%\n" rendSuperBlack to:JobInfoFile
				format "rendFieldRender =%\n" rendFieldRender to:JobInfoFile

				format "SkipRenderedFrames =%\n" skipRenderedFrames to:JobInfoFile

				format "backgroundColor=%\n" backgroundColor to:JobInfoFile
				format "useEnvironmentMap=%\n" useEnvironmentMap to:JobInfoFile
				format "ambientColor=%\n" ambientColor to:JobInfoFile
				format "lightTintColor=%\n" lightTintColor to:JobInfoFile
				format "lightLevel=%\n" lightLevel to:JobInfoFile

				--EXPORT ADVANCED RENDERING SETTINGS STARTS HERE
				local rendererID = SMTDFunctions.getRendererIdString()
				if rendererID == "scanline" AND SMTDSettings.ExportAdvancedRenderInfoScanline then
				(	
				
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()
				
					format "scanline_globalSamplerClassByName0=Max 2.5 Star\n"  to:JobInfoFile
					format "scanline_globalSamplerClassByName1=Hammersley\n"  to:JobInfoFile
					format "scanline_globalSamplerClassByName2=Adaptive Halton\n"  to:JobInfoFile
					format "scanline_globalSamplerClassByName3=Adaptive Uniform\n"  to:JobInfoFile
					
					format "scanline_antialiasFilterClassByName=%\n" (classof scanlineRender.antiAliasFilter) to:JobInfoFile
					format "scanline_antialiasFilterClassByName0=Area\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName1=Quadratic\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName2=cubic\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName3=Catmull_Rom\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName4=Blackman\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName5=Video\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName6=Plate_Match_MAX_R2\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName7=Cook_Variable\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName8=Soften\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName9=Mitchell_Netravali\n" to:JobInfoFile
					format "scanline_antialiasFilterClassByName10=Blendfilter\n" to:JobInfoFile
					
					local theVal = if classof scanlineRender.antiAliasFilter == blend then scanlineRender.antiAliasFilter.blend else 0.3
					format "scanline_antialiasFilterBlend=%\n"  theVal to:JobInfoFile

					if classof scanlineRender.antiAliasFilter == Mitchell_Netravali then 
					(
						theVal1=scanlineRender.antiAliasFilter.Blur 
						theVal2=scanlineRender.antiAliasFilter.Ringing
					)	
					else	
						theVal1 = theVal2 = 0.3333
					format "scanline_antialiasFilterBlur=%\n"  theVal1 to:JobInfoFile	
					format "scanline_antialiasFilterRinging=%\n"  theVal2 to:JobInfoFile	
				)
				
				if rendererID == "brazil" AND SMTDSettings.ExportAdvancedRenderInfoBrazil then
				(
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()
				
				
					local bucket_list = #("Random","Top to Bottom", "Left to Right", "Center Out")
					format "brazil_bucket_order_enums=%\n"  bucket_list[renderers.current.bucket_order+1] to:JobInfoFile
					for i = 0 to 3 do 
						format "brazil_bucket_order_enums%=%\n" i bucket_list[i+1] to:JobInfoFile

					bucket_list = #("16","32", "64", "128")
					format "brazil_bucket_size_enums=%\n"  bucket_list[renderers.current.bucket_size+1] to:JobInfoFile
					for i = 0 to 3 do 
						format "brazil_bucket_size_enums%=%\n" i bucket_list[i+1] to:JobInfoFile
				)
				
				if rendererID == "brmax" AND SMTDSettings.ExportAdvancedRenderInfoBrazil2 then
				(
					local brazilRenderer = ::sfs.b2_lib.getActiveB2() --Force global scope to access SplutterFish Script libraries!
					
					local blockNames = #("System_Options_Parameter_Block_Holder","Sampling_Parameter_Block_Holder","Motion_Blur_Parameter_Block_Holder","Ray_Server_Parameter_Block_Holder","Luma_Server_Parameter_Block_Holder","Render_Cache_Parameter_Block_Holder","Photon_Server_Parameter_Block_Holder","Render_Pass_Parameter_Block_Holder")
					for blockName in blockNames do
					(
						local block = brazilRenderer[blockName]
						if block != undefined then
						(
							local propNames = getPropNames block.object
							if propNames != undefined then
							(
								for p in propNames do
								(
									try(format "%_%=%\n" rendererID (p as string) (getProperty block.object p) to:JobInfoFile)catch()
								)
							)
						)
					)
					
					local block = brazilRenderer["System_Options_Parameter_Block_Holder"]
					if block != undefined then
					(
						local item_list = #("Hilbert","Top to Bottom","Left to Right","Center Out","Random")
						format "brmax_bucket_order_enums=%\n"  item_list[block.object.bucket_order+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_bucket_order_enums%=%\n" i item_list[i+1] to:JobInfoFile
						
						item_list = #("16","24","32","48","64")
						format "brmax_bucket_size_enums=%\n"  item_list[block.object.bucket_size+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_bucket_size_enums%=%\n" i item_list[i+1] to:JobInfoFile
						
						item_list = #("Disable","Automatic","Specify")
						format "brmax_rend_threading_mode_enums=%\n"  item_list[block.object.rend_threading_mode+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_rend_threading_mode_enums%=%\n" i item_list[i+1] to:JobInfoFile
					)
					
					block = brazilRenderer["Sampling_Parameter_Block_Holder"]
					if block != undefined then
					(
						local item_list = #("BrAreaFilter","BrMitNetFilter","BrCatmullRomFilter","BrCookVariableFilter","BrBlackmanFilter","BrVideoFilter","BrGaussianFilter")
						format "brmax_filter_name_enums=%\n"  block.object.filter_name to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_filter_name_enums%=%\n" i item_list[i+1] to:JobInfoFile
					)
					
					block = brazilRenderer["Motion_Blur_Parameter_Block_Holder"]
					if block != undefined then
					(
						local item_list = #("Off","Image Motion Blur","3D Motion Blur")
						format "brmax_motion_blur_type_enums=%\n"  item_list[block.object.motion_blur_type+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_motion_blur_type_enums%=%\n" i item_list[i+1] to:JobInfoFile
						
						item_list = #("None","Basic")
						format "brmax_shutter_type_enums=%\n"  item_list[block.object.shutter_type+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_shutter_type_enums%=%\n" i item_list[i+1] to:JobInfoFile
					)
					
					block = brazilRenderer["Ray_Server_Parameter_Block_Holder"]
					if block != undefined then
					(
						local item_list = #("BrDefaultAccel","BrLDAccel","BrLDKDTreeAccelDesc")
						format "brmax_ray_accel_name_enums=%\n"  block.object.ray_accel_name to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_ray_accel_name_enums%=%\n" i item_list[i+1] to:JobInfoFile
					)
					
					block = brazilRenderer["Luma_Server_Parameter_Block_Holder"]
					if block != undefined then
					(
						local item_list = #("No Enhancement","Auto-Occlusion","Retrace")
						format "brmax_rendercache_detail_mode_enums=%\n"  item_list[block.object.rendercache_detail_mode+1] to:JobInfoFile
						for i = 0 to item_list.count-1 do 
							format "brmax_rendercache_detail_mode_enums%=%\n" i item_list[i+1] to:JobInfoFile
					)
				)
				
				if rendererID == "amaretto" AND SMTDSettings.ExportAdvancedRenderInfoAmaretto then
				(
					propList = #(

						--MAIN CONTROLS > OPTIONS:
						#("ShowRenderInIV","Amaretto:ShowRenderInIV","Amaretto:ShowRenderInIV"),
						#("GrayOutVFB","Amaretto:GrayOutVFB","Amaretto:GrayOutVFB"),
						#("MultiThreading","Amaretto:MultiThreading","Amaretto:MultiThreading"),

						--GENERAL RENDERING PARAMETERS
						#("BucketWidth","Amaretto:BucketWidth","Amaretto:BucketWidth"),
						#("BucketHeight","Amaretto:BucketHeight","Amaretto:BucketHeight"),

						--SHADING,HIDING, INTERPOLATION
						#("ForceDoubleSided","Amaretto:ForceDoubleSided","Amaretto:ForceDoubleSided"),
						#("ForceCatmullClarkSDS","Amaretto:ForceCatmullClarkSDS","Amaretto:ForceCatmullClarkSDS"),
						#("dice_binary","dice:binary","dice:binary"),
						#("shading_rate","shadingquality","shadingquality"),
						#("hider","hider","hider"), --ENUM?

						--GEOMETRY EXPORT (ENUM!)
--						#("GeometryExport","Amaretto:GeometryExport","Amaretto:GeometryExport"),

						--ANTI-ALIASING
						#("SpatialQualityX","Amaretto:SpatialQualityX","Amaretto:SpatialQualityX"),
						#("SpatialQualityY","Amaretto:SpatialQualityY","Amaretto:SpatialQualityY"),

						--GLOBAL OVERRIDES
						#("DisableShadows","Amaretto:DisableShadows","Amaretto:DisableShadows"),
						#("DisableLights","Amaretto:DisableLights","Amaretto:DisableLights"),
						#("DontExportSurfaceShaders","Amaretto:DontExportSurfaceShaders","Amaretto:DontExportSurfaceShaders"),
						#("DontExportDisplacementShaders","Amaretto:DontExportDisplacementShaders","Amaretto:DontExportDisplacementShaders"),
						#("DontExportVolumeShaders","Amaretto:DontExportVolumeShaders","Amaretto:DontExportVolumeShaders"),
						#("displace_maxradius","displace:maxradius","displace:maxradius"),
						#("AddGlobalShader","Amaretto:AddGlobalShader","Amaretto:AddGlobalShader"),
						#("GlobalShaderType","Amaretto:GlobalShaderType","Amaretto:GlobalShaderType"), --ENUM?

						--PREVIEW MODE
						#("PreviewMode","Amaretto:PreviewMode","Amaretto:PreviewMode"),
						#("preview","preview","preview"),
						#("preview_temporalquality","preview:temporalquality","preview:temporalquality"),
						#("preview_dofquality","preview:dofquality","preview:dofquality"),
						#("preview_thincurves","preview:thincurves","preview:thincurves"),
						#("preview_thinpoints","preview:thinpoints","preview:thinpoints"),
						#("preview_limitpixelsize","preview:limitpixelsize","preview:limitpixelsize"),
						#("preview_limitdistance","preview:limitdistance","preview:limitdistance"),
						
						#("PreviewSpatialQuality","Amaretto:PreviewSpatialQuality","Amaretto:PreviewSpatialQuality"),
						#("PreviewBucketSize","Amaretto:PreviewBucketSize","Amaretto:PreviewBucketSize"),
						
						--PASSES
						#("FilterWidthX","Amaretto:FilterWidthX","Amaretto:FilterWidthX"),
						#("FilterWidthY","Amaretto:FilterWidthY","Amaretto:FilterWidthY"),
						#("filtertype","filtertype","filtertype"), --ENUMS!
						#("ShowPassesInIV","Amaretto:ShowPassesInIV","Amaretto:ShowPassesInIV"),
						#("gain","gain","gain"), 
						#("gamma","gamma","gamma"), 
						#("dither","dither","dither"), 
						#("ColorDepth","Amaretto:ColorDepth","Amaretto:ColorDepth"), --ENUMS!
						
						--LIGHTS AND SHADOWS
						#("shadow_opacitythreshold","shadow:opacitythreshold","shadow:opacitythreshold"),
						#("ForceShadowMaps","Amaretto:ForceShadowMaps","Amaretto:ForceShadowMaps"),
						#("RenderShadowMapsMode","Amaretto:RenderShadowMapsMode","Amaretto:RenderShadowMapsMode"),
						#("ForceRaytracedShadows","Amaretto:ForceRaytracedShadows","Amaretto:ForceRaytracedShadows"),
						#("DefaultShadowType","Amaretto:DefaultShadowType","Amaretto:DefaultShadowType"),
						#("UseGlobalShadowMaps","Amaretto:UseGlobalShadowMaps","Amaretto:UseGlobalShadowMaps"),
						#("GlobalShadowMapSize","Amaretto:GlobalShadowMapSize","Amaretto:GlobalShadowMapSize"),

						#("ShadowMapType","Amaretto:ShadowMapType","Amaretto:ShadowMapType"),
						#("GlobalShadowMapSamples","Amaretto:GlobalShadowMapSamples","Amaretto:GlobalShadowMapSamples"),
						#("GlobalShadowMapBlur","Amaretto:GlobalShadowMapBlur","Amaretto:GlobalShadowMapBlur"),
						#("GlobalShadowMapBias","Amaretto:GlobalShadowMapBias","Amaretto:GlobalShadowMapBias"),

						#("UseRaytracedShadowGlobals","Amaretto:UseRaytracedShadowGlobals","Amaretto:UseRaytracedShadowGlobals"),
						#("GlobalRaytracedShadowSpread","Amaretto:GlobalRaytracedShadowSpread","Amaretto:GlobalRaytracedShadowSpread"),
						#("GlobalRaytracedShadowBias","Amaretto:GlobalRaytracedShadowBias","Amaretto:GlobalRaytracedShadowBias"),
						#("GlobalRaytracedShadowQuality","Amaretto:GlobalRaytracedShadowQuality","Amaretto:GlobalRaytracedShadowQuality"),
						#("EnvLight_Enable","Amaretto:EnvLight:Enable","Amaretto:EnvLight:Enable"),
						#("EnvLight_Intensity","Amaretto:EnvLight:Intensity","Amaretto:EnvLight:Intensity"),
						#("EnvLight_Color","Amaretto:EnvLight:Color","Amaretto:EnvLight:Color"),
						#("EnvLight_NonSpecular","Amaretto:EnvLight:NonSpecular","Amaretto:EnvLight:NonSpecular"),
						#("EnvLight_EnvName","Amaretto:EnvLight:EnvName","Amaretto:EnvLight:EnvName"),
						#("EnvLight_EnvSpace","Amaretto:EnvLight:EnvSpace","Amaretto:EnvLight:EnvSpace"),
						#("EnvLight_Radius","Amaretto:EnvLight:Radius","Amaretto:EnvLight:Radius"),
						#("EnvLight_Blur","Amaretto:EnvLight:Blur","Amaretto:EnvLight:Blur"),
						
						--DOF	
						#("EnableDOF","Amaretto:EnableDOF","Amaretto:EnableDOF"),
						#("OverrideDOF","Amaretto:OverrideDOF","Amaretto:OverrideDOF"),
						#("dofquality","dofquality","dofquality"),
						#("FStop","Amaretto:FStop","Amaretto:FStop"),
						#("FocalLength","Amaretto:FocalLength","Amaretto:FocalLength"),
						#("FocalDistance","Amaretto:FocalDistance","Amaretto:FocalDistance"),

						--MBLUR	
						#("EnableMotionBlur","Amaretto:EnableMotionBlur","Amaretto:EnableMotionBlur"),
						#("EnableVertexMotionBlur","Amaretto:EnableVertexMotionBlur","Amaretto:EnableVertexMotionBlur"),
						#("temporalquality","temporalquality","temporalquality"),
						#("MotionBlurSegments","Amaretto:MotionBlurSegments","Amaretto:MotionBlurSegments"),
						#("ShutterType","Amaretto:ShutterType","Amaretto:ShutterType"),
						#("ShutterAngle","Amaretto:ShutterAngle","Amaretto:ShutterAngle"),
						#("dice_motionfactor","dice:motionfactor","dice:motionfactor"),
						
						-- STEREO
						#("EnableStereo","Amaretto:EnableStereo","Amaretto:EnableStereo"),
						#("RenderShadingCamera","Amaretto:RenderShadingCamera","Amaretto:RenderShadingCamera"),
						#("ShadingCamera","Amaretto:ShadingCamera","Amaretto:ShadingCamera"),

						--GI
						#("EnableGI","Amaretto:EnableGI","Amaretto:EnableGI"),
						#("Indirect_Samples","Amaretto:Indirect:Samples","Amaretto:Indirect:Samples"),
						#("Indirect_Bias","Amaretto:Indirect:Bias","Amaretto:Indirect:Bias"),
						#("Indirect_Adaptive","Amaretto:Indirect:Adaptive","Amaretto:Indirect:Adaptive"),
						#("indirect_minsamples","indirect:minsamples","indirect:minsamples"),
						#("indirect_maxpixeldist","indirect:maxpixeldist","indirect:maxpixeldist"),
						#("indirect_maxerror","indirect:maxerror","indirect:maxerror"),

						-- SUBSURFACE SCATTERING
						#("SSS_FOVMultiplier","Amaretto:SSS:FOVMultiplier","Amaretto:SSS:FOVMultiplier"),
						#("SSS_Resolution","Amaretto:SSS:Resolution","Amaretto:SSS:Resolution"),
						#("SSS_Disable","Amaretto:SSS:Disable","Amaretto:SSS:Disable"),
						
						--AMBIENT OCCULUSION
						#("occlusion_minsamples","occlusion:minsamples","occlusion:minsamples"),
						#("occlusion_maxpixeldist","occlusion:maxpixeldist","occlusion:maxpixeldist"),
						#("occlusion_maxerror","occlusion:maxerror","occlusion:maxerror"),
						
						#("GlobalShaderAmbientOcclusionSamples","Amaretto:GlobalShader:AmbientOcclusionSamples","Amaretto:GlobalShader:AmbientOcclusionSamples"),
						#("GlobalShaderAmbientOcclusionBias","Amaretto:GlobalShader:AmbientOcclusionBias","Amaretto:GlobalShader:AmbientOcclusionBias"),
						#("GlobalShaderAmbientOcclusionAdaptive","Amaretto:GlobalShader:AmbientOcclusionBias","Amaretto:GlobalShader:AmbientOcclusionBias"),
						
						#("ray_maxdepth","ray:maxdepth","ray:maxdepth"),
						#("ray_maxdepthcolor","ray:maxdepthcolor","ray:maxdepthcolor"),
						#("ray_displace","ray:displace","ray:displace"),
						#("ray_opaqueshadows","ray:opaqueshadows","ray:opaqueshadows"),						
						
						--PERFORMANCE
						#("limits_gridsize","limits:gridsize","limits:gridsize"),
						#("limits_texturememory","limits:texturememory","limits:texturememory"),
						#("limits_texturefiles","limits:texturefiles","limits:texturefiles"),
						#("limits_trimcurvememory","limits:trimcurvememory","limits:trimcurvememory"),
						#("trimcurve_quality","trimcurve:quality","trimcurve:quality"),
						#("limits_opacitythreshold","limits:opacitythreshold","limits:opacitythreshold"),
						#("limits_transparentgrids","limits:transparentgrids","limits:transparentgrids"),
						#("dice_tracedisplacements","dice:tracedisplacements","dice:tracedisplacements")
					)
					
					for p in propList do
					(
						try
						(
							local theValue = (Amaretto.GetProperty p[2])
							if theValue != undefined do format "amaretto_%=%\n" p[1] theValue to:JobInfoFile
						)catch()
					)
					
					--CUSTOM ENUMS
					try(format "%_%=%\n" rendererID "bucketorder_enums" (Amaretto.GetProperty "bucketorder") to:JobInfoFile)catch()
					for i = 0 to 2 do 
						format "amaretto_bucketorder_enums%=%\n" i #("horizontal","vertical","spiral")[i+1] to:JobInfoFile
					
				)
				
				--KRAKATOA EXPORT PROPERTIES
				if rendererID == "krakatoa" AND SMTDSettings.ExportAdvancedRenderInfoKrakatoa then
				(
					--Krakatoa - All Versions
					try(format "%_Version=%\n" rendererID FranticParticles.version to:JobInfoFile)catch()
					--Krakatoa 1.0.x and 1.1.x versions:
					if execute (substring FranticParticles.version 1 3) < 1.5 then
					(
						theArray = #("Volumetric Density","Additive Density","Constant Alpha")
						try(format "%_%=%\n" rendererID "Density_DensityMethod" (FranticParticles.GetProperty "Density:DensityMethod") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "Density_DensityMethod" i theArray[i+1] to:JobInfoFile
						
						theArray = #("No Scaling", "Material Opacity")
						try(format "%_%=%\n" rendererID "DensityScalingSource" (FranticParticles.GetProperty "DensityScalingSource") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "DensityScalingSource" i theArray[i+1] to:JobInfoFile
						
						theArray = #("Volumetric Density","Additive Density","Constant Alpha")
						try(format "%_%=%\n" rendererID "Lighting_Density_DensityMethod" (FranticParticles.GetProperty "Lighting:Density:DensityMethod") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "Lighting_Density_DensityMethod" i theArray[i+1] to:JobInfoFile
						
						try(format "%_%=%\n" rendererID "UseGlobalColorOverride" (FranticParticles.GetProperty "UseGlobalColorOverride") to:JobInfoFile)catch()

						theArray = #("Choose Color", "Medit1", "No Material","Blended Z Depth","Blended Camera Distance")
						try(format "%_%=%\n" rendererID "ParticleColorSource"  (FranticParticles.GetProperty "ParticleColorSource") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "ParticleColorSource" i theArray[i+1] to:JobInfoFile

						try(format "%_%=%\n" rendererID "ChosenColor" (FranticParticles.GetProperty "ChosenColor") to:JobInfoFile)catch()
						
						try(format "%_%=%\n" rendererID "UseLighting" (FranticParticles.GetProperty "UseLighting") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "Lighting_Specular_Enabled" (FranticParticles.GetProperty "Lighting:Specular:Enabled") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Lighting_Specular_Glossiness" (FranticParticles.GetProperty "Lighting:Specular:Glossiness") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Lighting_Specular_Level" (FranticParticles.GetProperty "Lighting:Specular:Level") to:JobInfoFile)catch()
						
						try(format "%_%=%\n" rendererID "RenderParticleFlowGeometry" (FranticParticles.GetProperty "RenderParticleFlowGeometry") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderParticleFlowBBox" (FranticParticles.GetProperty "RenderParticleFlowBBox") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderParticleFlowPhantom" (FranticParticles.GetProperty "RenderParticleFlowPhantom") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderParticleObjectExt" (FranticParticles.GetProperty "RenderParticleObjectExt") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "RenderMaxParticles" (FranticParticles.GetProperty "RenderMaxParticles") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderThinkingParticles" (FranticParticles.GetProperty "RenderThinkingParticles") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderGeometryVertices" (FranticParticles.GetProperty "RenderGeometryVertices") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderKrakatoaLoaders" (FranticParticles.GetProperty "RenderKrakatoaLoaders") to:JobInfoFile)catch()
					)
					else --Krakatoa 1.5.x+
					(
						try(format "%_%=%\n" rendererID "IgnoreSceneLights" (FranticParticles.GetProperty "IgnoreSceneLights") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "UseEnvironmentReflections" (FranticParticles.GetProperty "UseEnvironmentReflections") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "UseFilterColor" (FranticParticles.GetProperty "UseFilterColor") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "UseEmissionColor" (FranticParticles.GetProperty "UseEmissionColor") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "AdditiveMode" (FranticParticles.GetProperty "AdditiveMode") to:JobInfoFile)catch()
						
						try(format "%_%=%\n" rendererID "ColorOverride_Enabled" (FranticParticles.GetProperty "ColorOverride:Enabled") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "ColorOverride_Color" (FranticParticles.GetProperty "ColorOverride:Color") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "ColorOverride_BlendAmount" (FranticParticles.GetProperty "ColorOverride:BlendAmount") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "AbsorptionOverride_Enabled" (FranticParticles.GetProperty "AbsorptionOverride:Enabled") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "AbsorptionOverride_Color" (FranticParticles.GetProperty "AbsorptionOverride:Color") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "AbsorptionOverride_BlendAmount" (FranticParticles.GetProperty "AbsorptionOverride:BlendAmount") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "EmissionOverride_Enabled" (FranticParticles.GetProperty "EmissionOverride:Enabled") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "EmissionOverride_Color" (FranticParticles.GetProperty "EmissionOverride:Color") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "EmissionOverride_BlendAmount" (FranticParticles.GetProperty "EmissionOverride:BlendAmount") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "DensityOverride_Enabled" (FranticParticles.GetProperty "DensityOverride:Enabled") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "DensityOverride_Color" (FranticParticles.GetProperty "DensityOverride:Color") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "DensityOverride_BlendAmount" (FranticParticles.GetProperty "DensityOverride:BlendAmount") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "VoxelSize" (FranticParticles.GetProperty "VoxelSize") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "VoxelFilterRadius" (FranticParticles.GetProperty "VoxelFilterRadius") to:JobInfoFile)catch()
						
						try(format "%_%=%\n" rendererID "PhaseEccentricity" (FranticParticles.GetProperty "PhaseEccentricity") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "IgnoreMissingParticles" (FranticParticles.GetProperty "IgnoreMissingParticles") to:JobInfoFile)catch()

						theArray = #("Particle Rendering","Voxel Rendering")
						try(format "%_%=%\n" rendererID "RenderingMethod" (FranticParticles.GetProperty "RenderingMethod") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "RenderingMethod" i theArray[i+1] to:JobInfoFile

						theArray = #("Isotropic","Phong Surface","Henyey-Greenstein","Schlick","Kajiya-Kay Hair") 
						try(format "%_%=%\n" rendererID "PhaseFunction" (FranticParticles.GetProperty "PhaseFunction") to:JobInfoFile)catch()
						for i = 0 to theArray.count-1 do
							format "%_%%=%\n" rendererID "PhaseFunction" i theArray[i+1] to:JobInfoFile
						
						try(format "%_%=%\n" rendererID "RenderParticleFlowGeometry" (FranticParticles.GetProperty "RenderParticleFlowGeometry") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderParticleFlowBBox" (FranticParticles.GetProperty "RenderParticleFlowBBox") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderParticleFlowPhantom" (FranticParticles.GetProperty "RenderParticleFlowPhantom") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "RenderFumeFX" (FranticParticles.GetProperty "RenderFumeFX") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderMaxParticles" (FranticParticles.GetProperty "RenderMaxParticles") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderThinkingParticles" (FranticParticles.GetProperty "RenderThinkingParticles") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "RenderGeometryVertices" (FranticParticles.GetProperty "RenderGeometryVertices") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderKrakatoaLoaders" (FranticParticles.GetProperty "RenderKrakatoaLoaders") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "RenderGeometryVolumes" (FranticParticles.GetProperty "RenderGeometryVolumes") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "GlobalParticlePercentage" (FranticParticles.GetProperty "GlobalParticlePercentage") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "Lighting_Specular_SpecularPower" (FranticParticles.GetProperty "Lighting:Specular:SpecularPower") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Lighting_Specular_Level" (FranticParticles.GetProperty "Lighting:Specular:Level") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "Channel_Allocate_SpecularPower" (FranticParticles.GetProperty "Channel:Allocate:SpecularPower") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Channel_Allocate_SpecularLevel" (FranticParticles.GetProperty "Channel:Allocate:SpecularLevel") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Channel_Allocate_PhaseEccentricity" (FranticParticles.GetProperty "Channel:Allocate:PhaseEccentricity") to:JobInfoFile)catch()

						try(format "%_%=%\n" rendererID "Matte_RayDivisions" (FranticParticles.GetProperty "Matte:RayDivisions") to:JobInfoFile)catch()
						try(format "%_%=%\n" rendererID "Matte_SaveMultipleLayers" (FranticParticles.GetProperty "Matte:SaveMultipleLayers") to:JobInfoFile)catch()
					)
					
				
					try(format "%_%=%\n" rendererID "Density_LinkLightingAndRenderingDensity" (FranticParticles.GetProperty "Density:LinkLightingAndRenderingDensity") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "Density_DensityPerParticle" (FranticParticles.GetProperty "Density:DensityPerParticle") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "Density_DensityExponent" (FranticParticles.GetProperty "Density:DensityExponent") to:JobInfoFile)catch()

					try(format "%_%=%\n" rendererID "Lighting_Density_DensityPerParticle" (FranticParticles.GetProperty "Lighting:Density:DensityPerParticle") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "Lighting_Density_DensityExponent" (FranticParticles.GetProperty "Lighting:Density:DensityExponent") to:JobInfoFile)catch()

					try(format "%_%=%\n" rendererID "UseDepthMaps" (FranticParticles.GetProperty "UseDepthMaps") to:JobInfoFile)catch()
					
					theArray = #("Nearest Neighbor","Bilinear","Bicubic")
					try(format "%_%=%\n" rendererID "DrawPointFilter" (FranticParticles.GetProperty "DrawPointFilter") to:JobInfoFile)catch()
					for i = 0 to theArray.count-1 do
						format "%_%%=%\n" rendererID "DrawPointFilter" i theArray[i+1] to:JobInfoFile
					
					theArray = #("Nearest Neighbor","Bilinear","Bicubic")
					try(format "%_%=%\n" rendererID "AttenuationLookupFilter" (FranticParticles.GetProperty "AttenuationLookupFilter") to:JobInfoFile)catch()
					for i = 0 to theArray.count-1 do
						format "%_%%=%\n" rendererID "AttenuationLookupFilter" i theArray[i+1] to:JobInfoFile

					try(format "%_%=%\n" rendererID "EnableMotionBlur" (FranticParticles.GetProperty "EnableMotionBlur") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "EnableDepthOfField" (FranticParticles.GetProperty "EnableDepthOfField") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "EnableAttenuationMapSaving" (FranticParticles.GetProperty "EnableAttenuationMapSaving") to:JobInfoFile)catch()

					try(format "%_%=%\n" rendererID "MotionBlurSegments" (FranticParticles.GetProperty "MotionBlurSegments") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "JitteredMotionBlur" (FranticParticles.GetProperty "JitteredMotionBlur") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "DepthOfFieldSampleRate" (FranticParticles.GetProperty "DepthOfFieldSampleRate") to:JobInfoFile)catch()
					
					try(format "%_%=%\n" rendererID "BackgroundColor" (FranticParticles.GetProperty "BackgroundColor") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "UseEnvironmentColor" (FranticParticles.GetProperty "UseEnvironmentColor") to:JobInfoFile)catch()

					try(format "%_%=%\n" rendererID "PostDivideByAlpha" (FranticParticles.GetProperty "PostDivideByAlpha") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "ShutterAngleInDegrees" (FranticParticles.GetProperty "ShutterAngleInDegrees") to:JobInfoFile)catch()
					try(format "%_%=%\n" rendererID "ShutterBias" (FranticParticles.GetProperty "ShutterBias") to:JobInfoFile)catch()

					
					try(format "%_%=%\n" rendererID "Matte_UseMatteObjects" (FranticParticles.GetProperty "Matte:UseMatteObjects") to:JobInfoFile)catch()
				)--END KRAKATOA EXPORT PROPERTIES
				
				--MENTAL RAY RENDERER PROPERTIES
				if rendererID == "mentalray" AND SMTDSettings.ExportAdvancedRenderInfoMentalRay then
				(
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()

					local samples_list = #("1/64","1/16", "1/4", "1", "4", "16", "64", "256", "1024" )
					format "mentalray_MinimumSamples_enums=%\n" samples_list[renderers.current.MinimumSamples+4] to:JobInfoFile
					for i = 0 to samples_list.count-1 do 
						format "mentalray_MinimumSamples_enums%=%\n" i samples_list[i+1] to:JobInfoFile
						
					format "mentalray_MaximumSamples_enums=%\n" samples_list[renderers.current.MaximumSamples+4] to:JobInfoFile
					for i = 0 to samples_list.count-1 do 
						format "mentalray_MaximumSamples_enums%=%\n" i samples_list[i+1] to:JobInfoFile
					
					local filter_list = #("Box", "Gauss", "Triangle", "Mitchell", "Lanczos")
					format "mentalray_filter_enums=%\n" filter_list[renderers.current.filter+1] to:JobInfoFile
					for i = 0 to 4 do 
						format "mentalray_filter_enums%=%\n" i filter_list[i+1] to:JobInfoFile
						
					local order_list = #("Hilbert (best)", "Spiral", "Left to right", "Right to left", "Top-down", "Bottom-up")
					format "mentalray_TaskOrder_enums=%\n" order_list[renderers.current.TaskOrder+1] to:JobInfoFile
					for i = 0 to 5 do 
						format "mentalray_TaskOrder_enums%=%\n" i order_list[i+1] to:JobInfoFile				

					local order_list = for i = 1 to 15 collect ((i*i) as string)
					format "mentalray_RapidCollectRate_enums=%\n" order_list[renderers.current.RapidCollectRate] to:JobInfoFile
					for i = 0 to order_list.count-1 do 
						format "mentalray_RapidCollectRate_enums%=%\n" i order_list[i+1] to:JobInfoFile				
				)--END MENTAL RAY RENDERER PROPERTIES
				
				--FINAL RENDERER PROPERTIES
				if rendererID == "finalrender" AND SMTDSettings.ExportAdvancedRenderInfoFinalRender then
				(
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()
					
					local filter_list = #("Area","Blackman","Blend","Catmull-Rom","Cook Variable","Cubic","Plate Match/MAX R2","Mitchell-Netravali","Quadratic", "Sharp Quadratic", "Soften", "VRayBoxFilter","VRayLanczosFilter","VRaySincFilter","VRayTriangleFilter","Video")
					for i = 0 to filter_list.count-1 do 
						format "finalrender_aaFilterName%=%\n" i filter_list[i+1] to:JobInfoFile
					
					local size_list = #("16","32","64","128","256")
					format "finalrender_bucketSize_enums=%\n"  size_list[renderers.current.bucketSize+1] to:JobInfoFile
					for i = 0 to size_list.count-1 do 
						format "finalrender_bucketSize_enums%=%\n" i size_list[i+1] to:JobInfoFile
						
					local order_list = #("Top to Bottom","Left to Right","Spiral","Random","Hilbert")
					format "finalrender_bucketOrder_enums=%\n"  order_list[renderers.current.bucketOrder+1] to:JobInfoFile
					for i = 0 to order_list.count-1 do 
						format "finalrender_bucketOrder_enums%=%\n" i order_list[i+1] to:JobInfoFile
					
					local clear_list = #("Nothing","Clear Buffer","Clear Grid","Darken")
					format "finalrender_clearOptions_enums=%\n"  clear_list[renderers.current.clearOptions+1] to:JobInfoFile
					for i = 0 to clear_list.count-1 do 
						format "finalrender_clearOptions_enums%=%\n" i clear_list[i+1] to:JobInfoFile
					
					local storage_list = #("int (8 bpc)","int (16 bpc)","float (32 bpc)")
					format "finalrender_storage_enums=%\n"  storage_list[renderers.current.storage+1] to:JobInfoFile
					for i = 0 to storage_list.count-1 do 
						format "finalrender_storage_enums%=%\n" i storage_list[i+1] to:JobInfoFile
					
					local mode_list = #("Intensity","Intensity Centered","Vector Local Space","Vector Camera Space","Vector World Space")
					format "finalrender_mtdMode_enums=%\n"  mode_list[renderers.current.mtdMode+1] to:JobInfoFile
					for i = 0 to mode_list.count-1 do 
						format "finalrender_mtdMode_enums%=%\n" i mode_list[i+1] to:JobInfoFile
						
					local lens_list = #("Circular","Rhombic","Hexagon","Octagon","Triangle","Pentagon","Heptagon","Nanogon")
					format "finalrender_lensType_enums=%\n"  lens_list[renderers.current.lensType+1] to:JobInfoFile
					for i = 0 to lens_list.count-1 do 
						format "finalrender_lensType_enums%=%\n" i lens_list[i+1] to:JobInfoFile
					
					local type_list = #("Linear","Exponential","HSV Exponential","Gamma")
					format "finalrender_colorMapType_enums=%\n"  type_list[renderers.current.colorMapType+1] to:JobInfoFile
					for i = 0 to type_list.count-1 do 
						format "finalrender_colorMapType_enums%=%\n" i type_list[i+1] to:JobInfoFile
					
					local sampling_list = #("Absolute","Relative","Automatic")
					format "finalrender_geomSmpMode_enums=%\n"  sampling_list[renderers.current.geomSmpMode+1] to:JobInfoFile
					for i = 0 to sampling_list.count-1 do 
						format "finalrender_geomSmpMode_enums%=%\n" i sampling_list[i+1] to:JobInfoFile
					
					local skylight_list = #("Simple Sky","Physical Sky")
					format "finalrender_skyType_enums=%\n"  skylight_list[renderers.current.skyType+1] to:JobInfoFile
					for i = 0 to skylight_list.count-1 do 
						format "finalrender_skyType_enums%=%\n" i skylight_list[i+1] to:JobInfoFile
				)--END FINAL RENDERER PROPERTIES

				--VRAY RENDERER PROPERTIES
				if rendererID == "vray" AND SMTDSettings.ExportAdvancedRenderInfoVRay then
				(
					for p in getPropNames renderers.current do
					(
						--Ensure if rawFileName is declared that we add Delimiter to the end of the filename
						if p != undefined and p != "" and p == #output_rawFileName then
						(
							tempFile = getProperty renderers.current #output_rawFileName
							if tempFile != undefined and tempFile != "" do --Now adding the stereo camera token and state set token if needed
							(
								rawFile = (getFileNamePath tempFile) + stereoCameraToken 
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFileNameFile tempFile) pattern:(SMTDSettings.StateSetName +"_*") do rawFile += SMTDSettings.StateSetName + "_"
								rawFile += (getFileNameFile tempFile) 
								--if not (SMTDSettings.RemovePadding and rendTimeType == 1) do rawFile += SMTDSettings.Delimiter 
								rawFile += (getFileNameType tempFile)
								try(format "%_%=%\n" rendererID (p as string) rawFile to:JobInfoFile)catch()
							)
						)
						else if p != undefined and p != "" and p == #output_splitfilename then
						(
							tempFile = getProperty renderers.current #output_splitfilename
							if tempFile != undefined and tempFile != "" do --Now adding the stereo camera token and state set token if needed
							(
								splitFile = (getFileNamePath tempFile) + stereoCameraToken 
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFileNameFile tempFile) pattern:(SMTDSettings.StateSetName +"_*") do splitFile += SMTDSettings.StateSetName + "_"
								splitFile +=  (getFileNameFile tempFile) 
								--if not (SMTDSettings.RemovePadding and rendTimeType == 1) do splitFile += SMTDSettings.Delimiter 
								splitFile += (getFileNameType tempFile)
								try(format "%_%=%\n" rendererID (p as string) splitFile to:JobInfoFile)catch()
							)
						)
						else if p != undefined and p != #system_vrayLog_show do --Remove #system_vrayLog_show entry as it is handled explicitly further down
								try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()
					)--end p loop
						
					local enum_list = #("Irradiance map","Photon map","Brute force","Light cache")
					format "vray_gi_primary_type_enums=%\n"  enum_list[renderers.current.gi_primary_type+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_gi_primary_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("None","Photon map","Brute force","Light cache")
					format "vray_gi_secondary_type_enums=%\n"  enum_list[renderers.current.gi_secondary_type+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_gi_secondary_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Show new samples as brighter","Show new samples as green","Full preview")
					format "vray_gi_irradmap_previewMode_enums=%\n" enum_list[renderers.current.gi_irradmap_previewMode+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do
						format "vray_gi_irradmap_previewMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Screen","World")
					format "vray_gi_irradmap_detail_scale_enums=%\n" enum_list[renderers.current.gi_irradmap_detail_scale+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do
						format "vray_gi_irradmap_detail_scale_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Weighted average (good/robust)","Least squares fit (good/smooth)", "Delone triangulation (good/exact)","Least squares w/ Voronoi weights (test)")
					format "vray_adv_irradmap_interpolationType_enums=%\n"  enum_list[renderers.current.adv_irradmap_interpolationType+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_adv_irradmap_interpolationType_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Quad-balanced (good)","Nearest (draft)", "Overlapping (very good/fast)","Density-based (best)")
					format "vray_adv_irradmap_lookupType_enums=%\n"  enum_list[renderers.current.adv_irradmap_lookupType+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_adv_irradmap_lookupType_enums%=%\n" i enum_list[i+1] to:JobInfoFile	

					--IRRADIANCE MAP MODE REQUIRES SPECIAL HANDLING BOTH HERE AND WHEN CUSTOMIZING!
					--ONLY VRAY ADVANCED VERSIONS 1.4, 1.5 & 2.x/3.x ARE CURRENTLY HANDLED EXPLICITLY.

					--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.4 - BUCKET MODE IS FIRST ENUM!
					if matchPattern ((classof renderers.current) as string) pattern:"*_1_4*" then
					(
						local enum_list = #("Bucket Mode","Single Frame", "Multiframe Incremental","From File","Add to Current Map","Incremental Add to Current Map")
						format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.adv_irradmap_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile		
					)
					--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.5 - BUCKET MODE IS LAST ENUM!
					else if matchPattern ((classof renderers.current) as string) pattern:"*_1_5*" then
					(
						local enum_list = #("Single Frame", "Multiframe Incremental","From File","Add to Current Map","Incremental Add to Current Map","Bucket Mode")
						format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.adv_irradmap_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					)
					--SPECIAL CASE HANDLING FOR VRAY ADVANCED 2.x & 3.x
					else
					(
						local enum_list = #("Single frame", "Multiframe incremental","From file","Add to current map","Incremental add to current map","Bucket mode","Animation (prepass)","Animation (rendering)")
						format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.adv_irradmap_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					)

					--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.6 - NEW ENUM FOR DEFAULT LIGHTS
					if matchPattern ((classof renderers.current) as string) pattern:"*_1_60*" do
					(
						if (classof( renderers.current.options_defaultLights ) as string) == "Integer" do
						(
							local enum_list = #("Off","On", "Off with GI")
							format "vray_options_defaultLights_enums=%\n"  enum_list[renderers.current.options_defaultLights+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_options_defaultLights_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)
					)

					--LC Scale
					local enum_list = #("Screen","World")
					format "vray_lightcache_scale_enums=%\n" enum_list[renderers.current.lightcache_scale+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do
						format "vray_lightcache_scale_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--LC Filter
					local enum_list = #("None","Nearest","Fixed")
					format "vray_lightcache_filter_type_enums=%\n" enum_list[renderers.current.lightcache_filter_type+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do
						format "vray_lightcache_filter_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--LC Mode
					-- Disabled due to conflict which is explained in customise.ms - MO
					/*
					local enum_list = #("Single frame","Fly-through","From file","Progressive path tracing")
					format "vray_lightcache_mode_enums=%\n" enum_list[renderers.current.lightcache_mode+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do
						format "vray_lightcache_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					*/

					--Sequence
					local enum_list = #("Top->Bottom","Left->Right", "Checker","Spiral","Triangulation","Hilbert curve")
					format "vray_system_region_sequence_enums=%\n"  enum_list[renderers.current.system_region_sequence+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_system_region_sequence_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--Division Method
					local enum_list = #("Size","Count")
					format "vray_system_region_meaning_enums=%\n"  enum_list[renderers.current.system_region_meaning+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_system_region_meaning_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--Previous render
					local enum_list = #("Unchanged","Cross","Fields","Darken","Blue","Clear")
					format "vray_system_previousRender_enums=%\n"  enum_list[renderers.current.system_previousRender+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_system_previousRender_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--Default geometry
					local enum_list = #("Static","Dynamic","Auto")
					format "vray_system_instancedObjects_enums=%\n"  enum_list[renderers.current.system_instancedObjects+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_system_instancedObjects_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--Frame Stamp - Justify
					local enum_list = #("Left", "Center", "Right")
					format "vray_system_frameStamp_justify_enums=%\n"  enum_list[renderers.current.system_frameStamp_justify+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vray_system_frameStamp_justify_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					--SPECIAL CASE HANDLING FOR VRAY ADVANCED v1-v2.x / v3.x
					vrayVersionCheck = try(vrayVersion())catch(undefined) --2 element array returned in VRay v3.0+ only #(version, build)
					if vrayVersionCheck != undefined then
					(
						local vrayVer = vrayVersionCheck[1][1] as integer
						if vrayVer >= 3 do (
							-- "colorMapping_adaptationOnly" - VRay v3+
							local enum_list = #("Color mapping and gamma","None (don't apply anything)", "Color mapping only (no gamma)")
							format "vray_colorMapping_adaptationOnly_enums=%\n" enum_list[renderers.current.colorMapping_adaptationOnly+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do
								format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							
							-- "imageSampler_type" - VRay v3+
							local enum_list = #("Fixed","Adaptive", "Adaptive subdivision","Progressive")
							format "vray_imageSampler_type_enums=%\n"  enum_list[renderers.current.imageSampler_type+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_imageSampler_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							
							-- "camera_type" - VRay v3+
							local enum_list = #("Default","Spherical","Cylindrical (point)","Cylindrical (ortho)","Box","Fish eye","Warped spherical (old-style)","Orthographic","Perspective","Spherical panorama")
							format "vray_camera_type_enums=%\n" enum_list[renderers.current.camera_type+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do
								format "vray_camera_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)
					)
					else
					(	
						if matchPattern ((classof renderers.current) as string) pattern:"*_2_40_04*" then
						(
							-- "colorMapping_adaptationOnly" - VRay v2.40.04 only
							local enum_list = #("Color mapping and gamma","None (don't apply anything)", "Color mapping only (no gamma)")
							format "vray_colorMapping_adaptationOnly_enums=%\n" enum_list[renderers.current.colorMapping_adaptationOnly+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do
								format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)
						else
						(
							-- "colorMapping_adaptationOnly" - VRay v1/2.40.03 or earlier only
							local enum_list = #("true","false") --Do NOT change the case of true/false! (keep it lowercase)
							format "vray_colorMapping_adaptationOnly_enums=%\n" renderers.current.colorMapping_adaptationOnly to:JobInfoFile
							for i = 0 to enum_list.count-1 do
								format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)

						-- "imageSampler_type" - VRay v1/2
						local enum_list = #("Fixed Rate","Adaptive QMC", "Adaptive Subdivision")
						format "vray_imageSampler_type_enums=%\n"  enum_list[renderers.current.imageSampler_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_imageSampler_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						
						-- "camera_type" - VRay v1/2
						local enum_list = #("Default","Spherical","Cylindrical (point)","Cylindrical (ortho)","Box","Fish eye","Warped spherical (old-style)")
						format "vray_camera_type_enums=%\n" enum_list[renderers.current.camera_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_camera_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					)

					--Show Log Window
					if (hasProperty renderers.current #system_vrayLog_show) AND classof(renderers.current.system_vrayLog_show) == Integer then
					(
						local enum_list = #("Never","Always","Only on error/warning","Only on error")
						format "vray_system_vrayLog_show_enums=%\n"  enum_list[renderers.current.system_vrayLog_show+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_vrayLog_show_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					)
					else
						try(format "vray_system_vrayLog_show=%\n" (getProperty renderers.current #system_vrayLog_show) to:JobInfoFile)catch()
				)--END VRAY RENDERER PROPERTIES

				--VRAY RT RENDERER PROPETIES
				if rendererID == "vrayrt" AND SMTDSettings.ExportAdvancedRenderInfoVRayRT then
				(
					--EXPORT ALL VRAY RENDERER SETTINGS (EMBEDDED IN RT RENDERER)
					if (isProperty renderers.current #V_Ray_settings) do
					(
						for p in getPropNames renderers.current.V_Ray_settings do
							--Ensure if rawFileName is declared that we add Delimiter to the end of the filename
							if p != undefined and p != "" and p == #output_rawFileName then
							(
								tempFile = getProperty renderers.current.V_Ray_settings #output_rawFileName
								if tempFile != undefined and tempFile != "" do
									if (SMTDSettings.RemovePadding and rendTimeType == 1) then
										rawFile = (getFileNamePath tempFile) + (getFileNameFile tempFile) + (getFileNameType tempFile)
									else
										rawFile = (getFileNamePath tempFile) + (getFileNameFile tempFile) + SMTDSettings.Delimiter + (getFileNameType tempFile)
									try(format "vray_%=%\n" (p as string) rawFile to:JobInfoFile)catch()
							)
							else
								if p != undefined and p != #system_vrayLog_show do --Remove #system_vrayLog_show entry as it is handled explicitly further down
									try(format "vray_%=%\n" (p as string) (getProperty renderers.current.V_Ray_settings p) to:JobInfoFile)catch()

						local enum_list = #("Irradiance map","Photon map","Brute force","Light cache")
						format "vray_gi_primary_type_enums=%\n"  enum_list[renderers.current.V_Ray_settings.gi_primary_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_gi_primary_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						local enum_list = #("None","Photon map","Brute force","Light cache")
						format "vray_gi_secondary_type_enums=%\n"  enum_list[renderers.current.V_Ray_settings.gi_secondary_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_gi_secondary_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						local enum_list = #("Show new samples as brighter","Show new samples as green","Full preview")
						format "vray_gi_irradmap_previewMode_enums=%\n" enum_list[renderers.current.V_Ray_settings.gi_irradmap_previewMode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_gi_irradmap_previewMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						local enum_list = #("Screen","World")
						format "vray_gi_irradmap_detail_scale_enums=%\n" enum_list[renderers.current.V_Ray_settings.gi_irradmap_detail_scale+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_gi_irradmap_detail_scale_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						local enum_list = #("Weighted average (good/robust)","Least squares fit (good/smooth)", "Delone triangulation (good/exact)","Least squares w/ Voronoi weights (test)")
						format "vray_adv_irradmap_interpolationType_enums=%\n"  enum_list[renderers.current.V_Ray_settings.adv_irradmap_interpolationType+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_adv_irradmap_interpolationType_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						local enum_list = #("Quad-balanced (good)","Nearest (draft)", "Overlapping (very good/fast)","Density-based (best)")
						format "vray_adv_irradmap_lookupType_enums=%\n"  enum_list[renderers.current.V_Ray_settings.adv_irradmap_lookupType+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_adv_irradmap_lookupType_enums%=%\n" i enum_list[i+1] to:JobInfoFile	

						--IRRADIANCE MAP MODE REQUIRES SPECIAL HANDLING BOTH HERE AND WHEN CUSTOMIZING!
						--ONLY VRAY ADVANCED VERSIONS 1.4, 1.5 & 2.x/3.x ARE CURRENTLY HANDLED EXPLICITLY.

						--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.4 - BUCKET MODE IS FIRST ENUM!
						if matchPattern ((classof renderers.current) as string) pattern:"*_1_4*" then
						(
							local enum_list = #("Bucket Mode","Single Frame", "Multiframe Incremental","From File","Add to Current Map","Incremental Add to Current Map")
							format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.V_Ray_settings.adv_irradmap_mode+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile		
						)
						--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.5 - BUCKET MODE IS LAST ENUM!
						else if matchPattern ((classof renderers.current) as string) pattern:"*_1_5*" then
						(
							local enum_list = #("Single Frame", "Multiframe Incremental","From File","Add to Current Map","Incremental Add to Current Map","Bucket Mode")
							format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.V_Ray_settings.adv_irradmap_mode+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)
						--SPECIAL CASE HANDLING FOR VRAY ADVANCED 2.x & 3.x
						else
						(
							local enum_list = #("Single frame", "Multiframe incremental","From file","Add to current map","Incremental add to current map","Bucket mode","Animation (prepass)","Animation (rendering)")
							format "vray_adv_irradmap_mode_enums=%\n"  enum_list[renderers.current.V_Ray_settings.adv_irradmap_mode+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_adv_irradmap_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)

						--SPECIAL CASE HANDLING FOR VRAY ADVANCED 1.6 - NEW ENUM FOR DEFAULT LIGHTS
						if matchPattern ((classof renderers.current) as string) pattern:"*_1_60*" do
						(
							if (classof( renderers.current.V_Ray_settings.options_defaultLights ) as string) == "Integer" do
							(
								local enum_list = #("Off","On", "Off with GI")
								format "vray_options_defaultLights_enums=%\n"  enum_list[renderers.current.V_Ray_settings.options_defaultLights+1] to:JobInfoFile
								for i = 0 to enum_list.count-1 do 
									format "vray_options_defaultLights_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							)
						)

						--LC Scale
						local enum_list = #("Screen","World")
						format "vray_lightcache_scale_enums=%\n" enum_list[renderers.current.V_Ray_settings.lightcache_scale+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_lightcache_scale_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--LC Filter
						local enum_list = #("None","Nearest","Fixed")
						format "vray_lightcache_filter_type_enums=%\n" enum_list[renderers.current.V_Ray_settings.lightcache_filter_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_lightcache_filter_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--LC Mode
						-- Disabled due to conflict which is explained in customise.ms - MO
						/*
						local enum_list = #("Single frame","Fly-through","From file","Progressive path tracing")
						format "vray_lightcache_mode_enums=%\n" enum_list[renderers.current.V_Ray_settings.lightcache_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "vray_lightcache_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						*/

						--Sequence
						local enum_list = #("Top->Bottom","Left->Right", "Checker","Spiral","Triangulation","Hilbert curve")
						format "vray_system_region_sequence_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_region_sequence+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_region_sequence_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--Division Method
						local enum_list = #("Size","Count")
						format "vray_system_region_meaning_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_region_meaning+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_region_meaning_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--Previous render
						local enum_list = #("Unchanged","Cross","Fields","Darken","Blue","Clear")
						format "vray_system_previousRender_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_previousRender+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_previousRender_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--Default geometry
						local enum_list = #("Static","Dynamic","Auto")
						format "vray_system_instancedObjects_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_instancedObjects+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_instancedObjects_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--Frame Stamp - Justify
						local enum_list = #("Left", "Center", "Right")
						format "vray_system_frameStamp_justify_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_frameStamp_justify+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "vray_system_frameStamp_justify_enums%=%\n" i enum_list[i+1] to:JobInfoFile

						--SPECIAL CASE HANDLING FOR VRAY ADVANCED v1-v2.x / v3.x
						vrayVersionCheck = try(vrayVersion())catch(undefined) --2 element array returned in VRay v3.0+ only #(version, build)
						if vrayVersionCheck != undefined then
						(
							local vrayVer = vrayVersionCheck[1][1] as integer
							if vrayVer >= 3 do (
								-- "colorMapping_adaptationOnly" - VRay v3+
								local enum_list = #("Color mapping and gamma","None (don't apply anything)", "Color mapping only (no gamma)")
								format "vray_colorMapping_adaptationOnly_enums=%\n" enum_list[renderers.current.V_Ray_settings.colorMapping_adaptationOnly+1] to:JobInfoFile
								for i = 0 to enum_list.count-1 do
									format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
								
								-- "imageSampler_type" - VRay v3+
								local enum_list = #("Fixed","Adaptive", "Adaptive subdivision","Progressive")
								format "vray_imageSampler_type_enums=%\n"  enum_list[renderers.current.V_Ray_settings.imageSampler_type+1] to:JobInfoFile
								for i = 0 to enum_list.count-1 do 
									format "vray_imageSampler_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
								
								-- "camera_type" - VRay v3+
								local enum_list = #("Default","Spherical","Cylindrical (point)","Cylindrical (ortho)","Box","Fish eye","Warped spherical (old-style)","Orthographic","Perspective","Spherical panorama")
								format "vray_camera_type_enums=%\n" enum_list[renderers.current.V_Ray_settings.camera_type+1] to:JobInfoFile
								for i = 0 to enum_list.count-1 do
									format "vray_camera_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							)
						)
						else
						(	
							if matchPattern ((classof renderers.current) as string) pattern:"*_2_40_04*" then
							(
								-- "colorMapping_adaptationOnly" - VRay v2.40.04 only
								local enum_list = #("Color mapping and gamma","None (don't apply anything)", "Color mapping only (no gamma)")
								format "vray_colorMapping_adaptationOnly_enums=%\n" enum_list[renderers.current.V_Ray_settings.colorMapping_adaptationOnly+1] to:JobInfoFile
								for i = 0 to enum_list.count-1 do
									format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							)
							else
							(
								-- "colorMapping_adaptationOnly" - VRay v1/2.40.03 or earlier only
								local enum_list = #("true","false") --Do NOT change the case of true/false! (keep it lowercase)
								format "vray_colorMapping_adaptationOnly_enums=%\n" renderers.current.V_Ray_settings.colorMapping_adaptationOnly to:JobInfoFile
								for i = 0 to enum_list.count-1 do
									format "vray_colorMapping_adaptationOnly_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							)

							-- "imageSampler_type" - VRay v1/2
							local enum_list = #("Fixed Rate","Adaptive QMC", "Adaptive Subdivision")
							format "vray_imageSampler_type_enums=%\n"  enum_list[renderers.current.V_Ray_settings.imageSampler_type+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_imageSampler_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							
							-- "camera_type" - VRay v1/2
							local enum_list = #("Default","Spherical","Cylindrical (point)","Cylindrical (ortho)","Box","Fish eye","Warped spherical (old-style)")
							format "vray_camera_type_enums=%\n" enum_list[renderers.current.V_Ray_settings.camera_type+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do
								format "vray_camera_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)

						--Show Log Window
						if (hasProperty renderers.current.V_Ray_settings #system_vrayLog_show) AND classof(renderers.current.V_Ray_settings.system_vrayLog_show) == Integer then
						(
							local enum_list = #("Never","Always","Only on error/warning","Only on error")
							format "vray_system_vrayLog_show_enums=%\n"  enum_list[renderers.current.V_Ray_settings.system_vrayLog_show+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "vray_system_vrayLog_show_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)
						else
							try(format "vray_system_vrayLog_show=%\n" (getProperty renderers.current.V_Ray_settings #system_vrayLog_show) to:JobInfoFile)catch()
					)--end if not V_Ray_settings property exists

					--EXPORT ALL VRAY RT SPECIFIC SETTINGS
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()

					local enum_list = #("CPU","OpenCL","CUDA")
					format "vrayrt_engine_type_enums=%\n"  enum_list[renderers.current.engine_type+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vrayrt_engine_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Full-size textures (no paging)","Resize textures (no paging)","Paging with full-size textures")
					format "vrayrt_opencl_resizeTextures_enums=%\n"  enum_list[renderers.current.opencl_resizeTextures+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vrayrt_opencl_resizeTextures_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Float","Half","8-bit")
					format "vrayrt_opencl_textureFormat_enums=%\n"  enum_list[renderers.current.opencl_textureFormat+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vrayrt_opencl_textureFormat_enums%=%\n" i enum_list[i+1] to:JobInfoFile

					local enum_list = #("Disabled","Side by side","Interlaced","Checkered","Anaglyph (Red, Cyan)","Anaglyph (Green, Magenta)","OpenGL stereo","Duplicate (mono)")
					format "vrayrt_stereo_type_enums=%\n"  enum_list[renderers.current.stereo_type+1] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "vrayrt_stereo_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
				)
				--END VRAY RT RENDERER PROPETIES

				--MAXWELL RENDERER PROPERTIES
				if rendererID == "maxwell" AND SMTDSettings.ExportAdvancedRenderInfoMaxwell then
				(
					for p in getPropNames renderers.current do
					(
						try
						(
							p = (p as string)
							prop = (getProperty renderers.current p)
							
							-- Special case handling for string values - we need to strip off the leading #
							if p == "gsMXCLFlags" or p == "gsMXSOutputPath" or p == "gsMXIOutputPath" or p == "slApertureImagePath" or p == "slObscureImagePath" then
							(
								prop = (prop as string)
								if prop.count > 0 and prop[1] == "#" then
									prop = replace prop 1 1 ""
							)
							format "%_%=%\n" rendererID p prop to:JobInfoFile
						)
						catch ()
					)
					
					if renderers.current.version >= 20 then
					(
						/*
						local enum_list = #("Per Object","On", "Off")
						format "maxwell_gsMotionBlur_enums=%\n"  enum_list[renderers.current.gsMotionBlur+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "maxwell_gsMotionBlur_enums%=%\n" i enum_list[i+1] to:JobInfoFile						
						*/
						
						/*
						local enum_list = #("sRGB","Adobe RGB 98", "Apple RGB / SGI","PAL / SECAM","NTSC 1953","NTSC 1979","Wide Gamut RGB","ProPhoto RGB (ROMM)","ECI RGB","CIE 1931","Bruce RGB","ColorMatch RGB","Best RGB","Don RGB 4")
						format "maxwell_gsColorSpace_enums=%\n"  enum_list[renderers.current.gsColorSpace+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "maxwell_gsColorSpace_enums%=%\n" i enum_list[i+1] to:JobInfoFile						
						*/
						
						/*
						try
						(
							local enum_list = #("8","16", "32")
							format "maxwell_gsDepth_enums=%\n"  renderers.current.gsDepth to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "maxwell_gsDepth_enums%=%\n" i enum_list[i+1] to:JobInfoFile	
						)
						catch ()
						*/
						
						local enum_list = #("Diffuse+Reflection","Diffuse", "Reflection")
						format "maxwell_gsChannelRenderType_enums=%\n"  enum_list[renderers.current.gsChannelRenderType+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "maxwell_gsChannelRenderType_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					)
				)--END MAXWELL RENDERER PROPERTIES

				--CORONA RENDERER PROPERTIES
				if rendererID == "corona" AND SMTDSettings.ExportAdvancedRenderInfoCorona then
				(
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()

					--Check Corona version. Version's earlier than Alpha v6 are NOT supported and are no longer available from Corona Renderer website.
					coronaVersion = try(CoronaRenderer.CoronaFp.getCoronaVersion())catch(undefined)

					if coronaVersion == undefined or coronaVersion == "Alpha v7.2" then --assume Corona Alpha v6 FREE VERSION / NO UPDATES / NO SUPPORT or Corona Alpha v7.2
					(
						try(
						enum_list = #( "Bucket", "--", "Progressive", "Bidir/VCM" ) -- "--" handles irregular order of DDL items
						format "corona_renderer_enums=%\n"  enum_list[renderers.current.renderer+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_renderer_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.renderer]"))catch())

						try(
						enum_list = #( "None", "Path Tracing" )
						format "corona_GI_solver_enums=%\n"  enum_list[renderers.current.GI_solver+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_GI_solver_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.GI_solver]"))catch())

						try(
						enum_list = #( "None", "Path Tracing", "--", "HD Cache" ) -- "--" handles irregular order of DDL items
						format "corona_GI_secondary_solver_enums=%\n"  enum_list[renderers.current.GI_secondary_solver+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_GI_secondary_solver_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.GI_secondary_solver]"))catch())

						try(
						enum_list = #( "Circular", "Bladed", "Custom" )
						format "corona_Type_of_bokeh_shape_enums=%\n"  enum_list[renderers.current.Type_of_bokeh_shape+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_Type_of_bokeh_shape_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.Type_of_bokeh_shape]"))catch())

						try(
						enum_list = #( "None", "Native 3dsmax VFB", "Corona VFB" )
						format "corona_Type_of_VFB_window_enums=%\n"  enum_list[renderers.current.Type_of_VFB_window+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_Type_of_VFB_window_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.Type_of_VFB_window]"))catch())

						try(
						enum_list = #( "None", "Box", "Gaussian", "Tent" ) -- "Tent" & "Gaussian" order swapped to match the DDL item index
						format "corona_Image_Filter_enums=%\n"  enum_list[renderers.current.Image_Filter+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_Image_Filter_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.Image_Filter]"))catch())

						-- Not exposed to UI, but render property is present in Corona Alpha v6 & Alpha v7
						try(
						enum_list = #( "[PT+MIS] Path Tracing + Next Event Estimage", "[LT] Light Tracing", "[PPM] Progressive Photon Mapping", "[BDPM] Bidirectional PPM", "[BDPT] Bidirectional Path Tracing", "[VCM] Vertex Connection and Merging" )
						format "corona_VCM_mode_enums=%\n"  enum_list[renderers.current.VCM_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_VCM_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.VCM_mode]"))catch())

						if coronaVersion == "Alpha v7.2" then --Corona Alpha v7.2 ONLY
						(
							try(
							enum_list = #( "Calculate From Scratch", "Load From File", "Load From File + Append" )
							format "corona_HD_cache_precalculation_mode_enums=%\n"  enum_list[renderers.current.HD_cache_precalculation_mode+1] to:JobInfoFile
							for i = 0 to enum_list.count-1 do 
								format "corona_HD_cache_precalculation_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
							)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.HD_cache_precalculation_mode]"))catch())
						)
					)
					--All other versions including pre 1.0 / final 1.0+ build
					else
					(
						try(
						eum_list = #( "Use simple exposure", "Use photographic exposure" )
						format "corona_colormap_exposureType_enums=%\n"  enum_list[renderers.current.colormap_exposureType+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_colormap_exposureType_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.colormap_exposureType]"))catch())

						try(
						enum_list = #( "None (biased)", "Path Tracing" )
						format "corona_shading_primary_solver_enums=%\n"  enum_list[renderers.current.shading_primarySolver+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_shading_primary_solver_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.shading_primarySolver]"))catch())

						try(
						enum_list = #( "None (biased)", "Path Tracing", "UHD Cache", "HD Cache (legacy)" )
						format "corona_shading_secondary_solver_enums=%\n"  enum_list[renderers.current.shading_secondarySolver+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_shading_secondary_solver_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.shading_secondarySolver]"))catch())

						try(
						enum_list = #( "Use 3ds max settings (Environment tab)", "Use Corona:" )
						format "corona_bg_source_enums=%\n"  enum_list[renderers.current.bg_source+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_bg_source_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.bg_source]"))catch())

						try(
						enum_list = #( "Circular", "Bladed", "Custom" )
						format "corona_dof_bokehShape_enums=%\n"  enum_list[renderers.current.dof_bokehShape+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_dof_bokehShape_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.dof_bokehShape]"))catch())

						try(
						enum_list = #( "Screen size (px):", "World size (units):" )
						format "corona_geometry_displace_subdivType_enums=%\n"  enum_list[renderers.current.geometry_displace_subdivType+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_geometry_displace_subdivType_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.geometry_displace_subdivType]"))catch())

						try(
						enum_list = #( "Bucket", "--", "Progressive", "Bidir/VCM" ) -- "--" handles irregular order of DDL items
						format "corona_shading_renderEngine_enums=%\n"  enum_list[renderers.current.shading_renderEngine+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_shading_renderEngine_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.shading_renderEngine]"))catch())

						try(
						enum_list = #( "None (slooow)", "BVH full SAH", "Intel(r) Embree" )
						format "corona_geometry_accelerationStructure_enums=%\n"  enum_list[renderers.current.geometry_accelerationStructure+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_geometry_accelerationStructure_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.geometry_accelerationStructure]"))catch())
						
						try(
						enum_list = #( "Shared PRNG", "Per-pixel Shirley", "One-sample High-D", "5D Deterministic + PRNG", "Optimal 1S High-D", "Per-pixel Xorshift128", "Per-pixel TEA", "Per-pixel Xorshift*", "5D High-D + PRNG" )
						format "corona_system_randomSampler_enums=%\n"  enum_list[renderers.current.system_randomSampler+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_system_randomSampler_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.system_randomSampler]"))catch())

						try(
						enum_list = #( "None", "All but opacity", "All" )
						format "corona_texmapFiltering_enums=%\n"  enum_list[renderers.current.texmapFiltering+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_texmapFiltering_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.texmapFiltering]"))catch())

						try(
						enum_list = #( "Combined", "Better Object-based", "Object-based" )
						format "corona_lights_solver_enums=%\n"  enum_list[renderers.current.lights_solver+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_lights_solver_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.lights_solver]"))catch())

						try(
						enum_list = #( "Lights only", "BSDF only", "MIS - both (best)" )
						format "corona_lights_samplingMode_enums=%\n"  enum_list[renderers.current.lights_samplingMode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do
							format "corona_lights_samplingMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.lights_samplingMode]"))catch())

						-- Not exposed to UI, but render property is present in Corona Alpha v6, Alpha v7 & pre1.0 build
						try(
						enum_list = #( "[PT+MIS] Path Tracing + Next Event Estimage", "[LT] Light Tracing", "[PPM] Progressive Photon Mapping", "[BDPM] Bidirectional PPM", "[BDPT] Bidirectional Path Tracing", "[VCM] Vertex Connection and Merging" )
						format "corona_gi_vcm_mode_enums=%\n"  enum_list[renderers.current.gi_vcm_mode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_gi_vcm_mode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.gi_vcm_mode]"))catch())

						-- Not exposed to UI, but render property is present in Corona Alpha pre1.0 build
						try(
						enum_list = #( "Still frame (fast precomputation)", "Animation (flickerfree)" )
						format "corona_gi_uhdcache_preset_enums=%\n"  enum_list[renderers.current.gi_uhdcache_preset+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_gi_uhdcache_preset_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.gi_uhdcache_preset]"))catch())

						try(
						enum_list = #( "Calculate From Scratch", "Load From File", "Load From File + Append" )
						format "corona_gi_hdCache_precalcMode_enums=%\n"  enum_list[renderers.current.gi_hdCache_precalcMode+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_gi_hdCache_precalcMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.gi_hdCache_precalcMode]"))catch())

						try(
						enum_list = #( "None", "Native 3dsmax VFB", "Corona VFB" )
						format "corona_vfb_type_enums=%\n"  enum_list[renderers.current.vfb_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_vfb_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.vfb_type]"))catch())

						try(
						enum_list = #( "None", "Box", "Gaussian", "Tent" ) -- "Tent" & "Gaussian" order swapped to match the DDL item index
						format "corona_image_filter_type_enums=%\n"  enum_list[renderers.current.image_filter_type+1] to:JobInfoFile
						for i = 0 to enum_list.count-1 do 
							format "corona_image_filter_type_enums%=%\n" i enum_list[i+1] to:JobInfoFile
						)catch(try(SMTD_MainRollout.Ui_report ("--Corona Render Property Missing: [renderers.current.image_filter_type]"))catch())
					)
				)--END CORONA RENDERER PROPERTIES

				--IRAY RENDERER PROPERTIES
				if rendererID == "iray" AND SMTDSettings.ExportAdvancedRenderInfoIRay then
				(
					for p in getPropNames renderers.current do
					(
						if p != undefined and p == #HardwareReport then
						(
							local result = SMTDFunctions.ParseEolToSemicolon(getProperty renderers.current p)
							try(format "%_%=%\n" rendererID "HardwareReportString" result to:JobInfoFile)catch()
						)
						else
							try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()
					)
					
					enum_list = #( "#time", "#iterations", "#unlimited" )
					for i = 0 to enum_list.count-1 do 
						format "iray_durationMode%=%\n" i enum_list[i+1] to:JobInfoFile
					
					enum_list = #( "#Box", "#gauss", "#triangle" )
					for i = 0 to enum_list.count-1 do 
						format "iray_imageFilterType%=%\n" i enum_list[i+1] to:JobInfoFile

					enum_list = #( "#length", "#parametric" )
					for i = 0 to enum_list.count-1 do
						format "iray_displacementDisplaceMethod%=%\n" i enum_list[i+1] to:JobInfoFile
				)--END IRAY RENDERER PROPERTIES
				
				--QUICKSILVER RENDERER PROPERTIES
				if rendererID == "quicksilver" AND SMTDSettings.ExportAdvancedRenderInfoQuicksilver then
				(
					for p in getPropNames renderers.current do
						try(format "%_%=%\n" rendererID (p as string) (getProperty renderers.current p) to:JobInfoFile)catch()

					/*
					-- Hardware Sampling Quality
					index = case renderers.current.HardwareSamplingQuality of
					(
						#none: 1
						#2x: 2
						#4x: 3
						#8x: 4
					)
					
					enum_list = #("None (Draft)", "2x", "4x", "8x")
					format "quicksilver_HardwareSamplingQuality_enums=%\n"  enum_list[index] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "quicksilver_HardwareSamplingQuality_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					*/
					
					/*
					-- Software Sampling Quality
					index = case renderers.current.SoftwareSamplingQuality of
					(
						#none: 1
						#4x: 2
						#16x: 3
					)
					
					enum_list = #("None (Draft)", "4x", "16x")
					format "quicksilver_SoftwareSamplingQuality_enums=%\n"  enum_list[index] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "quicksilver_SoftwareSamplingQuality_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					*/
					
					/*
					-- Depth of Field Mode
					index = case try(renderers.current.DepthOfFieldMode)catch(#camera) of
					(
						#camera: 1
						#Override: 2
					)
					
					enum_list = #("From Camera","Override Camera")
					format "quicksilver_DepthOfFieldMode_enums=%\n"  enum_list[index] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "quicksilver_DepthOfFieldMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					*/
					
					/*
					-- Transparency Mode
					index = case renderers.current.TransparencyMode of
					(
						#simple: 1
						#Best: 2
					)	

					enum_list = #("Simple","Best")
					format "quicksilver_TransparencyMode_enums=%\n"  enum_list[index] to:JobInfoFile
					for i = 0 to enum_list.count-1 do 
						format "quicksilver_TransparencyMode_enums%=%\n" i enum_list[i+1] to:JobInfoFile
					*/
				)--END QUICKSILVER RENDERER PROPERTIES

				--EXPORT ADVANCED RENDERING SETTINGS ENDS HERE

				Close JobInfoFile
				true
			)
			else
				false
		),
		
		fn saveSettingsStructToMSFile theFileName =
		(
			theProps = getPropNames SMTDSettings 
			theFile = createFile theFileName
			options.printAllElements = true
			for p in theProps do
			(
				theVal = (getProperty SMTDSettings p)
				case classof theVal of
				(
					string: (
						theVal = "\"" + theVal + "\""
						newStr = ""
						for i = 1 to theVal.count do 
							newStr += (if theVal[i] == "\\" then "\\\\" else theVal[i] )
						theVal = newStr
					)
					array: (
						theVal = SMTDFunctions.formatValue theVal
					)
				)
				
				format "SMTDSettings.% = %\n" (p as string) theVal to:theFile 
			)	
			close theFile
		),
		
		fn formatValue theVal =
		(
			case classof theVal of
			(
				string: (
					newStr = ""
					for i = 1 to theVal.count do 
						newStr += (if theVal[i] == "\\" then "\\\\" else theVal[i] )
					theVal = newStr
				)
				array: (
					for i = 1 to theVal.count do
						theVal[i] = (SMTDFunctions.formatValue theVal[i])
				)
			)
			theVal
		),
		
		fn CreateImsqFile imsqFilename =
		(
			startFrame = case (rendTimeType) of
			(
				1: SMTDFunctions.GetSequenceString #(currentTime)
				2: SMTDFunctions.GetSequenceString ( SMTDFunctions.outOfOrderSequence (for t in animationRange.start to animationRange.start by 1 collect t) )
				3: SMTDFunctions.GetSequenceString ( SMTDFunctions.outOfOrderSequence (for t in rendStart to rendStart by 1 collect t) )
				4: 0
			)
			
			endFrame = case (rendTimeType) of
			(
				1: SMTDFunctions.GetSequenceString #(currentTime)
				2: SMTDFunctions.GetSequenceString ( SMTDFunctions.outOfOrderSequence (for t in animationRange.end to animationRange.end by 1 collect t) )
				3: SMTDFunctions.GetSequenceString ( SMTDFunctions.outOfOrderSequence (for t in rendEnd to rendEnd by 1 collect t) )
				4: 0
			)
			
			local imsqFile = CreateFile imsqFilename
			if (imsqFile != undefined) then
			(
				path = getFilenamePath RendOutputFilename
				filename = getFilenameFile RendOutputFilename
				extension = getFilenameType RendOutputFilename
						
				format "<ImageSequence Pattern=\"%%[####]%\" " path filename extension to:imsqFile
				format "First=\"%\" Last=\"%\" " startFrame endFrame to:imsqFile
				format "FrameRate=\"%/1\" />\n" frameRate to:imsqFile
								
				Close imsqFile
				true
			)
			else
				false
		),
		
		fn CreateImsqVbscript imsqVbscript imsqFilename =
		(
			local scriptFile = CreateFile imsqVbscript
			if (scriptFile != undefined) then
			(
				filename = getFilenameFile imsqFilename
				extension = getFilenameType imsqFilename
			
				copyPath = SMTDSettings.ImsqOutputPath + "\\" + filename + extension

				format ("from System.IO import *\n") to:scriptFile
				format ("from Deadline.Scripting import *\n") to:scriptFile
				format ("def __main__():\n") to:scriptFile
				format ("	ScriptUtils.LogText( r'Copying imsq file to " + copyPath + "...' )\n") to:scriptFile
				format ("	File.Copy( r'" + imsqFilename + "', r'" + copyPath + "', True )\n") to:scriptFile
				format ("	ScriptUtils.LogText( 'Copy complete.' )\n") to:scriptFile
				
				Close scriptFile
				true
			)
			else
				false
		),
		
		fn createSubmissionFolderAndUpdatePaths =
		(
			local theFilterTime = filterString localtime " /\\-:"
			local theTime = ""
			for i = 1 to theFilterTime.count-1 do theTime += theFilterTime[i] + "_"
			theTime += theFilterTime[theFilterTime.count]	
			local theSubFolder = SMTDPaths.TempDir + theTime + "\\"
			makeDir theSubFolder all:true
			SMTDPaths.submitSubFolder = theSubFolder
			SMTDPaths.SubmitInfoFile = 	theSubFolder + "max_submit_info.job"
			SMTDPaths.JobInfoFile = 	theSubFolder + "max_job_info.job"
			SMTDPaths.ResultFile = theSubFolder + "max_output.txt"
			SMTDPaths.BitmapList = theSubFolder + "max_sceneBitmaps.txt"
			SMTDPaths.RestoreTempMaxFile = theSubFolder + "max_backup_file.mx"
			SMTDPaths.SubmitOutput = theSubFolder + "submitOutput.txt"
			SMTDPaths.SubmitExitCode = theSubFolder + "submitExitCode.txt"
			SMTDPaths.ImsqVbscriptFile = theSubFolder + "copyImsq.py"
			SMTDPaths.DraftConfigFile = theSubFolder  + "draft_tile_config.txt"
			theSubFolder
		),		
		
		fn cleanUpSubmissionFolders all:false =
		(
			local sysio = dotNetClass "System.IO.Directory"
			local theFilterTime = filterString localtime " /\\-:"
			local theTime = "*"
			for i = 1 to 3 do theTime += theFilterTime[i] + "_"
			theTime += "*"
			
			theDirs = getDirectories (SMTDPaths.TempDir+"*")
			theDirs = for d in theDirs where (not matchPattern d pattern:theTime or all == true) and not matchPattern d pattern:"*lightning*" collect d
			for d in theDirs do
			(
				for f in getFiles (d+"*") do deleteFile f
				try(sysio.Delete d true)catch()
			)
		),
		
		fn replaceFrameNumber filename newFrame =
		(
			local theName = getFileNameFile filename
			local frameString = ""
			local done = false
			for i = theName.count to 1 by -1 while not done do
			(
				if findString "0123456789#" theName[i] == undefined then
					done = true
				else
					frameString = theName[i]+frameString
			)
			theName = substring theName 1 (theName.count-frameString.count) + SMTDFunctions.getZeros newFrame count: (amax frameString.count 4) + newFrame as string
			getFileNamePath filename + theName + getFileNameType filename
		),

		fn interpolateAnimatedRegion aData theTime =
		(
			local theArray = aData[10]
			local returnValue= if theArray == undefined or theArray.count == 0 then 
				#(theTime, aData[2], aData[3], aData[4], aData[5]) --constant value
			else if theArray.count == 1 then theArray[1] --one key
			else --multiple keys
			(
				local theMin = 0
				local theEqual = 0
				for i = 1 to theArray.count do 
				(
					if theArray[i][1] <= theTime as integer do theMin = i
					if theArray[i][1] == theTime as integer do theEqual = i
				)
				returnValue = if theMin == theArray.count then 
					theArray[theArray.count]
				else if theMin == 0 then theArray[1]
				else 
				(
					local theLeftRecord  = theArray[theMin]
					local theRightRecord = theArray[theMin+1]
					local factor = (1.0 * theTime as integer-theLeftRecord[1]) / (theRightRecord[1]-theLeftRecord[1])
					--format "% (%)-> %\n" theLeftRecord factor theRightRecord
					#(theTime as integer, theLeftRecord[2]*(1-factor) + theRightRecord[2]*factor, theLeftRecord[3]*(1-factor) + theRightRecord[3]*factor, theLeftRecord[4]*(1-factor) + theRightRecord[4]*factor, theLeftRecord[5]*(1-factor) + theRightRecord[5]*factor )
				)
			)	
			returnValue				
		),
		
		fn getBatchName =
		(
			(SMTDFunctions.FormatJobName SMTDSettings.JobName) + " BATCH [" + localtime +"]"
		),

		fn ParseEolToSemicolon tempString =
		(
			--remove carriage returns and line feeds
			removeChars = "\n\r"
			for a = 1 to removeChars.count do (tempString = substituteString tempString removeChars[a] ";")
			
			--deal with duplicate trailing semicolons
			while (matchPattern tempString pattern:"*;;*") do (tempString = substituteString tempString ";;" ";")
			tempString = (trimLeft (trimRight tempString ";") ";")

			tempString
		),

		--SUBMIT TILE JOBS
		fn spawnTileJobs forceMaxFile:"" batchName:"" forceCamera:"" stereoCameraLabel:"" =
		(
			try(SMTD_MainRollout.Ui_report (">Spawning Tile Jobs."))catch()
			
			if batchName == "" do batchName = SMTDFunctions.getBatchName() --when spawning tile jobs, we assume that all of them should be batched together.
				
			local stereoCameraToken = ""
			if stereoCameraLabel != "" do stereoCameraToken = stereoCameraLabel+"_"
			
			SMTDSettings.TilesSubmissionJobIDs = #()

			renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

			local DeltaX = (floor (1.0*renderDimensions[1]/SMTDSettings.TilesInX)) as integer
			local DeltaY = (floor (1.0*renderDimensions[2]/SMTDSettings.TilesInY)) as integer
			
			if SMTDSettings.TileBlowupMode then
			(
				DeltaX = (floor (1.0*(renderDimensions[1]/SMTDSettings.TilesInX)/SMTDSettings.TilesInX)) as integer
				DeltaY = (floor (1.0*(renderDimensions[2]/SMTDSettings.TilesInY)/SMTDSettings.TilesInY)) as integer
			)
			
			local theOutput = rendOutputFileName
			local theOutPath = getFileNamePath theOutput
			local theBaseName = getFileNameFile theOutput
			local theOutType = getFileNameType theOutput
			local theJobName = SMTDSettings.JobName
			
			local TempMaxFile 
			if forceMaxFile == "" then
				TempMaxFile = maxFilePath + maxFileName
			else	
				TempMaxFile = forceMaxFile

			local theNetworkPath = SMTDFunctions.GetNetworkRoot()
			theNetworkPath += "\\submission\\3dsmax\\Main\\" 

			local BitmapsCopyData = #()
			if SMTDSettings.CurrentRepository == "" and SMTDSettings.SubmitExternalFilesMode > 1 do
				BitmapsCopyData = SMTDFunctions.GetExternalFilesToCopy()
			
			local currentTile = 0

--------------------------------------------------------------				
--MULTI-FRAME MULTI-REGION  RENDERING
--------------------------------------------------------------				
			if SMTDSettings.RegionRenderingMode == #animationMultiRegion do
			(
				try(SMTD_MainRollout.Ui_report (">Multi-Frame Multi-Region Data Preparation..."))catch()

				SMTDSettings.SingleTileJobLeft = ""
				SMTDSettings.SingleTileJobRight = ""
				SMTDSettings.SingleTileJobTop = ""
				SMTDSettings.SingleTileJobBottom = ""
				SMTDSettings.SingleTileJobFilename = ""
				SMTDSettings.SingleTileJobReFilename = ""
				local SingleTileJobReFilenameSS = "" as stringStream
				local reManager = maxOps.GetCurRenderElementMgr()
				local reObjects = #()

				if reManager != undefined do
				(
					local reCount = reManager.NumRenderElements()
					reObjects = for i = 0 to reCount-1 collect
					(
						local reObject = reManager.GetRenderElement i
						#(reObject, try(reObject.enabled)catch(false), try(reManager.GetRenderElementFilename i)catch(""))
					)
				)--end if reManager undefined				
				
				local tileLefts = #()
				local tileBottoms = #()

				local currentFrame = 0
				local currentFrameList = ""
				
				local framesList = SMTDFunctions.GetFrameSequenceArray()
				
				local regionRenderJobIds = #()
				
				local splitFileName = ""
				local splitName = ""
				local rawName = ""
				local rawFileName = ""
				if (renderers.current.classid as string == "#(1941615238, 2012806412)") then
				(
					splitName = renderers.current.output_splitfilename
					local splitFile = renderers.current.output_splitgbuffer
					
					if(splitFile==true) then
					(
						if(splitName == undefined or splitName == "") then
						(
							splitFile = false
						)
						else
						(
							SMTDSettings.SplitBufferFile = "SplitBufferFile="+(splitFile as string)+"\n" --True/False
						)
					)
					
					local rawFile = renderers.current.output_saveRawFile
					rawName = renderers.current.output_rawFileName
					
					if(rawFile==true) then
					(
						if(rawName == undefined or rawName == "") then
						(
							rawFile = false
						)
						else
						(
							SMTDSettings.RawBufferFile = "RawBufferFile="+(rawFile as string)+"\n" --True/False
						)
					)
				)
				
				local currentIndex = 0
				for aData in SMTDSettings.MultiRegionData where aData[1] == True do
				(
					for y = 1 to aData[7] do
					(
						for x = 1 to aData[6] do
						(
							try(windows.processPostedMessages())catch()
							SMTDFunctions.createSubmissionFolderAndUpdatePaths() --create a new submission folder
								
							local tempLeft = #()
							local tempTop = #()
							local tempRight = #()
							local tempBottom = #()
							
							local tileString = "_region_" + (currentIndex) as string + "_" --+ SMTDFunctions.getZeros t + t as string
							local splitCount = 0
							local rawCount = 0
							SMTDSettings.SplitBufferFilename = ""
							SMTDSettings.RawBufferFilename = ""
							if splitFile==true do
							(
								splitFileName = getFilenamePath splitName
								splitFileName += stereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile splitName) pattern:(SMTDSettings.StateSetName +"_*") do splitFileName += SMTDSettings.StateSetName + "_"
								splitFileName +=(getFilenameFile splitName)+tileString+(getFilenameType splitName) --Delimiter is NOT required here as the VRay split RE is already delimited
							)
								
							if rawFile==true do
							(
								rawFileName = getFilenamePath rawName
								rawFileName += stereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile rawName) pattern:(SMTDSettings.StateSetName +"_*") do rawFileName += SMTDSettings.StateSetName + "_"
								rawFileName+=(getFilenameFile rawName)+tileString+SMTDSettings.Delimiter+(getFilenameType rawName)
							)
							
							renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

							for t in framesList do --loop through all frames
							(
								local theAnimRegionValue = SMTDFunctions.interpolateAnimatedRegion aData t
								local theTileWidth = theAnimRegionValue[4]/aData[6]
								local theTileHeight = theAnimRegionValue[5]/aData[7]
								local corner1X = ((floor ((theAnimRegionValue[2]+(theTileWidth*(x-1)))*renderDimensions[1])) as integer)
								local corner1Y = ((floor ((theAnimRegionValue[3]+(theTileHeight*(y-1)))*renderDimensions[2])) as integer)
								local corner2X = ((floor ((theAnimRegionValue[2]+(theTileWidth*x))*renderDimensions[1])) as integer)
								local corner2Y = ((floor ((theAnimRegionValue[3]+(theTileHeight*y))*renderDimensions[2])) as integer)

								append tempLeft corner1X
								append tempTop corner1Y
								append tempRight corner2X
								append tempBottom corner2Y
									
								--format "Time %: LeftX:% LeftY:% RightX:% RightY:% RegionWidth:% ActualWidth:%  RegionHeight:% ActualHeight: %\n" t corner1X corner1Y corner2X corner2Y (corner2X-corner1X) (renderWidth*theTileWidth) (corner2Y-corner1Y) (theTileHeight*renderHeight)
								
								if (renderers.current.classid as string == "#(1941615238, 2012806412)") then
								(
									if(splitFile==true) then
									(
										SMTDSettings.SplitBufferFilename += "SplitBufferFilename" + (splitCount as string) + "=" + splitFileName+"\n"
										splitCount += 1
									)
									
									if(rawFile==true) then
									(
										SMTDSettings.RawBufferFilename += "RawBufferFilename" + (rawCount as string) + "=" + rawFileName+"\n"
										rawCount += 1
									)
								)

								--append tileLefts corner1X
								--append tileBottoms (RenderHeight - corner2Y)							

							)--end t loop		

							SMTDSettings.RegionLeft = tempLeft
							SMTDSettings.RegionRight = tempRight
							SMTDSettings.RegionTop = tempTop
							SMTDSettings.RegionBottom = tempBottom
							
							currentTile +=1
							if currentFrameList == "" then
								currentFrameList = (currentFrame as string)
							else
								currentFrameList = currentFrameList + "," + (currentFrame as string) 

							try(SMTD_MainRollout.Ui_report (">Submitting Multi-Frame, Multi-Region Job " + currentIndex as string ))catch()
							SMTDSettings.JobName = theJobName + " - Region "+ currentIndex as string
								
							---------------------------------------
							--ACTUAL SUBMISSION
							---------------------------------------
							--if SMTDSettings.QuicktimeGenerate do SMTDFunctions.AutomaticQuicktimeGeneration()			
							
							SMTDSettings.SingleTileJobReFilename = SingleTileJobReFilenameSS as string
							SMTDSettings.SingleTileJobTileCount = currentTile
							
							SMTDSettings.SingleTileJobFrameList = ""
														
							SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile batchName:batchName currentTileString:("_region_" + currentIndex as string + "_") stereoCameraLabel:stereoCameraLabel
								
							SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile renderOutputOverride:(theOutPath + theBaseName  + "_region_" + currentIndex as string + "_" + theOutType) tileString:("_region_" + currentIndex as string + "_") forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
							
							local initialArgs = "" as stringStream
							format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs
							
							if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs 
							if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs 
							
							if( SMTDSettings.SubmitSceneMode == #reposave ) then
								format "%\n%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile TempMaxFile to:initialArgs 
							else
								format "%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile to:initialArgs 
							 
							if SMTDSettings.CopyVbscriptFile do format "%\n" SMTDPaths.ImsqVbscriptFile to:initialArgs
							if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
							if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
							if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
							if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
							if SMTDSettings.SubmitSceneMode == #reposave do
							(
								if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
							)

							--Output external files to the command line for copying
							if SMTDSettings.SubmitExternalFilesMode > 1 do				
								for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
									format "%\n" aBitmap[1] to:initialArgs				

							/*	
							if theExternalFilesToCopy.count > 0 then
								SMTDFunctions.CopyExternalFilesWithinRepository theExternalFilesToCopy
							else
								SMTDFunctions.CopyExternalFilesToRepository()
							*/

							local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "MultiRegionRenderArgsFile.txt") 
							local initialArgsFile = createFile initialArgsFileName
							format "%\n" (initialArgs as string) to:initialArgsFile
							close initialArgsFile 
							initialArgsFileName = "\""+initialArgsFileName+"\""
							
							retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true dontWait:SMTDSettings.UseSubmissionQueue
							if not SMTDSettings.UseSubmissionQueue do
							(
								local renderMsg = SMTDFunctions.getRenderMessage()				
								try(SMTD_MainRollout.Ui_report ((if retcode == #success then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
							)
							if retcode == #success or retcode == #queued then
							(
								if retcode == #success do
								(
									SMTDFunctions.getJobIDFromMessage renderMsg
									SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
									append regionRenderJobIds SMTDSettings.DeadlineSubmissionLastJobID	
								)
							)--end success
							else
								return false
							currentIndex += 1
						)--end x loop
					)--end y loop
				)--end i loop (active regions)			

-- NOW SUBMIT DEPENDENT DRAFT ASSEMBLY JOBS
				local jobName = SMTDSettings.JobName 
				if stereoCameraLabel != "" do jobName += " ["+stereoCameraLabel+"]"
				if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do jobName += (" [STATE SET '"+ SMTDSettings.StateSetName + "']")
				
				if rendSaveFile then
				(
					if rendOutputFilename != undefined and rendOutputFilename != "" then
					(
						try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions Beauty Pass"))catch()

						local paddingString = formattedPrint (currentTime.frame as integer) format:"04i"

						local outputImageFilenames = #()
						local fileCount = 0
						local theFile = theOutPath
						theFile += stereoCameraToken
						if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
						theFile += theBaseName + SMTDSettings.Delimiter + "####" + theOutType
						append outputImageFilenames theFile
						
						local inputImageFilenames = #()
						local theIndex = 0
						for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
						(
							for y2 = 1 to aData2[7] do
							(
								for x2 = 1 to aData2[6] do
								(
									local currTileString = "_region_" + theIndex as string + "_" 
									local theFile = theOutPath
									theFile += stereoCameraToken
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
									theFile += theBaseName + currTileString + SMTDSettings.Delimiter + paddingString + theOutType
									append inputImageFilenames theFile
									theIndex += 1
								)
							)
						)
						local SingleLayerTilesCount = inputImageFilenames.count --this is the number of tiles before RE are considered!

						local jobIdsString = "" as stringStream 
						for j in regionRenderJobIds do format "%," j to:jobIdsString 
						jobIdsString = jobIdsString as string
						jobIdsString = substring jobIdsString 1 (jobIdsString.count-1)
						local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+SingleLayerTilesCount as string + " Animation Regions Draft Assembly - Beauty RGBA]") outputImageFilenames SingleLayerTilesCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
						local renderMsg = SMTDFunctions.getRenderMessage()
						try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
						
						--Collect data for Automatic Quicktime Generation
						SMTDFunctions.getJobIDFromMessage renderMsg
						append SMTDSettings.QuicktimesToGenerate #(outputImageFilenames[1], batchName, #(SMTDSettings.DeadlineSubmissionLastJobID)) --input, batch, dependency
						--if SMTDSettings.QuicktimeGenerate do SMTDFunctions.AutomaticQuicktimeGeneration overrideOutputPath:(getFileNamePath outputImageFilenames[1]) overrideInput:outputImageFilenames[1] batchName:batchName
						
						if not tileResult do return false
					)
					else
						try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission as Render Output Filename is undefined."))catch()
				)
				else
					try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission as Render Output Save File is disabled."))catch()

				-- If any render elements are specified, include them 
				elementsToSkip = #()
				
				-- If rendering with VRay frame buffer, then we don't want to assemble the render elements because they
				-- are embedded in the main image.
				if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on ) then
				(
					local paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
					
					local jobIdsString = "" as stringStream 
					for j in regionRenderJobIds do format "%," j to:jobIdsString 
					jobIdsString = jobIdsString as string
					jobIdsString = substring jobIdsString 1 (jobIdsString.count-1)
					
					if renderers.current.output_saveRawFile then
					(
						local rawName = renderers.current.output_rawfilename

						if ( rawName != undefined and rawName != "" ) then
						(
							local rawBaseName = (getFilenameFile rawName) --el.elementName
							local rawOutputType = (getFilenameType rawName)
							local rawPath = (getFilenamePath rawName)
							
							if not matchPattern rawOutputType pattern:"*vrimg*" then
							(
								local outputImageFilenames = #()
								local inputImageFilenames = #()										
								local theIndex = 0

								local theFile = rawPath
								theFile += StereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
								theFile += rawBaseName + SMTDSettings.Delimiter + "####" + rawOutputType
								append outputImageFilenames theFile
								
								local theIndex = 0
								for aData in SMTDSettings.MultiRegionData where aData[1] == True do
								(
									for y = 1 to aData[7] do
									(
										for x = 1 to aData[6] do
										(
											local currTileString = "_region_" + theIndex as string + "_" 

											local theFile = rawPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += rawBaseName + currTileString + SMTDSettings.Delimiter + paddingString + rawOutputType
											append inputImageFilenames theFile
											--SMTD_MainRollout.Ui_report (">MRR Render Element Input Filename ["+theFile+"]")
											theIndex += 1
										)--end x loop
									)--end y loop
								)--end region loop
								try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions Raw Buffer."))catch()
								local tileCount = inputImageFilenames.count
								local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+ tileCount as string +" Animation Regions Draft Assembly - Raw Buffer]") outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
								local renderMsg = SMTDFunctions.getRenderMessage()				
								try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
								if not tileResult do return false
							)
							else
								try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission For VRay Raw Buffer, File Format .vrimg Not Supported!"))catch()
						)
						else
							try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission For VRay Raw Buffer as File Path is Empty."))catch()
					)
					
					if renderers.current.output_splitgbuffer then
					(
						local splitName = renderers.current.output_splitfilename

						if ( splitName != undefined and splitName != "" ) then
						(
							local splitBaseName = (getFilenameFile splitName) --el.elementName
							local splitOutputType = (getFilenameType splitName)
							local splitPath = (getFilenamePath splitName)
							if renderers.current.output_splitRGB then
							(
								local outputImageFilenames = #()
								local inputImageFilenames = #()										
								local theIndex = 0
								
								local theFile = splitPath
								theFile += StereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
								theFile += splitBaseName + ".RGB_color." + "####" + splitOutputType
								append outputImageFilenames theFile
								
								local theIndex = 0
								for aData in SMTDSettings.MultiRegionData where aData[1] == True do
								(
									for y = 1 to aData[7] do
									(
										for x = 1 to aData[6] do
										(
											local currTileString = "_region_" + theIndex as string + "_" 

											local theFile = splitPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += splitBaseName + currTileString + ".RGB_color." + paddingString + splitOutputType
											append inputImageFilenames theFile
											--SMTD_MainRollout.Ui_report (">MRR Render Element Input Filename ["+theFile+"]")
											theIndex += 1
										)--end x loop
									)--end y loop
								)--end region loop
								try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions [RGB_color] Render Element."))catch()
								
								local tileCount = inputImageFilenames.count
								local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+tileCount as string+ " Animation Regions Draft Assembly - RE:RGB_color]") outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
								local renderMsg = SMTDFunctions.getRenderMessage()				
								try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
								if not tileResult do return false
							)
							
							if renderers.current.output_splitAlpha then
							(
								local outputImageFilenames = #()
								local inputImageFilenames = #()										
								local theIndex = 0
								
								local theFile = splitPath
								theFile += StereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
								theFile += splitBaseName + ".Alpha." + "####" + splitOutputType
								append outputImageFilenames theFile
								
								local theIndex = 0
								for aData in SMTDSettings.MultiRegionData where aData[1] == True do
								(
									for y = 1 to aData[7] do
									(
										for x = 1 to aData[6] do
										(
											local currTileString = "_region_" + theIndex as string + "_" 
											
											local theFile = splitPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += splitBaseName + currTileString + ".Alpha." + paddingString + splitOutputType
											append inputImageFilenames theFile
											--SMTD_MainRollout.Ui_report (">MRR Render Element Input Filename ["+theFile+"]")
											theIndex += 1
										)--end x loop
									)--end y loop
								)--end region loop
								try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions [Alpha] Render Element."))catch()
								
								local tileCount = inputImageFilenames.count
								local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+tileCount as string+ " Animation Regions Draft Assembly - RE:Alpha]") outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
								local renderMsg = SMTDFunctions.getRenderMessage()				
								try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
								if not tileResult do return false
							)
							
							local reManager = maxOps.GetCurRenderElementMgr()
							if reManager != undefined do
							(
								if reManager.GetElementsActive() then 
								(
									local reCount = reManager.NumRenderElements()
									for i = 0 to reCount - 1 do
									(
										local reObject = reManager.GetRenderElement i
										if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
										(
											local outputImageFilenames = #()
											local inputImageFilenames = #()										
											local theIndex = 0
											
											local reName = reObject.elementName
											el = reManager.GetRenderElement i
											
											local theFile = splitPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += splitBaseName + SMTDSettings.Delimiter + reName + SMTDSettings.Delimiter + "####" + splitOutputType
											append outputImageFilenames theFile
											try(SMTD_MainRollout.Ui_report (">Render Element ["+reName+"] Output Filename ["+theFile+"]"))catch()
											
											local theIndex = 0
											for aData in SMTDSettings.MultiRegionData where aData[1] == True do
											(
												for y = 1 to aData[7] do
												(
													for x = 1 to aData[6] do
													(
														local currTileString = "_region_" + theIndex as string + "_" 
														
														local theFile = splitPath
														theFile += StereoCameraToken
														if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
														theFile += splitBaseName + currTileString + SMTDSettings.Delimiter + reName + SMTDSettings.Delimiter + paddingString + splitOutputType
														append inputImageFilenames theFile
														--SMTD_MainRollout.Ui_report (">MRR Render Element Input Filename ["+theFile+"]")
														theIndex += 1
													)--end x loop
												)--end y loop
											)--end region loop
											try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions ["+reObject.elementName+"] Render Element."))catch()
											
											local tileCount = inputImageFilenames.count
											local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+tileCount as string+" Animation Regions Draft Assembly - RE:"+ reObject.elementName+"]") outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
											local renderMsg = SMTDFunctions.getRenderMessage()				
											try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
											if not tileResult do return false
										)--is re enabled?
									)
								)
							)--end if reManager undefined
						)
						else
							try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission For VRay Split Buffer as File Path is Empty."))catch()
					)
				)
				else
				(
					-- If this is 3dsmax 2011 or later, check to see if we're rendering to the new exr format
					if ((maxVersion())[1]/1000 as integer) >= 13 do
					(
						if rendSaveFile then
						(
							if rendOutputFilename != undefined and rendOutputFilename != "" then
							(
								rend_type = getFileNameType rendOutputFilename
								is_exr = matchPattern rend_type pattern:".exr" ignoreCase:true
								is_fxr = matchPattern rend_type pattern:".fxr" ignoreCase:true
								
								-- If we are, we need to tell Deadline which render elements are to be embedded in the exr file so that it doesn't save them separately
								if (is_exr or is_fxr) and (fopenexr != undefined) do
								(
									if fopenexr.isAutoAddRenderElements() then
									(
										--The elements are being added automatically, so check the re manager.
										local reManager = maxOps.GetCurRenderElementMgr()
										if reManager != undefined do
										(
											if reManager.GetElementsActive() then 
											(
												local reCount = reManager.NumRenderElements()
												for i = 0 to reCount - 1 do
												(
													local theElement = reManager.GetRenderElement i
													if classof theElement != Missing_Render_Element_Plug_in AND theElement.enabled do
														append elementsToSkip theElement.elementName
												)
											)
										)--end if reManger undefined
									)
									else
									(
										--The elements are manually specified, so check the layers in the exr itself
										for i = 0 to fopenexr.numLayers() do
										(
											if (fopenexr.getLayerType i) == 1 then
												append elementsToSkip (fopenexr.getLayerName i)
										)
									)
								)
							)
							else
								try(SMTD_MainRollout.Ui_report ("!!Skipping Embedded RE's as Render Output Filename is undefined."))catch()
						)
						else
							try(SMTD_MainRollout.Ui_report ("!!Skipping Embedded RE's as Render Output Save File is disabled."))catch()
					)

					local reManager = maxOps.GetCurRenderElementMgr()
					if reManager != undefined do
					(
						if reManager.GetElementsActive() then
						(
							local reCount = reManager.NumRenderElements()
							for i = 0 to reCount - 1 do
							(
								local reObject = reManager.GetRenderElement i
								if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
								(
									if (findItem elementsToSkip reObject.elementName) == 0 do
									(
										
										local outputImageFilenames = #()
										local inputImageFilenames = #()										
										local theIndex = 0
										
										local reFilename = reManager.GetRenderElementFilename i
										
										--SMTD_MainRollout.Ui_report (">Render Element "+reObject.elementName + " Original Filename ["+reFilename+"]")
										if reFilename != undefined and reFilename != "" then
										(
											/*
											--Bobo: this looks like duplicate - we are already adding the state set name below
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do
												reFilename = (getFileNamePath reFilename) + SMTDSettings.StateSetName + "_" + (getFilenameFile reFilename) + (getFilenameType reFilename)
											*/
											local reOutputPath = (getFilenamePath reFilename)
											local reName = (getFilenameFile reFilename) --el.elementName
											local reOutputType = (getFilenameType reFilename)

											local theFile = reOutputPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (reName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += reName + SMTDSettings.Delimiter + "####" + reOutputType
											
											append outputImageFilenames theFile
											--SMTD_MainRollout.Ui_report (">Render Element Output Filename ["+theFile+"]")
											
											local theIndex = 0
											for aData in SMTDSettings.MultiRegionData where aData[1] == True do
											(
												for y = 1 to aData[7] do
												(
													for x = 1 to aData[6] do
													(
														local currTileString = "_region_" + theIndex as string + "_" 
														
														local theFile = reOutputPath
														theFile += StereoCameraToken
														if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (reName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
														theFile += reName + currTileString + SMTDSettings.Delimiter + paddingString + reOutputType
														
														append inputImageFilenames theFile
														--SMTD_MainRollout.Ui_report (">MRR Render Element Input Filename ["+theFile+"]")
														theIndex += 1
													)--end x loop
												)--end y loop
											)--end region loop
											try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job For Multi-Frame, Multi-Regions ["+reObject.elementName+"] Render Element."))catch()
											
											local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobIdsString (theJobName + " ["+SingleLayerTilesCount as string+ " Animation Regions Draft Assembly - RE:"+ reObject.elementName+"]") outputImageFilenames SingleLayerTilesCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
											local renderMsg = SMTDFunctions.getRenderMessage()				
											try(SMTD_MainRollout.Ui_report ((if tileResult then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
											if not tileResult do return false		
										)--is re path and name
										else
											try(SMTD_MainRollout.Ui_report ("!!Skipping Draft Assembly Job Submission For MF, MR ["+reObject.elementName+"] Render Element as Filename is Empty."))catch()
									)--skip?
								)--is re enabled?
							)--end re loop
						)--end RE Manager active
					)--end if reManager undefined
				)--end not vray output
				
				--SMTDSettings.RegionRendering = false
				SMTDSettings.JobName = theJobName								
							
				return true
			)--end  SMTDSettings.RegionRenderingMode == #animationMultiRegion

---------------------------------------------------------------
--MULTI-FRAME OLD STYLE TILE RENDERING
---------------------------------------------------------------
			if SMTDSettings.RegionRenderingMode == #animationTiles do
			(
				try(SMTD_MainRollout.Ui_report (">Multi-Frame Tiles Data Preparation..."))catch()

				renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

				for y = 1 to SMTDSettings.TilesInY do
				(
					for x = 1 to SMTDSettings.TilesInX do
					(
						SMTDFunctions.createSubmissionFolderAndUpdatePaths()
						try(windows.processPostedMessages())catch()
						currentTile +=1
						if not SMTDSettings.UseCustomTiles or findItem SMTDSettings.CustomTiles (Point2 x y) > 0 do
						(
							try(DeadlineUtil.SetProgress (100.0*currentTile/(SMTDSettings.TilesInX * SMTDSettings.TilesInY)) )catch()
							SMTDSettings.RegionLeft = DeltaX*(x-1) 
							SMTDSettings.RegionTop = DeltaY*(y-1) 
							
							if x == SMTDSettings.TilesInX then
								SMTDSettings.RegionRight = renderDimensions[1]
							else
								SMTDSettings.RegionRight = DeltaX*x
							
							if y == SMTDSettings.TilesInY then
								SMTDSettings.RegionBottom = renderDimensions[2]
							else
								SMTDSettings.RegionBottom = DeltaY*y 
							
							SMTDSettings.JobName = theJobName + " (TILE " + currentTile as string+ " : "  + x as string + "x" + y as string + " of " + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + ")"
							try(DeadlineUtil.LogMessage ("Spawning Job " + SMTDSettings.JobName))catch()
							try(SMTD_MainRollout.Ui_report (">Submitting Tile Job [" + SMTDSettings.JobName + "]"))catch()
		
							local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
								
							local OutputFileName = theOutPath 
							OutputFileName += StereoCameraToken
							if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do OutputFileName += SMTDSettings.StateSetName + "_"
							OutputFileName += theBaseName  + tileString + theOutType 
							
							if (renderers.current.classid as string == "#(1941615238, 2012806412)") and renderers.current.output_on == true then
							(
								if renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != undefined then
								(
									SMTDSettings.SplitBufferFile = "SplitBufferFile="+(renderers.current.output_splitgbuffer as string)+"\n"
									local splitName = renderers.current.output_splitfilename
									if (splitName != undefined and splitName != "") then
									(
										local splitBaseName = (getFilenameFile splitName) --el.elementName
										local splitOutputType = (getFilenameType splitName)
										local splitPath = (getFilenamePath splitName)
										
										local theFile = splitPath 
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += splitBaseName + tileString + splitOutputType --Delimiter is NOT required here as the VRay split RE is already delimited
										SMTDSettings.SplitBufferFilename = "SplitBufferFilename0" + "=" + theFile+"\n"
									)
								)

								if renderers.current.output_saveRawFile and renderers.current.output_rawfilename != undefined then
								(
									SMTDSettings.RawBufferFile = "RawBufferFile="+(renderers.current.output_saveRawFile as string)+"\n"
									local rawName = renderers.current.output_rawfilename
									if (rawName != undefined and rawName != "") then
									(
										local rawBaseName = (getFilenameFile rawName) --el.elementName
										local rawOutputType = (getFilenameType rawName)
										local rawPath = (getFilenamePath rawName)

										local theFile = rawPath 
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += rawBaseName + tileString + rawOutputType
										SMTDSettings.RawBufferFilename = "RawBufferFilename0" + "=" + theFile+"\n"
									)
								)
							)
		
							/*
							local TempMaxFile = SMTDPaths.TempDir + maxFileName
							if maxFileName == "" do TempMaxFile += "untitled.max"
							if (doesFileExist TempMaxFile) do deleteFile TempMaxFile
							
							if SMTDSettings.SubmitVisibleObjectsOnly and not SMTDFunctions.HasActiveSceneXRefs() then
								result = SMTDFunctions.SaveMaxFileVisibleOnly TempMaxFile
							else
								result = SMTDFunctions.SaveMaxFileCopy TempMaxFile
							*/
							
							--SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile customOutputFile:OutputFileName includeBothOutputs:true
								
							SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile customOutputFile:OutputFileName batchName:batchName currentTileString:tileString stereoCameraLabel:stereoCameraLabel
							SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile renderOutputOverride:OutputFileName tileString:tileString forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
							
							local initialArgs = "" as stringStream
							format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs

							
							if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs 
							if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs 
							
							if ( SMTDSettings.SubmitSceneMode == #reposave ) then
								format "%\n%\n%\n%maxTileAssemblerCommand.ms\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile TempMaxFile theNetworkPath to:initialArgs 							
								--format "%\n%\n%\n%maxTileAssemblerCommand.ms\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile TempMaxFile to:initialArgs 
							else
								format "%\n%\n%maxTileAssemblerCommand.ms\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile theNetworkPath to:initialArgs 
							
							--format "%maxTileSubmitter.ms\n" theNetworkPath to:initialArgs 
							
							if SMTDSettings.CopyVbscriptFile do format "%\n" SMTDPaths.ImsqVbscriptFile to:initialArgs
							if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
							if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
							if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
							if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
							if SMTDSettings.SubmitSceneMode == #reposave do
							(
								if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
							)

							--Output external files to the command line for copying
							if SMTDSettings.SubmitExternalFilesMode > 1 do				
								for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
									format "%\n" aBitmap[1] to:initialArgs							
								
							local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
							local initialArgsFile = createFile initialArgsFileName
							format "%\n" (initialArgs as string) to:initialArgsFile
							close initialArgsFile 
							initialArgsFileName = "\""+initialArgsFileName+"\""
							
							--print initialArgs
							retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true dontWait:SMTDSettings.UseSubmissionQueue
							if not SMTDSettings.UseSubmissionQueue do
							(
								local renderMsg = SMTDFunctions.getRenderMessage()				
								try(SMTD_MainRollout.Ui_report ((if retcode == #success then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
							)
							if retcode == #success or retcode == #queued then
							(
								if retcode == #success do
								(
									SMTDFunctions.getJobIDFromMessage renderMsg
									append SMTDSettings.TilesSubmissionJobIDs SMTDSettings.DeadlineSubmissionLastJobID
									/*if theExternalFilesToCopy.count > 0 then
										SMTDFunctions.CopyExternalFilesWithinRepository theExternalFilesToCopy
									else
										SMTDFunctions.CopyExternalFilesToRepository()
									*/	
									SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
								)
							)
							else
							(
								--SMTDSettings.RegionRendering = false
								SMTDSettings.JobName = theJobName
								return false
							)	
						)--end if custom tiles
					)--end x loop
				)--end y loop
				--SMTDSettings.TilesRendering = true
				--SMTDSettings.RegionRendering = false
				SMTDSettings.JobName = theJobName
				local filenameToRender = SMTDFunctions.getRendOutputFilename forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
				append SMTDSettings.QuicktimesToGenerate #(filenameToRender, batchName, SMTDSettings.TilesSubmissionJobIDs) --input, output, batch, dependencies
				--if SMTDSettings.QuicktimeGenerate do SMTDFunctions.AutomaticQuicktimeGeneration batchName:batchName overrideInput:OutputFileName
				return true
			)--end SMTDSettings.RegionRenderingMode == #animationTiles				

-------------------------------------------------------------------------					
--SINGLE-FRAME TILE OR MULTI-REGION RENDERING
-------------------------------------------------------------------------				
			
			if SMTDSettings.RegionRenderingMode == #singleFrameTiles or SMTDSettings.RegionRenderingMode == #singleFrameMultiRegion do
			(
				SMTDSettings.SingleTileJobLeft = ""
				SMTDSettings.SingleTileJobRight = ""
				SMTDSettings.SingleTileJobTop = ""
				SMTDSettings.SingleTileJobBottom = ""
				SMTDSettings.SingleTileJobFilename = ""
				SMTDSettings.SingleTileJobReFilename = ""

				SMTDSettings.SplitBufferFilename = ""
				SMTDSettings.RawBufferFilename = ""				
				
				local SingleTileJobReFilenameSS = "" as stringStream
				local reManager = maxOps.GetCurRenderElementMgr()
				local reObjects = #()

				if reManager != undefined do
				(
					local reCount = reManager.NumRenderElements()
					reObjects = for i = 0 to reCount-1 collect
					(
						local reObject = reManager.GetRenderElement i
						#(reObject, try(reObject.enabled)catch(false), try(reManager.GetRenderElementFilename i)catch(""))
					)
				)--end if reManager undefined
				
				local tileLefts = #()
				local tileBottoms = #()

				local currentFrame = 0
				local currentFrameList = ""
				local customFrameList = ""

				--if #singleFrameTiles OR #singleFrameMultiRegion then inject currentTime.frame as the paddingString
				local paddingString = formattedPrint (currentTime.frame as integer) format:"04i"
				local paddingOutputString = formattedPrint (currentTime.frame as integer) format:"04i"
				--if RemovePadding then strip the output padding only
				if SMTDSettings.RemovePadding do paddingOutputString = ""
				--if RemovePadding then remove the delimiter only in NON V-Ray VFB Region/RegionRE output and then handle downstream DTA/TA jobs
				local delimiter = SMTDSettings.Delimiter
				if SMTDSettings.RemovePadding do delimiter = ""

-------------------------------------------------------------------------
--SINGLE FRAME, MULTI-REGION RENDERING
-------------------------------------------------------------------------
				if SMTDSettings.RegionRenderingMode == #singleFrameMultiRegion do
				(
					try(SMTD_MainRollout.Ui_report (">Single Frame Multi Region Data Preparation..."))catch()
					
					renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

					local currentIndex = 0
					for aData in SMTDSettings.MultiRegionData where aData[1] == True do
					(
						for y = 1 to aData[7] do
						(
							for x = 1 to aData[6] do
							(
								theTileWidth = aData[4]/aData[6]
								theTileHeight = aData[5]/aData[7]
								tempLeft = (floor ((aData[2]+(theTileWidth*(x-1)))*renderDimensions[1])) as integer
								tempTop = (floor ((aData[3]+(theTileHeight*(y-1)))*renderDimensions[2])) as integer
								tempRight = (floor ((aData[2]+(theTileWidth*x))*renderDimensions[1])) as integer
								tempBottom = (floor ((aData[3]+(theTileHeight*y))*renderDimensions[2])) as integer

								append tileLefts tempLeft
								append tileBottoms (renderDimensions[2] - tempBottom)							
									
								SMTDSettings.SingleTileJobLeft = SMTDSettings.SingleTileJobLeft + "RegionLeft" + (currentIndex as string) + "=" + (tempLeft as string) + "\n"
								SMTDSettings.SingleTileJobTop = SMTDSettings.SingleTileJobTop + "RegionTop" + (currentIndex as string) + "=" + (tempTop as string) + "\n"
								SMTDSettings.SingleTileJobRight = SMTDSettings.SingleTileJobRight + "RegionRight" + (currentIndex as string) + "=" + (tempRight as string) + "\n"
								SMTDSettings.SingleTileJobBottom = SMTDSettings.SingleTileJobBottom + "RegionBottom" + (currentIndex as string) + "=" + (tempBottom as string) + "\n"						
									
								local tileString = "_region_" + (currentIndex) as string + "_"
								local regionFileName = theOutPath 
								regionFileName += StereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do regionFileName += SMTDSettings.StateSetName + "_"
								regionFileName += theBaseName  + tileString + delimiter + theOutType
								SMTDSettings.SingleTileJobFilename = SMTDSettings.SingleTileJobFilename + "RegionFilename" + (currentIndex as string) + "=" + regionFileName + "\n"
								
								if (renderers.current.classid as string == "#(1941615238, 2012806412)") and renderers.current.output_on == true then
								(
									if renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != undefined then
									(
										SMTDSettings.SplitBufferFile = "SplitBufferFile="+(renderers.current.output_splitgbuffer as string)+"\n"
										local splitFileName = ""
										local splitName = renderers.current.output_splitfilename
										if(splitName != undefined and splitName != "") then
										(
											local splitBaseName = (getFilenameFile splitName)
											local splitOutputType = (getFilenameType splitName)
											local splitPath = (getFilenamePath splitName)
											
											local theFile = splitPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += splitBaseName + tileString + splitOutputType --Delimiter is NOT required here as the VRay split RE is already delimited
											SMTDSettings.SplitBufferFilename += "SplitBufferFilename" + (currentIndex as string) + "=" + theFile+"\n"
										)
									)
									
									if renderers.current.output_saveRawFile and renderers.current.output_rawfilename != undefined then
									(
										SMTDSettings.RawBufferFile = "RawBufferFile="+(renderers.current.output_saveRawFile as string)+"\n"
										local rawName = renderers.current.output_rawfilename
										if(rawName != undefined and rawName != "") then
										(
											local rawBaseName = (getFilenameFile rawName)
											local rawOutputType = (getFilenameType rawName)
											local rawPath = (getFilenamePath rawName)
											
											local theFile = rawPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += rawBaseName + tileString + delimiter + rawOutputType --Delimiter is required here unless RemovePadding=True
											SMTDSettings.RawBufferFilename = SMTDSettings.RawBufferFileName +"RawBufferFilename" + (currentIndex as string) + "=" + theFile+"\n"
										)
									)
								)
								
								-- If any render elements are specified, include them 
								local outputFilenameIndex = 0
								if reManager.GetElementsActive() then 
								(
									for anElement in reObjects where anElement[2] == true do
									(
										local reFilename = anElement[3]
										if reFilename != undefined and reFilename != "" do
										(
											local regionReFileName = (getFilenamePath reFilename) 
											regionReFileName += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*") do regionReFileName += SMTDSettings.StateSetName + "_"
											regionReFileName += (getFilenameFile reFilename) + tileString + delimiter + (getFilenameType reFilename)
											format "RegionReFilename%_%=%\n" currentIndex outputFilenameIndex regionReFileName to:SingleTileJobReFilenameSS
											outputFilenameIndex += 1
										)
									)
								)

								currentTile +=1
								if currentFrameList == "" then
									currentFrameList = (currentFrame as string)
								else
									currentFrameList = currentFrameList + "," + (currentFrame as string) 

								currentIndex += 1
							)--end x loop
						)--end y loop
					)--end i loop (active regions)
				)--end single frame multi-region rendering
				
-------------------------------------------------------------------------								
--SINGLE FRAME TILE RENDERING
-------------------------------------------------------------------------								
				if SMTDSettings.RegionRenderingMode == #singleFrameTiles do 
				(
					try(SMTD_MainRollout.Ui_report (">Single Frame Tiles Data Preparation..."))catch()

					renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

					local rawName = ""
					local rawFileName = ""
					local splitFileName = ""
					local splitName = ""

					SMTDSettings.SplitBufferFilename = ""
					SMTDSettings.RawBufferFilename = ""

					if (renderers.current.classid as string == "#(1941615238, 2012806412)") then
					(
						splitName = renderers.current.output_splitfilename
						local splitFile = renderers.current.output_splitgbuffer
						
						if(splitFile) then
						(
							if(splitName == undefined or splitName == "") then
							(
								splitFile = false
							)
							else
							(
								SMTDSettings.SplitBufferFile = "SplitBufferFile="+(splitFile as string)+"\n" --True/False
							)
						)
						
						local rawFile = renderers.current.output_saveRawFile
						rawName = renderers.current.output_rawFileName
						
						if(rawFile) then
						(
							if(rawName == undefined or rawName == "") then
							(
								rawFile = false
							)
							else
							(
								SMTDSettings.RawBufferFile = "RawBufferFile="+(rawFile as string)+"\n" --True/False
							)
						)
					)
					
					for y = 1 to SMTDSettings.TilesInY do
					(
						for x = 1 to SMTDSettings.TilesInX do
						(
							--Remove this line to export all tiles
							--if not SMTDSettings.UseCustomTiles or findItem SMTDSettings.CustomTiles (Point2 x y) > 0 do
							(
								local tempRight = (DeltaX*x) as integer
								if x == SMTDSettings.TilesInX then
								(
									tempRight = renderDimensions[1]
									if SMTDSettings.TileBlowupMode then
									tempRight = (floor (1.0*(renderDimensions[1]/SMTDSettings.TilesInX))) as integer
								)

								local tempBottom = (DeltaY*y) as integer
								if y == SMTDSettings.TilesInY then
								(
									tempBottom = renderDimensions[2]
									if SMTDSettings.TileBlowupMode then
									tempBottom = (floor (1.0*(renderDimensions[2]/SMTDSettings.TilesInY))) as integer
								)

								local currentIndex = currentTile
								--if SMTDSettings.UseCustomTiles do currentIndex = currentFrame
								
								tempLeft = ((DeltaX*(x-1)) as integer)
								tempTop = ((DeltaY*(y-1)) as integer)
								
								append tileLefts tempLeft
								append tileBottoms (renderDimensions[2] - tempBottom)

								SMTDSettings.SingleTileJobLeft = SMTDSettings.SingleTileJobLeft + "RegionLeft" + (currentIndex as string) + "=" + (tempLeft as string) + "\n"
								SMTDSettings.SingleTileJobTop = SMTDSettings.SingleTileJobTop + "RegionTop" + (currentIndex as string) + "=" + (tempTop as string) + "\n"
								SMTDSettings.SingleTileJobRight = SMTDSettings.SingleTileJobRight + "RegionRight" + (currentIndex as string) + "=" + (tempRight as string) + "\n"
								SMTDSettings.SingleTileJobBottom = SMTDSettings.SingleTileJobBottom + "RegionBottom" + (currentIndex as string) + "=" + (tempBottom as string) + "\n"

								local tileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string  + "_"
								local regionFileName = theOutPath 
								regionFileName += StereoCameraToken
								if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do regionFileName += SMTDSettings.StateSetName + "_"
								regionFileName += theBaseName  + tileString + delimiter + theOutType
								SMTDSettings.SingleTileJobFilename = SMTDSettings.SingleTileJobFilename + "RegionFilename" + (currentIndex as string) + "=" + regionFileName + "\n"

								-- If any render elements are specified, include them 
								local outputFilenameIndex = 0
								if reManager.GetElementsActive() then 
								(
									for anElement in reObjects where anElement[2] == true do
									(
										local reFilename = anElement[3]
										if reFilename != undefined and reFilename != "" do
										(
											local regionReFileName = (getFilenamePath reFilename) 
											regionReFileName += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (getFilenameFile reBaseName) pattern:(SMTDSettings.StateSetName +"_*") do regionReFileName += SMTDSettings.StateSetName + "_"
											regionReFileName += (getFilenameFile reFilename) + tileString + delimiter + (getFilenameType reFilename)
											format "RegionReFilename%_%=%\n" currentIndex outputFilenameIndex regionReFileName to:SingleTileJobReFilenameSS
											outputFilenameIndex += 1
										)
									)
								)
								if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on ) then
								(
									if renderers.current.output_splitgbuffer then
									(
										local splitName = renderers.current.output_splitfilename
										if splitName != undefined and splitName != "" then 
										(
											local splitBaseName = (getFilenameFile splitName) --el.elementName
											local splitOutputType = (getFilenameType splitName)
											local splitPath = (getFilenamePath splitName)
											local theFile = splitPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += splitBaseName + tileString + splitOutputType --Delimiter is NOT required here as the VRay split RE is already delimited
											SMTDSettings.SplitBufferFilename += "SplitBufferFilename" + (currentIndex as string) + "=" + theFile+"\n"
										)
									)									

									if renderers.current.output_saveRawFile then
									(
										local rawName = renderers.current.output_rawfilename
										if rawName != undefined and rawName != "" then
										(
											
											local rawBaseName = (getFilenameFile rawName) --el.elementName
											local rawOutputType = (getFilenameType rawName)
											local rawPath = (getFilenamePath rawName)
											local theFile = rawPath
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += rawBaseName + tileString + delimiter + rawOutputType --Delimiter is required here unless RemovePadding=True
											SMTDSettings.RawBufferFilename += "RawBufferFilename" + (currentIndex as string) + "=" + theFile +"\n"
										)
									)
								)
									
								currentTile +=1
								if currentFrameList == "" then
									currentFrameList = (currentFrame as string)
								else
									currentFrameList += "," + (currentFrame as string) 
								
								--Collect the custom tile indices
								if SMTDSettings.UseCustomTiles AND findItem SMTDSettings.CustomTiles (Point2 x y) > 0 do
								(
									if customFrameList == "" then
										customFrameList = currentFrame as string
									else
										customFrameList += "," + (currentFrame as string) 
								)								
							)
							currentFrame += 1
						)--end x loop
					)--end y loop
				)--end single frame tiles

--Dependent Job is needed if:
--Single Frame Tile Rendering and SingleTileJobDependent is checked
--Multi-Region Rendering is requested, regardless of whether Single or Multiple Frames

				local tilesRendering = findItem #(#animationTiles, #singleFrameTiles) SMTDSettings.RegionRenderingMode > 0
				local multiRegionRendering = findItem #(#singleFrameMultiRegion, #animationMultiRegion) SMTDSettings.RegionRenderingMode > 0
				
				local AssemblyMode = #mxs
				if (regionMode == #singleFrameTiles OR SMTDSettings.SingleTileJobDependent) do AssemblyMode = #tile --default to assembly when single frame is requested, or when an assembly job is requested explicitly for multi-frame tiles.
				if ((SMTDSettings.SingleTileJobDependent AND SMTDSettings.SingleTileJobDraft) OR MultiRegionRendering) do AssemblyMode = #draft --default to draft when multi-region rendering single or multiple frames, or when explicitly asked for.
			
				SMTDSettings.SingleTileJobReFilename = SingleTileJobReFilenameSS as string
				
				SMTDSettings.SingleTileJobTileCount = currentTile
				
				SMTDSettings.SingleTileJobFrameList = ""
				--Use the customFrameList indices to enable the tasks that should be uncompleted:
				if SMTDSettings.UseCustomTiles do SMTDSettings.SingleTileJobFrameList = customFrameList
				
				SMTDFunctions.createSubmissionFolderAndUpdatePaths()
				SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile batchName:batchName stereoCameraLabel:stereoCameraLabel
				SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
				
				local initialArgs = "" as stringStream
				format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs
				
				if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs 
				if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs 
				
				if( SMTDSettings.SubmitSceneMode == #reposave ) then
					format "%\n%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile TempMaxFile to:initialArgs 
				else
					format "%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile to:initialArgs 
				 
				if SMTDSettings.CopyVbscriptFile do format "%\n" SMTDPaths.ImsqVbscriptFile to:initialArgs
				if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
				if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
				if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
				if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
				if SMTDSettings.SubmitSceneMode == #reposave do
				(
					if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
				)

				if AssemblyMode == #mxs do 
					format "%maxTileAssemblerCommand.ms\n" theNetworkPath to:initialArgs 							

				--Output external files to the command line for copying
				if SMTDSettings.SubmitExternalFilesMode > 1 do				
					for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
						format "%\n" aBitmap[1] to:initialArgs
					
				local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
				local initialArgsFile = createFile initialArgsFileName
				format "%\n" (initialArgs as string) to:initialArgsFile
				close initialArgsFile 
				initialArgsFileName = "\""+initialArgsFileName+"\""
				
				retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true dontWait:SMTDSettings.UseSubmissionQueue
				
				if not SMTDSettings.UseSubmissionQueue do
				(
					local renderMsg = SMTDFunctions.getRenderMessage()				
					try(SMTD_MainRollout.Ui_report ((if retcode == #success then "+" else "--")+"Submission Result: \n\n" + renderMsg))catch()		
				)
				
				if retcode == #success or retcode == #queued then
				(
					SMTDFunctions.getJobIDFromMessage renderMsg
					if not SMTDSettings.UseSubmissionQueue do SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
------------------------------------------------------------
-- SINGLE FRAME - MULTI-REGION OR TILES
-- SUBMIT DEPENDENT JOB HERE
------------------------------------------------------------
					if AssemblyMode != #mxs  then
					(
						local jobId = SMTDSettings.DeadlineSubmissionLastJobID
						local jobName = SMTDSettings.JobName 
						if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput do jobName += (" [STATE SET '"+ SMTDSettings.StateSetName + "']")
						jobName += " - "
						if AssemblyMode == #draft do jobName += "Draft "
						jobName+= "Tile Assembly"

						local outputImageFilenames = #()
						local inputImageFilenames = #()
						local fileCount = 0

						local theFile = theOutPath
						theFile += StereoCameraToken
						if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_" 
						if (SMTDSettings.RemovePadding and rendTimeType == 1) then
							theFile += theBaseName + theOutType
						else
							theFile += theBaseName + SMTDSettings.Delimiter + paddingOutputString + theOutType
						append outputImageFilenames theFile

						if AssemblyMode == #draft then
						(
							if MultiRegionRendering then
							(
								local theIndex = 0
								for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
								(
									for y = 1 to aData2[7] do
									(
										for x = 1 to aData2[6] do
										(
											local currTileString = "_region_" + theIndex as string + "_" 
											local theFile = theOutPath 
											theFile += StereoCameraToken
											if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
											theFile += theBaseName + currTileString + delimiter + paddingOutputString + theOutType
											append inputImageFilenames theFile
											theIndex += 1
										)
									)
								)
							)--end multi-region rendering
							else
							(
								for y = 1 to SMTDSettings.TilesInY do
								(
									for x = 1 to SMTDSettings.TilesInX do
									(
										fileCount +=1
										local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string+"_"
										local theFile = theOutPath
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += theBaseName + currTileString + delimiter + paddingOutputString + theOutType
										append inputImageFilenames theFile
									)
								)
							)
						)--end use draft for single tile job
						else --not draft
						(
							local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
							local theFile = theOutPath
							theFile += StereoCameraToken
							if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (theBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
							theFile += theBaseName + tileString + delimiter + paddingOutputString + theOutType
							append inputImageFilenames theFile
						)--end if not draft
						local SingleLayerTilesCount = inputImageFilenames.count --this is the number of tiles before RE are considered!
						
						if not rendSaveFile or rendOutputFilename == undefined or rendOutputFilename == "" do
						(
							inputImageFilenames = #()
							outputImageFilenames = #()
						)
						-- If any render elements are specified, include them 
						elementsToSkip = #()
						
						-- If rendering with VRay frame buffer, then we don't want to assemble the render elements because they
						-- are embedded in the main image.
						if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on) then
						(
							if renderers.current.output_saveRawFile and  renderers.current.output_rawfilename != undefined and renderers.current.output_rawfilename != "" then
							(
								local rawName = renderers.current.output_rawfilename
								local rawBaseName = (getFilenameFile rawName) --el.elementName
								local rawOutputType = (getFilenameType rawName)
								local rawPath = (getFilenamePath rawName)
								if not matchPattern rawOutputType pattern:"*vrimg*" do --Draft does not support the assembling of vrimg files
								(
									local theFile = rawPath
									theFile += StereoCameraToken
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
									
									if AssemblyMode == #draft then
									(
										--if assembling via Draft, then we are able to strip the delimiter & padding if requested
										if (SMTDSettings.RemovePadding and rendTimeType == 1) then
											theFile += rawBaseName + rawOutputType
										else
											theFile += rawBaseName + delimiter + paddingOutputString + rawOutputType
										append outputImageFilenames theFile

										if MultiRegionRendering then
										(
											local theIndex = 0
											for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
											(
												for y = 1 to aData2[7] do
												(
													for x = 1 to aData2[6] do
													(
														local currTileString = "_region_" + theIndex as string + "_" 
														local theFile = rawPath
														theFile += StereoCameraToken
														if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
														theFile += rawBaseName + currTileString + delimiter + paddingString + rawOutputType
														append inputImageFilenames theFile
														theIndex += 1
													)
												)
											)														
										)		
										else	
										(													
											for y = 1 to SMTDSettings.TilesInY do
											(
												for x = 1 to SMTDSettings.TilesInX do
												(
													local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
													local theFile = rawPath
													theFile += StereoCameraToken
													if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
													theFile += rawBaseName + currTileString + delimiter + paddingString + rawOutputType
													append inputImageFilenames theFile
												)
											)
										)
									)
									else --not draft
									(
										--if assembling via TA, then we are unable to strip the delimiter or padding from the output filename. Use Draft!
										theFile += rawBaseName + delimiter + paddingString + rawOutputType
										append outputImageFilenames theFile

										local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
										local theFile = rawPath
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (rawBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += rawBaseName + tileString + delimiter + paddingString + rawOutputType
										append inputImageFilenames theFile
									)--end if not draft
								)--end if not vrimg
							)--if rawfile defined

							if renderers.current.output_splitgbuffer and renderers.current.output_splitfilename != undefined and renderers.current.output_splitfilename != "" then
							(
								local splitName = renderers.current.output_splitfilename
								local splitBaseName = (getFilenameFile splitName) --el.elementName
								local splitOutputType = (getFilenameType splitName)
								local splitPath = (getFilenamePath splitName)
								if renderers.current.output_splitRGB then
								(
									local theFile = splitPath
									theFile += StereoCameraToken
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"

									if AssemblyMode == #draft then
									(									
										--if assembling via Draft, then we are able to strip the delimiter & padding if requested
										if (SMTDSettings.RemovePadding and rendTimeType == 1) then
											theFile += splitBaseName + ".RGB_color" + splitOutputType
										else
											theFile += splitBaseName + ".RGB_color." + paddingOutputString + splitOutputType
										append outputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Split RGB Output Filename ["+theFile+"]"))catch()

										if MultiRegionRendering then
										(
											local theIndex = 0
											for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
											(
												for y = 1 to aData2[7] do
												(
													for x = 1 to aData2[6] do
													(
														local currTileString = "_region_" + theIndex as string + "_" 
														local theFile = splitPath
														theFile += StereoCameraToken
														if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
														theFile += splitBaseName + currTileString + ".RGB_color." + paddingString + splitOutputType
														append inputImageFilenames theFile
														--try(SMTD_MainRollout.Ui_report (">Multi-Region Draft Assembler Split RGB Input Filename ["+theFile+"]"))catch()
														theIndex += 1
													)
												)
											)														
										)		
										else	
										(													
											for y = 1 to SMTDSettings.TilesInY do
											(
												for x = 1 to SMTDSettings.TilesInX do
												(
													local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
													local theFile = splitPath
													theFile += StereoCameraToken
													if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
													theFile += splitBaseName + currTileString + ".RGB_color." + paddingString + splitOutputType
													append inputImageFilenames theFile
													--try(SMTD_MainRollout.Ui_report (">Draft Tile Assembler Split RGB Input Filename ["+theFile+"]"))catch()
												)
											)
										)
									)
									else --not draft
									(
										--if assembling via TA, then we are unable to strip the padding from the output filename. Use Draft!
										theFile += splitBaseName + ".RGB_color." + paddingString + splitOutputType
										append outputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Split RGB Output Filename ["+theFile+"]"))catch()

										local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
										local theFile = splitPath
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += splitBaseName + tileString + ".RGB_color." + paddingString + splitOutputType
										append inputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Tile Assembler Split RGB Input Filename ["+theFile+"]"))catch()
									)--end if not draft
								)
								
								if renderers.current.output_splitAlpha then
								(
									local theFile = splitPath
									theFile += StereoCameraToken
									if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
									
									if AssemblyMode == #draft then
									(
										--if assembling via Draft, then we are able to strip the delimiter & padding if requested
										if (SMTDSettings.RemovePadding and rendTimeType == 1) then
											theFile += splitBaseName + ".Alpha" + splitOutputType
										else
											theFile += splitBaseName + ".Alpha." + paddingOutputString + splitOutputType
										append outputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Split Alpha Output Filename ["+theFile+"]"))catch()

										if MultiRegionRendering then
										(
											local theIndex = 0
											for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
											(
												for y = 1 to aData2[7] do
												(
													for x = 1 to aData2[6] do
													(
														local currTileString = "_region_" + theIndex as string + "_" 
														local theFile = splitPath
														theFile += StereoCameraToken
														if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
														theFile += splitBaseName + currTileString + ".Alpha." + paddingString + splitOutputType
														append inputImageFilenames theFile
														--try(SMTD_MainRollout.Ui_report (">Multi-Region Draft Assembler Split Alpha Input Filename ["+theFile+"]"))catch()
														theIndex += 1
													)
												)
											)														
										)		
										else --tile rendering
										(													
											for y = 1 to SMTDSettings.TilesInY do
											(
												for x = 1 to SMTDSettings.TilesInX do
												(
													local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
													local theFile = splitPath
													theFile += StereoCameraToken
													if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
													theFile += splitBaseName + currTileString + ".Alpha." + paddingString + splitOutputType
													append inputImageFilenames theFile
													--try(SMTD_MainRollout.Ui_report (">Draft Tile Assembler Split Alpha Input Filename ["+theFile+"]"))catch()
												)
											)
										)
									)
									else --not draft
									(
										--if assembling via TA, then we are unable to strip the padding from the output filename. Use Draft!
										theFile += splitBaseName + ".Alpha." + paddingString + splitOutputType
										append outputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Split Alpha Output Filename ["+theFile+"]"))catch()

										local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
										local theFile = splitPath
										theFile += StereoCameraToken
										if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
										theFile += splitBaseName + tileString + ".Alpha." + paddingString + splitOutputType
										append inputImageFilenames theFile
										--try(SMTD_MainRollout.Ui_report (">Tile Assembler Split Alpha Input Filename ["+theFile+"]"))catch()
									)--end if not draft
								)

								local reManager = maxOps.GetCurRenderElementMgr()
								if reManager != undefined do
								(
									if reManager.GetElementsActive() then 
									(
										local reCount = reManager.NumRenderElements()
										for i = 0 to reCount - 1 do
										(
											local reObject = reManager.GetRenderElement i
											if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
											(
												el = reManager.GetRenderElement i
												local reBaseName = el.elementName
												local theFile = splitPath
												theFile += StereoCameraToken
												if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"

												if AssemblyMode == #draft then
												(
													--if assembling via Draft, then we are able to strip the delimiter & padding if requested
													if (SMTDSettings.RemovePadding and rendTimeType == 1) then
														theFile += splitBaseName + SMTDSettings.Delimiter + reBaseName + splitOutputType --remove Delimiter if padding has been removed
													else
														theFile += splitBaseName + SMTDSettings.Delimiter + reBaseName + SMTDSettings.Delimiter + paddingOutputString + splitOutputType
													append outputImageFilenames theFile
													--try(SMTD_MainRollout.Ui_report (">Render Element Output Filename ["+theFile+"]"))catch()

													if MultiRegionRendering then
													(
														local theIndex = 0
														for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
														(
															for y = 1 to aData2[7] do
															(
																for x = 1 to aData2[6] do
																(
																	local currTileString = "_region_" + theIndex as string + "_" 
																	local theFile = splitPath
																	theFile += StereoCameraToken
																	if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
																	theFile += splitBaseName + currTileString + SMTDSettings.Delimiter + reBaseName + SMTDSettings.Delimiter + paddingString + splitOutputType
																	append inputImageFilenames theFile
																	--try(SMTD_MainRollout.Ui_report (">Multi-Region Draft Assembler Render Element Input Filename ["+theFile+"]"))catch()
																	theIndex += 1
																)
															)
														)														
													)		
													else	
													(													
														for y = 1 to SMTDSettings.TilesInY do
														(
															for x = 1 to SMTDSettings.TilesInX do
															(
																local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"															
																local theFile = splitPath
																theFile += StereoCameraToken
																if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*") do theFile += SMTDSettings.StateSetName + "_"
																theFile += splitBaseName + currTileString + SMTDSettings.Delimiter + reBaseName + SMTDSettings.Delimiter + paddingString + splitOutputType
																append inputImageFilenames theFile
																--try(SMTD_MainRollout.Ui_report (">Draft Tile Assembler Render Element Input Filename ["+theFile+"]"))catch()
															)
														)
													)
												)
												else --not draft
												(
													--if assembling via TA, then we are unable to strip the padding from the output filename. Use Draft!
													theFile += splitBaseName + SMTDSettings.Delimiter + reBaseName + SMTDSettings.Delimiter + paddingString + splitOutputType
													append outputImageFilenames theFile
													--try(SMTD_MainRollout.Ui_report (">Render Element Output Filename ["+theFile+"]"))catch()

													local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
													local theFile = splitPath
													theFile += StereoCameraToken
													if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput and not matchPattern (splitBaseName) pattern:(SMTDSettings.StateSetName +"_*")  do theFile += SMTDSettings.StateSetName + "_"
													theFile += splitBaseName + tileString + SMTDSettings.Delimiter + reBaseName + SMTDSettings.Delimiter + paddingString + splitOutputType
													append inputImageFilenames theFile
													--try(SMTD_MainRollout.Ui_report (">Tile Assembler Render Element Input Filename ["+theFile+"]"))catch()
												)--end if not draft
											)--is re enabled?
										)--end re loop
									)--end Render Elements Active
								)--end if reManager undefined
							)--if splitfile defined
						)--end if VFB enabled
						else
						(
							-- If this is 3dsmax 2011 or later, check to see if we're rendering to the new exr format
							if ((maxVersion())[1]/1000 as integer) >= 13 do
							(
								if rendSaveFile then
								(
									if rendOutputFilename != undefined and rendOutputFilename != "" then
									(
										rend_type = getFileNameType rendOutputFilename
										is_exr = matchPattern rend_type pattern:".exr" ignoreCase:true
										is_fxr = matchPattern rend_type pattern:".fxr" ignoreCase:true
										
										-- If we are, we need to tell Deadline which render elements are to be embedded in the exr file so that it doesn't save them separately
										if (is_exr or is_fxr) and (fopenexr != undefined) do
										(
											if fopenexr.isAutoAddRenderElements() then
											(
												--The elements are being added automatically, so check the re manager.
												local reManager = maxOps.GetCurRenderElementMgr()
												if reManager != undefined do
												(
													if reManager.GetElementsActive() then 
													(
														local reCount = reManager.NumRenderElements()
														for i = 0 to reCount - 1 do
														(
															local theElement = reManager.GetRenderElement i
															if classof theElement != Missing_Render_Element_Plug_in AND theElement.enabled do
																append elementsToSkip theElement.elementName
														)
													)
												)--end if reManager undefined
											)
											else
											(
												--The elements are manually specified, so check the layers in the exr itself
												for i = 0 to fopenexr.numLayers() do
												(
													if (fopenexr.getLayerType i) == 1 then
														append elementsToSkip (fopenexr.getLayerName i)
												)
											)
										)
									)
									else
										try(SMTD_MainRollout.Ui_report ("!!Skipping Embedded RE's as Render Output Filename is undefined."))catch()
								)
								else
									try(SMTD_MainRollout.Ui_report ("!!Skipping Embedded RE's as Render Output Save File is disabled."))catch()
							)

							-- RENDER ELEMENTS
							local reManager = maxOps.GetCurRenderElementMgr()
							if reManager != undefined do
							(
								if reManager.GetElementsActive() then 
								(
									local reCount = reManager.NumRenderElements()
									for i = 0 to reCount - 1 do
									(
										local reObject = reManager.GetRenderElement i
										if classof reObject != Missing_Render_Element_Plug_in AND reObject.enabled then
										(
											if (findItem elementsToSkip reObject.elementName) == 0 do
											(
												local reFilename = reManager.GetRenderElementFilename i
												try(SMTD_MainRollout.Ui_report (">Render Element "+reObject.elementName + " Original Filename ["+reFilename+"]"))catch()
												if reFilename != undefined and reFilename != "" then
												(
													if SMTDSettings.StateSetsSubmit and SMTDSettings.StateSetRenameOutput  and not matchPattern (getFilenameFile reFilename) pattern:(SMTDSettings.StateSetName +"_*")  do
														reFilename = getFileNamePath reFilename + SMTDSettings.StateSetName +"_"+(getFilenameFile reFilename) + (getFilenameType reFilename)

													el = reManager.GetRenderElement i
													local reBaseName = el.elementName
													local reOutputPath = (getFilenamePath reFilename)
													local reFilenameFile = (getFileNameFile reFilename)
													local reOutputType = (getFilenameType reFilename)
													
													local theFile = reOutputPath
													theFile += StereoCameraToken
													if (SMTDSettings.RemovePadding and rendTimeType == 1) then
														theFile += reFilenameFile + reOutputType
													else
														theFile += reFilenameFile + delimiter + paddingOutputString + reOutputType
													append outputImageFilenames theFile

													try(SMTD_MainRollout.Ui_report (">Render Element Output Filename ["+theFile+"]"))catch()
													
													if AssemblyMode == #draft then
													(
														if MultiRegionRendering then
														(
															local theIndex = 0
															for aData2 in SMTDSettings.MultiRegionData where aData2[1] == True do
															(
																for y = 1 to aData2[7] do
																(
																	for x = 1 to aData2[6] do
																	(
																		local currTileString = "_region_" + theIndex as string + "_"
																		local theFile = reOutputPath
																		theFile += StereoCameraToken
																		theFile +=  reFilenameFile + currTileString + delimiter + paddingOutputString + theOutType
																		append inputImageFilenames theFile
																		theIndex += 1
																	)
																)
															)														
														)		
														else	
														(													
															for y = 1 to SMTDSettings.TilesInY do
															(
																for x = 1 to SMTDSettings.TilesInX do
																(
																	local currTileString = "_tile_" + x as string + "x" + y as string + "_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
																	local theFile = reOutputPath
																	theFile += StereoCameraToken
																	theFile += reFilenameFile + currTileString + delimiter + paddingOutputString + reOutputType
																	append inputImageFilenames theFile
																)
															)
														)
													)
													else --not draft
													(
														local tileString = "_tile_1x1_" + SMTDSettings.TilesInX as string + "x" + SMTDSettings.TilesInY as string + "_"
														local theFile = reOutputPath
														theFile += StereoCameraToken
														theFile += reFilenameFile + tileString + delimiter + paddingOutputString + reOutputType
														append inputImageFilenames theFile
													)--end if not draft
												)--is re path and name 
											)--skip?
										)--is re enabled?
									)--end re loop
								)--end Render Elements Active
							)--end if reManager undefined
						)--end new EXR format
						
						if AssemblyMode == #draft then
						(
							if MultiRegionRendering then
							(					
								tileCount = SingleLayerTilesCount 		
							)
							else
							(
								tileCount = fileCount
							)

							try(SMTD_MainRollout.Ui_report (">Submitting Draft Assembly Job."))catch()
							local framesList = #(currentTime.frame as integer)
							local tileResult = SMTDFunctions.SubmitDraftTileAssemblerJob jobId jobName outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames framesList batchName:batchName
							if not tileResult then
								return false
						)
						else --regular assembler
						(
							try(SMTD_MainRollout.Ui_report (">Submitting Tile Assembly Job."))catch()
							local tileResult = SMTDFunctions.SubmitTileAssemblerJob jobId jobName outputImageFilenames inputImageFilenames batchName:batchName
							if not tileResult then
								return false
						)
					)--end single tile job dependent
				)--end success
				else
					return false
				
				return true
			)--end single frame
			true
		),
		
		fn getTimeStampString =
		(
			local theTime = getLocalTime()
			deleteItem theTime 3
			local txt = ""
			for i = 1 to 6 do 
			(	
				txt+=theTime[i] as string
				if i < 6 do txt+= "_"
				if i == 3 do txt+= "_"
				if( i == 2 or i == 3) and theTime[i] < 10 do txt+= "0"
			)
			txt
		),
		
		fn SubmitDraftTileAssemblerJob jobId jobName outputImageFilenames tileCount tileLefts tileBottoms inputImageFilenames FramesList batchName:"" =
		(
			if outputImageFilenames.count == 0 do --no tiles are being created
			(
				try(SMTD_MainRollout.Ui_report ("--Failed Draft Assembly Job Submission as NO Output Image Filenames declared!"))catch()
				return false
			)

			local formattedJobName = (SMTDFunctions.FormatJobName jobName)
			local formattedComment = "Draft Assembler Dependent Job Submission from 3ds Max"
			
			local tilesRendering = findItem #(#animationTiles, #singleFrameTiles) SMTDSettings.RegionRenderingMode > 0
			local multiRegionRendering = findItem #(#singleFrameMultiRegion, #animationMultiRegion) SMTDSettings.RegionRenderingMode > 0
			
			SMTDFunctions.createSubmissionFolderAndUpdatePaths()
			
			local tileJobInfoFile = CreateFile SMTDPaths.SubmitInfoFile
			if (tileJobInfoFile != undefined) then
			(
				format "Plugin=DraftTileAssembler\n" to:tileJobInfoFile
				format "Name=%\n" formattedJobName to:tileJobInfoFile
				format "BatchName=%\n" batchName to:tileJobInfoFile
				format "UserName=%\n" SMTDSettings.UserName to:tileJobInfoFile
				format "Comment=%\n" formattedComment to:tileJobInfoFile
				format "Department=%\n" SMTDSettings.Department to:tileJobInfoFile

				if not SMTDSettings.AssemblerOverride then
				(
					format "Priority=%\n" SMTDSettings.Priority to:tileJobInfoFile
					format "Pool=%\n" SMTDSettings.PoolName to:tileJobInfoFile
					if SMTDSettings.Pool2Name != "" do
						format "SecondaryPool=%\n" SMTDSettings.Pool2Name to:tileJobInfoFile
					format "Group=%\n" SMTDSettings.Group to:tileJobInfoFile
				)
				else
				(
					format "Priority=%\n" SMTDSettings.AssemblerPriority to:tileJobInfoFile
					format "Pool=%\n" SMTDSettings.AssemblerPoolName to:tileJobInfoFile
					if SMTDSettings.AssemblerPool2Name != "" do
						format "SecondaryPool=%\n" SMTDSettings.AssemblerPool2Name to:tileJobInfoFile
					format "Group=%\n" SMTDSettings.AssemblerGroup to:tileJobInfoFile
				)

				format "OnJobComplete=%\n" SMTDSettings.OnComplete to:tileJobInfoFile
				
				if not SMTDSettings.UseSubmissionQueue do
					format "JobDependencies=%\n" jobId to:tileJobInfoFile
				
				
				format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:tileJobInfoFile
				if findItem #(#singleFrameMultiRegion, #singleFrameTiles) SMTDSettings.RegionRenderingMode == 0 then --not single frame region, do frame dependent assembly
				(
					format "IsFrameDependent=1\n" to:tileJobInfoFile
					local FramesListString = "" as stringStream
					for f in FramesList do format "%," f to:FramesListString
					FramesListString = FramesListString as string
					FramesListString = substring FramesListString 1 (FramesListString.count-1)
					format "Frames=%\n" FramesListString to:tileJobInfoFile
				)
				else
					format "Frames=0-%\n" ((outputImageFilenames.count*FramesList.count)-1) to:tileJobInfoFile --output as many tasks as there are aux files times the number of frames,

				/*
				if FramesList.count > 1 then
				(
					local theFramesString = "" as stringStream
					for f in FramesList do format "%," f to:theFramesString
				)
				else
				(
					format "Frames=1-%\n" outputImageFilenames.count to:tileJobInfoFile
				)
				*/

				format "ChunkSize=1\n" to:tileJobInfoFile
				--format "MachineLimit=1\n" to:tileJobInfoFile

				for i = 1 to outputImageFilenames.count do
					format "OutputFilename%=%\n" (i-1) outputImageFilenames[i] to:tileJobInfoFile

				local formattedExtraInfo0 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo0)
				local formattedExtraInfo1 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo1)
				local formattedExtraInfo2 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo2)
				local formattedExtraInfo3 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo3)
				local formattedExtraInfo4 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo4)
				local formattedExtraInfo5 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo5)
				local formattedExtraInfo6 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo6)
				local formattedExtraInfo7 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo7)
				local formattedExtraInfo8 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo8)
				local formattedExtraInfo9 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo9)

				format "ExtraInfo0=%\n" formattedExtraInfo0 to:tileJobInfoFile
				format "ExtraInfo1=%\n" formattedExtraInfo1	to:tileJobInfoFile
				format "ExtraInfo2=%\n" formattedExtraInfo2	to:tileJobInfoFile
				format "ExtraInfo3=%\n" formattedExtraInfo3	to:tileJobInfoFile
				format "ExtraInfo4=%\n" formattedExtraInfo4	to:tileJobInfoFile
				format "ExtraInfo5=%\n" formattedExtraInfo5	to:tileJobInfoFile
				format "ExtraInfo6=%\n" formattedExtraInfo6	to:tileJobInfoFile
				format "ExtraInfo7=%\n" formattedExtraInfo7	to:tileJobInfoFile
				format "ExtraInfo8=%\n" formattedExtraInfo8	to:tileJobInfoFile
				format "ExtraInfo9=%\n" formattedExtraInfo9	to:tileJobInfoFile

				Close tileJobInfoFile
			)
			else
				return false

			local tileJobPluginFile = CreateFile SMTDPaths.JobInfoFile
			if (tileJobPluginFile != undefined) then
			(
				format "CleanupTiles=%\n" SMTDSettings.SingleTileJobCleanup to:tileJobPluginFile
				
				--Do not error on missing tiles or backgrounds in single tile mode
				if SMTDSettings.RegionRenderingMode == #singleFrameTiles then
					format "ErrorOnMissing=false\n" to:tileJobPluginFile
				else
					format "ErrorOnMissing=%\n" SMTDSettings.SingleTileJobDraftErrorOnMissing to:tileJobPluginFile
				format "MultipleConfigFiles=true\n" to:tileJobPluginFile
				if SMTDSettings.MultiRegionBackground == #previous or SMTDSettings.RegionRenderingMode == #singleFrameTiles do
				(
					format "ErrorOnMissingBackground=False\n" to:tileJobPluginFile
				)
				Close tileJobPluginFile
			)
			else
				return false

			local tileArgs = "" as stringstream
			format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:tileArgs						
			if SMTDSettings.bgSubmission do format "-background\n -notify\n" to:tileArgs 
			if SMTDSettings.dropSubmission do format "-drop\n" to:tileArgs 
			format "%\n"	SMTDPaths.SubmitInfoFile to:tileArgs 
			format "%\n"	SMTDPaths.JobInfoFile to:tileArgs 
			
			local theLeftsBottomsCounter = 0
			local dateString = SMTDFunctions.getTimeStampString()
			for f in FramesList do
			(
				for i = 0 to (outputImageFilenames.count-1) do
				(
					local currentDraftFileName = getFileNameFile outputImageFilenames[i+1]+"_"+i as string+"_config_"+ dateString + "_" +(SMTDFunctions.getZeros f) + (f as string) + getFileNameType SMTDPaths.DraftConfigFile
					local remoteConfigFileName = (getFileNamePath outputImageFilenames[i+1] + currentDraftFileName)
					local currConfigFileName = (getFileNamePath SMTDPaths.SubmitInfoFile + currentDraftFileName)
					
					format "%\n"	currConfigFileName to:tileArgs 
					--print currConfigFileName
					local draftConfigFile = CreateFile currConfigFileName
					if (draftConfigFile != undefined) then
					(
						format "\n" to:draftConfigFile

						if (SMTDSettings.RemovePadding and rendTimeType == 1) then
							format "ImageFileName=%\n" outputImageFilenames[i+1] to:draftConfigFile
						else
							format "ImageFileName=%\n" (SMTDFunctions.replaceFrameNumber outputImageFilenames[i+1] f) to:draftConfigFile

						case SMTDSettings.MultiRegionBackground of
						(
							#previous:
							(
								if (SMTDSettings.RemovePadding and rendTimeType == 1) then
									format "BackgroundSource=%\n" outputImageFilenames[i+1] to:draftConfigFile
								else
									format "BackgroundSource=%\n" (SMTDFunctions.replaceFrameNumber outputImageFilenames[i+1] f) to:draftConfigFile
							)
							#single: --only output custom background for Beauty pass
							(
								if i == 0 do format "BackgroundSource=%\n" SMTDSettings.MultiRegionBackgroundImage to:draftConfigFile
							)
							#sequence: --only output custom background for Beauty pass
							(
								if i == 0 do format "BackgroundSource=%\n" (SMTDFunctions.replaceFrameNumber SMTDSettings.MultiRegionBackgroundImage f) to:draftConfigFile
							)
						)

						format "TileCount=%\n" tileCount to:draftConfigFile
						format "TilesCropped=True\n" to:draftConfigFile
						format "DistanceAsPixels=True\n" to:draftConfigFile

						renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

						format "ImageWidth=%\n" renderDimensions[1] to:draftConfigFile
						format "ImageHeight=%\n" renderDimensions[2] to:draftConfigFile

						if MultiRegionRendering then
						(
							local theIndex = 0
							for aData in SMTDSettings.MultiRegionData where aData[1] == True do
							(
								for y = 1 to aData[7] do
								(
									for x = 1 to aData[6] do
									(
										try(windows.processPostedMessages())catch()
										theLeftsBottomsCounter+=1

										if (SMTDSettings.RemovePadding and rendTimeType == 1) then
											format "Tile%FileName=%\n" theIndex inputImageFilenames[(i * tileCount)+theIndex+1] to:draftConfigFile
										else
											format "Tile%FileName=%\n" theIndex (SMTDFunctions.replaceFrameNumber inputImageFilenames[(i * tileCount)+theIndex+1] f) to:draftConfigFile

										local theAnimRegionValue = SMTDFunctions.interpolateAnimatedRegion aData f
										local theTileWidth = theAnimRegionValue[4]/aData[6]
										local theTileHeight = theAnimRegionValue[5]/aData[7]
										local corner1X = ((floor ((theAnimRegionValue[2]+(theTileWidth*(x-1)))*renderDimensions[1])) as integer)
										local corner2Y = renderDimensions[2] - ((floor ((theAnimRegionValue[3]+(theTileHeight*y))*renderDimensions[2])) as integer)											

										format "Tile%X=%\n" theIndex corner1X to:draftConfigFile
										format "Tile%Y=%\n" theIndex corner2Y to:draftConfigFile									
										theIndex += 1	
									)
								)
							)
						)
						else
						(
							for j = 0 to tileCount-1 do
							(
								if (SMTDSettings.RemovePadding and rendTimeType == 1) then
									format "Tile%FileName=%\n" j inputImageFilenames[(i * tileCount) + j + 1] to:draftConfigFile
								else
									format "Tile%FileName=%\n" j (SMTDFunctions.replaceFrameNumber inputImageFilenames[(i * tileCount) + j + 1] f) to:draftConfigFile

								format "Tile%X=%\n" j tileLefts[j+1] to:draftConfigFile
								format "Tile%Y=%\n" j tileBottoms[j+1] to:draftConfigFile
							)
						)
						Close draftConfigFile
						if SMTDSettings.MultiRegionCopyDraftConfig == true do 
							copyFile currConfigFileName remoteConfigFileName 
					)
					else
						return false
				)--outputfile loop
			)--end frame loop	
			
			local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
			local initialArgsFile = createFile initialArgsFileName
			format "%" (tileArgs as string) to:initialArgsFile
			close initialArgsFile 
			
			retcode = SMTDFunctions.waitForCommandToComplete ("\"" + initialArgsFileName+"\"") SMTDSettings.TimeoutSubmission paramIsFile:true dontWait:SMTDSettings.UseSubmissionQueue 
			try(SMTD_MainRollout.Ui_report (">Draft Assembly Job Submission Returned " + retcode as string))catch()
			if retcode != #success and retcode != #queued then
				return false
			
			true
		),
		
		fn SubmitTileAssemblerJob jobId jobName outputImageFilenames inputImageFilenames batchName:"" =
		(
			local formattedJobName = (SMTDFunctions.FormatJobName jobName)
			local formattedComment = "Tile Assembler Dependent Job Submission from 3ds Max"
			
			SMTDFunctions.createSubmissionFolderAndUpdatePaths()
			
			local tileJobInfoFile = CreateFile SMTDPaths.SubmitInfoFile
			if (tileJobInfoFile != undefined) then
			(
				format "Plugin=TileAssembler\n" to:tileJobInfoFile
				format "Name=%\n" formattedJobName to:tileJobInfoFile
				format "BatchName=%\n" batchName to:tileJobInfoFile
				
				format "UserName=%\n" SMTDSettings.UserName to:tileJobInfoFile
				format "Comment=%\n" formattedComment to:tileJobInfoFile
				format "Department=%\n" SMTDSettings.Department to:tileJobInfoFile	

				if not SMTDSettings.AssemblerOverride then
				(
					format "Priority=%\n" SMTDSettings.Priority to:tileJobInfoFile
					format "Pool=%\n" SMTDSettings.PoolName to:tileJobInfoFile
					if SMTDSettings.Pool2Name != "" do
						format "SecondaryPool=%\n" SMTDSettings.Pool2Name to:tileJobInfoFile
					format "Group=%\n" SMTDSettings.Group to:tileJobInfoFile
				)
				else
				(
					format "Priority=%\n" SMTDSettings.AssemblerPriority to:tileJobInfoFile
					format "Pool=%\n" SMTDSettings.AssemblerPoolName to:tileJobInfoFile
					if SMTDSettings.AssemblerPool2Name != "" do
						format "SecondaryPool=%\n" SMTDSettings.AssemblerPool2Name to:tileJobInfoFile
					format "Group=%\n" SMTDSettings.AssemblerGroup to:tileJobInfoFile
				)

				format "OnJobComplete=%\n" SMTDSettings.OnComplete to:tileJobInfoFile
				format "JobDependencies=%\n" jobId to:tileJobInfoFile
				format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:tileJobInfoFile
				format "Frames=0-%\n" (outputImageFilenames.count-1) to:tileJobInfoFile
				format "ChunkSize=1\n" to:tileJobInfoFile

				for i = 0 to (outputImageFilenames.count-1) do
				(
					format "OutputFilename%=%\n" i outputImageFilenames[i+1] to:tileJobInfoFile
				)

				local formattedExtraInfo0 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo0)
				local formattedExtraInfo1 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo1)
				local formattedExtraInfo2 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo2)
				local formattedExtraInfo3 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo3)
				local formattedExtraInfo4 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo4)
				local formattedExtraInfo5 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo5)
				local formattedExtraInfo6 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo6)
				local formattedExtraInfo7 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo7)
				local formattedExtraInfo8 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo8)
				local formattedExtraInfo9 = (SMTDFunctions.FormatExtraInfo SMTDSettings.ExtraInfo9)

				format "ExtraInfo0=%\n" formattedExtraInfo0 to:tileJobInfoFile
				format "ExtraInfo1=%\n" formattedExtraInfo1	to:tileJobInfoFile
				format "ExtraInfo2=%\n" formattedExtraInfo2	to:tileJobInfoFile
				format "ExtraInfo3=%\n" formattedExtraInfo3	to:tileJobInfoFile
				format "ExtraInfo4=%\n" formattedExtraInfo4	to:tileJobInfoFile
				format "ExtraInfo5=%\n" formattedExtraInfo5	to:tileJobInfoFile
				format "ExtraInfo6=%\n" formattedExtraInfo6	to:tileJobInfoFile
				format "ExtraInfo7=%\n" formattedExtraInfo7	to:tileJobInfoFile
				format "ExtraInfo8=%\n" formattedExtraInfo8	to:tileJobInfoFile
				format "ExtraInfo9=%\n" formattedExtraInfo9	to:tileJobInfoFile

				Close tileJobInfoFile
			)
			else
				return false

			local tileJobPluginFile = CreateFile SMTDPaths.JobInfoFile
			if (tileJobPluginFile != undefined) then
			(
				for i = 0 to (inputImageFilenames.count-1) do
					format "InputImages%=%\n" i inputImageFilenames[i+1] to:tileJobPluginFile
					
				format "CleanupTiles=%\n" SMTDSettings.SingleTileJobCleanup to:tileJobPluginFile
				format "NotCropped=False\n" to:tileJobPluginFile
				format "IgnoreOverlap=False\n" to:tileJobPluginFile
				Close tileJobPluginFile
			)
			else
				return false
			
			local tileArgs = ""
			if SMTDSettings.bgSubmission do tileArgs += "-background -notify "
			if SMTDSettings.dropSubmission do tileArgs += "-drop "
			tileArgs += "\"" + SMTDPaths.SubmitInfoFile + "\" \"" + SMTDPaths.JobInfoFile + "\" "
			
			retcode = SMTDFunctions.waitForCommandToComplete ( tileArgs ) SMTDSettings.TimeoutSubmission
			if retcode != #success then
				return false
			
			true
		),

		--SUBMIT BATCH JOBS LOCALLY
		fn spawnBatchJobsLocal forceMaxFile: =
		(
			SMTDSettings.UseBatchRender = false --before spawning new jobs, make sure they don't become batch masters
			
			local batchName = SMTDFunctions.getBatchName()

			renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)

			local def_RenderWidth = renderDimensions[1]
			local def_RenderHeight = renderDimensions[2]
			local def_RenderPixelAspect = renderDimensions[3]
			local def_Camera = viewport.getCamera()
			local def_rendOutputFileName = rendOutputFileName 
			local def_rendSaveFile = rendSaveFile
			local def_rendTimeType = rendTimeType 
			local def_rendStart = rendStart
			local def_rendEnd = rendEnd
			
			local theJobName = SMTDSettings.JobName
			local currentJob = 0
			local numViews = batchRenderMgr.numViews 
			local views = (for i = 1 to numViews collect (batchRenderMgr.getView i))
			local numberOfBatchJobs =  (for i = 1 to numViews where (batchRenderMgr.getView i).enabled collect i).count
			
			local needMaxReload = false
			--local theNetworkPath = SMTDFunctions.GetNetworkRoot()
			--theNetworkPath += "\\submission\\3dsmax\\main\\"

			--SMTDFunctions.createSubmissionFolderAndUpdatePaths()
			local originalPath = SMTDPaths.RestoreTempMaxFile
			try(SMTD_MainRollout.Ui_report ("Backup Scene Path: [" + originalPath + "]"))catch()
			if (result = SMTDFunctions.SaveMaxFileCopy originalPath useMaxHold:true) != undefined do
				return ("SAVING BACKUP FILE:\n" + result)
			
			for i = 1 to numViews do
			(
				SMTDFunctions.createSubmissionFolderAndUpdatePaths()
				local theView = views[i]
				if theView.enabled then 
				(
					if needMaxReload then
					(
						try(SMTD_MainRollout.Ui_report (">Reloading original scene..."))catch()
						SMTDFunctions.RestoreMaxFileCopy originalPath
						needMaxReload = false
					)	
					else
					(
						RenderWidth = def_RenderWidth 
						RenderHeight = def_RenderHeight 
						RenderPixelAspect = def_RenderPixelAspect 
						if (def_Camera != undefined) and (IsValidNode def_Camera) do viewport.setCamera def_Camera
						rendOutputFileName = def_rendOutputFileName 
						rendSaveFile = def_rendSaveFile
						rendTimeType = def_rendTimeType 
						rendStart = def_rendStart 
						rendEnd = def_rendEnd 
					)
					
					if theView.outputFilename != "" then
					(
						currentJob+=1
						--try(DeadlineUtil.SetProgress (100.0*i/numViews) )catch()
						--try(DeadlineUtil.LogMessage (">Processing View Definition ["+ theView.name +"] ..."))catch()	
						SMTDSettings.JobName = theJobName + " (BATCH " + currentJob as string+ " of " + numberOfBatchJobs as string + ")"
						
						--Load Scene State
						if theView.sceneStateName == "" then
							try(SMTD_MainRollout.Ui_report ("--No Scene State Defined For This View"))catch()
						else
						(
							try(SMTD_MainRollout.Ui_report (">Restoring Scene State [" + theView.sceneStateName + "]"))catch()
							result = sceneStateMgr.RestoreAllParts theView.sceneStateName
							if result then
							(
								try(SMTD_MainRollout.Ui_report ("+Scene State Manager Successfully Restored the Scene State."))catch()
								needMaxReload = true
							)	
							else
								try(SMTD_MainRollout.Ui_report ("--Scene State Manager FAILED to Restore the Scene State"))catch()
						)		
						
						--Load Render Preset
						if (fileNameFromPath theView.presetFile) == "" then
							try(SMTD_MainRollout.Ui_report ("--No Render Preset Defined For This View"))catch()
						else
						(
							--DeadlineUtil.LogMessage (">Loading Render Preset [" + (fileNameFromPath theView.presetFile) + "]")
							--result = renderpresets.LoadAll 0 (maxFilePath + (fileNameFromPath theView.presetFile))
							try(SMTD_MainRollout.Ui_report (">Loading Render Preset [" +  theView.presetFile + "]"))catch()
							result = renderpresets.LoadAll 0 theView.presetFile
							if result then
							(
								try(SMTD_MainRollout.Ui_report ("+Render Presets Manager Successfully Loaded the Render Preset."))catch()
								needMaxReload = true
							)	
							else
								try(SMTD_MainRollout.Ui_report ("--Render Presets Manager FAILED to Load the Render Preset For This View"))catch()
						)	
						
						--Set Camera if specified
						if isValidNode theView.camera then
						(
							viewport.setCamera theView.camera
							if def_Camera == undefined do needMaxReload = true
						)	
						
						--Set New Output File
						rendOutputFileName = theView.outputFilename --get path from Batch Render Dialog
						rendSaveFile = true
						
						--Set Alternative Resolution and Pixel Aspect if Override Preset is on
						--Set Alternative Frame Range is Override Preset is on
						if theView.overridePreset then
						(
							RenderWidth = theView.width
							RenderHeight = theView.height
							RenderPixelAspect = theView.pixelAspect
							rendTimeType = 3
							rendStart = theView.startFrame
							rendEnd = theView.endFrame
						)	
						
						try(SMTD_MainRollout.Ui_report ("Spawning Job " + SMTDSettings.JobName))catch()
						
						local theMaxFileName = maxFileName
						if theMaxFileName == "" do theMaxFileName = "Untitled.max"
						local TempMaxFile = getFileNamePath (SMTDPaths.SubmitInfoFile) + theMaxFileName
						if (doesFileExist TempMaxFile) do deleteFile TempMaxFile
						result = SMTDFunctions.SaveMaxFileCopy TempMaxFile

						--SMTDFunctions.createSubmissionFolderAndUpdatePaths() --since this is on a slave, it does not matter
						SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile batchName:batchName stereoCameraLabel:stereoCameraLabel
						SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
						
						local initialArgs = "" as stringStream
						format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs						
						
						if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs 
						if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs 
						
						format "%\n%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile  TempMaxFile to:initialArgs  --(theNetworkPath + "maxTileAssemblerCommand.ms")
						if SMTDSettings.CopyVbscriptFile do format  "%\n" SMTDPaths.ImsqVbscriptFile to:initialArgs
						if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
						if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
						if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
						if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
						if SMTDSettings.SubmitSceneMode == #reposave do
						(
							if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
						)

						local BitmapsCopyData = #()
						if SMTDSettings.SubmitExternalFilesMode > 1 do
						(
							BitmapsCopyData = SMTDFunctions.GetExternalFilesToCopy()			
							for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
								format "%\n" aBitmap[1] to:initialArgs							
						)
							
						local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
						local initialArgsFile = createFile initialArgsFileName
						format "%\n" (initialArgs as string) to:initialArgsFile
						close initialArgsFile 
						initialArgsFileName = "\""+initialArgsFileName+"\""
							
						retcode = SMTDFunctions.waitForCommandToComplete ( initialArgsFileName ) SMTDSettings.TimeoutSubmission paramIsFile:true		
						SMTDFunctions.getJobIDFromMessage (SMTDFunctions.getRenderMessage())
					)
					else
						try(SMTD_MainRollout.Ui_report ("--View Definition ["+ theView.name +"] has NO Output File Name - Skipping..."))catch()
				)
				else
					try(SMTD_MainRollout.Ui_report ("--View Definition ["+ theView.name +"] is disabled - Skipping..."))catch()
			)--end batch loop
			try(SMTD_MainRollout.Ui_report (">Restoring Scene Backup From [" + originalPath + "]" ))catch()
			SMTDFunctions.RestoreMaxFileCopy originalPath
			SMTDSettings.UseBatchRender = true
			true
		),

		--SUBMIT BATCH JOBS FROM A SLAVE TO DEADLINE
		fn spawnBatchJobs =
		(
			SMTDSettings.UseBatchRender = false --before spawning new jobs, make sure they don't become batch masters

			renderDimensions = SMTDFunctions.getRenderDimensions() --#(renderWidth,renderHeight,renderPixelAspect)
			
			local def_RenderWidth = renderDimensions[1]
			local def_RenderHeight = renderDimensions[2]
			local def_RenderPixelAspect = renderDimensions[3]
			local def_Camera = viewport.getCamera()
			local def_rendOutputFileName = rendOutputFileName 
			local def_rendSaveFile = rendSaveFile
			local def_rendTimeType = rendTimeType 
			local def_rendStart = rendStart
			local def_rendEnd = rendEnd
			
			local batchName = SMTDFunctions.getBatchName()
			
			local theJobName = SMTDSettings.JobName
			local currentJob = 0
			local numViews = batchRenderMgr.numViews 
			local views = (for i = 1 to numViews collect (batchRenderMgr.getView i))
			local numberOfBatchJobs =  (for i = 1 to numViews where (batchRenderMgr.getView i).enabled collect i).count
			
			local needMaxReload = false
			
			local theExternalFilesToCopy = #()
			if SMTDSettings.CurrentRepository == "" and SMTDSettings.SubmitExternalFilesMode > 1 do
			(
				local ExternalFilesListName = DeadlineUtil.SceneFilePath + "\\ExternalFilesList.txt"  
				if doesFileExist ExternalFilesListName then
				(
					try(DeadlineUtil.logMessage "External File List Found!")catch()
					local theExternalFilesList = openFile ExternalFilesListName
					while not eof theExternalFilesList do
					(
						append theExternalFilesToCopy (readline theExternalFilesList)
					)
					close theExternalFilesList 
				)
				else
					try(DeadlineUtil.logMessage "External File List DOES NOT Exist!")catch()
			)
			
			for i = 1 to numViews do
			(
				local theView = views[i]
				if theView.enabled then 
				(
					if needMaxReload then
					(
						DeadlineUtil.LogMessage (">Reloading original scene...")
						--loadMaxFile (maxFilePath + maxFileName) quiet:true
						loadMaxFile (DeadlineUtil.SceneFilePath + "\\" + maxFileName) quiet:true
						needMaxReload = false
					)	
					else
					(
						RenderWidth = def_RenderWidth 
						RenderHeight = def_RenderHeight 
						RenderPixelAspect = def_RenderPixelAspect 
						if (def_Camera != undefined) and (IsValidNode def_Camera) do viewport.setCamera def_Camera
						rendOutputFileName = def_rendOutputFileName 
						rendSaveFile = def_rendSaveFile
						rendTimeType = def_rendTimeType 
						rendStart = def_rendStart 
						rendEnd = def_rendEnd 
					)
					
					if theView.outputFilename != "" then
					(
						currentJob+=1
						try(DeadlineUtil.SetProgress (100.0*i/numViews) )catch()
						try(DeadlineUtil.LogMessage (">Processing View Definition ["+ theView.name +"] ..."))catch()	
						SMTDSettings.JobName = theJobName + " (BATCH " + currentJob as string+ " of " + numberOfBatchJobs as string + ")"
						
						--Load Scene State
						if theView.sceneStateName == "" then
							DeadlineUtil.LogMessage ("--No Scene State Defined For This View")
						else
						(
							DeadlineUtil.LogMessage (">Restoring Scene State [" + theView.sceneStateName + "]")
							result = sceneStateMgr.RestoreAllParts theView.sceneStateName
							if result then
							(
								DeadlineUtil.LogMessage ("+Scene State Manager Successfully Restored the Scene State.")
								needMaxReload = true
							)	
							else
								DeadlineUtil.LogMessage ("--Scene State Manager FAILED to Restore the Scene State")
						)		
						
						--Load Render Preset
						if (fileNameFromPath theView.presetFile) == "" then
							DeadlineUtil.LogMessage ("--No Render Preset Defined For This View")
						else
						(
							--DeadlineUtil.LogMessage (">Loading Render Preset [" + (fileNameFromPath theView.presetFile) + "]")
							--result = renderpresets.LoadAll 0 (maxFilePath + (fileNameFromPath theView.presetFile))
							DeadlineUtil.LogMessage (">Loading Render Preset [" + (DeadlineUtil.SceneFilePath + "\\" + (fileNameFromPath theView.presetFile)) + "]")
							result = renderpresets.LoadAll 0 (DeadlineUtil.SceneFilePath + "\\" + (fileNameFromPath theView.presetFile))
							if result then
							(
								DeadlineUtil.LogMessage ("+Render Presets Manager Successfully Loaded the Render Preset.")
								needMaxReload = true
							)	
							else
								DeadlineUtil.LogMessage ("--Render Presets Manager FAILED to Load the Render Preset For This View")
						)	
						
						--Set Camera if specified
						if isValidNode theView.camera then
						(
							viewport.setCamera theView.camera
							if def_Camera == undefined do needMaxReload = true
						)	
						
						--Set New Output File
						rendOutputFileName = theView.outputFilename --get path from Batch Render Dialog
						rendSaveFile = true
						
						--Set Alternative Resolution and Pixel Aspect if Override Preset is on
						--Set Alternative Frame Range is Override Preset is on
						if theView.overridePreset then
						(
							RenderWidth = theView.width
							RenderHeight = theView.height
							RenderPixelAspect = theView.pixelAspect
							rendTimeType = 3
							rendStart = theView.startFrame
							rendEnd = theView.endFrame
						)	
						
						try(DeadlineUtil.LogMessage ("Spawning Job " + SMTDSettings.JobName))catch()
						
						local theNetworkPath = SMTDFunctions.GetNetworkRoot()
						
						local TempMaxFile = getFileNamePath (SMTDPaths.RestoreTempMaxFile) + maxFileName
						if (doesFileExist TempMaxFile) do deleteFile TempMaxFile
						result = SMTDFunctions.SaveMaxFileCopy TempMaxFile

						SMTDFunctions.createSubmissionFolderAndUpdatePaths() 
						SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile batchName:batchName stereoCameraLabel:stereoCameraLabel
						SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
						
						local initialArgs = "" as StringStream
						format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs
							
						if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs
						if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs
						
						theNetworkPath += "\\submission\\3dsmax\\Main\\"
						
						format "%\n%\n%\n%maxTileAssemblerCommand.ms\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile  TempMaxFile theNetworkPath to:initialArgs
						if SMTDSettings.CopyVbscriptFile do format "%\n" SMTDPaths.ImsqVbscriptFile  to:initialArgs
						if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
						if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
						if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
						if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
						if SMTDSettings.SubmitSceneMode == #reposave do
						(
							if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
						)

						for f in theExternalFilesToCopy do 
							format "%\n" (DeadlineUtil.SceneFilePath +"\\"+ (filenameFromPath f)) to:initialArgs
							
						local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
						local initialArgsFile = createFile initialArgsFileName
						format "%\n" (initialArgs as string) to:initialArgsFile
						close initialArgsFile 
						initialArgsFileName = "\""+initialArgsFileName+"\""
						retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true								
							
						SMTDFunctions.getJobIDFromMessage (SMTDFunctions.getRenderMessage())
					)
					else
						try(DeadlineUtil.LogMessage ("--View Definition ["+ theView.name +"] has NO Output File Name - Skipping..."))catch()
				)
				else
					try(DeadlineUtil.LogMessage ("--View Definition ["+ theView.name +"] is disabled - Skipping..."))catch()				
			)--end batch loop
			SMTDSettings.UseBatchRender = true
			true
		),

		
		fn getJobIDFromMessage renderMsg =
		(
			SMTDSettings.DeadlineSubmissionLastJobID = "failed"
			theStringStream = renderMsg as stringStream
			skipToString theStringStream "JobID="
			try(SMTDSettings.DeadlineSubmissionLastJobID = readline theStringStream)catch()
			close theStringStream 
		),

		fn getRenderMessage =
		(
			local resultFile = OpenFile SMTDPaths.SubmitOutput
			local renderMsg = "No message."
			if (resultFile != undefined) do
			(
				seek resultFile #eof
				local fileSize = filepos resultFile
				seek resultFile 0
				renderMsg = readChars resultFile fileSize errorAtEOF:false
				close resultFile
			)
			renderMsg 
		),
		
		fn GetExternalFilesToCopy =
		(
			local uniquenamedata = #()
			local BitmapsCopyData = #()
			if SMTDSettings.CurrentRepository == "" AND SMTDSettings.SubmitExternalFilesMode > 1 AND SMTDSettings.SubmitExternalFilesMode < 4  do
			(
				for o in SMTDExternalRefsArray.storeBitmapPath where findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)	
				for o in SMTDExternalRefsArray.storeHdriPath where findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)	
				for o in SMTDExternalRefsArray.StoreSceneXRefs where o[4] AND findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)	
				for o in SMTDExternalRefsArray.StoreObjectXRefs where findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)	
				for o in SMTDExternalRefsArray.StoreSceneVrayProxies where findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)
				for o in SMTDExternalRefsArray.StoreSceneCoronaProxies where findItem uniquenamedata o[2] == 0 do 
				(
					append uniquenamedata o[2]
					append BitmapsCopyData #(o[2],o[3])
				)
				for o in SMTDExternalRefsArray.StoreSceneMRProxies where findItem uniquenamedata o[2] == 0 do 
				(
					if o[1].animated then
					(
						local theAnimationFiles = SMTDFunctions.GetAnimationFiles o[2]
						for f in theAnimationFiles do
						(
							append uniquenamedata f
							append BitmapsCopyData #(f, SMTDFunctions.RenameTargetAnimationFile f o[3])
						)
					)
					else
					(
						append uniquenamedata o[2]
						append BitmapsCopyData #(o[2],o[3])
					)
				)					
				
				/*
				if SMTDSettings.UseBatchRender then
				(
					local numViews = batchRenderMgr.numViews 
					local numberOfBatchJobs =  (for i = 1 to numViews where (batchRenderMgr.getView i).enabled collect i).count
					for i = 1 to numViews do
					(
						local theView = batchRenderMgr.getView i
						if theView.enabled and theView.presetFile != "" then 
							append BitmapsCopyData #(theView.presetFile, fileNameFromPath theView.presetFile)
					)	
				)
				*/
			)
			BitmapsCopyData
		),
		

		fn SubmitTransferJob =
		(
			-- Only submit a transfer job if a remote repository has been selected.
			if SMTDSettings.CurrentRepository2 != "" do
			(
				try(SMTD_MainRollout.Ui_report ">Submitting Transfer Job.")catch()
				
				local transferJobID = SMTDSettings.DeadlineSubmissionLastJobID
				local transferJobRepository = SMTDSettings.CurrentRepository2
				local transferAsSuspended = SMTDSettings.TransferJobAsSuspended
				local transferCompress = SMTDSettings.TransferCompressed
				local transferEmailResults = true
				local transferRemoveLocal = true
				
				local transferJobName = ("Transfer of " + (SMTDFunctions.FormatJobName SMTDSettings.JobName) + " (" + transferJobID + ")")
				local transferDepartment = SMTDSettings.Department
				local transferPool = SMTDSettings.TransferPool
				local transferGroup = SMTDSettings.TransferGroup
				local transferPriority = SMTDSettings.TransferPriority
				local transferDeleteOnComplete = SMTDSettings.TransferDeleteOnComplete
				
				local jobInfoFilename = SMTDPaths.TempDir + "job_transfer_info.job"
				local pluginInfoFilename = SMTDPaths.TempDir + "job_transfer_plugin.job"
				
				-- Create job info file
				local jobInfoFile = CreateFile jobInfoFilename
				if (jobInfoFile != undefined) then
				(
					format "Plugin=JobTransfer\n"										to:jobInfoFile
					format "Name=%\n" 						transferJobName				to:jobInfoFile
					format "BatchName=%\n" 					SMTDSettings.JobName		to:jobInfoFile
					format "UserName=%\n"					SMTDSettings.UserName		to:jobInfoFile
					format "Department=%\n" 				transferDepartment		 	to:jobInfoFile
					format "Pool=%\n" 						transferPool				to:jobInfoFile
					format "Group=%\n" 						transferGroup				to:jobInfoFile
					format "Priority=%\n" 					transferPriority 	 		to:jobInfoFile
					format "Frames=0\n"													to:jobInfoFile
					format "ChunkSize=1\n" 												to:jobInfoFile
					if transferDeleteOnComplete do
						format "OnJobComplete=Delete\n"									to:jobInfoFile
					close jobInfoFile
				)
				
				-- Create the plugin info file
				local pluginInfoFile = CreateFile pluginInfoFilename
				if (pluginInfoFile != undefined) then
				(
					format "TransferJobID=%\n" 				transferJobID				to:pluginInfoFile
					format "TransferRepository=%\n"			transferJobRepository		to:pluginInfoFile
					format "SuspendedAfterTransfer=%\n" 	transferAsSuspended			to:pluginInfoFile
					format "RemoveLocalAfterTransfer=%\n" 	transferRemoveLocal			to:pluginInfoFile
					format "EmailResultsAfterTransfer=%\n" 	transferEmailResults		to:pluginInfoFile
					format "CompressFiles=%\n" 				transferCompress 	 		to:pluginInfoFile
					
					format "TransferJobFrames=\n"										to:pluginInfoFile
					format "TransferJobChunkSize=\n"									to:pluginInfoFile
					
					close pluginInfoFile
				)
				
				-- Submit the transfer job
				local initialArgs = "\"" + jobInfoFilename + "\" \"" + pluginInfoFilename + "\""
				local retCode = SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission
				if retCode == #success then
				(
					renderMsg = SMTDFunctions.getRenderMessage()
					try(SMTD_MainRollout.Ui_report ("Transfer Job submitted successfully.\n\n" + renderMsg))catch()
					try(SMTD_MainRollout.sld_lastSubmissionState.color = green)catch()
				)	
				else	
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red*0.7)catch()
					if result == #timeout then
						try(SMTD_MainRollout.Ui_report ("--Failed To Submit Transfer Job in " + SMTDSettings.TimeoutSubmission as string + " seconds.\nConsider Increasing the Job Submission Timeout in the User Options tab."))catch()
					else	
						try(SMTD_MainRollout.Ui_report ("--Failed To Submit Transfer Job."))catch()
				)
			)
		),
		
		fn SubmitJob createJobInfo:true createSubmitInfo:true timeout:3600 =
		(
			SMTDSettings.DeadlineSubmissionSuccessful = false
			SMTDSettings.DeadlineSubmissionLastJobID = "failed"
			renderSceneDialog.Commit()
			try(SMTD_RegionRendering.chk_showRegionGizmo.changed (SMTD_RegionRendering.chk_showRegionGizmo.state = false))catch()
			try(SMTD_TilesRendering.chk_showRegionGizmo.changed (SMTD_TilesRendering.chk_showRegionGizmo.state = false))catch()
				
			SMTDFunctions.createSubmissionFolderAndUpdatePaths()
				
			local TempMaxFile = ""
			case SMTDSettings.SubmitSceneMode of
			(
				#reposave: 
				(
					local TempMaxFile = getFileNamePath (SMTDPaths.RestoreTempMaxFile) + maxFileName
					if maxFileName == "" do TempMaxFile += "untitled.max"
					if (doesFileExist TempMaxFile) do deleteFile TempMaxFile
					result = SMTDFunctions.SaveMaxFileCopy TempMaxFile
					if result != undefined do return result
				)
				default: --#networksave or #globalnetworksave
				(
					local theFilterTime = filterString localtime " /\\-:"
					local theTime = ""
					for i = 1 to theFilterTime.count do theTime += theFilterTime[i] + "_"
					if SMTDSettings.SubmitSceneMode == #networksave then
						TempMaxFile = SMTDSettings.SubmitSceneBasePath +"\\"+SMTDSettings.userName+"\\"+theTime+"\\"
					else
						TempMaxFile = SMTDSettings.SubmitSceneGlobalBasePath +"\\"+SMTDSettings.userName+"\\"+theTime+"\\"
					makedir TempMaxFile all:true
					TempMaxFile += (if maxFileName == "" then "untitled.max" else maxFileName)
					result = SMTDFunctions.SaveMaxFileCopy TempMaxFile
					if result != undefined do return result
				)
				#networkuse: 
				(
					if maxFileName == "" then
					(
						filename = getMAXSaveFileName()
						if filename == undefined do return ""
						
						TempMaxFile = filename
					)
					else
						TempMaxFile = maxFilePath + maxFileName
					if not SMTDSettings.StateSetsSubmit AND SMTDSettings.DeleteEmptyStateSets do SMTDFunctions.DeleteEmptyStateSets()
					saveMaxFile TempMaxFile
				)
				#networksaveanduse:
				(
					if maxFileName == "" then
					(
						filename = getMAXSaveFileName()
						if filename == undefined do return ""
						
						TempMaxFile = filename
					)
					else
						TempMaxFile = maxFilePath + maxFileName
					if not SMTDSettings.StateSetsSubmit AND SMTDSettings.DeleteEmptyStateSets do SMTDFunctions.DeleteEmptyStateSets()
					saveMaxFile TempMaxFile
				)
				#networkremap:
				(
					
				)				
			)
				
			local initialArgs = "" As StringStream
			format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs
			
			if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs
			if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs
			
			if createSubmitInfo do
				if ((SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile) != true) do return #SubmitInfoFileCreationFailed
			if createJobInfo do
				if ((SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile) != true) do return #JobInfoFileCreationFailed
			
			if not doesFileExist SMTDPaths.SubmitInfoFile do return #SubmitInfoFileMissing
			if not doesFileExist SMTDPaths.JobInfoFile do return #JobInfoFileMissing
			
			if( SMTDSettings.SubmitSceneMode == #reposave ) then
				format "%\n%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile TempMaxFile to:initialArgs
			else
				format "%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile to:initialArgs
			
			if SMTDSettings.SubmitAsMXSJob do format "%\n" SMTDSettings.MAXScriptFile to:initialArgs
				
			local BitmapsCopyData = #()
			if SMTDSettings.CurrentRepository == "" and SMTDSettings.SubmitExternalFilesMode > 1 do
				BitmapsCopyData = SMTDFunctions.GetExternalFilesToCopy()			
			
			--Output external files to the command line for copying
			if SMTDSettings.SubmitExternalFilesMode > 1 do			
				for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
					format "%\n" aBitmap[1] to:initialArgs				
				
			local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
			local initialArgsFile = createFile initialArgsFileName
			format "%\n" (initialArgs as string) to:initialArgsFile
			close initialArgsFile 
			initialArgsFileName = "\""+initialArgsFileName+"\""
			
			local retCode = SMTDFunctions.waitForCommandToComplete initialArgsFileName timeout paramIsFile:true		
			
			SMTD_LastMessage = SMTDFunctions.getRenderMessage()
			if retCode == #success then
			(
				SMTDSettings.DeadlineSubmissionSuccessful = true
				SMTDFunctions.getJobIDFromMessage SMTD_LastMessage
				--SMTDFunctions.CopyExternalFilesToRepository() --try to copy external bitmaps
				SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
			)	
			retCode 
		),
		
		fn getStateSetChildrenRecursive theParent theTVParent parentArray =
		(
			for i = 0 to theParent.Children.count-1 do
			(
				currentParentArray = deepCopy parentArray
				local isObject = try(theParent.Children.Item[i].IsObjectStateSet)catch(false)
				local isNodeState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Nodes.State"
				local isScriptState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Scripted"
				local isViewportState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Viewports.State"
				local isRenderState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Rendering.State"

				if isScriptState do append currentParentArray theParent.Children.Item[i]				
				if not isObject and not isScriptState and not isNodeState and not isViewportState and not isRenderState do
				(
					local theName = theParent.Children.Item[i].Name
					local stateIsEmpty = try(theParent.Children.Item[i].IsEmpty)catch(true)
					local theDesc =  (if stateIsEmpty then "No Changes Recorded" else (try(theParent.Children.Item[i].Children.Item[0].Name)catch("???")))
					if matchPattern theDesc pattern:"1 *" then theDesc = substring theDesc 1 (theDesc.count-1)
					local newNode = if theTVParent != undefined then
						theTVParent.Nodes.add (theName+ " ["+theDesc+"]")
					else
						undefined
					if newNode != undefined do
					(
						newNode.checked = not stateIsEmpty
						newNode.forecolor = if newNode.checked then SMTD_ColorPalette.greenColor else SMTD_ColorPalette.grayColor
						newNode.Tag = ::SMTD_StateSetsTree.count+1
					)
					append currentParentArray theParent.Children.Item[i]
					append SMTD_StateSetsTree #(currentParentArray, not stateIsEmpty, theName, theDesc, newNode)
					if findItem #("Autodesk.Max.StateSets.Entities.StateSets.StateSet", "Autodesk.Max.StateSets.Entities.StateSets.Master") (theParent.Children.Item[i].ToString()) > 0 do
					(
						SMTDFunctions.getStateSetChildrenRecursive theParent.Children.Item[i] newNode currentParentArray
					)
					if newNode != undefined do newNode.expand()
				)
			)		
			return true
		),
		
		fn getStateSetChildrenForSubmissionRecursive theParent parentArray =
		(
			for i = 0 to theParent.Children.count-1 do
			(
				currentParentArray = deepCopy parentArray
				local isObject = try(theParent.Children.Item[i].IsObjectStateSet)catch(false)
				local isActualState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.StateSet"
				local isNodeState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Nodes.State"
				local isScriptState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Scripted"
				local isViewportState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Viewports.State"
				local isRenderState = theParent.Children.Item[i].ToString() == "Autodesk.Max.StateSets.Entities.StateSets.Rendering.State"
				
				if isScriptState do append currentParentArray theParent.Children.Item[i]				
				if not isObject and not isScriptState and not isNodeState and not isViewportState and not isRenderState do
				(
					local theName = theParent.Children.Item[i].Name
					local stateIsEmpty = try(theParent.Children.Item[i].IsEmpty)catch(true)
					local theDesc =  (if stateIsEmpty then "No Changes Recorded" else (try(theParent.Children.Item[i].Children.Item[0].Name)catch("???")))
					if matchPattern theDesc pattern:"1 *" then theDesc = substring theDesc 1 (theDesc.count-1)
					append currentParentArray theParent.Children.Item[i]
					append SMTD_StateSetsTreeForSubmission #(currentParentArray, not stateIsEmpty, theName, theDesc)
					if findItem #("Autodesk.Max.StateSets.Entities.StateSets.StateSet", "Autodesk.Max.StateSets.Entities.StateSets.Master") (theParent.Children.Item[i].ToString()) > 0 do
					(
						SMTDFunctions.getStateSetChildrenForSubmissionRecursive theParent.Children.Item[i] currentParentArray
					)
				)
			)		
			return true
		),
		
		fn SubmitStateSetJobs batchName:"" forceCamera:"" stereoCameraLabel:"" =
		(
			local StateSetsRootEntry
			if SMTDSettings.StateSetsSubmit then
			(
				local theMessages = "" as stringStream
				local theCount = (SMTDSettings.StateSetsList as array).count
				local theCountString1 = if theCount == 1 then "ONE" else theCount as string
				local theCountString2 = if theCount == 1 then "SET" else "SETS"
					
				format ">SUBMITTING % STATE %\n" theCountString1 theCountString2 to:theMessages
				--format "SMTDSettings.StateSetsList=%\n" SMTDSettings.StateSetsList

				local ssP = try(dotNetObject "Autodesk.Max.StateSets.Plugin")catch(undefined)
				if ssP != undefined do
				(
					::SMTD_StateSetsTreeForSubmission = #()
					StateSetsRootEntry = ssP.Instance.EntityManager.RootEntity
					SMTDFunctions.getStateSetChildrenForSubmissionRecursive StateSetsRootEntry.Children.Item[0] #()
				)
				if SMTD_StateSetsTreeForSubmission.count == SMTD_StateSetsTree.count then
				(
					local oldState = StateSetsRootEntry.MasterStateSet.CurrentState
					local cnt = 0
					
					if batchName == "" do batchName = SMTDFunctions.getBatchName()
					for i in SMTDSettings.StateSetsList do
					(
						cnt += 1
						SMTDSettings.StateSetToRender = i
						SMTDSettings.StateSetName =	SMTD_StateSetsTreeForSubmission[i][3]
						SMTDSettings.StateSetInfo = SMTD_StateSetsTreeForSubmission[i][4]
						format ">Submitting State Set %: % : %\n" SMTDSettings.StateSetToRender SMTDSettings.StateSetName SMTDSettings.StateSetInfo to:theMessages
						StateSetsRootEntry.MasterStateSet.CurrentState = SMTD_StateSetsTreeForSubmission[i][1]
						
						local theCameras = SMTDFUnctions.GetStereoCamerasFromCurrentView() --returns either the 3 cameras of a stereo rig, or empty array
						if stereoCameraLabel != "" do 
						(
							if theCameras.count == 3 then
							(
								forceCamera = case stereoCameraLabel of
								(
									(SMTDSettings.LeftEyeTag): theCameras[1].name
									(SMTDSettings.RightEyeTag): theCameras[2].name
									(SMTDSettings.CenterEyeTag): theCameras[3].name
									default: ""
								)
								format "+% Stereo Camera Requested, State Set Stereo Camera Is [%]\n" stereoCameraLabel forceCamera to:theMessages
							)
							else
							(
								local theViewCamera = viewport.getCamera()
								local theViewCameraName = "Current View"
								if isValidNode theViewCamera do theViewCameraName = theViewCamera.name
								format "--% Stereo Camera Requested, But State Set View Is [%]\n" stereoCameraLabel theViewCameraName to:theMessages
							)
						)
						
						format "\n%\n" ("==STATE SET [ "+SMTDSettings.StateSetName+" ] SUBMISSION MESSAGE START======================================================================================") to:theMessages

						if  SMTDSettings.SubmitSceneMode != #reposave  then
							SMTDSettings.SubmitSceneNetworkReuseLocation = cnt != 1 --when cnt is 1, set to false, otherwise true to reuse the file!
						else
							SMTDSettings.SubmitSceneNetworkReuseLocation  = false
							
						local theMessage = SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
						format "%\n\n" theMessage to:theMessages
						format "%\n\n" ("==STATE SET JOB [ "+SMTDSettings.StateSetName+" ] SUBMISSION MESSAGE END======================================================================================") to:theMessages
					)--end loop
					StateSetsRootEntry.MasterStateSet.CurrentState = oldState
					SMTDSettings.SubmitSceneNetworkReuseLocation = false
					theMessages as string
				)
				else "--The Scene State Sets DO NOT MATCH the State Sets Displayed In SMTD UI!\n--Please Press the [UPDATE LIST] Button in the StateSets Tab, then Submit Again!"
			)--end if
			else "--State Sets submission function called, but State Sets submission was disabled via "
		),		
		
		fn GetStereoCamerasFromCurrentView =
		(
			--This function will attempt to figure out the left/right/center cameras based on what camera is active in the current view
			--It works with the native Stereo Camera rig of 3ds Max, or custom rigs that follow the following rules
			-- * The custom cameras must contain the token "left", "right" or "center"/"centre" to be considered part of the custom stereo rig - the tokes will be used to determine which is which
			-- * A custom stereo rig *must* contain at least a "left" and a "right" camera with a common parent, the "center" camera is optional.
			-- * If the common parent is not another camera, it must contain the token "stereo" in its name. Such a parent can be a helper, a group head, or any other object.
			--* If the common parent is another camera, it can be the "center" camera (in which case the center camera will also be submittable), or any other camera (but it won't be submittable)
			
			local theViewCamera = viewport.getCamera() --get the current view's camera
			if theViewCamera != undefined then --if it is valid,
			(
				--try to find any objects that include the current view's camera in its parent list, and the parent is either a native stereo rig head, contains the token "stereo" in the object's name, or happens to be a camera, too
				local theParents = (for o in objects where (try(findItem o.children theViewCamera > 0)catch(false)) AND (classof o == Stereo_Camera_Assembly_Head_Object OR matchPattern o.name pattern:"*stereo*" or isKindOf o Camera) collect o)
				append theParents theViewCamera --add the camera to the parents list, in case it was used as the parent of the stereo rig
				if theParents.count > 0 then --if any parents were found that match the above rules,
				(
					for p in theParents do --loop through the parents
					(
						local theChildren = for o in p.children where isKindOf o Camera collect o --collect all cameras that are linked to that parent
						if isKindOf p Camera do append theChildren p --if cameras are linked to another camera (e.g. the Center one), include the parent in the list of children
						if classof p != Stereo_Camera_Assembly_Head_Object do --if not a native stereo rig, we need to figure out the left/right/center cameras by name and put them in the right order
						(
							local theOrderedChildren = #() --this will be the list in correct order
							local theCameras1 = for o in theChildren where matchPattern o.name pattern:"*left*" collect o --collect all cameras that contain "left" in their name
							if theCameras1.count > 0 then  --if there were any, use the first one found, otherwise skip the loop as we cannot submit stereo cameras without a left camera
								append theOrderedChildren theCameras1[1] 
							else
								continue
							
							theCameras1 = for o in theChildren where matchPattern o.name pattern:"*right*" collect o --collect all right cameras, same as above
							if theCameras1.count > 0 then 
								append theOrderedChildren theCameras1[1] 
							else
								continue
							
							theCameras1 = for o in theChildren where (matchPattern o.name pattern:"*center*" or matchPattern o.name pattern:"*centre*") collect o --collect all center / centre cameras
							if theCameras1.count > 0 do  --if there were any, add the first one
								append theOrderedChildren theCameras1[1] 
							if theOrderedChildren.count > 1 then --at this point, we should have at least left+right, or left+right+center collected in the right order. If yes, we will return them as the result, otherwise we skip the loop
								theChildren = theOrderedChildren
							else 
								continue
						)
						
						if theChildren.count > 1 then --if we got at least two cameras collected, we return them, otherwise we skip the loop
							return theChildren
						else
							continue
					)
					#() --if all parents' loops were skipped, we will end up here without a stereo rig, so we return an empty array
				)
				else --if no parents were found, we return an empty array 
					#()
			)
			else #() --if the view was not a valid camera object, we return an empty array
		),
		
		fn canSubmitPreviewJob TilesRendering MultiRegionRendering =
		(
			if not SMTDSettings.RenderFramesPreviewJob do return false
				
			try(SMTD_MainRollout.Ui_report ">Preview Job Submission was requested, checking for validity...")catch()
			
			if SMTDSettings.SubmitAsMXSJob do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: A MAXScript Job was requested.")catch()
				return false
			)
			if rendTimeType == 1 do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: Rendering a Single Frame was requested.")catch()
				return false
			)						
			if rendTimeType == 4 do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: Rendering a Custom Frame List was requested.")catch()
				return false
			)
			if TilesRendering do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: Tiles Rendering was requested.")catch()
				return false
			)
			if MultiRegionRendering do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: Multi-Region Rendering was requested.")catch()
				return false
			)
			if (SMTDFunctions.GetFrameSequenceString frameMode:#rest).count == 0 do
			(
				try(SMTD_MainRollout.Ui_report "--Cannot Submit Preview Job: Requested Preview Job would include All Frames - will submit a Regular Job instead.")catch()
				return false
			)
			try(SMTD_MainRollout.Ui_report "+Preview Job Submission is possible.")catch()
			true
		),		
		
		fn SubmitJobFromUI batchName:"" forceCamera:"" stereoCameraLabel:"" =
		(
			--some additional sanity checking...
			local tilesRendering = findItem #(#animationTiles, #singleFrameTiles) SMTDSettings.RegionRenderingMode > 0
			local multiRegionRendering = findItem #(#singleFrameMultiRegion, #animationMultiRegion) SMTDSettings.RegionRenderingMode > 0

			if SMTDSettings.MultiRegionData.count == 0 and ::SMTD_MultiRegionSettingsPersistentGlobal != undefined and ::SMTD_MultiRegionSettingsPersistentGlobal.count > 0 do
				SMTDSettings.MultiRegionData = deepCopy ::SMTD_MultiRegionSettingsPersistentGlobal
			local activeRegions = 0
			local badRegions = 0
			for i in SMTDSettings.MultiRegionData  do
			(
				if i[1] == True do activeRegions+=1
				if i[4] == 0 or i[5] == 0 do badRegions +=1
			)

			if multiRegionRendering  do
			(
				--Check for active regions in jigsaw
				if activeRegions == 0 do
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red)catch()
					return "--FAILED: Multi-Region Rendering Requested, But No Active Regions Found!"
				)
				--Check jigsaw active regions have width/height defined
				if badRegions > 0 do
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red)catch()
					return "--FAILED: Multi-Region Rendering - Bad Regions With ZERO Width Or Height!"
				)
			)
			
			if SMTDSettings.RegionRenderingMode == #singleFrameMultiRegion do
			(
				local result = SMTDFunctions.waitForCommandToComplete ("-getjobtasklimit " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
				if  result == #success then			
				(
					taskLimit = 5000
					local theFile = openFile SMTDPaths.SubmitOutput
					try(taskLimit = readValue theFile)catch()
					if activeRegions > taskLimit do
					(  
						result = "--FAILED: Unable to submit job with "+(activeRegions as string)+" tasks.  Task Count exceeded Repository Job Task Limit of "+(taskLimit as string)
						return result
					)
				)
			)
			if SMTDSettings.RegionRenderingMode == #singleFrameTiles do
			(
				local result = SMTDFunctions.waitForCommandToComplete ("-getjobtasklimit " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
				if  result == #success then			
				(
					taskLimit = 5000
					local theFile = openFile SMTDPaths.SubmitOutput
					try(taskLimit = readValue theFile)catch()
					
					if SMTDSettings.TilesInX * SMTDSettings.TilesInY > taskLimit do
					(  
						result = "--FAILED: Unable to submit job with "+((SMTDSettings.TilesInX * SMTDSettings.TilesInY) as string)+" tasks.  Task Count exceeded Repository Job Task Limit of "+(taskLimit as string)
						try(SMTD_MainRollout.Ui_report (result))catch()
						return result
					)
				)
			)

			try(SMTD_MainRollout.Ui_report ">Job Submission Started...")catch()
			SMTDSettings.DeadlineSubmissionSuccessful = false
			try(SMTD_MainRollout.sld_lastSubmissionState.color = red)catch()
			SMTDSettings.DeadlineSubmissionLastJobID = "failed"
			
			try(SMTD_RegionRendering.chk_showRegionGizmo.changed (SMTD_RegionRendering.chk_showRegionGizmo.state = false))catch()
			try(SMTD_TilesRendering.chk_showTilesGizmo.changed (SMTD_TilesRendering.chk_showTilesGizmo.state = false))catch()
			
			SMTDSettings.nonFatalErrorsCount = 0
			local backupSceneFileSaved = false
			local theXRefObjects = #()
			local theSceneXRefsCount = 0
			local renderMsg = "--"
			local warnAboutMissingFiles = true
			local oldMatEditorOpenState = false
			local oldVRayVFBState = false
			
			local oldSubmitMaxScript = false
			local oldMaxScriptFile = ""
				
			SMTDSettings.QuicktimesToGenerate = #() --we will collect requests for QT generation here	
				
			local oldRenderDialogState = renderSceneDialog.isOpen()
			renderSceneDialog.Close()
			
			if oldRenderDialogState do
			(
				try(SMTD_MainRollout.Ui_report "+Render Dialog Closed.")catch()
			)				
			
			local canSubmitQT = true
			if SMTDSettings.QuicktimeGenerate do
			(
				if matchPattern (getFileNameType rendOutputFilename) pattern:".EXR" do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - 3ds Max Render Output Is .EXR"))catch()
					SMTDSettings.nonFatalErrorsCount+=1
					canSubmitQT = false
				)
				if rendTimeType == 1 OR rendTimeType == 4 do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - 3ds Max Render Output Is Not A Continuous Animation Sequence"))catch()
					SMTDSettings.nonFatalErrorsCount+=1
					canSubmitQT = false
				)
				if SMTDSettings.SubmitAsMXSJob do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - MAXScript Job Enabled"))catch()
					SMTDSettings.nonFatalErrorsCount+=1						
					canSubmitQT = false
				)
				if TilesRendering do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - Tiles Rendering Job"))catch()
					SMTDSettings.nonFatalErrorsCount+=1	
					canSubmitQT = false
				)
				--Multi-Region animations now supports Quicktime generation!
				/*if MultiRegionRendering do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - Multi-Region Rendering Job"))catch()
					canSubmitQT = false
				)*/
				if SMTDSettings.UseBatchRender do 
				(
					try(SMTD_MainRollout.Ui_report ("--No Quicktime Job - Batch Submission"))catch()
					SMTDSettings.nonFatalErrorsCount+=1
					canSubmitQT = false
				)
			)
			if batchName == "" do
			(
				if ( SMTDSettings.DraftSubmitJob ) do
				(
					try(SMTD_MainRollout.Ui_report (">BatchName Needed For Future Draft Job"))catch()
					batchName = SMTDFunctions.getBatchName() --batch if Draft is enabled
				)
				if SMTDSettings.QuicktimeGenerate and canSubmitQT do 
				(
					try(SMTD_MainRollout.Ui_report (">BatchName Needed For Quicktime Job"))catch()
					batchName = SMTDFunctions.getBatchName() --batch if generating quicktime
				)
				if SMTDFunctions.canSubmitPreviewJob TilesRendering MultiRegionRendering do
				(
					try(SMTD_MainRollout.Ui_report (">BatchName Needed For Preview Job"))catch()
					batchName = SMTDFunctions.getBatchName() --batch if submitting preview job
				)
			)
			try(SMTD_MainRollout.Ui_report (">BatchName: ["+batchName+"]"))catch()
			
			SMTDSettings.CopyVbscriptFile = false
				
			SMTDFunctions.createSubmissionFolderAndUpdatePaths()

			if rpmdata != undefined and RPMDataNet != undefined and RPMDataNet.CustomSubmitStruct != undefined do --only if RPM is active
			(
				previouslysubmittedJobs = rpmdata.getcustglobstorage 10002 -- array of submitted jobs in this submission session
				doPassDependency = rpmdata.getcustglobstorage 10000
				passDependencyList = rpmdata.getcustglobstorage 10001
				if previouslysubmittedJobs == undefined do previouslysubmittedJobs = #()
				if doPassDependency == undefined do doPassDependency = False
				if passDependencyList == undefined do passDependencyList = #()
				warnAboutMissingFiles = false
			)

			-- If merging of XRefs is requested, try to save a temp. copy of the scene and then merge the xrefs into the scene.
			-- This was moved up here to allow the bitmaps of xrefs to be collected, too.
				
			--if SMTDSettings.CurrentRepository == "" then ( --Bobo:Not sure why this would matter, if we are merging, we are merging regardless of target repository
			if SMTDSettings.MergeXRefsOnSubmission or SMTDSettings.MergeSceneXRefsOnSubmission do
			(
				theXRefObjects = for i = 1 to objXRefMgr.recordCount collect (objXRefMgr.GetRecord i) --where (objXRefMgr.GetRecord i).enabled
				
				theSceneXRefsCount = xrefs.getXRefFileCount()
				if (SMTDSettings.MergeXRefsOnSubmission AND theXRefObjects.count > 0) OR (SMTDSettings.MergeSceneXRefsOnSubmission AND theSceneXRefsCount > 0) do 
				(
					try(SMTD_MainRollout.Ui_report ">Saving Scene To Backup File Before Merging XRefs..."	)catch()
					if (doesFileExist SMTDPaths.RestoreTempMaxFile) do deleteFile SMTDPaths.RestoreTempMaxFile
					if (result = SMTDFunctions.SaveMaxFileCopy SMTDPaths.RestoreTempMaxFile useMaxHold:true) != undefined do
						return ("SAVING BACKUP FILE:\n" + result)
					backupSceneFileSaved = true
					if SMTDSettings.MergeSceneXRefsOnSubmission do
					(
						for i = theSceneXRefsCount to 1 by -1 do
						(
							local theXRefFile = (xrefs.getXRefFile i)
							local theFileName = theXRefFile.filename 
							if doesFileExist theFileName then
							(
								if not theXRefFile.disabled then
								(
									local result = merge theXRefFile
									if result == true then
									(
										try(SMTD_MainRollout.Ui_report ("+Merged Scene XRef File "+ i as string + " ["+ theFileName +"]")	)catch()
									)
									else
									(
										try(SMTD_MainRollout.Ui_report ("--FAILED To Merge Scene XRef File "+ i as string + " ["+ theFileName +"]")	)catch()
										SMTDSettings.nonFatalErrorsCount+=1
									)
								)
								else
								(
									local result = delete theXRefFile
									if result == true then
									(
										try(SMTD_MainRollout.Ui_report ("+Deleted Disabled Scene XRef File "+ i as string + " ["+ theFileName +"]")	)catch()
									)
									else
									(
										try(SMTD_MainRollout.Ui_report ("--FAILED to Delete Disabled Scene XRef File "+ i as string + " ["+ theFileName +"]")	)catch()
										SMTDSettings.nonFatalErrorsCount+=1
									)
								)
							)
							else
							(
								try(SMTD_MainRollout.Ui_report ("--FAILED To Merge MISSING Scene XRef File "+ i as string + " ["+ theFileName +"]")	)catch()
								SMTDSettings.nonFatalErrorsCount+=1
							)
						)
					)
					
					if SMTDSettings.MergeXRefsOnSubmission do 
					(
						for i = objXRefMgr.recordCount to 1 by -1 do 
						(							
							local theRecord = objXRefMgr.GetRecord i
							local theSourceFileName = theRecord.srcFileName 
							if theRecord.enabled then --merge only the enabled XRef objects
							(
								local result = objXRefMgr.MergeRecordIntoScene theRecord 
								if result == true then
								(
									try(SMTD_MainRollout.Ui_report ("+Merged XRef Object Record "+ i as string + " ["+ theSourceFileName+"]")	)catch()
								)
								else
								(
									try(SMTD_MainRollout.Ui_report ("--FAILED to Merge XRef Object Record "+ i as string + " ["+ theSourceFileName+"]")	)catch()
									SMTDSettings.nonFatalErrorsCount+=1
								)
							)
							else --if disabled, remove the record to avoid surprises at render time
							(
								theRecord.enabled = true --have to enable it before removing?! WTF Autodesk?
								local result = objXRefMgr.RemoveRecordFromScene theRecord --remove disabled record
								if result == true then
								(
									try(SMTD_MainRollout.Ui_report ("+Removed Disabled XRef Object Record "+ i as string + " ["+ theSourceFileName+"]")	)catch()
								)
								else
								(
									try(SMTD_MainRollout.Ui_report ("--FAILED to Remove Disabled XRef Object Record "+ i as string + " ["+ theSourceFileName+"]")	)catch()
									SMTDSettings.nonFatalErrorsCount+=1
								)
							)
						)--end i loop
					)
				)	
			)	
			
			try(SMTD_MainRollout.Ui_report ">Checking For Missing External Files..."	)catch()
			SMTDFunctions.checkForMissingMaps()
			
			-- Only warn about missing files if we're not submitting from RPM. Don't want to prompt them each time.
			if warnAboutMissingFiles and SMTDSettings.MissingFiles.count > 0 then
			(
				try(SMTD_MainRollout.Ui_report ">Missing Files:")catch()
				for i in SMTDSettings.MissingFiles do 
					try(SMTD_MainRollout.Ui_report ("   " + i ))catch()
				local txt = if SMTDSettings.MissingFiles.count == 1 then "File" else "Files"
				local theMessage = "The Scene Contains "+  SMTDSettings.MissingFiles.count as string +" Missing External "+ txt + ".\n\n"
				if SMTDSettings.WarnAboutMissingExternalFiles then
				(
					if SMTDSettings.IgnoreMissingExternalFiles then
					(
						theMessage += "The 'Ignore Missing External File Errors' option is checked - \n"
						theMessage += "The job will render successfully but incorrectly!\n\n"
					)
					else
					(	
						theMessage += "The 'Ignore Missing External File Errors' option is NOT checked -\n"
						theMessage += "The job will not render correctly. It is suggested to cancel the submission\n\n!"
					)	
					
					theMessage += "Press Yes to Continue Submission.\nPress No to Cancel Submission and Correct the Problems."
					local theAnswer = querybox theMessage title:"SMTD: Missing External Files"
					if not theAnswer do return "--Submission Cancelled by User - Missing External Files Found!"
				)
			)				

			queryExternalFiles = true
			local theBitmapsFileName = ""
			if SMTDSettings.CurrentRepository == "" do
			(
				if SMTDSettings.SubmitExternalFilesMode > 1 do
				(
					try(SMTD_MainRollout.Ui_report ">Collecting External Files..."	)catch()
					if maxfilepath != "" do sysinfo.currentdir = maxfilepath --this sets the current directory to the location of the MAX file, so if the bitmaps are stripped of paths, it would resolve them using the MAX source directory
					bitmapFilenames = SMTDFunctions.returnAllBitmaps()
					local BitmapsCopyData = SMTDFunctions.GetExternalFilesToCopy()
					/*if SMTDSettings.SubmitExternalFilesMode == 4 then
					(
						theBitmapsFileName = SMTDFunctions.createExternalFilesList bitmapFilenames
					)
					else*/
					(
						local sizeInMB = 0.0
						for b in BitmapsCopyData do
							sizeInMB += getFileSize b[1]
						sizeInMB /= 1024.0*1024.0
						local txt = if BitmapsCopyData.count == 1 then "File" else "Files"
						try(SMTD_MainRollout.Ui_report ("+Found "+ BitmapsCopyData.count as string +" External "+ txt +" with "+ sizeInMB as string +"MB."))catch()
						if SMTDSettings.ExternalFilesWarningOn AND (BitmapsCopyData.count > SMTDSettings.ExternalFilesWarningCount or sizeInMB > SMTDSettings.ExternalFilesWarningMB) do
							queryExternalFiles = querybox (BitmapsCopyData.count as string + " External "+txt+" (" + sizeInMB as string + " MB) Found In The Scene.\nYou have requested to submit External Files to the Repository.\nDo you want to continue?") title:"Submit To Deadline: External Files Found"
					)	
				)
			)
			
			if not queryExternalFiles then
			(
				try(SMTD_MainRollout.sld_lastSubmissionState.color = red*0.5; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
				if backupSceneFileSaved == true then
				(
					try(SMTD_MainRollout.Ui_report ">Restoring Original Scene From Backup File..."	)catch()
					SMTDFunctions.RestoreMaxFileCopy SMTDPaths.RestoreTempMaxFile
				)				
				else
				(
					try(SMTD_MainRollout.Ui_report ">Restoring Original External File Paths..."	)catch()
					SMTDFunctions.restoreExternalReferencePaths()
				)
				return ("DEADLINE JOB SUBMISSION:\n\nExternal Files Submission Cancelled by User.")				
			)
			
			-- need to close State Sets UI if open to stop crash when 3dsMax running via service
			local oldSSDialogState = False
			try
			(
				local ssP = try(dotNetObject "Autodesk.Max.StateSets.Plugin")catch(undefined)
				if ssP == undefined do ssP = try(dotNetObject "Ephere.Plugins.Autodesk.Max.Zookeeper.Plugin")catch(undefined)
				if ssP != undefined then
				(
					local ssPi = ssP.Instance

					oldSSDialogState = try(ssPi.IsMainFrameVisible)catch(undefined) --IsMainFrameVisible not implemented in < Max2015, so return undefined, so we close but not restore dialog

					if oldSSDialogState != undefined AND oldSSDialogState then
					(
						--Max 2015 Ext2 added "Sequencer Mode..." to State Sets
						if (hasProperty ssPi "IsInSequencerMode") AND ssPi.IsInSequencerMode then
						(
							ssPi.ToggleMainFrame()
							ssPi.HideMainFrame()
							try(SMTD_MainRollout.Ui_report "+State Sets [Sequencer Mode...] Exited and Dialog Closed.")catch()
							try(SMTD_MainRollout.Ui_report "+State Sets Dialog Closed.")catch()
						)
						else if (hasProperty ssPi "IsInSequencerMode") AND (not ssPi.IsInSequencerMode) then
						(
							ssPi.HideMainFrame()
							try(SMTD_MainRollout.Ui_report "+State Sets Dialog Closed.")catch()
						)
						
						--earlier than Max2015
						if not (hasProperty ssPi "IsInSequencerMode") then
						(
							ssPi.HideMainFrame()
							try(SMTD_MainRollout.Ui_report "+State Sets Dialog Closed.")catch()
						)
					)
					else
					(
						ssPi.HideMainFrame()
						try(SMTD_MainRollout.Ui_report "+State Sets Dialog Closed.")catch()
					)
				)
			)
			catch()
			
			-- need to close scene explorers to workaround a problem (2008 to 2014)
			local oldSceneExplorerStates = #()
			if ((maxVersion())[1] >= 10000) AND ((maxVersion())[1] < 17000) do
			(
				SceneExplorerManager.CloseManageInstancesDialog()
				for i = 1 to SceneExplorerManager.GetExplorerCount() do
				(
					local name = SceneExplorerManager.GetExplorerName i
					local visible = SceneExplorerManager.ExplorerIsOpen name
					append oldSceneExplorerStates visible
					if visible do SceneExplorerManager.CloseExplorer name
				)
			)
			
			local oldMeditLockedState = renderers.medit_locked --get the locked state of the Medit renderer
			if oldMeditLockedState == true and SMTDSettings.UnlockMEditRenderer == true do 
			(
				renderers.medit_locked = false --if locked, unlock it. This was requested by Jon Reynolds to fix problems with VRay 1.5, might not be needed in general but does not hurt either.
				try(SMTD_MainRollout.Ui_report "+Unlocked the Material Editor Renderer.")catch()
			)	
			if SMTDSettings.ClearMaterialEditorOnSubmission do 
			(
				oldMatEditorOpenState = MatEditor.isOpen()
				if oldMatEditorOpenState do MatEditor.Close()
				try(SMTD_MainRollout.Ui_report "+Closed Material Editor...")catch()
				SMTDFunctions.clearMaterialEditor()
				try(SMTD_MainRollout.Ui_report "+Cleared Material Editor...")catch()
			)	
			
			if renderers.current.classid as string == "#(1121714582, 90602926)" then
			(
				oldAmarettoExportMode = Amaretto.getProperty "Amaretto:PygExportMode" 
				if oldAmarettoExportMode != "5" and oldAmarettoExportMode != "1" then
				(
					try(SMTD_MainRollout.Ui_report (">Overriding Amaretto Submission Mode with [Direct To Gelato]"))catch()
					Amaretto.setProperty "Amaretto:PygExportMode" "1"
				)	
				else
					if oldAmarettoExportMode == "1" then
						try(SMTD_MainRollout.Ui_report (">Amaretto Submission Mode is already [Direct To Gelato]."))catch()
					else
						try(SMTD_MainRollout.Ui_report (">Amaretto Submission Mode is already [Export And Render Direct]"))catch()
			)	
			
			
			if not SMTDSettings.RenderElementNamesPermanentChanges do 
			(
				try(SMTD_MainRollout.Ui_report ">Storing the Render Elements Names...")catch()
				SMTDFunctions.storeRenderElementNames() --Store original Render Element names for later restoration
			)

			try(SMTD_MainRollout.Ui_report ">Purifying the Render Elements Names...")catch()
			SMTDFunctions.fixRenderElementNames() --remove spaces and other unwanted characters from Render Element instance names
			
			-- CHECK VRAY VFB if not bake job
			if not SMTDSettings.IsBakeJob then
			(
				/*
				if renderers.current.classid as string == "#(1941615238, 2012806412)" do
				(
					if renderers.current.output_on and renderers.current.output_saveRawFile then
					(
						-- If tiled exrs are being rendered, automatically disable the memory frame buffer
						oldVRayVFBState = renderers.current.output_useram
						renderers.current.output_useram = false
						SMTD_MainRollout.Ui_report "+Disabled V-Ray Frame Buffer rendering to RAM."
					)
					else
					(
						-- Otherwise, just disable the vray vfb entirely
						oldVRayVFBState = renderers.current.output_on
						renderers.current.output_on = false
						SMTD_MainRollout.Ui_report "+Disabled V-Ray Frame Buffer."
						
						SMTDFunctions.RenderElementsStoreVrayVFB()
						SMTDFunctions.RenderElementsUpdateVrayVFB()
					)
				)
				*/
			)
			else
			(
				oldMaxScriptFile = SMTDSettings.SubmitAsMXSJob
				oldSubmitMaxScript = SMTDSettings.MAXScriptFile
				
				SMTDSettings.SubmitAsMXSJob = true
				SMTDSettings.MAXScriptFile = SMTDFunctions.GetNetworkRoot() + "\\submission\\3dsmax\\Main\\TextureBake.ms"
				
				try(SMTD_MainRollout.Ui_report "+Overwriting MaxScript Job Settings.")catch()
			)
			
			--FORCE HIGH PRIORITY THREAD
			if SMTDSettings.OverrideLowPriorityThread do
			(
				try (
					VRAY_lowThreadPriority = renderers.current.system_lowThreadPriority
					if VRAY_lowThreadPriority do  (
					renderers.current.system_lowThreadPriority = false
					SMTD_MainRollout.Ui_report ("+Forcing V-Ray Low Thread Priority to [false].")
					)
				)catch() 
				try (
					BRAZIL_lowThreadPriority = renderers.current.low_priority_thread_on
					if BRAZIL_lowThreadPriority do (
					renderers.current.low_priority_thread_on = false
					SMTD_MainRollout.Ui_report ("+Forcing Brazil r/s Low Thread Priority to [false].")
					)
				)catch() 
			)

			if SMTDSettings.ReplaceOutputFilenameWithUserPattern do
			(
				OutputFilenameByUserPattern = copy SMTDSettings.OutputFilenameUserPattern
				OutputFilenameByUserPattern = substituteString OutputFilenameByUserPattern "$user" SMTDSettings.userName
				local theMaxFileName = (getFileNameFile maxFileName)
				if theMaxFileName == "" do theMaxFileName = "Untitled"
				OutputFilenameByUserPattern = substituteString OutputFilenameByUserPattern "$scene" theMaxFileName
				
				local theFilterTime = filterString localtime " /\\-:"
				local theTime = ""
				for i = 1 to theFilterTime.count-1 do theTime += theFilterTime[i] + "_"
				theTime += theFilterTime[theFilterTime.count]	
				OutputFilenameByUserPattern = substituteString OutputFilenameByUserPattern "$date" theTime
				OutputFilenameByUserPattern = substituteString OutputFilenameByUserPattern "$" "_"
				makeDir (getFileNamePath OutputFilenameByUserPattern) all:true
				if doesFileExist (getFileNamePath OutputFilenameByUserPattern) do
				(
					oldrendOutputFilename = rendOutputFilename
					rendOutputFilename = OutputFilenameByUserPattern
				)
			)	

			if SMTDSettings.RebuildRenderElements do
			(
				try(SMTD_MainRollout.Ui_report ">Rebuilding Render Elements")catch()
				SMTDFunctions.RebuildRenderElements()
				try(SMTD_MainRollout.Ui_report "+Rebuilt Render Elements")catch()
			)

			local retcode = #success		
			
			if SMTDSettings.StrictOutput then
			(
				if RendOutputFilename != "" then
				(						   
					try(SMTD_MainRollout.Ui_report ">Strict Output Check...")catch()
					local path = getFilenamePath RendOutputFilename
					local directory = getFilenameFile maxFilename
					local filename = getFilenameFile maxFilename
					local extension = getFilenameType RendOutputFilename
								
					-- if the output path already contains the max filename, assume that
					-- it already contains the correct directory structure, so we don't keep
					-- appending directories everytime the job is submitted
					if findString path directory != undefined then
						RendOutputFilename = path + filename + extension
					else
						RendOutputFilename = path + directory + "\\" + filename + extension
				)
			)--end strict output
			
			if SMTDSettings.RenderElementsUpdatePaths do
			(
				try(SMTD_MainRollout.Ui_report ">Updating Render Elements Paths..."	)catch()
				if not SMTDSettings.RenderElementsPermanentChanges do 
				(
					SMTDFunctions.RenderElementsStorePaths()
					try(SMTD_MainRollout.Ui_report "+Stored Render Elements Paths."	)catch()
				)	
				SMTDFunctions.RenderElementsUpdatePaths()
				try(SMTD_MainRollout.Ui_report "+Updated Render Elements Paths."	)catch()
			)				
			
			--Output Info about Repository being submitted to
			try
			(
				if SMTDSettings.CurrentRepository != "" then
				(
					SMTD_MainRollout.Ui_report (">Submitting "+ SMTDFunctions.getPluginToUse() +" Render Job to Remote Repository:")
					SMTD_MainRollout.Ui_report ("["+ SMTDSettings.CurrentRepository +"]...")
				)	
				else
					SMTD_MainRollout.Ui_report (">Submitting "+ SMTDFunctions.getPluginToUse() +" Render Job to Local Repository...")
			)catch()		

			local TempMaxFile = ""
			case of
			(
				(SMTDSettings.SubmitSceneMode == #reposave):
				(
					TempMaxFile = SMTDPaths.submitSubFolder + maxFileName
					if maxFileName == "" do TempMaxFile += "untitled.max"
					if (doesFileExist TempMaxFile) do deleteFile TempMaxFile
				)
				(SMTDSettings.SubmitSceneMode == #networksaveanduse):
				(
					if SMTDSettings.SubmitSceneNetworkReuseLocation == false do
					(
						if maxFileName == "" then
						(
							filename = getMAXSaveFileName()
							if filename == undefined do return "--Submission Cancelled by User - scene must be saved before submission"
							
							TempMaxFile = filename
						)
						else
							TempMaxFile = maxFilePath + maxFileName
						if not SMTDSettings.StateSetsSubmit AND SMTDSettings.DeleteEmptyStateSets do SMTDFunctions.DeleteEmptyStateSets()
						saveMaxFile TempMaxFile
					)
				)
				(SMTDSettings.SubmitSceneMode == #networksave OR SMTDSettings.SubmitSceneMode == #globalnetworksave):
				(
					if SMTDSettings.SubmitSceneNetworkReuseLocation == false or SMTDSettings.SubmitSceneNetworkLocation == "" then --if saving requested, or last saved file name not defined
					(
						local theFilterTime = filterString localtime " /\\-:"
						local theTime = ""
						for i = 1 to theFilterTime.count do theTime += theFilterTime[i] + "_"
						if SMTDSettings.SubmitSceneMode == #networksave then
							TempMaxFile = SMTDSettings.SubmitSceneBasePath +"\\"+SMTDSettings.userName+"\\"+theTime+"\\"
						else
							TempMaxFile = SMTDSettings.SubmitSceneGlobalBasePath +"\\"+SMTDSettings.userName+"\\"+theTime+"\\"
						makedir TempMaxFile all:true
						TempMaxFile += (if maxFileName == "" then "untitled.max" else maxFileName)
						SMTDSettings.SubmitSceneNetworkLocation = TempMaxFile
					)
					else
						TempMaxFile = SMTDSettings.SubmitSceneNetworkLocation
				)
				(SMTDSettings.SubmitSceneMode == #networkremap): ( )				
			)

			if SMTDSettings.SubmitSceneMode != #networkuse and SMTDSettings.SubmitSceneMode != #networksaveanduse and SMTDSettings.SubmitSceneMode != #networkremap and SMTDSettings.SubmitSceneNetworkReuseLocation == false then
			(
				if SMTDSettings.UseCustomShader do
				(
					try(SMTD_MainRollout.Ui_report ">Applying Custom Shaders...")catch()
					SMTDFunctions.CollectSceneMaterials()
					SMTDFunctions.assignCustomShaders()
				)

				if SMTDSettings.SubmitVisibleObjectsOnly and not SMTDFunctions.HasActiveSceneXRefs() then
				(
					try(SMTD_MainRollout.Ui_report (">Saving Visible Objects For Submission to ["	+ TempMaxFile + "]"))catch()
					result = SMTDFunctions.SaveMaxFileVisibleOnly TempMaxFile
				)	
				else
				(
					try(SMTD_MainRollout.Ui_report (">Saving Scene For Submission to ["	+ TempMaxFile + "]"))catch()
					result = SMTDFunctions.SaveMaxFileCopy TempMaxFile
				)	
				
				if SMTDSettings.UseCustomShader do
				(
					try(SMTD_MainRollout.Ui_report ">Restoring Scene Shaders...")catch()
					SMTDFunctions.restoreSceneMaterials()
				)
			)
			else result = undefined
	
			if result != undefined do return result
			
			if RendOutputFilename != "" and SMTDSettings.CreateImsqFile then
			(
				try(SMTD_MainRollout.Ui_report ">Creating Image Sequence File...")catch()
				path = getFilenamePath RendOutputFilename
				filename = getFilenameFile RendOutputFilename
				imsqFilename = path + filename + ".imsq"
				if ((SMTDFunctions.CreateImsqFile imsqFilename) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Image Sequence file"
				
				if SMTDSettings.CopyImsqFile and SMTDSettings.ImsqOutputPath != "" then
				(
					if ((SMTDFunctions.CreateImsqVbscript SMTDPaths.ImsqVbscriptFile imsqFilename) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Image Sequence Vbscript file"
					SMTDSettings.CopyVbscriptFile = true
				)										   
			)
			
			try(SMTD_MainRollout.sld_lastSubmissionState.color = yellow)catch()
			
			if SMTDSettings.UseBatchRender and SMTDSettings.BatchRenderMode == 1 then
			(
				try(SMTD_MainRollout.Ui_report ">Initiating Local Batch Submission...")catch()
				result = SMTDFunctions.spawnBatchJobsLocal forceMaxFile:TempMaxFile
				if result then retCode = #success else retCode = #batchFailure
			)
			else if findItem #(#animationTiles, #singleFrameTiles,#singleFrameMultiRegion, #animationMultiRegion) SMTDSettings.RegionRenderingMode > 0 then
			(
				try(SMTD_MainRollout.Ui_report ">Initiating Tiles Submission...")catch()
				result = SMTDFunctions.spawnTileJobs forceMaxFile:TempMaxFile batchName:batchName forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
				if result then retCode = #success else retCode = #tileFailure
				renderMsg = SMTDFunctions.getRenderMessage()
			)
			else --REGULAR SUBMISSION
			(
				try(SMTD_MainRollout.Ui_report ">Initiating Regular Job Submission...")catch()
				local initialArgs = "" as stringstream
				format "-outputfiles\n%\n%\n" SMTDPaths.SubmitOutput  SMTDPaths.SubmitExitCode to:initialArgs
				
				if SMTDSettings.bgSubmission do format "-background\n-notify\n" to:initialArgs
				if SMTDSettings.dropSubmission do format "-drop\n" to:initialArgs 
				
				if( SMTDSettings.SubmitSceneMode == #reposave ) then
					format "%\n%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile  TempMaxFile  to:initialArgs 
				else
					format "%\n%\n" SMTDPaths.SubmitInfoFile SMTDPaths.JobInfoFile  to:initialArgs 
				
				--If scripts enabled, send the script files as aux. files:
				if SMTDSettings.SubmitAsMXSJob then
				(
					format "%\n" SMTDSettings.MAXScriptFile to:initialArgs 
					try(SMTD_MainRollout.Ui_report "+This is a MAXScript Job!")catch()
				)
				else
				(
					/*
					if SMTDSettings.SubmitExternalFilesMode == 4 then
					(
						for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
						format "\"%\" \n" aBitmap[1] to:initialArgs
						--initialArgs += "\"" + theBitmapsFileName + "\" " 
						SMTDSettings.RunPreLoadScript = true
						SMTDSettings.PreLoadScriptFile = SMTDFunctions.GetNetworkRoot() + "\\submission\\3dsmax\\Main\\DeadlineMaxCacheTexturesOnSlave_PreLoad.ms"
						--initialArgs += "\"" +SMTDSettings.PreLoadScriptFile+ "\" " 
					)	
					*/
					
					if SMTDSettings.CopyVbscriptFile do format "%\n" SMTDPaths.ImsqVbscriptFile to:initialArgs
					if SMTDSettings.RunPreLoadScript do format "%\n" SMTDSettings.PreLoadScriptFile to:initialArgs
					if SMTDSettings.RunPostLoadScript do format "%\n" SMTDSettings.PostLoadScriptFile to:initialArgs
					if SMTDSettings.RunPreFrameScript do format "%\n" SMTDSettings.PreFrameScriptFile to:initialArgs
					if SMTDSettings.RunPostFrameScript do format "%\n" SMTDSettings.PostFrameScriptFile to:initialArgs
					if SMTDSettings.SubmitSceneMode == #reposave do
					(
						if SMTDSettings.UsePathConfigFile and doesFileExist SMTDSettings.PathConfigFile do format "%\n" SMTDSettings.PathConfigFile to:initialArgs
					)

					--SUBMITTING A TILES MASTER JOB OR A REGION RENDERING
					if TilesRendering do 
					(
						try(SMTD_MainRollout.Ui_report ">Tiles Job - Adding Tile Submitter Script to Auxiliary Files...")catch()
						local theNetworkPath = SMTDFunctions.GetNetworkRoot()
						theNetworkPath += "\\submission\\3dsmax\\Main\\"
						format "%\n" (theNetworkPath + "maxTileSubmitter.ms") to:initialArgs 
					)	
					/*
					if SMTDSettings.RegionRendering do 
					(
						try(SMTD_MainRollout.Ui_report ">Region Rendering - Adding Tile Assembler Command to Auxiliary Files For Compatibility...")catch()
						local theNetworkPath = SMTDFunctions.GetNetworkRoot()
						theNetworkPath += "\\submission\\3dsmax\\Main\\"
						format "%\n" (theNetworkPath + "maxTileAssemblerCommand.ms") to:initialArgs 
					)	
					*/					
					if SMTDSettings.UseBatchRender and SMTDSettings.BatchRenderMode == 2 do 
					(
						try(SMTD_MainRollout.Ui_report ">Batch Master Job - Adding Batch Submitter Script To Auxiliary File")catch()
						local theNetworkPath = SMTDFunctions.GetNetworkRoot()
						theNetworkPath += "\\submission\\3dsmax\\Main\\"
						format "%\n" (theNetworkPath + "maxBatchSubmitter.ms") to:initialArgs 
						
						local numViews = batchRenderMgr.numViews 
						for i = 1 to numViews do
						(
							local theView = batchRenderMgr.getView i
							if theView.enabled and theView.presetFile != "" do
								format "%\n" theView.presetFile to:initialArgs 
						)
						
						theBitmapsFileName = SMTDFunctions.createExternalFilesList bitmapFilenames
						format "%\n" (theBitmapsFileName) to:initialArgs 
					)	
					if (SMTDSettings.UseBatchRender and SMTDSettings.BatchRenderMode == 2) do  --SMTDSettings.TilesRendering or 
					(
						try(SMTD_MainRollout.Ui_report ">Master Job - Saving SMTD Struct Settings To Auxiliary File...")catch()
						SMTDFunctions.saveSettingsStructToMSFile (getFileNamePath SMTDPaths.JobInfoFile + "SubmitterSettingsStruct.ms")
						format "%\n" (getFileNamePath SMTDPaths.JobInfoFile + "SubmitterSettingsStruct.ms") to:initialArgs 
					)
				)	

				--Output external files to the command line for copying
				if SMTDSettings.SubmitExternalFilesMode > 1 do				
					for aBitmap in BitmapsCopyData where findItem SMTDSettings.MissingFiles aBitmap[1] == 0 do
						format "%\n" aBitmap[1] to:initialArgs
				
				local initialArgsFileName = (getFileNamePath SMTDPaths.JobInfoFile + "initialArgsFile.txt") 
				local initialArgsFile = createFile initialArgsFileName
				format "%\n" (initialArgs as string) to:initialArgsFile
				close initialArgsFile 
				initialArgsFileName = "\""+initialArgsFileName+"\""
					
				--CHANGE PRIORITY FOR STEREO CAMERAS	
				local oldStereoPriority = SMTDSettings.Priority
				case SMTDSettings.StereoCameraPriorityOrder	of
				(
					#lrc: ( --left right center
						if stereoCameraLabel == SMTDSettings.RightEyeTag do SMTDSettings.Priority -= 1
						if stereoCameraLabel == SMTDSettings.CenterEyeTag do SMTDSettings.Priority -= 2
					)
					#rlc: ( --right left center
						if stereoCameraLabel == SMTDSettings.LeftEyeTag do SMTDSettings.Priority -= 1
						if stereoCameraLabel == SMTDSettings.CenterEyeTag do SMTDSettings.Priority -= 2
					)
					#clr: ( --center left right 
						if stereoCameraLabel == SMTDSettings.LeftEyeTag do SMTDSettings.Priority -= 1
						if stereoCameraLabel == SMTDSettings.RightEyeTag do SMTDSettings.Priority -= 2
					)					
					#crl: ( --center right left 
						if stereoCameraLabel == SMTDSettings.RightEyeTag do SMTDSettings.Priority -= 1
						if stereoCameraLabel == SMTDSettings.LeftEyeTag do SMTDSettings.Priority -= 2
					)	
					#lcr: ( --left center right
						if stereoCameraLabel == SMTDSettings.CenterEyeTag do SMTDSettings.Priority -= 2
						if stereoCameraLabel == SMTDSettings.RightEyeTag do SMTDSettings.Priority -= 2
					)	
					#rcl: ( --right center left 
						if stereoCameraLabel == SMTDSettings.CenterEyeTag do SMTDSettings.Priority -= 1
						if stereoCameraLabel == SMTDSettings.LeftEyeTag do SMTDSettings.Priority -= 2
					)						
				)
				if SMTDSettings.Priority < 0 do SMTDSettings.Priority = 0
				
				--IF FRAMES PREVIEW JOB REQUESTED, SUBMIT TWO JOBS - ONE FOR EVERY NTH, ONE FOR THE REST
				if SMTDFunctions.canSubmitPreviewJob TilesRendering MultiRegionRendering then
				(
					try(SMTD_MainRollout.Ui_report ">Submitting Two Jobs: Frame Preview and Remaining Frames...")catch()
					oldPriority = SMTDSettings.Priority
					SMTDSettings.Priority += SMTDSettings.PreviewJobPriorityOffset
					if SMTDSettings.Priority > SMTDSettings.MaximumPriority do SMTDSettings.Priority = SMTDSettings.MaximumPriority -- max. value used to be hard-coded to 100, now is variable
					if SMTDSettings.Priority < 0 do SMTDSettings.Priority = 0
					
					--if ((SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#nth) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
					local result = false
					--if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_rawFileName != undefined and renderers.current.output_rawFileName != "" ) then
					--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile customOutputFile:renderers.current.output_rawFileName includeBothOutputs:true frameMode:#nth
					--else
					--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#nth
					
					result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#nth batchName:batchName stereoCameraLabel:stereoCameraLabel
					if not result do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
					
					if ((SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Job Info file"
					
					
					try(SMTD_MainRollout.Ui_report ">Submitting Frame Preview Job...")catch()
					retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true
					SMTDSettings.Priority = oldPriority 
					renderMsg = SMTDFunctions.getRenderMessage()
					SMTDFunctions.getJobIDFromMessage renderMsg
					if retCode == #success then
					(
						try(SMTD_MainRollout.Ui_report ("Frames Preview Job Submitted Successfully.\n\n" + renderMsg) )catch()
						--SMTDFunctions.CopyExternalFilesToRepository() --copy files to preview job
						SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
						
						--if ((SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#rest) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
						local result = false
						--if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_rawFileName != undefined and renderers.current.output_rawFileName != "" ) then
						--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile customOutputFile:renderers.current.output_rawFileName includeBothOutputs:true frameMode:#rest
						--else
						--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#rest
						result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile frameMode:#rest batchName:batchName
						if not result do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
						
						try(SMTD_MainRollout.Ui_report ">Submitting Remaining Frames Job...")catch()
						retcode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true
						renderMsg = SMTDFunctions.getRenderMessage()
						SMTDFunctions.getJobIDFromMessage renderMsg
						if retCode == #success then
						(
							try(SMTD_MainRollout.Ui_report ("Remaining Frames Job submitted successfully.\n\n" + renderMsg) )catch()
							--SMTDFunctions.CopyExternalFilesToRepository() --copy files to main job
							SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
						)	
						else
						(
							try(SMTD_MainRollout.Ui_report ("Remaining Frames Job Submission FAILED.\n\n" + renderMsg) )catch()
						)
					)	
					else
					(
						try(SMTD_MainRollout.Ui_report ("Frames Preview Job Submission FAILED.\n\n" + renderMsg) )catch()
					)
				)
				
				else  --otherwise submit just one job
				(
					try(SMTD_MainRollout.Ui_report ">Submitting All Frames In One Job...")catch()
					
					--if ((SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
					local result = false
					--if (renderers.current.classid as string == "#(1941615238, 2012806412)" and renderers.current.output_on and renderers.current.output_rawFileName != undefined and renderers.current.output_rawFileName != "" ) then
					--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile customOutputFile:renderers.current.output_rawFileName includeBothOutputs:true
					--else
					--	result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile
					result = SMTDFunctions.CreateSubmitInfoFile SMTDPaths.SubmitInfoFile batchName:batchName stereoCameraLabel:stereoCameraLabel
					if not result do return "DEADLINE JOB SUBMISSION:\n\nCould not create Submit Info file"
					
					if ((SMTDFunctions.CreateJobInfoFile SMTDPaths.JobInfoFile forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel) != true) do return "DEADLINE JOB SUBMISSION:\n\nCould not create Job Info file"
					
					try(SMTD_MainRollout.Ui_report ("Command Line Arguments: ["+initialArgs+"]\n\n"))catch()
					retCode = SMTDFunctions.waitForCommandToComplete initialArgsFileName SMTDSettings.TimeoutSubmission paramIsFile:true
					renderMsg = SMTDFunctions.getRenderMessage()
					SMTDFunctions.getJobIDFromMessage renderMsg 
					if retCode == #success do
					(
						--SMTDFunctions.CopyExternalFilesToRepository()
						SMTDFunctions.SubmitTransferJob() -- submits a remote transfer job if necessary
						
						--Auto-Dependencies
						
						append SMTDSettings.PreviousJobsArray #(SMTDSettings.JobName,SMTDSettings.DeadlineSubmissionLastJobID,"3dsmax",SMTDSettings.UserName,SMTDSettings.Department,SMTDSettings.Group, "Previous")
						try(::SMTD_Dependencies.updateDependencyDisplay())catch()
					)
				)
			)--end if not local tiles submission
			
			
			SMTDSettings.Priority = oldStereoPriority

			--If the merging of XRef objects was requested and there were any, restore the copy of the scene from the temp. file
			if backupSceneFileSaved == true then
			(
				try(SMTD_MainRollout.Ui_report ">Restoring Original Scene From Backup File..."	)catch()
				SMTDFunctions.RestoreMaxFileCopy SMTDPaths.RestoreTempMaxFile
			)
			else --we only need to restore the paths if the scene was not restored from a temp. file
			(
				if SMTDSettings.SubmitExternalFilesMode > 1 and not (SMTDSettings.UseBatchRender AND  SMTDSettings.BatchRenderMode == 1) do --and SMTDSettings.SubmitExternalFilesMode < 4
				(
					try(SMTD_MainRollout.Ui_report ">Restoring Original External File Paths..."	)catch()
					SMTDFunctions.restoreExternalReferencePaths()
				)	
			)
			
			--if not SMTDSettings.BgSubmission and SMTDSettings.SubmitSceneMode == #reposave do deleteFile TempMaxFile
			if renderers.current.classid as string == "#(1121714582, 90602926)" then
			(
				try(SMTD_MainRollout.Ui_report (">Restoring Amaretto Submission Mode to [" + oldAmarettoExportMode+"]" ))catch()
				Amaretto.setProperty "Amaretto:PygExportMode" oldAmarettoExportMode 
			)			
			if oldMeditLockedState == true and SMTDSettings.UnlockMEditRenderer == true do 
			(
				renderers.medit_locked = true --if the MEdit renderer was previously locked, lock it again.
				try(SMTD_MainRollout.Ui_report "+Restored the Locked State of the Material Editor Renderer...")catch()
			)
			
			if ((maxVersion())[1] >= 10000) AND ((maxVersion())[1] < 17000) do
			(
				for i = 1 to SceneExplorerManager.GetExplorerCount() do
				(
					if oldSceneExplorerStates[i] do
					(
						local name = SceneExplorerManager.GetExplorerName i
						SceneExplorerManager.OpenExplorer name
					)
				)
			)
			
			--restore the output file name if changed by global pattern
			if SMTDSettings.ReplaceOutputFilenameWithUserPattern do
			(
				rendOutputFilename = oldrendOutputFilename
			)
			
			if oldRenderDialogState do 
			(
				renderSceneDialog.Open() 
				try(SMTD_MainRollout.Ui_report "+Restored the Open State of the Render Scene Dialog...")catch()
			)

			--restore state sets dialog if open
			if oldSSDialogState != undefined AND oldSSDialogState do
			(
				try
				(
					ssP = try(dotNetObject "Autodesk.Max.StateSets.Plugin")catch(undefined)
					if ssP == undefined do ssP = try(dotNetObject "Ephere.Plugins.Autodesk.Max.Zookeeper.Plugin")catch(undefined)
					if ssP != undefined then
					(
						ssPi = ssP.Instance
						ssPi.ShowMainFrame()
						try(SMTD_MainRollout.Ui_report "+Restored the Open State of the State Sets Dialog...")catch()
					)
				)
				catch()
			)

			if SMTDSettings.ClearMaterialEditorOnSubmission do 
			(
				SMTDFunctions.restoreMaterialEditor()
				try(SMTD_MainRollout.Ui_report "+Restored the Material Editor Samples...")catch()
				if oldMatEditorOpenState do 
				(
					MatEditor.Open()
					try(SMTD_MainRollout.Ui_report "+Restored the Material Editor open state..."	)catch()
				)
			)
			
			if not SMTDSettings.IsBakeJob then
			(
				/*
				if renderers.current.classid as string == "#(1941615238, 2012806412)" do
				(
					if renderers.current.output_on and renderers.current.output_saveRawFile then
					(
						if oldVRayVFBState do
						(
							renderers.current.output_useram = true
							try(SMTD_MainRollout.Ui_report "+Reenabled V-Ray Frame Buffer rendering to RAM.")catch()
						)
					)
					else
					(
						if oldVRayVFBState do
						(
							renderers.current.output_on = true
							try(SMTD_MainRollout.Ui_report "+Reenabled V-Ray Frame Buffer.")catch()
						)
						
						SMTDFunctions.RenderElementsRestoreVrayVFB()
					)
				)
				*/
			)
			else
			(
				SMTDSettings.SubmitAsMXSJob = oldMaxScriptFile
				SMTDSettings.MAXScriptFile = oldSubmitMaxScript
				try(SMTD_MainRollout.Ui_report "+Restored MaxScript Job Settings.")catch()
			)
			
			if SMTDSettings.OverrideLowPriorityThread do
			(
				try (
					if VRAY_lowThreadPriority do (
					renderers.current.system_lowThreadPriority = true
					SMTD_MainRollout.Ui_report ("+Restored V-Ray Low Thread Priority to [true].")
					)
				)catch()
				try (
					if BRAZIL_lowThreadPriority do (
					renderers.current.low_priority_thread_on = true
					SMTD_MainRollout.Ui_report ("+Restored Brazil Low Thread Priority to [true].")
					)
				)catch()
			)
			
			if SMTDSettings.RenderElementsUpdatePaths do
			(
				if not SMTDSettings.RenderElementsPermanentChanges do 
				(
					SMTDFunctions.RenderElementsRestorePaths()
					try(SMTD_MainRollout.Ui_report "+Restored the Render Elements Paths...")catch()
				)	
			)	
			
			if not SMTDSettings.RenderElementNamesPermanentChanges do 
			(
				SMTDFunctions.restoreRenderElementNames() --Restore original Render Element names 
				try(SMTD_MainRollout.Ui_report "+Restored the Render Elements Names...")catch()
			)

			case retCode of
			(
				#success:
				(
					local copyResult = 0
					SMTDSettings.DeadlineSubmissionSuccessful = true
					
					--INTERNAL: Frantic Films Asset Tracker, should be removed
					--try(FF_AssetTracker_Functions.TrackDeadlineRender SMTDSettings.DeadlineSubmissionLastJobID)catch()
					
					--INTERNAL: Output Camera Info Data to Render Output Folder:
					/*
					if PFPPL_RenderPassFunctions != undefined and rendOutputFilename != "" do 
					(
						local theViewCamera = viewport.getCamera()
						if theViewCamera != undefined do
						(	
							local frameList = for t = (animationrange.start.frame as integer)  to (animationrange.end.frame as integer) collect t							
							PFPPL_RenderPassFunctions.saveCameraInfoFiles (getFileNamePath rendOutputFilename+ "camData\\") theViewCamera frameList
						)
					)					
					*/
					if SMTDSettings.QuicktimeGenerate AND not TilesRendering and NOT MultiRegionRendering do 
					(
						local filenameToRender = SMTDFunctions.getRendOutputFilename forceCamera:forceCamera stereoCameraLabel:stereoCameraLabel
						append SMTDSettings.QuicktimesToGenerate #(filenameToRender , batchName, #(SMTDSettings.DeadlineSubmissionLastJobID)) --input, output, batch, dependencies
					)
					if SMTDSettings.QuicktimeGenerate do SMTDFunctions.AutomaticQuicktimeGeneration() --batchName:batchName
					
					if copyResult == 0 then
						try(SMTD_MainRollout.sld_lastSubmissionState.color = green; SMTD_MainRollout.sld_lastSubmissionState.value = 100)catch()
					else	
						try(SMTD_MainRollout.sld_lastSubmissionState.color = red*0.75 + green*0.5; SMTD_MainRollout.sld_lastSubmissionState.value = 100)catch()
						
					try
					(
						local theFn =  (getIniSetting SMTDPaths.InIFile "Scripts"  "PostSubmissionFunction")
						if theFn != "" then
						(
							execute theFn
							try(SMTD_MainRollout.Ui_report ("+Executed Post-Submission Function: "+  theFn) )catch()
						)
					)
					catch
					(
						try(SMTD_MainRollout.Ui_report ("--Failed To Execute Post-Submission Function: "+  theFn) )catch()
						SMTDSettings.nonFatalErrorsCount+=1
					)	
					--print renderMsg; --FIXME
						
					("+JOB SUBMITTED SUCCESSFULLY.\n\n" + renderMsg)
				)--end success	
				#failed:
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
					("--DEADLINE JOB SUBMISSION FAILED:\n\nFailed to submit job.\n\n" + renderMsg)
				)--end failed	
				#readerror:
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
					("--DEADLINE JOB SUBMISSION FAILED:\n\nRead Error.\n\n" + renderMsg)
				)--end read error
				#timeout:
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
					("--DEADLINE JOB SUBMISSION TIMED OUT AFTER "+ SMTDSettings.TimeoutSubmission as string +" SECONDS!\nConsider increasing the Job Submission Timeout in the User Options tab.\n\n")
				)
				default: 
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
					("--DEADLINE JOB SUBMISSION FAILED FOR UNKNOWN REASON.\n\n")			
				)
				#tileFailure: 
				(
					try(SMTD_MainRollout.sld_lastSubmissionState.color = red; SMTD_MainRollout.sld_lastSubmissionState.value = 100.0)catch()
					("--DEADLINE DISTRIBUTED TILES JOB SUBMISSION FAILED.\n\n") --scroll back up message stack to understand the reason for failure in the SMTD log	
				)
			)--end retCode case
			
		)--end submit job fn	
	)
)