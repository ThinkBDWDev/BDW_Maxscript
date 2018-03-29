


global Cams = #()
Cams = for i in cameras where classof i == VRayPhysicalCamera or classof i == Freecamera  collect i
	

CamNames = #()
for i=1 to Cams.count do
(CamNames[i] =Cams[i].name)

if Cams.count == 0 then
	(messagebox "No cameras in the Scene!")
else
(

if 	Cams.count <= 5 then(ListboxSize = 10)else(ListboxSize = Cams.count)

	
rollout test ""
	
(

		
	multilistbox CamsList "Cameras" height:ListboxSize--items:CamNames
	
	
-- 	on test open do CamsList.items = CamNames
		fn SelectionChanged =
		(
			CamsList.selection = for j in selection collect finditem CamsList.items j.name
			global Cams = Cams = for i in cameras where classof i == VRayPhysicalCamera or classof i == Freecamera  collect i
			CamNames = #()
			for i=1 to Cams.count do
			(CamNames[i] =Cams[i].name)
			CamsList.items = CamNames
-- 			CamsList.height = Cams.count
			)

			
		
	on  CamsList selected o do
		(
			print CamsList.selection
			selNames = for i in CamsList.selection collect CamsList.items[i]
			print o
			select (for j in CamsList.selection collect getnodebyname CamsList.items[j])
			
			)
	on CamsList rightclick o do
		(
			clearselection()
			CamsList.selection = #{}
			)
			
on test open do
(
	
CamsList.items = CamNames
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
)