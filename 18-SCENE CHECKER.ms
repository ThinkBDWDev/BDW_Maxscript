
(

	try ( destroyDialog rlt_TeagueSceneChecker ) catch()
	try ( destroyDialog rlt_sceneCheckerObjects ) catch()
	
	-- Script variables
	global scriptName = "Teague Scene Checker"
	global versionNum = 1.08
	global scriptDirectory = (getDir #userScripts) + "\\TeagueSceneChecker"
	global bannerBitmapLocation = scriptDirectory + "\\TeagueBanner.bmp"
	--local bannerBitmapLocation = "\\\\peabody\\Library\\Software\\maxscript\\Teague_Scripts\\ColinScripts\\dev\\TeagueSceneChecker\\TeagueBanner.bmp"
	
	-- Rollouts
	global rlt_TeagueSceneChecker
	global rlt_sceneCheckerObjects
	-- Function Init
	global removeItemsFromArray
	global GetIndividualInstances
	global GetArrayReturnProperty
	global checkForProblems
	global addProblem
	global clearProblems
	global getDependentsOfType
	global isRendererVRay
	global isMaxVersion2011Plus
	-- Structure Init
	struct s_Problem (	-- Structure for adding problems to the scene
		type = #info, 
		id = undefined, 
		message = "",
		objs = #()
	) 
	-- Variables
	global aProblem = #()	-- Array of problems the scene has of type "s_Problem"
	
	/************************************************************************
										FUNCTIONS
	************************************************************************/
	
	/*************************
	FUNCTION: 
	NAME: removeItemsFromArray
	PURPOSE: used for GetIndividualInstances to remove instances of a light from an array
	RETURNS: the array with the items to remove
	**************************/		
	fn removeItemsFromArray arr arrItemsToRemove verbose:false = (
		local ret = arr
		
		if (verbose) then
		(
			format "------------- Array -------------\n"
			for i=1 to arr.count do print ("[" + i as string + "] " + arr[i].name)
			format "---------- To Remove -----------\n"
			for a in arrItemsToRemove do print a.name
		)
		
		for j in arrItemsToRemove where (idx = (findItem arr j)) != 0 do (
			if (verbose) then
			(
				format "Deleting item @ index:%  named: %\n" idx j.name
			)
			deleteItem arr idx			
		)
		
		--for j = arrItemsToRemove.count to 1 by -1 where (idx = (findItem arr arrItemsToRemove[j])) != 0 do
			--deleteItem arr idx	
		
		ret
	)

	/*************************
	FUNCTION: 
	NAME: GetIndividualInstances
	PURPOSE: returns only one object of the type 'superclass' because the rest are instances of that light
	RETURNS: array of only single instances of instanced lights
	**************************/	
	fn GetIndividualInstances superclass type = (
		local ret = #()
		local instances = #()
		
		-- Get all the VRayLights
		allVRayLights = for l in superclass where (classof l == type) collect l
		
		for l in allVRayLights do (
			instances = #()
			InstanceMgr.GetInstances l &instances
			
			--format "l: %  instances: %s\n" l.name instances
			
			singleInstance = instances[1]
			
			append ret singleInstance
			
			-- Take one of them, remove the others from allVRayLights		
			removeItemsFromArray allVRayLights instances verbose:false
		)
		
		if allVRayLights.count > 0 then 
		(
			-- These lights are unique and should be added to the list
			for l in allVRayLights do append ret l
		)
		
		ret
	)	
	
	fn GetArrayReturnProperty arr property = (
		for a in arr where (isProperty a property) collect (GetProperty a property)
	)	
	
	/*************************
	FUNCTION: 
	NAME: isRendererVRay
	PURPOSE: Checks to see what the current renderer is
	RETURNS: true/false
	**************************/	
	fn isRendererVRay = (
		currentRenderer = (classof renderers.current)
		if (matchPattern (renderers.current as string) pattern:"V_Ray_Adv*") then
			true
		else 
			false
	)
	
	/*************************
	FUNCTION: 
	NAME: getDependentsOfType
	PURPOSE: Takes an array (arr) of objects and finds the dependents of a certain type (type)
	RETURNS: array of dependents of the specified type
	**************************/	
	fn getDependentsOfType arr type = (
		local returnArray = #()
		for a in arr do (
			for d in (refs.dependents a) where (isKindOf d type) do (
				append returnArray d
			)
		)
		returnArray
	)
	
	/*************************
	FUNCTION: 
	NAME: isMaxVersion2011Plus
	PURPOSE: Function to detect if max version is at LEAST Max 2011
	RETURNS: true/false on success/failure
	**************************/
	fn isMaxVersion2011Plus = (
		if (maxVersion())[1] >= 13000 then true else false
	)
	
	/*************************
	FUNCTION: 
	NAME: addProblem
	PURPOSE: Function to add problems to the array aProblem
	RETURNS: true/false on success/failure
	**************************/
	fn addProblem theType theID theMessage objs: = (
		if (classof theType) == Name and (classof theID) == Name and (classof theMessage) == String then (
			local newProblem = s_Problem type:theType id:theID message:((theType as string) + ":: " + theMessage) objs:objs
			append aProblem newProblem
			true
		) else (
			print "TeagueSceneChecker:: Problem adding the structure"
			false
		)
	)
	
	/*************************
	FUNCTION: 
	NAME: clearProblem
	PURPOSE: Function to clear all problems
	RETURNS: void
	**************************/
	fn clearProblems = ( 
		aProblem = #()
	)
	
	/***************************************************************************************************************************/
	/*************************
	FUNCTION: 
	NAME: checkForProblems
	PURPOSE: Main function that goes through and checks for problems with the scene
	RETURNS: void 
	**************************/
	fn checkForProblems = (
		clearProblems()	-- Clear the problems array
		
		-- Variables
		local vrayMaterials = getClassInstances VRayMtl
		
		/********************************************************* INFO ********************************************************/
		-- This section is intended only for warnings that the user might want to be aware of
		
		/******************* Check for VRay ******************/
		if not(isRendererVRay()) then (
			addProblem #info #VRayRenderer "!!! V-Ray is NOT the current renderer"
			return false
		)
		
		/******************* Bitmap Pager ********************/
		if (IBitmapPager.enabled) then (
			addProblem #critical #BitmapPager "!!! Bitmap Pager is on, automatically turning it off..."
			addProblem #critical #BitmapPager2 "!!! You must re-open your scene for the bitmap pager to be disabled"
			IBitmapPager.enabled = false
		)
		
		/******************* VRayFur ************************/
		-- Warn if there is a VRayFur object in the scene
		local VRayFurObjects = getClassInstances VRayFur
		local VRayFurDeps = getDependentsOfType VRayFurObjects GeometryClass

		if VRayFurDeps.count != 0 then (
			addProblem #info #VRayFurInScene ("VRayFur Object is in your scene") objs:VRayFurDeps
		)
		
		/****************** VRayFastSSS (2) *****************/
		local VRayFastSSSMaterials = for m in sceneMaterials where ((classof m) == VRayFastSSS) or ((classof m) == VRayFastSSS2) collect m
		
		if VRayFastSSSMaterials.count != 0 then (
			addProblem #info #VRayFastSSSInScene ("VRayFastSSS material is in your scene") objs:VRayFastSSSMaterials
		)
		
		/***************** VRayCarPaint materials ************/
		local VRayCarPaintMtlMaterials = for m in sceneMaterials where ((classof m) == VRayCarPaintMtl) or ((classof m) == VRayFlakesMtl) collect m
		
		if VRayCarPaintMtlMaterials.count != 0 then (
			addProblem #info #VRayCarPaint ("VRayCarPaintMtl/FlakesMtl is in your scene") objs:VRayCarPaintMtlMaterials
		)
		
		/****************** Use Interpolation ****************/
		-- Warn if "Use Interpolation" is on for any VRay material
		local vrayMaterialWithUseInterpolationOn = for v in vrayMaterials where ((v.refraction_useInterpolation) or (v.reflection_useInterpolation)) collect v
		
		if vrayMaterialWithUseInterpolationOn.count > 0 then (
			addProblem #info #UseInterpolation ("\"Use Interpolation\" is on, turn it off when doing an animation") objs:vrayMaterialWithUseInterpolationOn
		)
		
		/******* VRayLightMaterial with Direct Light on *******/
		local vrayLightMaterialWithDirectLightOn = for m in sceneMaterials where ((classof m == VRayLightMtl) and (m.directLight_on)) collect m
		
		if vrayLightMaterialWithDirectLightOn.count > 0 then (
			addProblem #info #LightMaterialDirectLightOn ("VRayLightMtl found with \"Direct Illumination\" on") objs:vrayLightMaterialWithDirectLightOn
		)	
		
		/******************* Irradiance Map Primary **********/
		-- Warn if Irradiance Map is not the primary GI Engine
		if (renderers.current.gi_primary_type != 0) then
			addProblem #info #IMAPNotPrimary "Primary GI engine is not set to \"Irradiance Map\""
				
		/******************* Light Cache Secondary ***********/
		-- Warn if Light Cache is not the secondary GI Engine
		if (renderers.current.gi_secondary_type != 3) then
			addProblem #info #LCNotSecondary "Secondary GI engine is not set to \"Light Cache\""
		
		/********** Use Light Cache for Glossy Rays ***********/
		-- Warn if "Use Light Cache for glossy rays" is not on
		if (renderers.current.gi_secondary_type != 3) and (renderers.current.lightcache_useForGlossyRays == false) then
			addProblem #info #UseLCForGlossyRays "\"Use light cache for glossy rays\" is off in the scene"
		
		/*************** Dynamic Memory Limit low ***********/
		-- Warn if Dynamic Memory Limit is very low
		if (renderers.current.system_raycaster_memlimit != 0) and (renderers.current.system_raycaster_memlimit < 3000) then
			addProblem #info #DynamicMemoryLimitLow "\"Dynamic memory limit\" in the V-Ray:: System tab is set very low, up the value"
  				
		/*************** VRayDisplacementMod ***************/
		local VRayDisplacementMods = getClassInstances VRayDisplacementMod
		local VRayDisplacementModDeps = (getDependentsOfType VRayDisplacementMods GeometryClass)
		
		if VRayDisplacementModDeps.count > 0 then (
			addProblem #info #VRayDisplacementMod "VRayDisplacementMod (modifier) is on the following objects" objs:VRayDisplacementModDeps
		)
		
		/************* Displacement in Materials *************/
		local standardMaterials = getClassInstances Standardmaterial
		local materialsWithDisplacementOn = #()
		
		join standardMaterials vrayMaterials
		for m in standardMaterials do (
			if (classof m) == VRayMtl then (
				if (isProperty m #texmap_displacement_on) and (isProperty m #texmap_displacement) then (
					if (m.texmap_displacement_on) and (m.texmap_displacement != undefined) then
						append materialsWithDisplacementOn m
				)
			)
			
			if (classof m) == Standardmaterial then (
				if (isProperty m #displacementMapEnable) and (isProperty m #displacementMap) then (
					if (m.displacementMapEnable) and (m.displacementMap != undefined) then 
						append materialsWithDisplacementOn m
				)
			)
		)
		
		if materialsWithDisplacementOn.count > 0 then
			addProblem #info #MaterialDisplacement "Materials with displacement on found" objs:materialsWithDisplacementOn
		
		/*************** Filter maps are off ***********/
		-- Info if Map filtering is off
		if (renderers.current.options_filterMaps == false) or (renderers.current.options_mtl_filterMaps_indirect == false) then
			addProblem #info #filterMapsOff "\"Filter maps\" or \"Filter for GI\" are off in the V-Ray:: Global Switches tab"		
		
		/*************** Bitmap Filtering ***************/
		local bitmaps = getClassInstances BitmapTexture
		local bitmapsWithBadFiltering = #()
		local bitmapsWithLowBlur = for b in bitmaps where (isProperty b #coords) and (isProperty b.coords #blur) and (b.coords.blur < 0.25) collect b
		local bitmapsNotSetToPyramidalFiltering = for b in bitmaps where (isProperty b #filtering) and (b.filtering != 0) collect b
		
		join bitmapsWithBadFiltering bitmapsWithLowBlur
		join bitmapsWithBadFiltering bitmapsNotSetToPyramidalFiltering
		
		if bitmapsWithBadFiltering.count > 0 then (
			addProblem #info #BitmapFiltering "Bitmap Filtering \"blur\" is low or Non-Pyramidal on the following material(s)" objs:bitmapsWithBadFiltering
		)		
		
		/********************************************************* WARNINGS ********************************************************/
		
		/******************* LWF Gamma Check **************/
		if IDisplayGamma.colorCorrectionMode == #gamma then (
			if displayGamma == 2.2 then (
				if isRendererVRay() then (
					if renderers.current.colorMapping_gamma != 2.2 then
						addProblem #warn #LWFCheckGamma "Linear Workflow:: Color Mapping gamma not set to 2.2"
					if renderers.current.colorMapping_adaptationOnly == false then
						addProblem #warn #LWFCheckAdapation "Linear Workflow:: Don't affect colors (adaptation only) should be on"				
				)
			)
		)
		
		/******************* Architerual Material *************/
		local architecturalMaterials = GetClassInstances Architectural
		
		if architecturalMaterials.count != 0 then (
			addProblem #warn #ArchitecturalMaterial "Architectural material found in the scene" objs:architecturalMaterials
		)
		
		/******************* Autodesk Generic ***************/
		/* Version 1.02 -- Max 2009 does not have an Autodesk_Material */
		if isMaxVersion2011Plus() then (
			local autodeskGenericMaterial = GetClassInstances Autodesk_Material
			
			if autodeskGenericMaterial.count != 0 then (
				addProblem #warn #AutodeskMaterial "Autodesk_Generic material found in the scene" objs:autodeskGenericMaterial
			)
		)
		
		/******************* Detail Enhancement *************/
		if (renderers.current.gi_primary_type == 0) and (renderers.current.gi_irradmap_detail_on) then 
			addProblem #warn #DetailEnhancementOn "Detail Enhancement is on in the Irradiance map settings"
		
		/************ Material Reflection Subdivs > 32 ********/
		local vrayMaterialsHighReflSubdivs = for m in VRayMaterials where (m.reflection_subdivs > 32)  collect m
		
		if vrayMaterialsHighReflSubdivs.count > 0 then (
			addProblem #info #reflectionSubdivsHigh ("VRay material(s) with > 32 Reflection subdivs found") objs:vrayMaterialsHighReflSubdivs
		)
		
		/************ Material Refraction Subdivs > 32 ********/
		local vrayMaterialsHighRefrSubdivs = for m in VRayMaterials where (m.refraction_subdivs > 32)  collect m
		
		if vrayMaterialsHighRefrSubdivs.count > 0 then (
			addProblem #info #refractionSubdivsHigh ("VRay material(s) with > 32 Refraction subdivs found") objs:vrayMaterialsHighRefrSubdivs
		)		
		
		/********************* Light Subdivs > 32 *************/
		--local vrayLights = for l in lights where (((classof l) == VRayLight) or ((classof l) == VRayIES) or ((classof l) == VRaySun)) collect l
		local vrayLights = #()
		join vrayLights (GetIndividualInstances lights VRayLight)
		join vrayLights (GetIndividualInstances lights VRayIES)
		join vrayLights (GetIndividualInstances lights VRaySun)
		
		local foundLights = #()
		local found = false
		for l in vrayLights do (
			if ((classof l) == VRayLight) and (l.subdivs > 32) then (
				found = true
				append foundLights l
			) else if ((classof l) == VRayIES) and (l.shape_subdivs > 32) then (
				found = true
				append foundLights l
			) else if ((classof l) == VRaySun) and (l.shadow_subdivs > 32) then (
				found = true
				append foundLights l
			)
		)
		if found then
			addProblem #info #VRayLightSubdivsHigh ("VRay Light with > 32 Subdivisions found") objs:foundLights
		
		
		/****************************************************** CRITICAL ERRORS *****************************************************/
		-- This section is intended only for show-stopping problems or huge increases in render time due to errors
		
		/****** Standard Light with unsupported Shadow Type ********/
		local standardLights = for l in lights where (((classof l) == targetSpot) or ((classof l) == freeSpot) or ((classof l) == DirectionalLight) or ((classof l) == TargetDirectionalLight) or ((classof l) == omniLight)) collect l
		local found = false
		local foundLights = #()
		for l in standardLights do (
			-- Parse the shadow type
			if ((classof l.shadowGenerator) != VRayShadow) and ((classof l.shadowGenerator) != VRayShadowMap) then (
				found = true
				append foundLights l
			)			
		)
		if found then (
			addProblem #warn #UnsupportedShadowType ("A Standard light with an unsupported Shadow found") objs:foundLights
		)
		
		/************** Use Irrad Map unchecked *************/
		local vrayMtlUseIrradMapOff = for m in VRayMaterials where (m.option_useIrradMap == false) collect m
		
		if vrayMtlUseIrradMapOff.count > 0 then (
			addProblem #warn #useIrradMapOff ("\"Use Irradiance Map\" unchecked on VRayMtl (object will be brute forced)") objs:vrayMtlUseIrradMapOff
		)		
		
		/****************** Raytrace Map ********************/
		local raytraceMaps = getClassInstances Raytrace
		local raytraceMapsDeps = getDependentsOfType raytraceMaps material
		if raytraceMapsDeps.count > 0 then (
			addProblem #critical #RaytraceMap ("Raytrace map exists in the follow materials ") objs:raytraceMapsDeps
		)
		
		/****************** MR Lights ***********************/
		local mrLights = for l in lights where ((classof l) == miAreaLightomni) or ((classof l) == miAreaLight) collect l
		if mrLights.count > 0 then (
			addProblem #critical #mrLights ("Unsupported Mental Ray Lights") objs:mrLights
		)
	)
	
	/************************************************************************
										ROLLOUTS
	************************************************************************/
	
	rollout rlt_TeagueSceneChecker (scriptName+" "+(versionNum as string)) (
		imgTag img_banner tooltip:"Teague.com" height:91 width:540
		listbox lst_problems "" height:15 width:540
		button btn_scanForProblems "Scan for Problems"
		--button btn_printProblemArray "Print Problem Array"
		
		fn updateProblemsList = (
			if aProblem.count > 0 then (		-- There are problems in the scene
				local tempItems = #()
				
				for i = 1 to aProblem.count do	-- Go through all the problems array (aProblem)
					append tempItems aProblem[i].message
				
				lst_problems.items = tempItems
			) else (		-- No problems found
				lst_problems.items = #("No problems found")
				rlt_sceneCheckerObjects.lst_objects.items = #()
			)
		)
		
		on lst_problems selected val do (
			local tempItems = #()
			if (aProblem.count > 0) then (
				if (aProblem[val].objs) != unsupplied then (
					for o in aProblem[val].objs do (
						-- Adding a special case for vray materials / lights to catch their subdivs value and put it in the window
						-- This should be redone and allow you to specify how the items are listed with another option param, but alas, no time at the moment
						if (aProblem[val].id == #reflectionSubdivsHigh) then (
							if (isProperty o #reflection_subdivs) then append tempItems ("[" + ((getProperty o #reflection_subdivs) as string) + "] " + o.name) else append tempItems o.name
						
						) else if (aProblem[val].id == #refractionSubdivsHigh) then (
							if (isProperty o #refraction_subdivs) then append tempItems ("[" + ((getProperty o #refraction_subdivs) as string) + "] " + o.name) else append tempItems o.name
						
						) else if (aProblem[val].id == #VRayLightSubdivsHigh) then (
							local subdivsPropertyName = case (classof o) of (
								VRayLight: #subdivs
								VRayIES: #shape_subdivs
								VRaySun: #shadow_subdivs
								default: #none
							)
							
							if subdivsPropertyName != #none then
								append tempItems ("[" + ((getProperty o subdivsPropertyName) as string) + "] " + o.name) 
							else 
								append tempItems o.name
						
						) else (
							/* DEFAULT WAY TO NAME THE ITEMS IN THE LIST */
							append tempItems o.name
						)
					)
					rlt_sceneCheckerObjects.lst_objects.items = tempItems
				) else (
					rlt_sceneCheckerObjects.lst_objects.items = #()
				)
			)
		)		
		
		on btn_printProblemArray pressed do (
			print aProblem
		)
		
		on btn_scanForProblems pressed do (
			checkForProblems()
			updateProblemsList()
		)
		
		on rlt_TeagueSceneChecker open do (
			-- Setup the Image Banner
			teagueBanner = openBitmap bannerBitmapLocation
			img_banner.bitmap = teagueBanner
			
			global mainRolloutPosition = GetDialogPos rlt_TeagueSceneChecker
			global mainRolloutSize = GetDialogSize rlt_TeagueSceneChecker
			createDialog rlt_sceneCheckerObjects 210 mainRolloutSize[2] pos:[mainRolloutPosition.x+mainRolloutSize[1]+4, mainRolloutPosition.y]
			
			checkForProblems()
			updateProblemsList()
		)
		
		on rlt_TeagueSceneChecker close do (
			try ( destroyDialog rlt_sceneCheckerObjects ) catch()
		)
		
		on rlt_TeagueSceneChecker moved xy do (
			SetDialogPos rlt_sceneCheckerObjects [xy.x+mainRolloutSize[1]+4, xy.y]
		)
		
		on img_banner click do (
			-- Goto the Teague website
			if (queryBox "Would you like to visit the teague website?" title:"Teague.com" beep:false) == true then 
				ShellLaunch "http://www.teague.com" ""
		)
	)
	
	rollout rlt_sceneCheckerObjects "Objects/Materials" (
		label lbl_one "Double-Click on an item to select"
		multilistbox lst_objects "" height:21 offset:[0,-3]
		button btn_selectAll "All" width:55 offset:[-63,0] height:18
		button btn_selectNone "None" width:55 offset:[0,-23] height:18
		button btn_selectInvert "Invert" width:55 offset:[63,-23] height:18
		button btn_select "SELECT" width:186 height:25
		
		on lst_objects doubleClicked val do (
			local currentSelectedObj = aProblem[rlt_TeagueSceneChecker.lst_problems.selection].objs[val]
			local theObjs = aProblem[rlt_TeagueSceneChecker.lst_problems.selection].objs
			
			if (isKindOf currentSelectedObj GeometryClass) or (isKindOf currentSelectedObj Light) then (
				clearSelection()
				try (
					select currentSelectedObj	-- Select the object
				) catch ()
			) else if (isKindOf currentSelectedObj Material) then (
				try (	macros.run "Medit Tools" "clear_medit_slots"	) catch ( print "TeagueSceneChecker:: Could not clear the material editor" )
				
				if MatEditor.isOpen() == false then (
					MatEditor.Open()
				)
				
				medit.PutMtlToMtlEditor currentSelectedObj 1	
			)
			
		)
		
		on btn_select pressed do (
			local theBitArray = lst_objects.selection as array
			local currentSelectedObj = #()
			
			for b in theBitArray do (
				append currentSelectedObj aProblem[rlt_TeagueSceneChecker.lst_problems.selection].objs[b]
			)
			
			if (isKindOf currentSelectedObj[1] GeometryClass) or (isKindOf currentSelectedObj[1] Light) then (
				clearSelection()
				try (
					select currentSelectedObj	-- Select the object
				) catch ()
			) else if (isKindOf currentSelectedObj[1] Material) then (
				try (	macros.run "Medit Tools" "clear_medit_slots"	) catch ( print "TeagueSceneChecker:: Could not clear the material editor" )
				
				if MatEditor.isOpen() == false then (
					MatEditor.Open()
				)
				
				for i = 1 to 24 do (
					try (
						medit.PutMtlToMtlEditor currentSelectedObj[i] i		
					) catch ()
				)
			)
			
		)
		
		on btn_selectNone pressed do (
			lst_objects.selection = #{}
		)
		
		on btn_selectInvert pressed do (
			lst_objects.selection = -lst_objects.selection
		)
		
		on btn_selectAll pressed do (
			lst_objects.selection = #{1..(lst_objects.items.count)}
		)
			
		on rlt_sceneCheckerObjects close do (
			try ( destroyDialog rlt_TeagueSceneChecker ) catch()
		)
	)
	
	createDialog rlt_TeagueSceneChecker 563 360
)	
