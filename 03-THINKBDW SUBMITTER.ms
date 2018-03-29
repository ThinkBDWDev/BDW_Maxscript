UsersList = #()
UsersList = getdirectories @"\\CGISERVER\BDWRenderC\CGIRender\*"
	UsersListUI = #()
	for i =1 to UsersList.count do
		(
			UsersListUI[i] = (filterstring UsersList[i] @"\")[4]
			
			)
			
	try (destroydialog _USERSEL)catch()
Rollout _USERSEL "Select User"
			
(
	
	dropdownlist _User "User" items:UsersListUI	
	checkButton _StillsTool "Stills" Width:100 height:35
	checkbutton _Animation "Animations" Width:100 height:35
	checkbutton _AnimBF "Animation BF" Width:100 height:35




	
	on _StillsTool changed state do
		(
			If state == on then
			(
				global _UserSelected = _User.selected
				print _UserSelected
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\InteriorStillsSubmitter.ms")
			if state == off then
			(try(destroydialog IntStillsSubmitter )catch())
			)
			
	on _Animation changed state do
		(
			If state == on then
			(
				global _UserSelected = _User.selected
				print _UserSelected
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\03-RENDER CONTROL PANEL_Batch+Lightdependecy.ms")
			if state == off then
				(try(destroydialog _AnimCRTL)catch())
			)
	on _AnimBF changed state do
		(
			If state == on then
			(
				global _UserSelected = _User.selected
				print _UserSelected
				::filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\03-RENDER CONTROL PANEL_BruteForce.ms")
			if state == off then
				(try(destroydialog _AnimCRTLBF)catch())
			)
	
	
	
	)
createdialog _USERSEL pos:[100,100] Width:115
	
	
-- 			on RenderSettings changed state do
-- 			(
-- 				if state == on then
-- 					(renderscenedialog.open())
-- 				if state == off then
-- 					(renderscenedialog.close())
-- 				)	