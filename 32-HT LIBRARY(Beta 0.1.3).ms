/*HeaderStart*******************************************************
:Created By:			Rodri Garcia			
:Purpose: HT Library

:History:
	V:0.00.05A 
		Getting started. 
:Todo:
	-Add Max File Save + Date to generate Preview
	-
	-
	-
	
:Bugs:




:Tests:



*******************************************************HeaderEnd*/







ScreenPath =@"\\CGISERVER\BDWRenderC\CGIResources\3D\HT Library\"

-- fn ResizeViewport width height=
-- (
-- 	compensation = 4
-- 	ViewportHwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
-- 	assembly.setwindowpos (dotNetObject "System.IntPtr" ViewportHwnd) 0 0 0 (width+compensation) (height+compensation) 0x0026
-- 	ForcecompleteRedraw()
-- 	)


fn LR_CaptureRenderAspectViewport  = 
    (
    local ViewCap=undefined         
    local cv = getViewSize()
    local ratio = undefined
 
           case of 
           ( 
            (cv.x > cv.y):(ratio = cv.y/cv.x)
            (cv.x = cv.y):(ratio = 1)           
            (cv.x < cv.y):(ratio = cv.x/cv.y)
       )
		VptDib =gw.getViewportDib();
--         VptDib =viewport.getViewportDib();
                ViewCap = bitmap renderwidth renderheight color:white
                ViewportRatio = VptDib.width/VptDib.height as float
                RenderRatio = renderwidth/renderheight as float
 
                    case of
                    (
                    (ViewportRatio <= RenderRatio):(
                    CapturetoRenderHeightRatio =VptDib.width/RenderRatio as float
                    TopEdge = ((VptDib.Height-CapturetoRenderHeightRatio)/ 2.0) as integer
                    FullViewcap = bitmap vptdib.width CapturetoRenderHeightRatio color:white
                    pasteBitmap VptDib FullViewcap (box2 0 TopEdge VptDib.width VptDib.height) [0,0]
                    Copy FullViewcap ViewCap)
                    (ViewportRatio > RenderRatio):(
                    CapturetoRenderHeightRatio =VptDib.height*RenderRatio as float
                    LeftEdge = ((VptDib.width-CapturetoRenderHeightRatio)/ 2.0) as integer
                    FullViewcap = bitmap CapturetoRenderHeightRatio VptDib.height color:white
                    pasteBitmap VptDib FullViewcap (box2 LeftEdge 0 VptDib.width VptDib.height) [0,0]
                    Copy FullViewcap ViewCap)
                    default:()
                    )
                close VptDib
        gc()
 
                if viewcap != undefined then (setclipboardbitmap viewcap;close ViewCap;return true)else(return false)
    )


	
ClientsPath = 	getdirectories @"\\CGISERVER\BDWRenderC\CGIResources\3D\HT Library\*"
ClientsPathUI = #()	
for i = 1 to ClientsPath.count do
(
	ClientsPathUI[i] = (filterstring ClientsPath[i] @"\")[6]
	)
	
	
	

try(destroydialog HTLibrary )catch()
	rollout HTLibrary "HT Library"
	(
		bitmap FrontTh "" width:300 height:300 pos:[220,5]
		bitmap LeftTh "" width:300 height:300 pos:[220,305]
		bitmap RightTh "" width:300 height:300 pos:[525,5]
		bitmap BackTh "" width:300 height:300 pos:[525,305]
		bitmap TopTh "" width:300 height:300 pos:[525,605]
		

		listbox ClientsList "Client"  width:150 pos:[10,5]
		Listbox HTList "HT Name" width:150 Pos:[10,180] height:25
		
		edittext Search "Search" width:147
		edittext JobNumber "Job Number" width:147
		edittext JobName "Job Name" width:147
		
-- 		button MergeHT "Merge File"
-- 		button OpenHT "Open HT"
		
		
		
		
		Button GenPreview "Add to Library" pos:[10,620] width:100 height:60
		
		
		
		
		
-- 		button Test "Test" pos:[200,620]
		
		
		
		fn ScreenCap MaxFileFileSave Index = 
(				
					
				
				savemaxfile MaxFileFileSave
				
				if doesfileexist (ClientsPath[ClientsList.selection] + @"\" + "tags") == false then
				makedir (ClientsPath[ClientsList.selection] + @"\" + "tags")
	
				if hasINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags" + @"\" + (getfileNameFile maxFileName) + ".ini") "FILE NAME" "Name" == false then
				(setINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags" + @"\" + (getfileNameFile maxFileName) + ".ini") "FILE NAME" "Name" (maxFileName))
				if hasINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags"  + @"\" + (getfileNameFile maxFileName) + ".ini") "JOB NUMBER" "Job" == false then
				(setINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags"  + @"\" + (getfileNameFile maxFileName) + ".ini") "JOB NUMBER" "Job" (JobNumber.text))
				if hasINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags"  + @"\" + (getfileNameFile maxFileName) + ".ini") "JOB NAME" "Name" == false then
				(setINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags" + @"\" + (getfileNameFile maxFileName) + ".ini") "JOB NAME" "Name" (JobName.text))
	
	
				hide shapes
				
-- 				ResizeViewport 1000 1000
				max zoomext sel
				max zoomext sel
				
				IDisplayGamma.colorCorrectionMode = #gamma
				actionMan.executeAction 0 "550"
				actionMan.executeAction 0 "557"
				completeredraw()
				
				OldWidth = renderwidth 
				Oldheight = RenderHeight
				
				renderwidth = 300
				renderheight = 300
				
				viewport.setType #view_Front
				max zoomext sel
				viewport.zoom 1.5
				completeredraw()
				ShotCam = viewport.getType() as string
				ShotName = (filterstring ShotCam "_")[2]
-- 				img = gw.getViewportDib()
				tempbmp = LR_CaptureRenderAspectViewport()
				img = getclipboardbitmap()
-- 				img = viewport.getViewportDib() 
				img.filename = ScreenPath + ClientsList.selected  + @"\" + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
				save img
				Close img

				viewport.setType #view_Left
				max zoomext sel
				viewport.zoom 1.5
				completeredraw()
				ShotCam = viewport.getType() as string
				ShotName = (filterstring ShotCam "_")[2]
-- 				img = gw.getViewportDib()
				tempbmp = LR_CaptureRenderAspectViewport()
				img = getclipboardbitmap()
				img.filename = ScreenPath + ClientsList.selected  + @"\"  + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
				save img
				Close img

				viewport.setType #view_Right
				max zoomext sel
				viewport.zoom 1.5
				completeredraw()
				ShotCam = viewport.getType() as string
				ShotName = (filterstring ShotCam "_")[2]
-- 				img = gw.getViewportDib()
				tempbmp = LR_CaptureRenderAspectViewport()
				img = getclipboardbitmap()
				img.filename = ScreenPath + ClientsList.selected  + @"\"  + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
				save img
				Close img

				viewport.setType #view_Top
				max zoomext sel
				viewport.zoom 1.5
				completeredraw()
				ShotCam = viewport.getType() as string
				ShotName = (filterstring ShotCam "_")[2]
-- 				img = gw.getViewportDib()
				tempbmp = LR_CaptureRenderAspectViewport()
				img = getclipboardbitmap()				
				img.filename = ScreenPath + ClientsList.selected  + @"\"  + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
				save img
				Close img

				viewport.setType #view_Back
				max zoomext sel
				viewport.zoom 1.5
				completeredraw()
				ShotCam = viewport.getType() as string
				ShotName = (filterstring ShotCam "_")[2]
-- 				img = gw.getViewportDib()
				tempbmp = LR_CaptureRenderAspectViewport()
				img = getclipboardbitmap()
				img.filename = ScreenPath + ClientsList.selected  + @"\"  + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
				save img
				Close img

				renderwidth = OldWidth
				renderheight = Oldheight
				
				unhide shapes
				
-- 				JobName.text = ""
-- 				JobNumber.text = ""
				
				
-- 				IDisplayGamma.colorCorrectionMode = #gamma
)



		on Test pressed do
			()
		
		
		On search changed P do
		(
			Token = P + "*"
			SearchList = #()
			CorrectedSearchList = #()
			for i = 1 to HTFilesUI.count do
			(
				if matchpattern HTFilesUI[i] pattern:Token ignoreCase:true then
				(SearchList[i] = HTFilesUI[i])
			)
			try(
			for i=1 to SearchList.count do
			(
				if SearchList[i] != undefined then
					(
						Append CorrectedSearchList SearchList[i]
						)
				))catch()

			HTList.items = CorrectedSearchList
		)
		
		
		on JobNumber changed  P do
		(
			IniFiles=#()
			IniFilesPath = (ClientsPath[ClientsList.selection] + @"\" + "tags" + @"\" +  "*.ini")
			IniFiles = Getfiles IniFilesPath
			INIRead = #()
			JobNoSearch =  #()
			for i=1 to IniFiles.count do
			(
-- 				INIRead[i] = getINISetting (ClientsPath[ClientsList.selection] + @"\" + "tags" + @"\" + ".ini") "JOB NUMBER" "Job"
				INIRead[i] = getINISetting IniFiles[i] "JOB NUMBER" "Job"
		
				JobNoToken = P + "*"
				
				if matchpattern INIRead[i] pattern:JobNoToken ignoreCase:true 
					then(
-- 				print (getINISetting (IniFiles[i]) "FILE NAME" "Name")
				
				JobNoSearch[i] = (getINISetting (IniFiles[i]) "FILE NAME" "Name")
						)
			)
			JobNoSearchCorrected = #()
			
			for i=1 to JobNoSearch.count do
				(if JobNoSearch[i] != undefined then(
					append JobNoSearchCorrected JobNoSearch[i]
				))
			HTList.items = JobNoSearchCorrected
			
			
		)
		
		
		
		
		
		on ClientsList selected P do
			(
				HTFiles = #()
				HTFiles = getfiles (ClientsPath[ClientsList.selection] + "*.max")
				
				HTFilesUI = #()
				for i=1 to HTFiles.count do 
				(
					HTFilesUI[i] = (filterstring HTFiles[i] @"\")[7]
				)
				HTList.items = HTFilesUI
			)
				
		on ClientsList rightclick do
		(
			OpenPath = ClientsPath[ClientsList.selection] 
			shelllaunch OpenPath ""
			
			)
		
		on HTList Selected P do
		(
			NoPreview = openBitmap @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\HTLibrary\NoPreview_Logo.jpg"
-- 			Print ("Selected " + HTList.selected)
			try(
			OrigMap = (ScreenPath + ClientsList.selected  + @"\" + ((trimright HTList.selected ".max") + " " + "front" ) + ".jpg")
			bmpTex = openBitmap OrigMap
			if bmpTex == undefined then
			(FrontTh.bitmap = NoPreview
			)else(
			FrontTh.bitmap = bmpTex
			)

			OrigMap = (ScreenPath + ClientsList.selected  + @"\"  + ((trimright HTList.selected ".max") + " " + "left" ) + ".jpg")
			bmpTex = openBitmap OrigMap
			if bmpTex == undefined then
			(LeftTh.bitmap = NoPreview
			)else(
			LeftTh.bitmap = bmpTex
			)
						
			
			OrigMap = (ScreenPath + ClientsList.selected  + @"\"  + ((trimright HTList.selected ".max") + " " + "right" ) + ".jpg")
			bmpTex = openBitmap OrigMap
			if bmpTex == undefined then
			(RightTh.bitmap = NoPreview
			)else(
			RightTh.bitmap = bmpTex
			)
-- 			RightTh.bitmap = bmpTex	
			
			OrigMap = (ScreenPath + ClientsList.selected  + @"\"  + ((trimright HTList.selected ".max") + " " + "back" ) + ".jpg")
			bmpTex = openBitmap OrigMap
			if bmpTex == undefined then
			(BackTh.bitmap = NoPreview
			)else(
			BackTh.bitmap = bmpTex
			)
-- 			BackTh.bitmap = bmpTex				

			OrigMap = (ScreenPath + ClientsList.selected  + @"\"  + ((trimright HTList.selected ".max") + " " + "top" ) + ".jpg")
			bmpTex = openBitmap OrigMap
			if bmpTex == undefined then
			(TopTh.bitmap = NoPreview
			)else(
			TopTh.bitmap = bmpTex
			)
-- 			TopTh.bitmap = bmpTex	

		)catch()

			
			)
		on HTList doubleclicked P do
			(
				if querybox "Load File?" beep:true then (LoadMaxFile (ClientsPath[ClientsList.selection] + HTList.selected))
				
				)
		
		
		on GenPreview pressed do
			(
-- 				BGColor = (GetUIColor 41*255) as color
-- 				viewport.EnableSolidBackgroundColorMode true
-- 				SetUIColor 41 (color 6 6 6)
-- 				colorMan.repaintUI #repaintAll
				
				
				clearselection()
				MaxFileFileSave = ClientsPath[ClientsList.selection] + maxFileName
				if maxFileName == undefined then
				(messagebox "Name your max file first")
				else
				(
				if doesfileexist (ClientsPath[ClientsList.selection] + maxFileName) then
				(if querybox "WARNING, You are about to overwrite an existing File, Proceed?" beep:true then(

				ScreenCap MaxFileFileSave ClientsList.selected

				))else(ScreenCap MaxFileFileSave ClientsList.selected)
				)
-- 				viewport.EnableSolidBackgroundColorMode false
			)
		
		on HTLibrary open do
		(
			ClientsList.items = ClientsPathUI
-- 			ClientsList.height = ClientsPathUI.count +10
			
			
			
			
-- 			OrigMap = (ScreenPath + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg")
-- 			bmpTex = openBitmap OrigMap
-- 			ResizedMap = bitmap 200 200
-- 			ResizedMap.filename = ScreenPath + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
-- 			copy bmpTex ResizedMap
-- 			FrontTh.bitmap = bmpTex	
			
			
			
		)
		
		
	)
	createdialog HTLibrary width:835 height: 950
	
	
-- 	viewport.EnableSolidBackgroundColorMode false