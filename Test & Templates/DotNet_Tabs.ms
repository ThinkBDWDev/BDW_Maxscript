



LibsFiles = getdirectories (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\*")

LibsFilesUI = #()

for i=1 to LibsFiles.count do
	(
		LibsFilesUI[i] = (filterstring LibsFiles[i] @"\")[6]
	)














--Destroy the dialog if it is already open 
try(destroyDialog AssetmanagerUI)catch()

--Create a rollout
rollout AssetmanagerUI "Asset Manager" 
(
	--Add a dot net tab control
	dotNetControl tabs "system.windows.forms.tabControl" width:(AssetmanagerUI.width-30) height:25 
	--Add a sub rollout.
	subRollout subRoll "Sub" width:(AssetmanagerUI.width-30) height:450 offset:[0,-5]
	
	--Function to show all properties, methods and events for any dotNet object
	fn showProps obj=
	(
		clearListener()
		format "Properties:\n"
		showProperties obj
		format "\nMethods:\n"
		showMethods obj
		format "\nEvents:\n"
		showEvents obj
	)
	
	--Add rollouts to the subRollout based on which tab is currently selected. 
	fn addTabRollout index=
	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		sub=case index of
		(
			default:
			(
				rollout sub01 "Files" 
				(
-- 					button testBt "test Button"
-- 					bitmap thumb width:400 height:400 pos:[5,5]
					button thumb width:400 height:400 pos:[5,5]
					listbox Categories "" width:150 pos:[425,5] items: LibsFilesUI
					listbox AssetItems "" width:150 pos:[580,5] 
					button LoadAsset "Load" width:150 pos:[425,390]
					button MergeAsset "Merge" width:150 pos:[580,390]
					
					on Categories selected  a do
						(
							ItemsFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\*.max")

							ItemsFilesUI = #()

							for i=1 to ItemsFiles.count do
								(
									ItemsFilesUI[i] = (filterstring ItemsFiles[i] @"\")[7]
								)
														
							AssetItems.items = ItemsFilesUI
								
							CatSel  = Categories.selected
								
						)
					
					
					on AssetItems selected  a do
					(
						try(	
				
								ImgThumb = ""
								ImgThumb = openbitmap (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\" +  AssetItems.selected + ".jpg")
								ResizeImg = bitmap 400 400
											
									if  doesfileexist (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\" +  AssetItems.selected + ".jpg") == false then
										(
											ResizeImg = openbitmap (@"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\HTLibrary\NoPreview_Logo.jpg")
											)
											else
											(	
											copy ImgThumb ResizeImg
											)
											
								thumb.images = #(ResizeImg, undefined, 1,1,1,1,1 )
										
								)catch()
									
							AssetSel = AssetItems.selected 
					)
					
					on LoadAsset pressed do
						
						(
							loadMaxfile (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\" +  AssetItems.selected) useFileUnits:true quiet:true

						)
						
					on MergeAsset pressed do
						
						(
							mergeMaxfile (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\" +  AssetItems.selected) #select

						)					
					
					
					
					
					
	
				)
			)
			1:
			(
				rollout sub01 "Options"
				(
					
					button SaveAsset "Save As" width:100 height:50 pos:[5,5]
					button RenderPreview "Get Preview" width:100 height:50 pos:[5,55]
					radiobuttons Option labels:#("proxy", "max") columns:1 pos:[110,15]
					
					listbox Categories "" width:150 pos:[580,5]  items: LibsFilesUI
-- 					listbox AssetItems "" width:150 pos:[580,5] 
					button LoadAsset "Load" width:150 pos:[425,390]
					
					
					on Categories selected  a do
						(
							ItemsFiles = getfiles (@"\\CGISERVER\BDWRenderC\CGIResources\3D\AssetManager\" + Categories.selected + @"\*.max")

							ItemsFilesUI = #()

							for i=1 to ItemsFiles.count do
								(
									ItemsFilesUI[i] = (filterstring ItemsFiles[i] @"\")[7]
								)
								
						)
					
					
					
					
				)
			)
-- 			2:
-- 			(
-- 				rollout sub01 "Sub 03"
-- 				(
-- 					button testBt "test Button"
-- 					on testBt pressed do (messageBox "You pressed the button" title:"Alert!")
-- 				)
-- 			)
		)
		addSubRollout subRoll sub
	)
	
	--Tab initilization function.
	fn initTabs tab labels:#() =
	(
		--Clear any existing tabs incase we do an update of them at some point. 
		tab.tabPages.clear()
		--Set the size mode so that we can control their width. 
		tab.sizeMode=tab.sizeMode.fixed
		--Set the width of every tab.
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/labels.count)-2) 25
		
		--Loop through all the labels that we pass to the function and add a tab by the same name. 
 		for x in labels do tab.tabPages.add x
	)
	
	--When the mouse button is released on a tab get the selected tab and pass it to our addTabRollout function. 
	on tabs MouseUp senderArg arg do
	(
-- 		showProps arg
		addTabRollout senderArg.SelectedIndex
	)
	
	--When the rollout opens initilize the tab control
	on AssetmanagerUI open do
	(
-- 		showProps tabs
		
		initTabs tabs labels:#("Files", "Options")
		addTabRollout 0
	)
)
--Create the dialog
createDialog AssetmanagerUI width:785 height:500