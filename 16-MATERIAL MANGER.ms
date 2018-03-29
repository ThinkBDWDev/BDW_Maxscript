
try Destroydialog  mats catch()

rollout mats "Materials" width:162 height:294
(
	GroupBox grp1 "Exterior Materials" pos:[10,15] width:142 height:253
	button Bricks "bricks" pos:[22,40] width:118 height:37
on Bricks pressed do
	(
	filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\Material manager\Brick_materials.ms"
	)
	
	
	button render "Render" pos:[22,85] width:118 height:37
	on render pressed do
	(
	filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\Material manager\Render_materials.ms"	
	)
	button General "General House Mats" pos:[22,130] width:118 height:37
		on General pressed do
	(
	filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\Material manager\General_materials.ms"	
	)
-- 	button Glass "Glass" pos:[22,174] width:118 height:37
-- 		on Glass pressed do
-- 		(
-- 	
-- 	)
	
	button RoofTiles "RoofTiles" pos:[22,174] width:118 height:37
on RoofTiles pressed do
		(
		filein @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\Material manager\RoofTiles_materials.ms"	
	)
	
	
	
	
	


	
)

Createdialog Mats  pos: [1005,100]