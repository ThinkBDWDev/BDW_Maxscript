-------------------------------------------------------------------------

/*
Name			: adBitmapUtilities
Version			: 1.0.0
Description		: Script with various bitmap related functions
Date Created   	: 2015/03/06
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 	2015/03/16 - Added in write to file feature.
					2015/05/25 - Added in gamma & file path adjustments
					2015/05/27 - Bugs Fixed (EXR  / HDRi) & Added in File Save check.

*/


-------------------------------------------------------------------------


(

global b = #()	



------------------------------------------------------------------------------------------------------------------------------
--------------STRIP PATH--------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
fn pthStr=
(
	--print ("in function Path Strip")
	for a in getClassInstances Bitmaptexture do
	(
		a.fileName = filenameFrompath a.fileName
		--print ((a.filename) + ("                                  :               ") + ("File Path Stripped"))          
	)
)	-- PATH STRIP fuction ENDS
------------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------------
--------------ABSOLUTE PATH--------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
fn pthAbs=
(
	--print ("In function Path Absolute")
	for b in getClassInstances Bitmaptexture do
	(
		--print (mapPaths.getFullFilePathb.filename)
		b.filename = mapPaths.getFullFilePath b.filename
		--print ((filenameFrompath b.filename) + ("                                           :               ") + ("File Path Absolute"))
		--print (b.filename)
	)
)	-- ABSOLUTE PATH function ENDS
------------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------------
--------------RELATIVE PATH---------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
fn pthRel=
(
	PrjFolderPath = pathConfig.getCurrentProjectFolder()
	--print PrjFolderPath
	for c in getClassInstances Bitmaptexture do
		(
			FullPath = mapPaths.getFullFilePath c.filename
			print (c.filename)
			print (pathConfig.convertPathToRelativeTo FullPath PrjFolderPath)
			c.filename =pathConfig.convertPathToRelativeTo FullPath PrjFolderPath
		)
)	-- RELATIVE PATH function ENDS
------------------------------------------------------------------------------------------------------------------------------




	
rollout adBitmapUtilitiesRollout "adBitmapUtilities" width:696 height:408
(
	

	local s1 = maxFileName
	local s2 = ".max"
	local s3 = ".txt"
	local SaveFileName = substituteString s1 s2 s3
	
	local s6 = ".exr"
	local s7 = ".hdr"
	
	
	-- Bitmap Path
	button btnPthStr "Strip Path" pos:[528,136] width:128 height:24
	button btnPthAbs "Absolute" pos:[528,168] width:128 height:24
	button btnPthRel "Relative" pos:[528,200] width:128 height:24
	
	-- Project Folder
	GroupBox grp10 "Project Folder Path" pos:[8,40] width:480 height:56
	button btnPrjPthRef "Refresh" pos:[32,64] width:128 height:24
	edittext edtPrjPthRef "" pos:[192,64] width:288 height:24 enabled:false text:("  " + (pathConfig.getCurrentProjectFolder()))
	
	
	-- Bitmap Gamma Set
	GroupBox grp8 "" pos:[496,104] width:192 height:136
	label lblInpGma "Bitmap Input Gamma" pos:[512,264] width:112 height:16
	spinner spnBitGammaVal "" pos:[624,264] width:48 height:16 range:[1,5,2.2] type:#float
	button btnApyGma "Apply Gamma" pos:[528,328] width:128 height:24	
	

	-- List Bitmap files
	listbox lbxAllBitmaps "Bitmap File Path List" pos:[16,176] width:464 height:12
	button btnGetAllBitmap "List All Bitmap Textures" pos:[32,136] width:128 height:24 


	-- Write Bitmap List to file
	button btnWriteToFile "Write to File" pos:[384,136] width:87 height:24 enabled:false
	edittext edtFileName pos:[192,136] width:184 height:24 enabled:false text:SaveFileName

		
		
		
	GroupBox grp2 "" pos:[184,120] width:296 height:48
	GroupBox grp3 "" pos:[16,120] width:160 height:48
	

	label lbl3 "adBitmapUtilities" pos:[248,16] width:88 height:16
	--label lbl4 "v1.0.0" pos:[576,48] width:32 height:16
	GroupBox grp7 "" pos:[8,104] width:480 height:264
	
	

		
	
		
	label lbl16 "Exclude EXR / HDRi" pos:[512,296] width:112 height:16
	checkbox chkGmaEXR "Checkbox" pos:[640,296] width:16 height:16 checked:true
	GroupBox grp9 "" pos:[496,240] width:192 height:128
	
	
	HyperLink lbl18 "www.ashishdani.com" pos:[232,376] width:112 height:24 address:"www.ashishdani.com"
	HyperLink cust3 "Web Help" pos:[568,64] width:56 height:24 address:"http://www.ashishdani.com/adtools_max/"

	

		
	on btnApyGma pressed do
	(
		for adGammaVar in (getClassInstances BitmapTexture)  do
		(
			if chkGmaEXR.checked == True do
			(
				print ("EXCLUDING EXR")
				local chkForExtension = mapPaths.getFullFilePath adGammaVar.filename
				print chkForExtension
				
				if matchPattern chkForExtension pattern:".exr" != True or  matchPattern chkForExtension pattern:".hdr" != True do
				(
					print ("Executing gamma correction")
					adGammaVar.bitmap = openBitmap adGammaVar.bitmap.filename gamma:spnBitGammaVal.value
				)
				
			)
			if chkGmaEXR.checked == False do
			(
				print ("FALSE")
				adGammaVar.bitmap = openBitmap adGammaVar.bitmap.filename gamma:spnBitGammaVal.value
			)
		)
	)		
	
	
	on btnPrjPthRef pressed do
	(
		edtPrjPthRef.text = ("  " + (pathConfig.getCurrentProjectFolder()))
	)
	
	
	
	on btnPthStr pressed do
	(
		pthStr()
	)
	
	on btnPthAbs pressed do
	(
		pthAbs()
	)
	
	on btnPthRel pressed do
	(
		pthRel()
	)
	
	
	
	on lbxAllBitmaps doubleClicked itm do
	(
		--print ("\n\n OPENING")
		setClipBoardText lbxAllBitmaps.selected
	)
	
	
	
	on btnGetAllBitmap pressed do
	(
		--print ("\n\n BUTTON PRESSED")
		
		a = 1
		while a <= b.count do
		(
			deleteItem b a
			--a += 1
		)
		
		bitmapName = getClassInstances BitmapTexture
		--print ("\n	The no of Instances are	"	+ (bitmapName as string))
		btnWriteToFile.enabled = true
		edtFileName.enabled = true
		
		for a in bitmapname do
		(
			appendIfUnique b a.filename	
		)
		
		sort b
		lbxAllBitmaps.items = b		
	)
	
	
	
	on btnWriteToFile pressed do
	(
		print ("Write to file pressed")
		print (maxFileName)
		
		if (edtFileName.text != "") do
		(
			local out_name = (maxfilepath + (edtFileName.text))
			print (out_name)
		
			local z = 1
			
			if (doesfileexist out_name) == true do
			(
				print ("File EXISTS, will overwrite existing file")
				deleteFile out_name		
			)	
		
			if (doesfileexist out_name) == false do
			(
				out_file = createfile out_name
				while z <= b.count do
				(
					format ("\n" + b[z] as string) to:out_file
					--print (b[z] as string)
					z += 1
				)
			)
			z = 1
			close out_file
		)
		if (edtFileName.text == "") do
		(
			messageBox "Please Save your scene first, \n and Relaunch Script" title:"Scene Not Saved"
		)
	)
)


 fn adBitmapUtilitiesDefaults =
(
	createdialog adBitmapUtilitiesRollout()
)


)