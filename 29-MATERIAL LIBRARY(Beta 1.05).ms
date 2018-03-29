/*HeaderStart*******************************************************
:Created By:			Rodri Garcia
:Email:				info@rgarcia-digitaldesign.com
:Purpose:				Material manager

:History:
	V:0.00.01A 
		Getting started. 
:Todo:
	-import modifier max file on apply material__DONE
	-change name on max file after rename __ DONE

:Bugs:
:Tests:
*******************************************************HeaderEnd*/
clearlistener()

if doesfileexist (@"D:\TestMSG.ms") then
(deletefile (@"D:\TestMSG.ms"))
	
if doesfileexist (@"D:\TestMSG_cm.ms") then
(deletefile (@"D:\TestMSG_cm.ms"))	

copyfile (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TestMSG.ms") (@"D:\TestMSG.ms")
copyfile (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TestMSG_cm.ms") (@"D:\TestMSG_cm.ms")
ScriptLauncherPath = systemTools.getEnvVariable("USERPROFILE") + "\AppData\Local\Autodesk\3dsMax\TestMSG.ms"
-- LibsFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\*.mat") -- Get Library Files (.mat)
LibsFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\*.mat")
LibFilesName= #()
for i=1 to LibsFiles.count do
	(
		LibFilesName[i] = (filterstring LibsFiles[i] @"\")[7]
		)-- Output Clean Names for material Libraries Files
		
LibFilesUI= #()
for i=1 to LibFilesName.count do
	(
		LibFilesUI[i] = (trimright LibFilesName[i] ".mat")
		)-- Output Clean Names for material Libraries Files (Remove the ".mat" form name)

MatPath = @""
global Mat2Apply = #()

try(destroydialog MatPresets)catch()
	rollout MatPresets "Materials Presets"
	(
		Listbox LibList "Library" Items:LibFilesUI width:200
		listbox MatList "Materials" width:200 height:18
		Button ApplyMat "Apply Material" pos:[10,425] width:200 height:50
		button GatherMat "Gather Material" pos:[10,475] width:200 height:50
		button SaveMat "Save Material" pos:[10,525] width:200 height:50
		
		button AddUVW "Add UVW" pos:[10,595] width:200 height:50
		checkbox Scalemap "Real-World Map Size" pos:[10,655] --width:150 height:50
		
		button PreviewGen "Generate Preview" pos:[10,930] width:200 height:50
		button DelMat "Delete Material" pos:[10,980] width:200 height:50
		bitmap MatThumb pos:[220,10] width:1024 height:1024
		bitmap DiffText "" pos:[35,675]  width:150 height:150
-- 		button DiffText "" pos:[10,575]  width:150 height:150 image:#(undefined, undefined, 1,1,1,1,1)

		EditText W "" pos:[10,835] width:200 readOnly:True
		EditText H "" pos:[10,855] width:200 readOnly:True
		
		
		
		EditText Rename "Rename Mat" pos:[10,885] width:200 toolTip:"Press ENTER After renaming to take effect"
		EditText SearchMat "Search" width:200 toolTip:"Type for search to start" pos:[10,905]
		
		
		

		

		
		on AddUVW pressed do
			(
				UVWMod = UVWMap()
				for i in selection do
				(
						
						addmodifier i UVWMod
				if Scalemap.state then
					(
						i.modifiers[#UVW_Map].realWorldMapSize = true
						i.modifiers[#UVW_Map].maptype = 4
					)
				else
					(
						i.modifiers[#UVW_Map].realWorldMapSize = False
						i.modifiers[#UVW_Map].maptype = 4
						i.modifiers[#UVW_Map].height = 2000
						i.modifiers[#UVW_Map].length = 2000
						i.modifiers[#UVW_Map].width = 2000
						
						)
					)
				
				)
		
		on LibList selected P do
			(try(
				global CatSel = LibList.selected
				Global MatPath = LibsFiles[LibList.selection]
				
				Global LibLoad = loadTempMaterialLibrary MatPath
				Global MatLib = #()
				
				
				for i =1 to LibLoad.count do
				(Mat2Apply[i] = LibLoad[i])
				
				for i =1 to LibLoad.count do
				(MatLib[i] = LibLoad[i] as string)
				Global MatLibUI = #()
				for i = 1 to MatLib.count do
					(
-- 						MatLibUI[i] = (filterstring MatLib[i] ":")[1] --Old Method to display Name
						MatLibUI[i] = Mat2Apply[i].name
								
					)
				MatList.Items = MatLibUI
-- 				MatList.height = MatLibUI.count*20
-- 				createdialog MatDisplay --width: height:
					if MatLibUI.count != 0 then(
				BTFilename = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\" + MatList.selected + ".mat" + ".jpg")	
				MatThumb.filename = BTFilename
				global TabName = MatList.selected 
				
						
						
						/*
		--Make a destination bitmap:
		theNewMap = bitmap 128 128 
		--Copy original map into it:
		copy theOldMap theNewMap
		--If you display it, it will be a resized version:
		display theNewMap
		*/		try(
					TextBitmap = getSubTexmap Mat2Apply[MatList.selection].material.texmap_diffuse 1
-- 					TextBitmap = Mat2Apply[MatList.selection].texmap_diffuse.bitmap
					theNewMap = bitmap 150 150
					theNewMap.filename = Mat2Apply[MatList.selection].texmap_diffuse.filename
					copy TextBitmap theNewMap
					DiffText.bitmap = theNewMap					
-- 					DiffText.image = #(theNewMap.filename, undefined, 1,1,1,1,1)

			
					tex = Mat2Apply[MatList.selection].texmap_diffuse.filename
					bmpTex = openBitmap theNewMap.filename	
					format "Width:% Height:%\n" bmpTex.width bmpTex.height
					W.text  = (bmpTex.width as string)  -- bmpTex.height
					H.text  = (bmpTex.Height as string) 
					)catch()	

					))catch()
				)
		
		on MatList selected A do
			(
				BTFilename = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\" + MatList.selected + ".mat" + ".jpg")
				if  doesfileexist BTFilename == false then
					(
						BTFilename = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\HTLibrary\NoPreview_Logo.jpg"
						)
				MatThumb.filename = BTFilename
				print BTFilename
				try(
					TextBitmap = Mat2Apply[MatList.selection].texmap_diffuse.bitmap
					theNewMap = bitmap 150 150
					theNewMap.filename = Mat2Apply[MatList.selection].texmap_diffuse.filename
					copy TextBitmap theNewMap
					DiffText.bitmap = theNewMap
					
					tex = Mat2Apply[MatList.selection].texmap_diffuse.filename
					bmpTex = openBitmap theNewMap.filename	
					format "Width:% Height:%\n" bmpTex.width bmpTex.height
					W.text  = (bmpTex.width as string)  -- bmpTex.height
					H.text  = (bmpTex.Height as string) 
					
					
-- 			TESTING = Mat2Apply[MatList.selection]
-- 					print TESTING
			
					)catch()
				)
		
		on ApplyMat pressed do
			(
			
			CurSel = (selection as array)
				if doesfileexist (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\"  + MatList.selected + ".max") then
				(
			mergeMAXFile (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\"  + MatList.selected + ".max") #select #mergeDups #useSceneMtlDups quiet:true
			ModHolder = $
				
			SourceMods = ModHolder.modifiers
			
			
				
			for i in CurSel do
			(
				SelectedMat = Mat2Apply[MatList.selection]
				print SelectedMat
				if i == undefined then (messagebox "Select Object first")
				else(
					i.material = SelectedMat
						if ModHolder.modifiers.count != 0 then
						(				TargetUVW = i.modifiers[#UVW_Map]
										try(deletemodifier i TargetUVW)catch()
										TargetDISPL = i.modifiers[#VRayDisplacementMod]
										try(deletemodifier i TargetDISPL)catch()
							
							for a in SourceMods.count to 1 by -1 do
								(
									if classof SourceMods[a] == Uvwmap or classof SourceMods[a] == VRayDisplacementMod do( 
										addmodifier i SourceMods[a])
								)

						)
					)
				)
				delete ModHolder)else(
											for i in CurSel do
												(
												SelectedMat = Mat2Apply[MatList.selection]
												print SelectedMat
												if i == undefined then (messagebox "Select Object first")
												else(
												i.material = SelectedMat)))
			)
		on GatherMat pressed do
			(
				try(
				TabName = (Mat2Apply[MatList.selection] as string + Random 0 100 as string)
				global NewView = sme.GetView(sme.CreateView TabName)
				NewView.CreateNode Mat2Apply[MatList.selection] [0,0]
				)Catch()
				
				)
		on SaveMat pressed do
			(
				
				TempMaxFile = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TempMaxFile.max" 

				if $ != undefined and ((selection as array).count == 1) then
				(	

				obj_copy = copy $
				obj_copy.name = "MatHolder"
				select obj_copy

				saveNodes $ TempMaxFile quiet:true
				
				SelLib = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibFilesName[LibList.selection]
-- 				SelLib = LibFilesName[LibList.selection]
				loadMaterialLibrary SelLib	
				append currentMaterialLibrary (obj_copy.material)
-- 				Print  ("MatName = " + currentMaterialLibrary[MatList.selection])
				saveMaterialLibrary SelLib
					
				obj_copy.name = obj_copy.material.name
				
				ModMaxFile = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\"  + obj_copy.name + ".max" 
					
				saveNodes obj_copy ModMaxFile quiet:true	
				
				Delete obj_copy
					
				Category = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Category.ms"

				if doesfileexist Category == false then 
				(cf = createfile Category
					flush
					close cf
				)
				if doesfileexist Category then
				(
				fs = (openFile Category mode:"w")
				format "%\n" CatSel to:fs
				close fs	
				)	
-- 							
				if querybox "Create Preview NOW?" beep:true then
				(
					if units.SystemType == #millimeters then
					(
				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  D:\TestMSG.ms"
					)
					if units.SystemType == #centimeters then
					(
				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  D:\TestMSG_cm.ms"
					)
						
						
						
-- 				DOSCommand "3dsmax.exe -mip -q -silent -u MAXScript  C:\Users\Rodri.Garcia\Desktop\TestMSG.ms" 
-- 				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  c:\Users\Rodri.Garcia\Desktop\TestMSG.ms"
-- 				DOSCommand ("\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript   ScriptLauncherPath")
				)

				

			)
			)
		on PreviewGen pressed do
			(
				
				TempMaxFile = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TempMaxFile.max" 

				
					

				obj_copy = Box lengthsegs:1 widthsegs:1 heightsegs:1 length:70.6217 width:50.1747 height:31.7971 mapcoords:on pos:[-2.37643,-13.7645,0] isSelected:on
				obj_copy.name = "MatHolder"
				select obj_copy
				SelectedMat = Mat2Apply[MatList.selection]
				obj_copy.material = SelectedMat

				saveNodes $ TempMaxFile quiet:true
				
				
				Delete obj_copy
					
				Category = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\Category.ms"

				if doesfileexist Category == false then 
				(cf = createfile Category
					flush
					close cf
				)
				if doesfileexist Category then
				(
				fs = (openFile Category mode:"w")
				format "%\n" CatSel to:fs
				close fs	
				)	
				
-- 				DOSCommand "3dsmax.exe -mip -q -silent -u MAXScript  C:\Users\Rodri.Garcia\Desktop\TestMSG.ms"  -- WORKS
-- 				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  c:\Users\Rodri.Garcia\Desktop\TestMSG.ms" -- WORKS
-- 				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  c:\Users\Rodri.Garcia\AppData\Local\Autodesk\3dsMax\TestMSG.ms" -- WORKS
				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  D:\TestMSG.ms"
				
-- 				DOSCommand "\"c:/Program Files/Autodesk/3ds Max 2014/3dsmax.exe\" -mip -q -silent -u MAXScript  \\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\TestMSG.ms"

		
			)	

		on Rename entered P do
			(
				try(
				SelLib = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibFilesName[LibList.selection]
				loadMaterialLibrary SelLib	
				currentMaterialLibrary[MatList.selection].name = P
				print currentMaterialLibrary[MatList.selection]
				saveMaterialLibrary SelLib
-- 				
				BTFilename = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\" + MatList.selected + ".mat" + ".jpg")	
				NewBTFilename = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\" + P + ".mat" + ".jpg")
				
				ModMaxFile = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\"  + MatList.selected + ".max")
				NewModMaxFile = (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibList.selected + @"\"  + P + ".max")	
					
				
				renameFile BTFilename NewBTFilename
				renameFile ModMaxFile NewModMaxFile	
-- 				print BTFilename	
					
					
					
					
				)catch()

				
				
				
				)

				
		on DelMat pressed do
			(
				
				  
				SelLib = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\" + LibFilesName[LibList.selection]
-- 				SelLib = LibFilesName[LibList.selection]
				loadMaterialLibrary SelLib	
				deleteItem currentMaterialLibrary MatList.selection
				saveMaterialLibrary SelLib
-- 				filein 
-- 				loadMaterialLibrary SelLib
-- 				MatList.Items = MatLibUI
				
				)
				
				
		on SearchMat changed A do
		(
			Token = A + "*"
			SearchList = #()
			CorrectedSearchList = #()
			for i = 1 to MatLibUI.count do
			(
				if matchpattern MatLibUI[i] pattern:("*"+Token) ignoreCase:true then
				(SearchList[i] = MatLibUI[i])
			)
			try(
			for i=1 to SearchList.count do
			(
				if SearchList[i] != undefined then
					(
						Append CorrectedSearchList SearchList[i]
						)
				))catch()

			MatList.items = CorrectedSearchList
			
			
			
			
			
			
			)
	)
	createdialog MatPresets  width:1250 height:1040 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_maximizebox)
