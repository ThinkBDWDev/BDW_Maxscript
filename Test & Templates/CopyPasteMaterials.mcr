--Copy/Paste Obects v0.2
--------------------------------
--Vladimir Mulhem 
--vlad@futuregeist.co.uk	
--
--Description: 
--Inspired by and partly based On Copy/Paste Objects v.0.2 by Christopher Grant. Alows you to copy materials between open max files. Much like a clipboard. 
--
--Instructions:
--  Select the material (only works with one at a time) in medit you want to copy. Run the copy command. Now you can "paste" them into either the same
--  file or you can load another instance of max and "paste" the materials into a slot in medit.
--
--Installation:
-- 1. Click Maxscript / Run Script and choose wherever you downloaded this file to
-- 	1a. It will seem like nothing happened but that's exactly what it should do, you now need to assign a shortcut to it
-- 2. Click Customize / Customize User Interface / Keyboard (tab) or /Quads tab
-- 3. Change the Category to "Futuregeist"
-- 4. Click "Copy Material to File" and change its Hotkey to something, maybe Ctrl+Alt+C .Click Assign or put it in a Quad menu
-- 5. Click "Paste Material from File" and change its Hotkey to something, maybe Ctrl+Alt+V. Click Assign or put it in a Quad menu
-- 6. Click Save and save your custom UI settings to a file, do yourself a favor and don't use the default.
-- 7. That's it.
--
--History:
-- this is the first beta revision. I'm no maxscript genius so any improvements are appreciated. Script is provided as is. I don't have much time to provide support for it.

--------------------------------
macroScript Copy_Material_To_File Category:"Futuregeist" toolTip:"Copy Material to File"
(
	thecopypastedir = getdir #autoback -- CHANGE THIS TO ANY FOLDER YOU WANT
	thecopypastefile = "\pastematfile.mat" --this is the filename to save as...
	thecopypastestring = thecopypastedir + thecopypastefile --this is the complete string

	selectedmat=medit.GetCurMtl()
	pastelib=loadTempMaterialLibrary thecopypastestring	
		if pastelib == undefined then (
			loadDefaultMatLib			
			saveTempMaterialLibrary currentMaterialLibrary thecopypastestring
			pastelib=loadTempMaterialLibrary thecopypastestring
		)
		
		for i=1 to pastelib.count do(
		deleteitem pastelib (i)
		)
	--currentMaterialLibrary
	append pastelib selectedmat
	saveTempMaterialLibrary pastelib thecopypastestring
	--if $ != undefined do 
		--saveNodes $ thecopypastestring --this saves ("copies") the objects as a file
)

macroScript Paste_Materials_From_File Category:"Futuregeist" toolTip:"Paste Material from File"
(
	thecopypastedir = getdir #autoback -- CHANGE THIS TO ANY FOLDER YOU WANT
	thecopypastefile = "\pastematfile.mat" --this is the filename to save as...
	thecopypastestring = thecopypastedir + thecopypastefile --this is the complete string
    
	pastelib=loadTempMaterialLibrary thecopypastestring
	selectedmatslot= activeMeditSlot
	pastedmat=pastelib[1]
	setMeditMaterial selectedmatslot pastedmat
	--mergemaxfile (thecopypastedir + thecopypastefile) #select --this merges ("pastes") and selects objects from file
)