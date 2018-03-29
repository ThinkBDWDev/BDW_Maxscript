-------------------------------------------------------------------------
/*
Name				: adSelectBySceneMaterial
Version			: 1.0.0
Description		: Script to select the objects assigned to a particular material
Type				: GUI
Date Created   	: 2015/03/06
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com


UPDATES			:

*/
-------------------------------------------------------------------------



 
(

 

global SceneMatList = #()


 


 

rollout adSelBySceneMatRoll "adSelectBySceneMaterial" width:264 height:280
(


	button btnGetAllSceneMat "Get Materials" pos:[56,56] width:152 height:32

	listbox lbxAllSceneMat "All Scene Materials" pos:[16,96] width:232 height:9 enabled:false



                

                


	label lbl7 "adSelectBySceneMaterial" pos:[64,16] width:128 height:16

	
	
	HyperLink cust3 "Web Help" pos:[200,16] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[80,248] width:104 height:24 address:"www.ashishdani.com"	
	
	

                


	GroupBox grp12 "" pos:[8,40] width:248 height:200

	on btnGetAllSceneMat pressed do
	(
	
	    SceneMatList = for a in SceneMaterials collect a.name
	
	    /*           
	
	    for a in SceneMatList do
	
	    (
	
	        print (a as string)
	
	    ) */
	
	    lbxAllSceneMat.enabled = true
	
	    lbxAllSceneMat.items = SceneMatList
	
	)
	on lbxAllSceneMat selected itm do
	(
	
	    select (for x in Geometry where x.material != undefined and x.material.name ==lbxAllSceneMat.selected collect x)
	
	)
)


 
 
fn adSelectBySceneMaterialDefaults =
(
	createdialog adSelbySceneMatRoll
)


)