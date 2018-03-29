/*Quick Forest Access ***************************

 */

-- try(destroydialog ForestItems) catch() 

Global ForestOBJUI=#()
Global ForestOBJ=#()


rollout ForestItems "Forest Objects" 
(
	
	--UI items***********************************
	button updateFoerest "update Forest Objs" 
-- 	button ClearSurf "Clear Surfaces"
	
	group ""
	(
	
	Checkbox Display_chk "Disable Forest Objs" align: #center
	radiobuttons Vdesplay "" labels: #("PCloud", "Boxes")
		
	)
	listbox Itm_list "In File"
	button Add_items "Add Surfaces"
	button Add_Objects "Add Selected Items"
-- 	button HideSelected "Hide Selected"
	spinner Dens "density" type: #integer
	
	fn Reload =
	(
		
		ForestOBJUI=#()
		ForestOBJ=#()
		for o in objects where ClassOf o == Forest_Pro do (append ForestOBJ o)

		for i = 1 to ForestOBJ.count do
		(
		
			ForestOBJUI [i] = (ForestOBJ[i].name)
			
		)
		
		Itm_list.items = ForestOBJUI

	)
	
	--items density display
	on Dens changed state do
	(
	 for o in objects where ClassOf o == Forest_Pro do (o.cloudens = Dens.value)
	)	
	
	on HideSelected pressed do
	(
		
		ForestOBJ[Itm_list.selection].disabled= true
		
	)
	
	on ClearSurf pressed do
	(
			
		if queryBox "Do you Want Clear Surfaces?" then 

		(
		ForestToAdd= ForestOBJ[Itm_list.selection]
		deselect ForestToAdd
		ForestToAdd.surflist = #()
		)
		
	
	)
	
	
	on Add_Objects pressed do
	(
		
		ForestItem = ForestOBJ[Itm_list.selection]
		deselect ForestItem
		SelOBJs = (selection as array)
		
		if SelOBJs.count !=0 then
		(
		
		for o in SelOBJs do
			(
			ListItems = ForestItem.namelist.count
			ForestItem.tempnamelist[ListItems + 1] = "One Plane"
			ForestItem.namelist [ListItems + 1] = o.name
			ForestItem.geomlist [ListItems + 1] = 2
			ForestItem.usemeshdimlist [ListItems + 1] = on
			ForestItem.conamelist [ListItems + 1] = o.name
			ForestItem.cobjlist [ListItems + 1] = o
			ForestItem .problist [ListItems + 1] = 100
			)
		
		)else (messagebox "No Items Selected!")
	)
	
	--Display Radiobuttons***********************************
	on Vdesplay changed state do
	(
		if Vdesplay.state ==1 do 
		(for o in objects where ClassOf o == Forest_Pro do (o.vmesh = 3))
		if Vdesplay.state ==2 do 
		(for o in objects where ClassOf o == Forest_Pro do 
			(
				o.vtype = 2
				o.vmesh = 1
			)
		)
	)
		
	--Listbox  Select items***********************************
	on Itm_list selected i do
	(
		SelectForest= ForestOBJ[i]
		Select SelectForest
	)
		
	--Add items to selected***********************************
	on Add_items pressed do
	(
		ForestToAdd= ForestOBJ[Itm_list.selection]
		deselect ForestToAdd
		ItemsToAdd = (selection as array)
		
		if ItemsToAdd.count != 0 then
		(
		ForestSurfaceList = ForestToAdd.surflist
		for o in ItemsToAdd do (append ForestSurfaceList o)
		) else (messagebox "No Items Selected!")
	)
	
	--Update Items***********************************
	on updateFoerest pressed do
	(
	for o in objects where ClassOf o == Forest_Pro do (o.surfanim = true )
	)
	
	--Hide Items***********************************
	on Display_chk changed state do
	(
		if state== on then
			(
			for o in objects where ClassOf o == Forest_Pro do 
				(o.disabled= true)
			)
			
		else 
			(
				for o in objects where ClassOf o == Forest_Pro do 
					(o.disabled= false)
			)
	)
		
	--UI Open***********************************
	on ForestItems open do
	(
		Reload()
		callbacks.removescripts id:#Test
		callbacks.addscript #selectionSetChanged "ForestItems.Reload()" id:#Test
		
	)
	
	on ForestItems close do
	(
	callbacks.removescripts id:#Test
	ForestOBJUI=undefined
	ForestOBJ=undefined

	)
	
)
createdialog ForestItems
