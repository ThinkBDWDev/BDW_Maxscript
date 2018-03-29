-------------------------------------------------------------------------

/*
Name				: adbackFaceCulling
Version			: 1.0.0
Description		: This script turns off the "backfaceCulling" for all objects in the scene
Type				: GUI
Date Created   	: 2015/02/17
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 	

*/


-------------------------------------------------------------------------

(



allObjectsInSceneBC = $*

rollout adbackFaceCullingRollout "adbackFaceCulling" width:176 height:192
(
	button btnECul "Enable Backface Culling" pos:[16,112] width:144 height:32
	button btnDCul "Disable Backface Culling" pos:[16,72] width:144 height:32
	label lbl1 "adBackFaceCulling" pos:[48,16] width:88 height:16
	HyperLink cust3 "Web Help" pos:[64,40] width:56 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[40,160] width:104 height:24 address:"www.ashishdani.com"
	
	
	
	
	
	on btnECul pressed do
	(
		for OBJbc in allObjectsInSceneBC do
		(
			-- Turn off backfaceCulling
			OBJbc.backfacecull = on
		)
	)
	on btnDCul pressed do
	(
		for OBJbc in allObjectsInSceneBC do
		(
			-- Turn off backfaceCulling
			OBJbc.backfacecull = off
		)
	)
)



fn adBackfaceCullingDefaults =
(
	createdialog adBackfaceCullingRollout()
)


)
