/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose:
:History:V2.6

:Todo: Button to add items to LIB
		Merge selected items to local user machine..
		
:Bugs: fixed window size per angle issue.. updated window Distribute items frequency..

Added Help file
:Tests: 
*******************************************************HeaderEnd*/
 
--Vars
Global Curtains = #()
Global WindowLedgeItems = #()
Global WinItems =#()
Global SEL = #()

--Paths to assets --work
Global CurtainsFilePath = @"\\CGISERVER\BDWRenderC\CGIResources\3D\windows\WindowTool\Curtains_Blinds.max"
Global DessingItemsPath = @"\\CGISERVER\BDWRenderC\CGIResources\3D\windows\WindowTool\Decor\*.max"

--Items LIB
Global DressignItemLIB = GetFiles DessingItemsPath
Global DressignItemLIBUI = for item in DressignItemLIB collect getFilenameFile item
Global DressignItemLIBPreviews = GetFiles (trimRight DessingItemsPath ".max" + ".jpg")
Global UsedDItems = #()
Global UsedDItemsUI = for item in UsedDItems collect getFilenameFile item

fn MatchScale obj: targetOBJ: Axis: =
(
--scale in z only
ratios = (targetOBJ.max - targetOBJ.min) / (obj.max - obj.min)
if Axis == 3 then (the_scale = amin #(ratios.z))
if Axis == 2 then (the_scale = amin #(ratios.y))
if Axis == 1 then (the_scale = amin #(ratios.x))

if Axis == 3 then (scale obj ([1, 1,the_scale * 1]))
if Axis == 2 then (scale obj ([1, the_scale * 1, 1]))
if Axis == 1 then (scale obj ([the_scale * 1, 1, 1]))

)

fn AddToLayer LayerNa: Arr: HideLayer:False Freez:False DelLayer:false =
(
	if DelLayer != true then
	(
		LayerManager.newLayerFromName LayerNa
		SEL = Arr
		for i =1 to SEL.count do
		(
			layerName = LayerManager.getLayerFromName LayerNa
			layerName.ishidden = HideLayer
			layerName.isfrozen = Freez
			layerName.addnode SEL[i]
		)
	)

	if DelLayer == true then
	(
		try (
		deselect Selection
		layer = layermanager.getLayerFromName LayerNa
		layer.select true
		Delete selection
		LayerManager.deleteLayerByName LayerNa
		)catch()
	)

)

 fn MergeItems MaxItemsPath: Arr: HideItems: =
 (
		--Curtains Merge***********************************
		mergemaxfile MaxItemsPath #mergeDups #renameMtlDups #select
        Imports=(selection as array)
        for i=1 to Imports.count do
			(			
			Append Arr Imports[i]
			)
	    if HideItems==true then (hide Selection)
	    deselect Selection
 )
 
fn MakeAlingPlane Item: AppendArray: =
(
	
max create mode 
	
for i = 1 to Item.count do
(

convertToPoly Item[i]
count = polyop.getNumFaces Item[i]

if count == 1 then
(

OldOBJ = Item[i]
resetxform OldOBJ

maxOps.cloneNodes OldOBJ cloneType:#copy newNodes:&CopyOBJ #nodialog

-- ITEM = $ --original mesh
tempPlane = (plane length: 100 width:100 lengthsegs:1 widthsegs: 1)

select CopyOBJ
	
ItemToUse = $

the_pos = polyop.getfacecenter ItemToUse 1
the_dir = polyop.getfacenormal ItemToUse 1
the_rot = 

tempPlane.pos = the_pos
tempPlane.dir = the_dir


--MAKE CHILD
ItemToUse.parent = tempPlane
MovePlane = (plane length: 100 width:100 lengthsegs:1 widthsegs: 1)

tempPlane.pos = MovePlane.pos
tempPlane.dir = MovePlane.dir

--realine item
resetxform ItemToUse
convertToPoly ItemToUse

--check and size plane
SizeSelected = ($.max - $.min)
MakePlane = plane length: (SizeSelected[2]) width:(SizeSelected[1]) lengthsegs:1 widthsegs: 1

delete tempPlane
delete MovePlane
delete ItemToUse

MakePlane.pos = the_pos
MakePlane.dir = the_dir

convertToPoly MakePlane
append AppendArray MakePlane
delete OldOBJ
) else (messagebox "Some Items have more or less than 1 poly!")

)

) 


fn MakeWinFill Arr: =
(
	if Arr.count !=0 then 
	(

	--make mat
	WinBackMat = vraymtl()
	WinBackMat.name = "WinBack"
	WinBackMat.diffuse = black

	InteriorMat = vraymtl()
	InteriorMat.name = "Interior"
	InteriorMat.diffuse = (color 250 230 190)

	MakeMultiMat = multisubmaterial numsubs:2 
	MakeMultiMat.materialList[2] = WinBackMat
	MakeMultiMat.materialList[1] = InteriorMat
	
	max create mode
	for i=1 to Arr.count do
	(
		convertToPoly Arr[i]
		--new***********************************WORKS
		polyop.extrudeFaces Arr[i] 1 -150
		polyop.bevelFaces Arr[i] 1 0 -8
		polyop.deleteFaces Arr[i] #{2..9}
		polyop.extrudeFaces Arr[i] 1 -312
		polyop.extrudeFaces Arr[i] 1 -900  --was -514
		
		Arr[i].extrusionType = 1
		polyop.extrudeFaces Arr[i] #{6..9} -445 --SORT type
		
		--material setup***********************************
		polyop.setFaceMatID Arr[i] #{1, 6..9, 14..17} 2
		
		Arr[i].name = uniquename"Window_fill"
		Arr[i].wirecolor =  gray 
		
		--MakeVary***********************************
		Arr[i].material = MakeMultiMat
		
		
	)
	
  )else (messagebox "No Items Selected!")
	
)

fn MakeRoomFill Arr: ArrToCheck: =
(
	if ArrToCheck.count !=0 then 
	(
	
	--make mat
	WinBackMat = vraymtl()
	WinBackMat.name = "InteriorFloor"
	WinBackMat.diffuse = black

	InteriorMat = vraymtl()
	InteriorMat.name = "InteriorWalls"
	InteriorMat.diffuse = (color 250 230 190)

	MakeMultiMat = multisubmaterial numsubs:2 
	MakeMultiMat.name = "RoomsMulti"
	MakeMultiMat.materialList[2] = WinBackMat
	MakeMultiMat.materialList[1] = InteriorMat
-- 	
	max create mode
	for i=1 to Arr.count do
	(
		convertToPoly Arr[i]
		--new***********************************WORKS
		polyop.extrudeFaces Arr[i] 1 -150
		polyop.bevelFaces Arr[i] 1 0 -8
		polyop.deleteFaces Arr[i] #{2..9}
		polyop.extrudeFaces Arr[i] 1 -312
		polyop.extrudeFaces Arr[i] 1 -4000
		
		Arr[i].extrusionType = 1
		polyop.extrudeFaces Arr[i] #{6..9} -2000--SORT type
		polyop.setFaceSelection Arr[i] #{7}
		
		move Arr[i].selectedFaces [0,1300,0]
		
		polyop.setFaceSelection Arr[i] #{9}
		move Arr[i].selectedFaces [0,-1000,0]
		
		
		--material setup***********************************
		polyop.setFaceMatID Arr[i] #{7} 2
		
		ShelMod = shell()
		show ShelMod
		ShelMod.innerAmount = 20
		ShelMod.straightenCorners = true
		addmodifier Arr[i] ShelMod
		
		Arr[i] .name = uniquename"Window_fill"
		Arr[i] .wirecolor =  yellow
		
		--MakeVary***********************************
		Arr[i].material = MakeMultiMat
	)
	
	)else (messagebox "No Items Selected!")
)

fn DistributeCurtains Arr: ItemsSel: curtains:true Blinds:true =
(
	for i =1 to Arr.count do
	(
	
        Items=#()
		for o = 1 to ItemsSel.count do
			( 
				selectVar = random 0 1
				if selectVar != 0 do
				(
					append Items ItemsSel[o]
			    )
			
-- 			print Items

			)
			
			SizeSelected = (Arr[i].max - Arr[i].min)

					FinishedItems =#()
					
					convertTopoly Arr[i]
					
					if curtains == true then
					(if Items.count==0 then (append Items $Curtain_toClone1_))
						else (Items[1]= $ImportBlind_1)
					
					if Blinds == true then
					(if Items.count==0 then (append Items $ImportBlind_1))
						
					
					if Items[1].name == "ImportBlind_1" then 
						(
							if Blinds == true then
							(
							
								if SizeSelected [1] <= 1600 then
								(	
									if SizeSelected [2] <= 1600 then
									(
										top = polyop.getfacecenter Arr[i] 5
										align1 = polyop.getfacenormal Arr[i] 1
										maxOps.cloneNodes (Items[1]) cloneType:#instance newNodes:&Blind #nodialog 
										BlindClone = Blind
										BlindClone.name = uniquename "Blind"
										BlindClone.dir = align1
										BlindClone.pos = top
										if SizeSelected [1] <= 1300 then
										(
										MatchScale obj:BlindClone[1] targetOBJ:Arr[i] Axis:3
										) else (MatchScale obj:BlindClone[1] targetOBJ:Arr[i] Axis:3)
										
										for i=1 to BlindClone.count do (append FinishedItems BlindClone[i]) --add to array
									)
								)
							)
						
						) 
						else
						
						(
						if curtains == true then
						(
							if SizeSelected [1] >= 1200 then
							(
								if SizeSelected [2] >= 1200 then
								(
									Side1 = polyop.getfacecenter Arr[i] 4
									Side2 = polyop.getfacecenter Arr[i] 2
									align1 = polyop.getfacenormal Arr[i] 1
									maxOps.cloneNodes (Items[1]) cloneType:#instance newNodes:&dd #nodialog 
									SelClone = dd
									SelClone.name = uniquename "Curtain"
									SelClone.dir = align1
									SelClone.pos = Side1
									MatchScale obj:SelClone[1] targetOBJ:Arr[i] Axis:3
									for i=1 to SelClone.count do (append FinishedItems SelClone[i]) --add to array
									
									maxOps.cloneNodes (Items[1]) cloneType:#instance newNodes:&aa #nodialog 
									SelClone = aa
									SelClone.dir = align1
									SelClone.pos = Side2
									SelClone.name = uniquename "Curtain"
									MatchScale obj:SelClone[1] targetOBJ:Arr[i] Axis:3
									for i=1 to SelClone.count do (append FinishedItems SelClone[i]) --add to array
								)
							)
	
						)
						else (Items[1]= $ImportBlind_1)
						)
		

				AddToLayer LayerNa:"Curtains" Arr:FinishedItems HideLayer:false Freez:false DelLayer:false

						
	)

)

fn DistributeItems Arr: ItemsSel: =
(
	
	tempArry =#()
	num = 0
	if Arr.count !=0 then
	(
		for i = 1 to Arr.count do
		(
			
			base = polyop.getfacecenter Arr[i] 3
			align1 = polyop.getfacenormal Arr[i] 3
			
			SizeSelected = (Arr[i].max - Arr[i].min)--size of win limeted
			if SizeSelected [3] <= 2500 then
			(
				FinishedItems =#()
				convertTopoly Arr[i]
				
				if tempArry.count != ItemsSel.count then
				(
					NumCount = num += 1 
					maxOps.cloneNodes (ItemsSel[NumCount]) cloneType:#instance newNodes:&ItemOBJ #nodialog
					BlindClone = ItemOBJ
					BlindClone.dir = align1
					BlindClone.pos = base
					
					append tempArry "test"
				)
				
				else
				(
					maxOps.cloneNodes (ItemsSel[random 1 ItemsSel.count]) cloneType:#instance newNodes:&ItemOBJ #nodialog
					BlindClone = ItemOBJ
					BlindClone.dir = align1
					BlindClone.pos = base
					
				)
				--error adding BlindClone item to FinishedItems...
				for i=1 to BlindClone.count do (append FinishedItems BlindClone[i]) --add to array
				AddToLayer LayerNa:"#Dressing_Items" Arr:FinishedItems HideLayer:false Freez:false DelLayer:false
			)
		)
	)		
)
--remove unused items on layer
AddToLayer LayerNa:"WindowTool_items" Arr:"" HideLayer:true Freez:true DelLayer:true	

fn HelpInfoDialog =
(
  
 try(destroydialog help) catch() 
 rollout help "Help" width:570 height:272
 (
   label hel "" pos:[12,7] width:536 height:257 
	 
	 on help open do
	 (
		 hel.text =  "Info \n" + \

				"Only works with single faced geometry eg. \n" + \
				"Single faced planes, detached meshes from window holes etc. \n" + \
				"\n" + \
				"The options allow you to include or exclude curtains, blinds, decoration and window fills. \n" + \
				"Empty window count spinner will control the number of empty windows that won’t be filled with decoration. \n" + \
				"You can add or subtract window ledge items you’d like to include in the creation process via the two lists. \n" + \
				"\n" + \
				"Use \n " + \
				"\n" + \
				"Select your single faced polys \n" + \
				"Select your options \n" + \
				"Add the dressing items you want  \n" + \
				"Create Windows \n" + \
				"\n" + \ 
				"Wait for the Network! :)" 
	 )
 )
 CreateDialog help
)

fn ImportFiles =
(
	
	n = $Curtain_toClone1_
	if n == undefined then 
	(
	Curtains = #()
	reload = (selection as array)
	--items to import.####
	--import items for curtains
	MergeItems MaxItemsPath:CurtainsFilePath Arr:Curtains HideItems:false 
	AddToLayer LayerNa:"WindowTool_items" Arr:Curtains HideLayer:true Freez:true DelLayer:false
		select reload
	)
)

fn MakeBox =
(
	MakeAlingPlane Item:SEL AppendArray:WinItems
	MakeWinFill Arr:WinItems
	SEL = #()
)

fn MakeRoom =
(
	MakeAlingPlane Item:SEL AppendArray:WinItems
	MakeRoomFill Arr:WinItems ArrToCheck:SEL
	SEL = #()
)

fn DistributeCurt curt: Blind: =
	
(
	DistributeCurtains Arr:WinItems ItemsSel:curtains curtains:curt Blinds:Blind
	AddToLayer LayerNa:"WindowTool_items" Arr:curtains HideLayer:true Freez:true DelLayer:false
)

fn DisItems =
(
	DistributeItems Arr:WinItems ItemsSel:WindowLedgeItems
)

fn resetWin = (WinItems =#())
	
fn delWinFill = (delete WinItems)
	
fn AddFill count: =
(
	for i = 1 to count do
	(	
	winFiller = dummy()
	winFiller.name = "A"
	append WindowLedgeItems winFiller
	)
)

fn DeleteFillItems =
(
try (

deselect Selection
layer = layermanager.getLayerFromName "Curtains" 
layer.select true
SEL = (selection as array)
for o=1 to SEL.count where ClassOf SEL[o] == dummy do (delete SEL[o])
-- Delete selection
deselect Selection

)catch()

)

--UI
  try(destroydialog WindowTool) catch() 
 
  rollout WindowTool "Window Tool" width:337 height:502
  (
	
	button help "Help?" pos:[289,449] width:38 height:25
	label lab "Empty Window Count" pos:[221,175] width:124 height:13
  	spinner BlankWin "" pos:[222,193] width:102 height:16 range:[0,10,5] type:#integer
	  
	button MakeWin "Create Windows" pos:[105,448] width:118 height:29
  	bitmap bmp1 "Bitmap" pos:[10,14] width:196 height:197
  	multiListBox lbx1 "Items Used" pos:[207,219] width:118 height:15 items:UsedDItemsUI
  	multiListBox lbx2 "Window Dressings" pos:[11,219] width:118 height:15 items:DressignItemLIBUI
  	button AddItem ">>" pos:[153,312] width:28 height:21
  	button removeItem "<<" pos:[153,336] width:28 height:21
  	progressBar prog "ProgressBar" pos:[9,482] width:319 height:15 color:red
  	radiobuttons WinFillOpts "" pos:[220,89] width:80 height:48 labels:#("WindowBox", "RoomBox", "None") columns:1
  	checkbox Curts "Curtains" pos:[220,16] width:90 height:19 enabled:true checked:true
  	checkbox BlindsOBJ "Blinds" pos:[220,38] width:90 height:19 enabled:true checked:true
  	checkbox WinItems "Window Dressing" pos:[220,60] width:110 height:19 enabled:true checked:true
	
	--Logic##########################################################
	fn reload =
	(
		
		DressignItemLIBUI = for item in DressignItemLIB collect getFilenameFile item
		UsedDItemsUI = for item in UsedDItems collect getFilenameFile item
		
		lbx2.items = DressignItemLIBUI
		lbx1.items = UsedDItemsUI
		
	)
	
	on help pressed do
	(
		HelpInfoDialog()
	)
	
		--bitmap preivew2
	on lbx2 selected i do
	(
		for o in lbx2.selection do
		(
				--find jpg files
		PreviewItems = DressignItemLIB[o]
		Thumnail = (trimRight PreviewItems ".max" + ".jpg")

-- 	-- 	--add bitmap to ui
		if Thumnail != undefined then
		(
		bmp001 = openBitMap Thumnail
		if bmp001 != undefined then (bmp1.bitmap = bmp001) -- laod bitmap
		)	
		
		)
	)
	
	
	on AddItem pressed do
	(
		for o in lbx2.selection do
		(
			Item = DressignItemLIB[o]
			append UsedDItems Item
	    )
		
		for i = 1 to UsedDItems.count do 
		(
			tt = findItem DressignItemLIB UsedDItems[i]
			try(deleteItem DressignItemLIB tt)catch()
		)
		reload()
		
	)
	
	--Remove items from listbox
	on RemoveItem pressed do
	(
		for o in lbx1.selection do
		(
			Item = UsedDItems[o]
			append DressignItemLIB Item
	    )
		
		for i = 1 to DressignItemLIB.count do 
		(
			tt = findItem UsedDItems DressignItemLIB[i]
			try(deleteItem UsedDItems tt)catch()
		)
		reload()
	)
	
	
	--Run Action #######################
	on MakeWin pressed do
	(
		try(
		ImportFiles()
		resetWin()
		--Add selection
		SEL = (Selection as array)

		if WinFillOpts.state == 1 then
		(
			MakeBox()
		)
		
		if WinFillOpts.state == 2 then
		(
			MakeRoom()
		)
		
		if WinFillOpts.state == 3 then
		(
           MakeBox()
		)
		
		if BlindsOBJ.state then
		(
			if Curts.state then
			(
			)
			else
			(
			DistributeCurt curt:false Blind:true
			)
		)
		
		if WinItems.state then
		(
			WindowLedgeItems =#()
			for i = 1 to UsedDItems.count do
			(
			   prog.value = 100.*i/UsedDItems.count
			   MergeItems MaxItemsPath:UsedDItems[i] Arr:WindowLedgeItems HideItems:false
			   AddToLayer LayerNa:"WindowTool_items" Arr:WindowLedgeItems HideLayer:true Freez:true DelLayer:false
			)
			   AddFill count:BlankWin.value
			   DisItems()
			delete WindowLedgeItems
		)
		
		if Curts.state then
		(
			
			if BlindsOBJ.state then
			(
			DistributeCurt curt:true Blind:true
			)
			else
			(
			DistributeCurt curt:true Blind:false
			)
		)
		
		if WinFillOpts.state == 3 then
		(
	      delWinFill()
		)
		
		DeleteFillItems()
-- 		messagebox "Finished!"
		prog.value = 0
	)catch()
		
	)
	
	
	--openUI ########################
	on WindowTool open do 
		(

-- 			ImportFiles()

		)
	
	on WindowTool close do
	(
		AddToLayer LayerNa:"WindowTool_items" Arr:"" HideLayer:true Freez:true DelLayer:true
	)
	
  )
  CreateDialog WindowTool style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)