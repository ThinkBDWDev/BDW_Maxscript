
VR = renderers.current
			
global ListboxSize = ""		



OverMat =VR.excludeListOverrideMtl
-- VR.excludeListOverrideMtl = #()
-- VR.excludeListOverrideMtl = OverMat
OverMatNameList = #()
for i = 1 to OverMat.count do
	(
		OverMatNameList[i] = OverMat[i].name
		
		)


if OverMat.count <= 10 then (ListboxSize = 10)
else (ListboxSize = OverMat.count)

	
rollout test ""
	
(

		
	multilistbox OverMatList "Override Object List" height:ListboxSize--items:CamNames
	
	
-- 	on test open do CamsList.items = CamNames
		fn SelectionChanged =
		(
			OverMat =VR.excludeListOverrideMtl
			
			OverMatList.selection = for j in selection collect finditem OverMatList.items j.name
			OverMat =VR.excludeListOverrideMtl
			OverMatNameList = #()
			for i = 1 to OverMat.count do
				(
					OverMatNameList[i] = OverMat[i].name
					
					)	
			OverMatList.items = OverMatNameList

			)

button AddToList "Add to Exclude"
button RemoveFromList "Remove from Exclude"

on AddToList pressed do
	(
		VR = renderers.current
		TempList =VR.excludeListOverrideMtl
		(
			
			nodes = selection as array
			if nodes.count != 0 do VR.excludeListOverrideMtl = nodes
				for i = 1 to nodes.count do
					(appendIfUnique TempList nodes[i])
			VR.excludeListOverrideMtl = TempList	
		)
SelectionChanged()
)


on RemoveFromList pressed do
	(
		VR = renderers.current
		SEL = (selection as array)		
		NewList =VR.excludeListOverrideMtl	
		for i = 1 to NewList.count do
			(
				global TEMP = findItem NewList SEL[i] 
				if temp != 0 then
					(deleteitem NewList TEMP)
				print TEMP
		
 		) 
	VR.excludeListOverrideMtl = NewList
	SelectionChanged()	
	)
			
			
			
		
	on  OverMatList selected o do
		(
			print OverMatList.selection
			selNames = for i in OverMatList.selection collect OverMatList.items[i]
			print o
			select (for j in OverMatList.selection collect getnodebyname OverMatList.items[j])
			
			)
	on OverMatList rightclick o do
		(
			clearselection()
			OverMatList.selection = #{}
			)
			
on test open do
(
	
OverMatList.items = OverMatNameList
callbacks.removescripts id:#MLB_Camera_SEL
callbacks.addscript #selectionSetChanged "test.SelectionChanged()" id:#MLB_Camera_SEL
callbacks.removescripts id:#ObjCreated_RGG
callbacks.addscript #nodeCreated "test.SelectionChanged()" id:#ObjCreated_RGG
callbacks.removescripts id:#ObjDeleted_RGG
callbacks.addscript #nodePostDelete "test.SelectionChanged()" id:#ObjDeleted_RGG
)

on test close do
(
callbacks.removescripts id:#MLB_Camera_SEL
callbacks.removescripts id:#ObjDeleted_RGG
callbacks.removescripts id:#ObjCreated_RGG
test=()
)


		
	)
createdialog test
