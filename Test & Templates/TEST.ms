(
		rollout gui_Path "Render CC"
	(
		
		button _getpath "Browse Path" --Path Linking
		on _getpath pressed do
		(
			selectedPath = getSavePath initialDir:"//CGISERVER/BDWRenderC/CGIRender/Rodri"
			X = pathConfig.normalizePath selectedPath
			messagebox X
			print X
		)
				button _Paths "Paths"  --Path Generation & Render Setup
					on _Paths pressed do
			(
--  				if selectedPath == undefined then
-- 				(messagebox "Path Not SET"
-- 				destroydialog gui_path)
-- 				else
				 (actionMan.executeAction 0 "40068" 
				curcam = try(getActiveCamera()) catch()
				if curcam != undefined do select curcam
				sortKeys $.controller
				num_keys = numkeys $.position.controller
				StartKey = getkeytime $.position.controller 1
				EndKey = StartKey
	
				for i = 1 to num_keys do
	
					(key_time = getkeytime $.position.controller i
						if key_time > EndKey then
						EndKey = key_time)

					animationRange = interval StartKey EndKey)

					CamName = curcam.name
					

							-- //CGISERVER/BDWRenderC/CGIRender/Rodri/SCRIPT_TEST

							-- DirName = "//CGISERVER/BDWRenderC/CGIRender/Rodri/SCRIPT_TEST"

					RenderDir = X + "/" + CamName -- \\CGISERVER\BDWRenderC\CGIRender\Rodri\....
				
					
			MakeDir RenderDir --Directory Creation
					
					RenderFile = RenderDir + "/" + CamName + "_" + ".exr"
					
					renderSceneDialog.cancel()	-- Keep Render Dialog Box Closed!!!!!!	
					vr = renderers.current --I enable vray frame buffer and set vray output  
 					vr.output_splitgbuffer = False
					vr.output_splitgbuffer = true
					vr.output_splitfilename = RenderFile
					
-- 					rendSaveFile = true -- Enable File Save
-- 					rendoutputfilename = RenderFile -- Filename + Format
			
						clearselection()
						MSN = "Path Created at" + " " + X +"/" + CamName
						messagebox  MSN
			
					
	
				
			)
		button _folders "Open Folders" --Open Folders
			on _folders pressed do
			(
				actionMan.executeAction 0 "40068" 
				curcam2 = try(getActiveCamera()) catch()
				if curcam2 != undefined do select curcam2
				
				CamName2 = curcam2.name
				RenderDir2 = X + "/" + CamName2
				
				shelllaunch 	RenderDir2 ""
				
				clearselection()
				)
			button _CheckP "Check Path" --path Checking
			on _CheckP pressed do
			(
				if selectedpath == undefined then
				(	
				messagebox "Path Not SET"
				)
				else
				(
				messagebox X
				)
			)
	)
createdialog gui_Path
)



/*	actionMan.executeAction 0 "40068" 
curcam = try(getActiveCamera()) catch()
if curcam != undefined do select curcam
	
sortKeys $.controller
num_keys = numkeys $.position.controller
StartKey = getkeytime $.position.controller 1
EndKey = StartKey
	
for i = 1 to num_keys do
	
(key_time = getkeytime $.position.controller i
if key_time > EndKey then
EndKey = key_time)

animationRange = interval StartKey EndKey

CamName = curcam.name

-- //CGISERVER/BDWRenderC/CGIRender/Rodri/SCRIPT_TEST

-- DirName = "//CGISERVER/BDWRenderC/CGIRender/Rodri/SCRIPT_TEST"

RenderDir = result + "/" + CamName

MakeDir RenderDir --Directory Creation
*/