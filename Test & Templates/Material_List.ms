/**************************************************************************************
Author: 		Dave Szybala
Date: 			11/19/2009
Program: 		Material_List
Description: 	This script will give the user access to special material functions.
***************************************************************************************/

try (destroyDialog matListRollout) catch()

(--put script into local scope
	global matListRollout
	local rootMaterials = #()
	local allMaterials = #()
	local allMaterialNames = #()
	local matListIniFile = getDir #plugcfg + "\\MaterialList.ini"
	local matListRolloutPos
	
	/***************************************************************************************/
	fn Sort_By_Name elementOne elementTwo =
	(
		case of
		(
			(elementOne.name < elementTwo.name): -1
			(elementOne.name > elementTwo.name): 1
			default: 0
		)--end case
	)--end fn
	
	/***************************************************************************************/
	fn Get_Sub_Materials currentMat offsetValue =
	(
		local nameOffset = ""
		local currentSubMat = undefined
		
		for x = 1 to (getNumSubMtls currentMat) do
		(
			currentSubMat = getSubMtl currentMat x
			
			if currentSubMat != undefined do
			(
				append allMaterials currentSubMat
				for y = 1 to offsetValue do nameOffset += "   "
				allMaterialNames[allMaterialNames.count + 1] = (nameOffset + currentSubMat.name)
				nameOffset = ""
				if (getNumSubMtls currentSubMat) > 0 do Get_Sub_Materials currentSubMat (offsetValue + 1)
			)--end if
		)--end for
	)--end fn
	
	/***************************************************************************************/
	fn Get_Materials =
	(
		rootMaterials = #() --clear previous materials
		allMaterials = #() --clear previous materials
		allMaterialNames = #() --clear previous names
		
		for currentMat in sceneMaterials do
		if (superClassOf currentMat) == material do append rootMaterials currentMat
	
		qsort rootMaterials Sort_By_Name
		
		for currentMat in rootMaterials do
		(
			append allMaterials currentMat
			append allMaterialNames currentMat.name
		
			if matListRollout.subMatChk.checked do
			(
				if (getNumSubMtls currentMat) > 0 do Get_Sub_Materials currentMat 1
			)--end if
		)--end for
	)--end fn
	
	/***************************************************************************************/
	fn Refresh_List =
	(
		local theState = false
		local counter = 0
		
		if (matListRollout.forceUpdateChk.checked) do
		(
			saveNodes #() (GetDir #scene + "\\_Temp.max") quiet:true --needed to force max to update internal variable
			deleteFile (GetDir #scene + "\\_Temp.max") --needed to force max to update internal variable
		)--end if
		
		Get_Materials()
		
		for currentName in allMaterialNames do
			if currentName[1] != " " do counter += 1
		matListRollout.totalLabel.text = ("Total: " + (counter as string))
		
		matListRollout.matNameList.items = allMaterialNames
		
		if allMaterials.count > 0 do theState = true
		matListRollout.showMaterialBtn.enabled = matListRollout.slotNumberSpn.enabled = matListRollout.populateEditorBtn.enabled = \
		matListRollout.selectObjBtn.enabled = matListRollout.selectAddChk.enabled = \
		matListRollout.assignMatBtn.enabled = matListRollout.matIDBtn.enabled = matListRollout.matIDSpn.enabled = \
		matListRollout.duplicateBtn.enabled = theState
	)--end fn
	
	/***************************************************************************************/
	fn Get_Root_Indices =
	(
		local currentSelection = matListRollout.matNameList.selection as array
		local returnIndices = #(0)
		local index = 0
			
		if currentSelection.count >= 1 do
		(
			for i = 1 to currentSelection.count do
			(
				index = currentSelection[i]
				while allMaterialNames[index][1] == " " do index -= 1
				currentSelection[i] = index
			)--end for
			
			returnIndices = makeUniqueArray currentSelection
		)--end if
		
		returnIndices --return value
	)--end fn

	/***************************************************************************************/
	rollout matListRollout "Material List"
	(
		label totalLabel "Total: 0" pos:[5,5] width:100 height:15
		button updateListBtn "Update" pos:[195,3] width:50 height:15
		MultiListBox matNameList "" pos:[5,20] width:240 height:18
		
		checkBox subMatChk "Show All Sub Materials" pos:[5,265] width:135 height:15
		checkBox forceUpdateChk "Force Max Material Update" pos:[5,285] width:155 height:15
		
		groupBox editorGrp "Material Editor" pos:[5,305] width:240 height:95
			button showMaterialBtn "Show in Slot" pos:[15,325] width:170 height:20
			spinner slotNumberSpn "#" pos:[198,327] width:37 height:16 range:[1,24,1] type:#integer scale:1
			button populateEditorBtn "Populate" pos:[15,350] width:125 height:20
			checkbox rootOnlyChk "Root Only" pos:[155,352] width:65 height:15 checked:true enabled:false
			button clearEditorBtn "Clear" pos:[15,375] width:125 height:20
			checkbox defaultMatChk "Default Mats" pos:[155,377] width:80 height:15 checked:true
			
		groupBox miscGrp "Misc" pos:[5,405] width:240 height:145
			button selectObjBtn "Select Objects" pos:[15,425] width:105 height:20
			checkbox selectAddChk "Add to Selection" pos:[135,427] width:95 height:15
			button assignMatBtn "Assign Material to Selected" pos:[15,450] width:220 height:20
			button matIDBtn "Assign Material ID" pos:[15,475] width:170 height:20
			spinner matIDSpn "#" pos:[198,477] width:37 height:16 range:[0,15,1] type:#integer scale:1
			button duplicateBtn "Remove Duplicate Materials" pos:[15,500] width:220 height:20
			button matsOfSelectedBtn "Show Materials of Selected" pos:[15,525] width:220 height:20
			
		label progLbl "Standing by..." pos:[5,555] width:240 height:15
			
		-------------------------------------------------------------------
		on matListRollout open do
		(
			progLbl.text = "Updating material list..."
			Refresh_List()
			progLbl.text = "Standing by..."
		)--end on
		
		-------------------------------------------------------------------
		on matListRollout moved pos do
			setIniSetting matListIniFile "Dialog" "Position" (pos as string)
		
		-------------------------------------------------------------------
		on updateListBtn pressed do
		(
			progLbl.text = "Updating material list..."
			Refresh_List()
			progLbl.text = "Material list has been updated."
		)--end on
		
		-------------------------------------------------------------------
		on subMatChk changed theState do
		(
			progLbl.text = "Updating material list..."
			Refresh_List()
			if not(theState) do matListRollout.rootOnlyChk.checked = true
			matListRollout.rootOnlyChk.enabled = theState
			progLbl.text = "Standing by..."
		)--end on
		
		-------------------------------------------------------------------
		on showMaterialBtn pressed do
		(
			local currentSelection = matNameList.selection as array
			local currentSlot = slotNumberSpn.value
			
			for i = 1 to currentSelection.count do
			(
				setMeditMaterial currentSlot allMaterials[currentSelection[i]]
				if currentSlot < 24 then currentSlot += 1
				else currentSlot = 1
			)--end for
			
			if MatEditor.isOpen() != true do MatEditor.Open() --open material editor
		)--end on
		
		-------------------------------------------------------------------
		on populateEditorBtn pressed do
		(
			local userSelection = #()
			local counter = 0
			local index = 1
			local currentSlot = 1
			
			if rootOnlyChk.checked then
			(
				userSelection = Get_Root_Indices()
				
				if userSelection[1] > 0 then
					index = userSelection[1]
				else
					index = 1
				
				while index > 0 do
				(
					if allMaterialNames[index][1] != " " do counter += 1
					index -= 1
				)--end while
				
				index = counter
				
				while currentSlot < 25 do
				(
					setMeditMaterial currentSlot rootMaterials[index]
					index += 1
					currentSlot += 1
					if index > rootMaterials.count do currentSlot = 25
					if currentSlot > rootMaterials.count do currentSlot = 25
				)--end while
			)--end if
			else
			(
				userSelection = matNameList.selection as array
				if userSelection.count > 0 do index = userSelection[1]
				
				while currentSlot < 25 do
				(
					setMeditMaterial currentSlot allMaterials[index]
					index += 1
					if index > allMaterials.count do index = 1
					currentSlot += 1
					if currentSlot > allMaterials.count do currentSlot = 25
				)--end while
			)--end else
			
			if MatEditor.isOpen() != true do MatEditor.Open() --open material editor
		)--end on
		
		-------------------------------------------------------------------
		on clearEditorBtn pressed do
		(
			local currentRenderer = ((classOf renderers.production) as string)
			if defaultMatChk.checked do currentRenderer = "1"
			
			case of
			(
				(matchPattern currentRenderer pattern:"mental*"):for i = 1 to 24 do meditmaterials[i] = Arch___Design__mi()
				(matchPattern currentRenderer pattern:"Brazil*"):for i = 1 to 24 do meditmaterials[i] = Brazil2_Advanced_Material()
				(matchPattern currentRenderer pattern:"V_Ray*"):for i = 1 to 24 do meditmaterials[i] = VRayMtl()
				(matchPattern currentRenderer pattern:"finalRender*"):for i = 1 to 24 do meditmaterials[i] = fR_Advanced()
				default:for i = 1 to 24 do meditmaterials[i] = StandardMaterial()
			)--end case
			
			for i = 1 to 24 do
			(
				if i < 10 then meditmaterials[i].name = ("0" + (i as string) + " - Default")
				else meditmaterials[i].name = ((i as string) + " - Default")
			)--end for
		)--end on
			
		-------------------------------------------------------------------
		on selectObjBtn pressed do
		(
			local rootSelection = Get_Root_Indices()
			local foundObjects = #()
			--setListenerSel #(-1,-1)
			
			if rootSelection[1] != 0 then
			(
				clearSelection()
				
				for current in objects do
				(
					for i = 1 to rootSelection.count do
						if current.material == allMaterials[rootSelection[i]] do append foundObjects current
				)--end for
				
				if selectAddChk.checked then
				(
					selectMore foundObjects
					progLbl.text = ((foundObjects.count as string) + " object(s) found. " + (selection.count as string) + " total selected.")
				)--end if
				else
				(
					select foundObjects
					progLbl.text = ((foundObjects.count as string) + " object(s) selected.")
				)--end else
			)--end if
			else
				progLbl.text = "ERROR: No material selected."
		)--end on
		
		-------------------------------------------------------------------
		on assignMatBtn pressed do
		(
			local rootSelection = Get_Root_Indices()
			--setListenerSel #(-1,-1)
			
			if rootSelection.count == 1 then
			(
				if rootSelection[1] != 0 then
				(
					for current in selection do current.material = allMaterials[rootSelection[1]]
					progLbl.text = (allMaterialNames[rootSelection[1]] + " has been assigned.")
				)--end if
				else
					progLbl.text = "ERROR: No material selected."
			)--end if
			else
				progLbl.text = "ERROR: More than 1 material selected."
		)--end on
		
		-------------------------------------------------------------------
		on matIDBtn pressed do
		(
			local currentSelection = matNameList.selection as array
			--setListenerSel #(-1,-1)
			
			if currentSelection.count > 0 then
			(
				for i = 1 to currentSelection.count do
				(
					allMaterials[currentSelection[i]].effectsChannel = matIDSpn.value
				)--end for
				
				progLbl.text = ("Material ID " + (matIDSpn.value as string) + " has been assigned.")
			)--end if
			else
				progLbl.text = "ERROR: No material selected." 
		)--end on
		
		-------------------------------------------------------------------
		on duplicateBtn pressed do
		(
			local duplicateFound = false
			local replacedMaterial = #()
			local rootNames = #()
			
			for currentMat in rootMaterials do append rootNames currentMat.name
			
			for i = 1 to rootNames.count - 1 do
			(
				if (findItem replacedMaterial rootNames[i]) == 0 do
				(
					for x = i + 1 to rootNames.count do
					(
						if rootNames[i] == rootNames[x] do
						(
							duplicateFound = true
							append replacedMaterial rootNames[i]
						)--end if
					)--end for
					
					if duplicateFound do
					(
						for current in geometry do
						(
							if current.material != undefined do
							(
								if current.material.name == rootNames[i] do current.material = rootMaterials[i]
							)--end if
						)--end for
					)--end if
					
					duplicateFound = false
				)--end if
			)--end for
			
			progLbl.text = "Updating material list..."
			Refresh_List()
			--messagebox "Duplicates removed. In order to correctly refresh the\nmaterial list you must apply a material to an object\nusing the material editor, and then use the update button\non the material list rollout." title:"Duplicates Removed"
			progLbl.text = "Duplicates removed."
		)--end on
		
		-------------------------------------------------------------------
		on matsOfSelectedBtn pressed do
		(
			local currentMaterials = #()
			local counter = 0
			--setListenerSel #(-1,-1)
			
			if selection.count > 0  then
			(
				for current in selection do
				(
					if current.material != undefined do
						appendifunique currentMaterials current.material
				)--end for
				
				if currentMaterials.count > 0 then
				(
					counter = currentMaterials.count
					
					if counter > 24 do counter = 24
					 
					for i = 1 to counter do
						setMeditMaterial i currentMaterials[i]
						
					if MatEditor.isOpen() != true do MatEditor.Open() --open material editor
				)--end if
				else
					progLbl.text = "ERROR: Selected objects do not have materials."
			)--end if
			else
				progLbl.text = "ERROR: No objects are selected."
		)--end on
	)--end rollout
	matListRolloutPos = execute (getIniSetting matListIniFile "Dialog" "Position")
	if matListRolloutPos == OK do matListRolloutPos = [100,100]
	if matListRolloutPos.x > sysinfo.desktopsize.x - 250 do matListRolloutPos.x = sysinfo.desktopsize.x - 255
	if matListRolloutPos.y > sysinfo.desktopsize.y - 635 do matListRolloutPos.y = sysinfo.desktopsize.y - 635
	if matListRolloutPos.x < 0 do matListRolloutPos.x = 0
	if matListRolloutPos.y < 0 do matListRolloutPos.y = 0
	createDialog matListRollout 250 575 matListRolloutPos.x matListRolloutPos.y style:#(#style_titlebar, #style_minimizebox, #style_border, #style_sysmenu)
)--end local scope