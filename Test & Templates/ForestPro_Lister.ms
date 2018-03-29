global DisplayMode = ""
global SelFPObjs = #()
global SelFPObjs = (for i in objects where classof i == Forest_Pro  collect i)
global Cams = #()
Cams = for i in objects where classof i == Forest_Pro  collect i
	

CamNames = #()
for i=1 to Cams.count do
(CamNames[i] =Cams[i].name)

if Cams.count == 0 then
	(messagebox "No Forest Objects in the Scene!")
else
(

if 	Cams.count <= 5 then(ListboxSize = 10)else(ListboxSize = Cams.count)

try(destroydialog FPLister) catch()
rollout FPLister "Forest Pro Lister"
	
(

		
	multilistbox CamsList "Cameras" height:ListboxSize--items:CamNames
	dropdownlist DispMode "Display Mode" items:#("Mesh","Adaptative","Proxy","Point-Cloud")
	spinner Distro "Distribution" type:#integer range:[1000,60000,6000]
	checkbutton  UpdateSurf "Live Update" highlightColor:red 


on Distro changed o do
(for i in selection do(i.units_x = Distro.value)
)

	
on UpdateSurf changed state do
( 	if state == on then
		(
		SelFPObjs = (for i in objects where classof i == Forest_Pro  collect i)as array
-- 		SelFP = (selection as array)
		if SelFPObjs.count == 0 then
		(messagebox "NO forest pro in this Scene")
		else
		(
		for o =1 to SelFPObjs.count do
			(
			SelFPObjs[o].surfanim = on
			)

		)
	)
	else
	(for o =1 to SelFPObjs.count do
		(

		SelFPObjs[o].surfanim = off
		)	
	)
)	
	
	
on Dispmode selected o do
	(  SelFP = (selection as array)
		if SelFP.count == 0 then
		(messagebox "NO forest pro selected on the list")
		else
		(
		DisplayMode = (DispMode.selection - 1)
		for i in SelFP do
			(if classof i == Forest_Pro then($.vmesh = DisplayMode)
			else (messagebox "Select a forest Pro Object")
				
			)
		)
	)
	
-- 	on test open do CamsList.items = CamNames
		fn SelectionChanged =
		(
			CamsList.selection = for j in selection collect finditem CamsList.items j.name
			global Cams = Cams = for i in objects where classof i == Forest_Pro  collect i
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
			
on FPLister open do
(
-- 	
CamsList.items = CamNames
callbacks.removescripts id:#MLB_Camera_SEL
callbacks.addscript #selectionSetChanged "FPLister.SelectionChanged()" id:#MLB_Camera_SEL
callbacks.removescripts id:#ObjCreated_RGG
callbacks.addscript #nodeCreated "FPLister.SelectionChanged()" id:#ObjCreated_RGG
callbacks.removescripts id:#ObjDeleted_RGG
callbacks.addscript #nodePostDelete "FPLister.SelectionChanged()" id:#ObjDeleted_RGG
)

on FPLister close do
(
callbacks.removescripts id:#MLB_Camera_SEL
callbacks.removescripts id:#ObjDeleted_RGG
callbacks.removescripts id:#ObjCreated_RGG
-- FPLister=()
)
		
	)
createdialog FPLister
)