-----------------------------------------------------------------------------------------------------------------------------------------------
--THIS FILE CONTAINS THE GENERAL CHECKS TO BE PERFORMED AND THE FUNCTIONS
--TO BE USED TO CHECK AND REPAIR THE SCENE BEFORE SUBMISSION
-----------------------------------------------------------------------------------------------------------------------------------------------
--THIS FILE MAY BE UPDATED WHEN DEADLINE IS UPDATED.
--MODIFY AT YOUR OWN RISK!
-----------------------------------------------------------------------------------------------------------------------------------------------

(
	global SMTD_SanityCheckFunctions
	global SMTD_RepairFunctions 
	global SMTD_SanityChecksToPerform
	global SMTD_SanityCheck_errorReportRollout

	struct SMTD_SanityCheckFunctions
	(
		fn ReturnRETypes =
		(
			global reTypes = #()
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
					if (reManager.GetRenderElement i).enabled then
					(
						append reTypes (reManager.GetRenderElement i)
					)
			)--end if reManger undefined
			return reTypes
		),
		fn ReturnREPaths =
		(
			global rePaths = #()
			local reManager = maxOps.GetCurRenderElementMgr()
			if reManager != undefined do
			(
				local reCount = reManager.NumRenderElements()
				for i = 0 to reCount - 1 do
					if reManager.GetRenderElementFilename i != undefined and reManager.GetRenderElementFilename i != "" then
					(
						append rePaths (reManager.GetRenderElementFilename i)
					)
			)--end if reManager undefined
			return rePaths
		),
		fn ReturnFumeFXObjects =
		(
			global FumeFXObjects = #()
			for i = 1 to geometry.count where (classof geometry[i] == FumeFX) do
			(
				append FumeFXObjects geometry[i]
			)
			return FumeFXObjects
		),
		fn CheckForEmptyScene = 
		(
			(objects as array).count > 0
		),
		fn CheckForLockedViewport =
		(
			-- the locked viewport rendering seems to work fine in max 2015
			if( ((maxVersion())[1]/1000 as integer) > 16 ) then
				true
			else
			(
				-- option only available in 3dsmax 2009 to 2014
				if( ((maxVersion())[1]/1000 as integer) > 10 ) then
					rendUseActiveView
				else
					true
			)
		),
		fn CheckForDuplicateCameraName =
		(
			duplicatesFound = false
			
			local theCameras = for o in objects where findItem Camera.classes (classof o) > 0 collect o
			local theObjects = for o in objects where findItem Camera.classes (classof o) == 0 collect o
			if (theCameras as array).count > 0 then
			(
				for i = 1 to theCameras.count do
				(
					cameraName = theCameras[i].name
					for j = (i + 1) to theCameras.count do
					(
						if cameraName == theCameras[j].name then
						(
							duplicatesFound = true
							exit
						)
					)
					
					if duplicatesFound then exit
					
					for j = 1 to theObjects.count do
					(
						if cameraName == theObjects[j].name then
						(
							duplicatesFound = true
							exit
						)
					)
					
					if duplicatesFound then exit
				)
			)
			
			duplicatesFound == false
		),
		fn CheckForCameraView =
		(
			if (renderers.current.classid as string) != "#(272052741, 712862621)" then
				viewport.getCamera() != undefined
			else
				true
		),
		fn CheckForMaxwellCameraView =
		(
			if (renderers.current.classid as string) == "#(272052741, 712862621)" then
				viewport.getCamera() != undefined
			else
				true
		),
		fn CheckForMaxwellSingleFrame =
		(
			if (renderers.current.classid as string) == "#(272052741, 712862621)" then
				rendTimeType != 1
			else
				true
		),
		fn CheckForMPassRenderer =
		(
			rendClass = substring (( classof renderers.current) as string) 1 3
			rendClass == "Bra" or rendClass == "Def"
		),
		fn CheckForRenderingSingleFrame =
		(
			-- Maxwell has it's own fatal error when a single frame is being rendered, so we can
			-- skip this check if Maxwell is the current renderer.
			if (renderers.current.classid as string) != "#(272052741, 712862621)" then
			(
				if ( not SMTDSettings.RemovePadding ) then
					rendTimeType > 1
				else
					true
			)
			else
				true
		),
		fn CheckForRenderingMultiFrame =
		(
			if ( SMTDSettings.RemovePadding ) then
				rendTimeType == 1
			else
				true
		),
		fn CheckForRenderOutputPath =
		(
			rendOutputFilename != ""
		),
		fn CheckForRenderOutputSaveFlag =
		(
			rendOutputFilename == "" OR rendSaveFile 
		),
		fn CheckForLocalDrive =
		(
			local drive_letter = substring rendOutputFilename 1 2
			not (drive_letter == "C:" or drive_letter == "D:" or drive_letter == "E:")
		),	
		fn CheckForRestartRenderer =
		(
			local rendererID = case (renderers.current.classid as string) of
			(
				"#(1, 0)": true --scanline
				"#(1387076610, 288174012)": SMTDSettings.RestartRenderer --brazil
				"#(95494396, 474502030)": SMTDSettings.RestartRenderer --brmax
				"#(1492548972, 1338981315)": true --mentalray
				"#(1941615238, 2012806412)": if (not renderers.current.options_dontRenderImage) then SMTDSettings.RestartRenderer else true --vray
				default: true
			)
		),
		fn CheckForRenderOutputTrail =
		(
			if ( rendTimeType > 1 ) then
			(
				theFileName = getFileNameFile rendOutputFilename
				theFileType = getFileNameType rendOutputFilename
				if not matchPattern theFileType pattern:"*mov" and not matchPattern theFileType pattern:"*avi" then
				(
					if theFileName.count > 3 then
						not (try((classof (execute (substring theFileName theFileName.count 1)) == Integer and classof (execute (substring theFileName (theFileName.count-3) 4)) != Integer ))catch(false))
					else true
				)
				else true
			)
			else true
		),
		fn CheckForRenderOutputMovie =
		(
			theFileType = getFileNameType rendOutputFilename
			not (matchPattern theFileType pattern:"*mov" or matchPattern theFileType pattern:"*avi")
		),
		fn CheckForUntitledFile =
		(
			MaxFileName != ""
		),
		
		fn CheckForDistributedRendering =
		(
			case (renderers.current.classid as string) of
			(
				"#(1492548972, 1338981315)": not (renderers.current.DistributedEnable)
				"#(1941615238, 2012806412)": not (renderers.current.system_distributedRender)
				default: true
			)
		),
		
		fn CheckForVRayDistributedRendering =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				if renderers.current.system_distributedRender then
					SMTDSettings.forceWorkstationMode
				else
					true
			)
			else
				true
		),
		
		fn CheckForVRayNoFinalImage =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				if renderers.current.options_dontRenderImage then
					(not SMTDSettings.RestartRenderer) and SMTDSettings.LimitEnabled and (SMTDSettings.MachineLimit == 1)
				else
					true
			)
			else
				true
		),
		
		fn CheckForKrakatoaCacheState =
		(
			if renderers.current.classid as string == "#(-1204370534, -399920359)" then
				not (FranticParticles.GetBoolProperty "EnableParticleCache")
			else
				true
		),
		fn CheckForTileRenderAndVrayVfb =
		(
			if SMTDSettings.TilesRendering then
			(
				if renderers.current.classid as string == "#(1941615238, 2012806412)" then
					not renderers.current.output_on
				else
					true
			)
			else
				true
		),
		fn CheckForRenderElements =
		(
			undefinedFileName = true
			if not SMTDSettings.RenderElementsUpdatePaths do
			(
				reMgr = maxOps.GetCurRenderElementMgr()
				if reMgr != undefined do
				(
					for i = 0 to (reMgr.numrenderelements()-1) do
					(
						fname = reMgr.GetRenderElementFileName i
						if fname == undefined or fname == "" then
						(				
							undefinedFileName = false
						)
					)
				)--end if reMgr undefined
			)
			undefinedFileName
		),
		fn CheckForOutputPathLength =
		(
			RenderOutput = rendOutputFilename
			if RenderOutput.count > 254 then
				false
			else
				true
		),
		fn CheckForREPathLength = 
		(
			re = maxOps.GetCurRenderElementMgr()
			if re != undefined then
			(
				if re.numrenderelements() != 0 then
					(
						Paths = SMTD_SanityCheckFunctions.ReturnREPaths()
						(PathLengths = for n in 1 to Paths.count where (Paths[n].count > 254) collect n).count == 0
					)
				else true
			)--end if re undefined
			else true
		),
		fn CheckForDuplicateREPaths = 
		(
			re = maxOps.GetCurRenderElementMgr()
			if re != undefined then
			(
				if re.numrenderelements() != 0 then
					(
						Paths = SMTD_SanityCheckFunctions.ReturnREPaths()
						uniquePaths = makeuniquearray Paths
						Paths.count == uniquePaths.count
					)
				else true
			)--end if re undefined
			else true
		),
		fn CheckForObjectNames =
		(
			if geometry.count > 0 then
				(
					(for o in 1 to geometry.count where (geometry[o].name.count > 254) collect o).count == 0
				)
			else true
		),
		fn CheckForCorruptGroup =
		(
			if objects.count > 0 then
				(
					(for n in 1 to objects.count where ((isgrouphead objects[n] == true) AND (objects[n].children.count == 0)) collect n).count == 0
				)
			else true
		),
		fn CheckForActiveJigsawRegions =
		(
			if SMTDSettings.RegionRenderingMode == #singleFrameMultiRegion OR SMTDSettings.RegionRenderingMode == #animationMultiRegion then
			(
				(for o in SMTDSettings.MultiRegionData where (o)[1] == true collect true).count != 0
			)
			else true
		),
		fn CheckForVRayRawFileName =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.output_on and vr.output_saveRawFile then
				(
					vr.output_rawFileName != ""
				)
				else true
			)
			else true
		),
		fn CheckForVRaySplitFileName =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.output_on and vr.output_splitgbuffer then
				(
					vr.output_splitfilename != ""
				)
				else true
			)
			else true
		),
		fn CheckForVRayGeneratePreview =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.output_on and vr.output_saveRawFile then
				(
					not vr.output_genpreview
				)
				else true
			)
			else true
		),
		fn CheckForVRayRegionRender =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.output_on then
				(
					not vrayVFBGetRegionEnabled()
				)
				else true
			)
			else true
		),
		fn CheckForVRayTrackMouse =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				local vrayVer = 2
				vrayVersionCheck = try(vrayVersion())catch(undefined)
				if vrayVersionCheck != undefined then (
					vrayVer = vrayVersionCheck[1][1] as integer
				)
				if vrayVer >= 3 then
				(
					vr = renderers.current
					if vr.output_on then
					(
						-- Function only available in V-Ray v3.0+ onwards
						(vfbControl(#trackmouse))[1] == 0
					)
					else true					
				)
				else true
			)
			else true
		),
		fn CheckForCameraMatchBmp =
		(
			oldView = viewport.activeViewport
			bitmapCount = #()
			for i in 1 to viewport.numViews do
			(
				viewport.activeViewport = i
				if backgroundimagefilename != "" then
				(
					append bitmapCount backgroundimagefilename
				)
			)
			viewport.activeViewport = oldView
			bitmapCount.count == 0
		),
		fn CheckForTgaBitDepth =
		(
			if rendOutputFilename != "" then
			(
				if (toLower (getFileNameType rendOutputFilename)) == ".tga" then
				(
					Targa.getColorDepth() != 32
				)
				else true
			)
			else true
		),
		fn CheckForVRayVFBTA =
		(
			local enabledTA = #()
			if SMTDSettings.RegionRenderingMode == #singleFrameTiles and (not SMTDSettings.SingleTileJobDraft) then
			(
				if renderers.current.classid as string == "#(1941615238, 2012806412)" then
				(
					vr = renderers.current
					if vr.output_on and vr.output_splitgbuffer then
					(
						reTypes = SMTD_SanityCheckFunctions.ReturnRETypes()
						if reTypes.count != 0 then
						(
							classTypes = #(VRayAlpha, VRayReflection, VRayReflectionFilter, VRayRefraction, VRayRefractionFilter)

							for n in 1 to reTypes.count do
							(
								if findItem classTypes (classof reTypes[n]) > 0 then
								(
									--Append the Render Element Name as string to the enabledTA array if it matches one of the above classType array items
									append enabledTA (reTypes[n].elementName as string)
								)
							)
						)
						if vr.output_splitAlpha then
						(
							--Additionally, if "Save alpha" is enabled in the V-Ray VFB, then append this to the enabledTA array
							append enabledTA "Save alpha"
						)
					)
				)
			)
			--If array != 0 then there is either a V-Ray RE (16bit) or VFB "Save Alpha" (16bit) which will fail via Tile Assembler and must use Draft Tile Assembler instead.
			enabledTA.count == 0
		),
		fn CheckForVRayValidIMAPFile =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.gi_on AND vr.adv_irradmap_mode == 2 then
				(
					if (vr.adv_irradmap_loadFileName == "") OR (not doesFileExist vr.adv_irradmap_loadFileName) then
					(
						false
					)
					else true
				)
				else true
			)
			else true
		),
		fn CheckForVRayValidPhotonFile =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.gi_on AND vr.photonMap_mode == 1 then
				(
					if (vr.photonMap_loadFileName == "") OR (not doesFileExist vr.photonMap_loadFileName) then
					(
						false
					)
					else true
				)
				else true
			)
			else true
		),
		fn CheckForVRayValidLCFile =
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.gi_on AND vr.lightcache_mode == 2 then
				(
					if (vr.lightcache_loadFileName == "") OR (not doesFileExist vr.lightcache_loadFileName) then
					(
						false
					)
					else true
				)
				else true
			)
			else true
		),
		fn CheckForVRayValidCausticsFile = 
		(
			if renderers.current.classid as string == "#(1941615238, 2012806412)" then
			(
				vr = renderers.current
				if vr.caustics_on AND vr.caustics_mode == 1 then
				(
					if (vr.caustics_loadFileName == "") OR (not doesFileExist vr.caustics_loadFileName) then
					(
						false
					)
					else true
				)
				else true
			)
			else true
		),
		fn CheckForActiveShade =
		(
			renderers.renderDialogMode != #activeShade
		),
		fn CheckForFumeFXSimProgress =
		(
			FumeFXObjects = SMTD_SanityCheckFunctions.ReturnFumeFXObjects()
			if FumeFXObjects.count > 0 and (SMTDSettings.DisableProgressUpdateTimeout != true) then
				(
					(for n in FumeFXObjects where (n.BackBurnerSim) collect n).count == 0
				)
			else true
		),
		fn CheckForFumeFXSimChunkSize =
		(
			FumeFXObjects = SMTD_SanityCheckFunctions.ReturnFumeFXObjects()
			if FumeFXObjects.count > 0 and (rendTimeType != 1) then
				(
					(for n in FumeFXObjects where (n.BackBurnerSim) collect n).count == 0
				)
			else true
		),
		fn CheckForFumeFXSimMachineLimit =
		(
			FumeFXObjects = SMTD_SanityCheckFunctions.ReturnFumeFXObjects()
			if (FumeFXObjects.count > 0 and (SMTDSettings.LimitEnabled != true)) or (FumeFXObjects.count > 0 and (SMTDSettings.MachineLimit != 1)) then
				(
					(for n in FumeFXObjects where (n.BackBurnerSim) collect n).count == 0
				)
			else true
		)
	)

	struct SMTD_RepairFunctions
	(
		fn doNothing = 
		(
			true
		),
		fn cannotFix =
		(
			SMTD_SanityCheck_errorReportRollout.log_action "FATAL" (color 0 0 255) true  ("Please load a new MAX file or create/merge objects before submitting!")
		),	
		fn SuggestPossibleCamera = 
		(
			local theCameras = for o in objects where findItem Camera.classes (classof o) > 0 collect o
			if (theCameras as array).count > 0 then
			(
				possibleCamera = SelectByName single:true title:"Select Camera to Submit to Deadline:" filter:(fn filterCamera obj = (superclassof obj == Camera))
				if possibleCamera != undefined then
				(
					viewport.setCamera possibleCamera 
					SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true ("Camera ["+ possibleCamera.name +"] set in the current viewport.")
				)	
				else
					SMTD_SanityCheck_errorReportRollout.log_action "FAILED" (color 0 0 255) true "No Camera was selected."
			)	
			else
				SMTD_SanityCheck_errorReportRollout.log_action "FAILED" (color 0 0 0) true "There are NO CAMERAS in the scene."

		),
		fn EnableMPassMBlur = 
		(
			theCam = viewport.getCamera() 
			if theCam != undefined do 
			(
				if classof theCam.mpassEffect != Motion_BlurMPassCamEffect do 
					theCam.mpassEffect = Motion_BlurMPassCamEffect()
				theCam.mpassEnabled = true
				SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true ("Enabled MultiPass Motion Blur in Camera ["+theCam.name+"]")
			)	
		),
		fn FixLockedViewport =
		(
			-- option only available in 3dsmax 2009 and later
			if( ((maxVersion())[1]/1000 as integer) > 10 ) do
			(
				renderSceneDialog.close()
				rendUseActiveView = true
				renderSceneDialog.open()
				SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Locked viewport disabled."
			)
		),
		fn FixRenderingSingleFrame =
		(
			renderSceneDialog.close()
			rendTimeType = 2
			renderSceneDialog.open()
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Rendering Output Time changed to ACTIVE TIME SEGMENT."
		),
		fn FixRenderingMultiFrame =
		(
			renderSceneDialog.close()
			rendTimeType = 1
			renderSceneDialog.open()
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Rendering Output Time changed to SINGLE FRAME."
		),
		fn FixRenderOutputPath =
		(
			renderSceneDialog.open()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, Pick a valid path, then re-test!"
		),
		fn FixRenderOutputSaveFlag =
		(
			renderSceneDialog.close()
			rendSaveFile = true
			renderSceneDialog.open()
		),
		fn FixRestartRenderer =
		(
			SMTDSettings.RestartRenderer = true
			setIniSetting SMTDPaths.InIFile "RenderingOptions"  "RestartRenderer" (SMTDSettings.RestartRenderer as string)
		),
		fn FixRenderOutputTrail =
		(
			rendOutputFilename = getFileNamePath rendOutputFilename + getFileNameFile rendOutputFilename + "_" + getFileNameType rendOutputFilename
		),
		fn FixRenderOutputMovie =
		(
			renderSceneDialog.open()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, please select a single frame format, then re-test!"
		),
		fn SaveUntitledFile =
		(
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "File>Save As dialog is OPEN. Please save the scene to a file, then re-test!"
			max file save 
		),
		fn FixDistributedRendering =
		(
			case (renderers.current.classid as string) of
			(
				"#(1492548972, 1338981315)": renderers.current.DistributedEnable = false
				"#(1941615238, 2012806412)": renderers.current.system_distributedRender = false
				default: true
			)
		),
		fn FixVRayDistributedRendering =
		(
			SMTDSettings.ForceWorkstationMode = true
			setIniSetting SMTDPaths.InIFile "RenderingOptions"  "ForceWorkstationMode" (SMTDSettings.ForceWorkstationMode as string)
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Workstaton Mode has been enabled."
		),
		fn FixVRayNoFinalImage =
		(
			SMTDSettings.RestartRenderer = false
			SMTDSettings.LimitEnabled = true
			SMTDSettings.MachineLimit = 1
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Restart Renderer disabled, Machine Limit enabled and set to 1."
		),
		fn FixKrakatoaCache =
		(
			try(
				FranticParticles.SetProperty "EnableParticleCache" "false"
				FranticParticles.SetProperty "EnableLightingCache" "false"
				SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Krakatoa PCache and LCache turned OFF."
				Krakatoa_GUI_Main.refresh_GUI()
			)catch()
		),
		fn FixMaxwellSingleFrame =
		(
			renderSceneDialog.close()
			rendTimeType = 4
			rendPickupFrames = (((slidertime as integer) / ticksperframe) as string)
			renderSceneDialog.open()
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Rendering Output Time changed to animation with just the current frame."
		),
		fn FixTileRenderAndVrayVfb =
		(
			renderers.current.output_on = false
		),
		fn FixRenderElements =
		(
			renderSceneDialog.close()
			renderSceneDialog.open() 
			for i=1 to tabbedDialogs.getNumPages #render do
			(
				if (tabbedDialogs.getPageTitle #render i) == "Render Elements" then
					tabbedDialogs.setCurrentPage #render i
			)
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) true "If using V-Ray Frame Buffer and ALL RE's have been Disabled, then IGNORE this Sanity Check!"
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) true "Ensure that a Render Element Output File has been selected for each Render Element!"
		),
		fn FixOutputPathLength =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				--Common Tab
				tabbedDialogs.setCurrentPage #render #(1379758294, 1692354418)
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) true "Try reducing the Render Output Path Length < 255 characters!"
		),
		fn FixREPathLength =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				--RE Tab
				tabbedDialogs.setCurrentPage #render #(1547006576, 1564889954)
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) true "Try reducing the RE - Render Path Length < 255 characters!"
		),
		fn FixDuplicateREPaths =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				--RE Tab
				tabbedDialogs.setCurrentPage #render #(1547006576, 1564889954)
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) true "One or more Render Elements are saving to the same File!"
		),
		fn FixObjectNames =
		(
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "One or more objects have a name > 255 characters!"
		),
		fn FixCorruptGroup =
		(
			nodeSel=#()
			(for n in 1 to objects.count where ((isgrouphead objects[n] == true) AND (objects[n].children.count == 0)) do (append nodeSel objects[n]))
			if nodeSel.count > 0 then
			(
				for n in 1 to nodeSel.count do
				(
					SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true ("Group Deleted: ["+ nodeSel[n].name +"]")
				)
			)
			delete nodeSel
		),
		fn FixVRayRawFileName =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(539584185, 72172985) --VRay Tab
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "V-Ray Frame Buffer (VFB): [V-Ray raw image file] - Ensure you enter a valid image file save path."
		),
		fn FixVRaySplitFileName =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(539584185, 72172985) --VRay Tab
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "V-Ray Frame Buffer (VFB): [Separate render channels] - Ensure you enter a valid image file save path."
		),
		fn FixVRayGeneratePreview =
		(
			renderers.current.output_genpreview = false
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "V-Ray Frame Buffer (VFB): [Generate preview] is now DISABLED!"
		),
		fn FixVRayRegionRender =
		(
			vrayVFBSetRegionEnabled false
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "V-Ray Frame Buffer (VFB): [Region render] is now DISABLED!"
		),
		fn FixVRayTrackMouse =
		(
			vfbControl(#trackmouse) false --function only available in V-Ray v3.0+ onwards
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "V-Ray Frame Buffer (VFB): [Track mouse while rendering] is now DISABLED!"
		),
		fn FixCameraMatchBmp =
		(
			oldView = viewport.activeViewport
			cameraBitmaps=#()
			for n in 1 to viewport.numViews do
			(
				viewport.activeViewport = n
				if backgroundimagefilename != "" then
				(
					append cameraBitmaps backgroundimagefilename
				)
			)
			for n in 1 to cameraBitmaps.count do (SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true ("Deleted: ["+ cameraBitmaps[n] +"]"))

			for n in 1 to viewport.numViews do
			(
				viewport.activeViewport = n
				if backgroundimagefilename != "" then
				(
					backgroundimagefilename = ""
				)
			)
			viewport.activeViewport = oldView
		),
		fn FixTgaBitDepth =
		(
			renderSceneDialog.open()
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(1379758294, 1692354418) --Common Tab
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, change the Render Output, *.tga bit depth to 32bit for Alpha."
		),
		fn FixVRayVFBTA =
		(
			SMTDSettings.SingleTileJobDraft = true
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Use Draft for Assembly has been ENABLED."
		),
		fn FixVRayValidIMAPFile =
		(
			renderSceneDialog.open()
			try(
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(353437075,945298394) --VRay GI tab
			)catch()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, V-Ray GI tab, ensure IMAP File (*.vrmap) is set to a valid file path."
		),
		fn FixVRayValidPhotonFile = 
		(
			renderSceneDialog.open()
			try(
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(353437075,945298394) --VRay GI tab
			)catch()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, V-Ray GI tab, ensure Photon File (*.vrpmap) is set to a valid file path."
		),
		fn FixVRayValidLCFile =
		(
			renderSceneDialog.open()
			try(
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(353437075,945298394) --VRay GI tab
			)catch()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, V-Ray GI tab, ensure LC File (*.vrlmap) is set to a valid file path."
		),
		fn FixVRayValidCausticsFile =
		(
			renderSceneDialog.open()
			try(
			if tabbedDialogs.isOpen #render do
				tabbedDialogs.setCurrentPage #render #(353437075,945298394) --VRay GI tab
			)catch()
			SMTD_SanityCheck_errorReportRollout.log_action "Hint" (color 155 0 0) false "In the Render Scene Dialog, V-Ray GI tab, ensure Caustics File (*.vrpmap) is set to a valid file path."
		),
		fn FixActiveShade =
		(
			renderers.renderDialogMode = #Production
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Production Render Mode has been ENABLED."
		),
		fn FixFumeFXSimProgress =
		(
			SMTDSettings.DisableProgressUpdateTimeout = true
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Progress Update Timeout has been DISABLED for FumeFX Sim Job."
		),
		fn FixFumeFXSimChunkSize =
		(
			rendTimeType = 1
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Rendering Output Time set to SINGLE FRAME for FumeFX Sim Job."
		),
		fn FixFumeFXSimMachineLimit =
		(
			SMTDSettings.LimitEnabled = true
			SMTDSettings.MachineLimit = 1
			SMTD_SanityCheck_errorReportRollout.log_action "Fixed" (color 0 155 0) true "Machine Limit ENABLED and Set to 1 for FumeFX Sim Job."
		)
	)

	global SMTD_SanityChecksToPerform =
	#(
		#(SMTD_SanityCheckFunctions.CheckForEmptyScene, #fail, "The scene does not contain ANY objects!", SMTD_RepairFunctions.cannotFix, true),
		#(SMTD_SanityCheckFunctions.CheckForUntitledFile, #fix, "The current Scene Name is Untitled.", SMTD_RepairFunctions.SaveUntitledFile, true),
		#(SMTD_SanityCheckFunctions.CheckForCameraView, #fix, "The current view is NOT a Camera.", SMTD_RepairFunctions.SuggestPossibleCamera, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderingSingleFrame, #fix, "The Render Time Output is set to SINGLE FRAME!", SMTD_RepairFunctions.FixRenderingSingleFrame, true),
		#(SMTD_SanityCheckFunctions.CheckForLocalDrive, #fix, "The Render Output Path appears to point at a LOCAL DRIVE!", SMTD_RepairFunctions.FixRenderOutputPath, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderOutputTrail, #fix, "The Render Output File Name ends with a DIGIT - trailing numbers might fail.", SMTD_RepairFunctions.FixRenderOutputTrail, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderOutputPath, #fix, "The Render Output Path is NOT DEFINED!", SMTD_RepairFunctions.FixRenderOutputPath, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderOutputMovie, #warn, "The Render Output is set to a MOVIE format.", SMTD_RepairFunctions.FixRenderOutputMovie, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderOutputSaveFlag, #fix, "The Render Output Save File Checkbox is NOT CHECKED! No Frames Will Be Saved!", SMTD_RepairFunctions.FixRenderOutputSaveFlag, true),
		#(SMTD_SanityCheckFunctions.CheckForDistributedRendering, #warn, "The Distributed Rendering option is enabled for this renderer.", SMTD_RepairFunctions.FixDistributedRendering, true),
		#(SMTD_SanityCheckFunctions.CheckForMaxwellCameraView, #fail, "Maxwell is the renderer and the current view is NOT a Camera.", SMTD_RepairFunctions.SuggestPossibleCamera, true),
		#(SMTD_SanityCheckFunctions.CheckForDuplicateCameraName, #fail, "The scene contains objects or groups with the same name as a camera!", SMTD_RepairFunctions.cannotFix, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayDistributedRendering, #fix, "Workstation Mode must be enabled to use V-Ray Distributed Rendering.", SMTD_RepairFunctions.FixVRayDistributedRendering, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayNoFinalImage, #warn, "Not rendering final image (GI), so Restart Renderer should be disabled, and Machine Limit set to 1.", SMTD_RepairFunctions.FixVRayNoFinalImage, true),
		--#(SMTD_SanityCheckFunctions.CheckForMaxwellSingleFrame, #fail, "Maxwell is the renderer and the Render Time Output is set to a SINGLE FRAME!", SMTD_RepairFunctions.FixMaxwellSingleFrame, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderingMultiFrame, #fix, "The Render Time Output is NOT set to single frame, and Remove Filename Padding is enabled!", SMTD_RepairFunctions.FixRenderingMultiFrame, true),
		#(SMTD_SanityCheckFunctions.CheckForKrakatoaCacheState, #fix, "The current Renderer is Krakatoa and Particle Cache is ON!", SMTD_RepairFunctions.FixKrakatoaCache, true),
		#(SMTD_SanityCheckFunctions.CheckForRestartRenderer, #warn, "Restart Renderer Between Frames is disabled and V-Ray or Brazil is the selected renderer.", SMTD_RepairFunctions.FixRestartRenderer, true),
		#(SMTD_SanityCheckFunctions.CheckForLockedViewport, #warn, "Viewport is currently locked, which can result in incorrect renders with Deadline.", SMTD_RepairFunctions.FixLockedViewport, true),
		#(SMTD_SanityCheckFunctions.CheckForTileRenderAndVrayVfb, #warn, "Tile Rendering is enabled and the V-Ray VFB is currently on.", SMTD_RepairFunctions.FixTileRenderAndVrayVfb, true),
		#(SMTD_SanityCheckFunctions.CheckForRenderElements, #fix, "One or more Render Element Save File Paths are EMPTY! (V-Ray? - Disable the Individual RE)", SMTD_RepairFunctions.FixRenderElements, true),
		#(SMTD_SanityCheckFunctions.CheckForOutputPathLength, #fail, "Render Output Path length exceeds 255 characters!", SMTD_RepairFunctions.FixOutputPathLength, true),
		#(SMTD_SanityCheckFunctions.CheckForREPathLength, #fail, "Render Elements Output Path length exceeds 255 characters!", SMTD_RepairFunctions.FixREPathLength, true),
		#(SMTD_SanityCheckFunctions.CheckForDuplicateREPaths, #fail, "Duplicate Render Elements saving to same File Found!", SMTD_RepairFunctions.FixDuplicateREPaths, true),
		#(SMTD_SanityCheckFunctions.CheckForObjectNames, #fail, "Scene Object(s) contain names > 255 characters!", SMTD_RepairFunctions.FixObjectNames, true),
		#(SMTD_SanityCheckFunctions.CheckForCorruptGroup, #fail, "Corrupt Group(s) detected in your Scene!", SMTD_RepairFunctions.FixCorruptGroup, true),
		#(SMTD_SanityCheckFunctions.CheckForActiveJigsawRegions, #fail, "Multi-Region Rendering Requested, But No Active Regions Found!", SMTD_RepairFunctions.doNothing, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayRawFileName, #fail, "V-Ray Save Raw Image File is Enabled, but Raw Image File Path is Empty!", SMTD_RepairFunctions.FixVRayRawFileName, true),
		#(SMTD_SanityCheckFunctions.CheckForVRaySplitFileName, #fail, "V-Ray Save Separate Render Channels is Enabled, but Separate Render Channels File Path is Empty!", SMTD_RepairFunctions.FixVRaySplitFileName, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayGeneratePreview, #fail, "V-Ray VFB Save Raw Image File - [Generate preview] should be Disabled!", SMTD_RepairFunctions.FixVRayGeneratePreview, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayRegionRender, #fix, "V-Ray VFB - [Region render] button might need to be Disabled!", SMTD_RepairFunctions.FixVRayRegionRender, true),
		--#(SMTD_SanityCheckFunctions.CheckForVRayTrackMouse, #fail, "V-Ray VFB - [Track mouse while rendering] button should be Disabled!", SMTD_RepairFunctions.FixVRayTrackMouse, true),
		#(SMTD_SanityCheckFunctions.CheckForCameraMatchBmp, #fix, "Camera Match Background Image(s) in your Scene. Right-click to REMOVE these ref. bitmaps!", SMTD_RepairFunctions.FixCameraMatchBmp, true),
		#(SMTD_SanityCheckFunctions.CheckForTgaBitDepth, #fix, "Alpha Channel will NOT be stored if saving *.tga file @ 16/24bit depth! Select 32bit for Alpha!", SMTD_RepairFunctions.FixTgaBitDepth, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayVFBTA, #fail, "V-Ray RE:[Alpha,Reflection,Refraction] or [Save alpha] requires Draft Tile Assembler. NOT supported with TA.", SMTD_RepairFunctions.FixVRayVFBTA, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayValidIMAPFile, #fix, "V-Ray IMAP File (*.vrmap) set to 'From File' is missing/invalid file path!", SMTD_RepairFunctions.FixVRayValidIMAPFile, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayValidPhotonFile, #fix, "V-Ray Photon File (*.vrpmap) set to 'From File' is missing/invalid file path!", SMTD_RepairFunctions.FixVRayValidPhotonFile, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayValidLCFile, #fix, "V-Ray LC File (*.vrlmap) set to 'From File' is missing/invalid file path!", SMTD_RepairFunctions.FixVRayValidLCFile, true),
		#(SMTD_SanityCheckFunctions.CheckForVRayValidCausticsFile, #fix, "V-Ray Caustics File (*.vrpmap) set to 'From File' is missing/invalid file path!", SMTD_RepairFunctions.FixVRayValidCausticsFile, true),
		#(SMTD_SanityCheckFunctions.CheckForActiveShade, #fix, "Current Scene is Rendering in Active Shade Mode. Are you sure you want to Submit?", SMTD_RepairFunctions.FixActiveShade, true),
		#(SMTD_SanityCheckFunctions.CheckForFumeFXSimProgress, #fix, "FumeFX Sim Job? - Disable Progress Timeout MUST be ENABLED!", SMTD_RepairFunctions.FixFumeFXSimProgress, true),
		#(SMTD_SanityCheckFunctions.CheckForFumeFXSimChunkSize, #fix, "FumeFX - Sim Jobs ONLY need to be a SINGLE FRAME (ALL Frames will be Simulated)", SMTD_RepairFunctions.FixFumeFXSimChunkSize, true),
		#(SMTD_SanityCheckFunctions.CheckForFumeFXSimMachineLimit, #fix, "FumeFX - Sim Jobs MUST have a MACHINE LIMIT = 1 (RUN only on 1 machine)", SMTD_RepairFunctions.FixFumeFXSimMachineLimit, true)
	)
)
