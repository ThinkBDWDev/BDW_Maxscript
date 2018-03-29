-- Gizmo Dude v 1.0 --
-- By Saad Minhas --

try (destroydialog GizmoDudeRollout) catch()
rollout GizmoDudeRollout "GizmoDude" width:168 height:136
(
	button PeopleBtn "People" pos:[32,88] width:48 height:31
	button PeopleReset "Reset" pos:[96,88] width:48 height:31
	spinner PeopleSpn "Radius" pos:[40,56] width:100 height:16 range:[0,5000,1500] type:#integer
	GroupBox grp3 "People Gizmos" pos:[8,32] width:152 height:96
	label lbl1 "Gizmo Dude v 1.0" pos:[8,8] width:144 height:16
	
	
	on PeopleBtn pressed do
	(
		
	if selection.count != 0 do 
	(
		disableSceneRedraw()
		layerManager.newLayerFromName "AnimPeople_Gizmos"
		Lay = layermanager.GetLayerFromName "AnimPeople_Gizmos"
		
		for i in selection do
		(
			peoplegiz = spheregizmo()
			peoplegiz.name = uniquename "PeopleGiz_"
			peoplegiz.radius = PeopleSpn.value
			peoplegiz.scale = [1,1,1.5]
			peoplegiz.pos = i.pos
			peoplegiz.parent = i
			Lay.addNode peoplegiz
		)
		enableSceneRedraw()
	)if selection.count == 0 do
		(
		messagebox "Duh! \n Please Select atleast one object!" 
		)
	)
	
	
	on PeopleReset pressed do
	(
		max select none
		Lay = layerManager.getlayerfromname "AnimPeople_Gizmos"; 	
		Lay.Select on
		delete$
	)
	on PeopleSpn changed val do
		(
	
	)
)
createdialog GizmoDudeRollout
