-------------------------------------------------------------------------

/*
Name				: adCollapseAllModifiers
Version			: 1.0.0
Description		: Collapses the full stack (all modifiers)
Type				: GUI
Date Created   	: 2015/07/27
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 

*/


-------------------------------------------------------------------------
(

fn adCollapseMod adAllStack=
(

	if $ == undefined then
	(
		Messagebox "Please select atleast one object" title:"CollapseAllModifiers"
	)
	else
	(
		for z in $ do
		(
			if z.modifiers.count == 0 do
			(
				print ("For " + (Z.name as string) + "	No Modifiers added in")
			)
			/*
			-- For Future USE
			if z.modifiers.count != 0 AND adAllStack == false do
			(
				for j=1 to z.modifiers.count do
				(
					if classof z.modifiers[j] ==Shell then
					(
						print ("SHELL")
						maxOps.CollapseNode z off
					)
				)
				--convertTo z PolyMeshObject
			)
			*/
			if z.modifiers.count !=0 AND adAllStack == true do
			(
				maxOps.CollapseNode z off
				if classof z == Editable_Mesh then
				(
					print (classof z as string)
					convertTo z PolyMeshObject		-- Convert to Editable Poly
				)	
			)
			
		)
	)

)
rollout adCollapseModRoll "adCollapseMod" width:160 height:128
(
	button btnColAll "Collapse All Modifiers" pos:[16,40] width:128 height:40
	HyperLink cust3 "Web Help" pos:[56,8] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[32,96] width:104 height:24 address:"www.ashishdani.com"
	GroupBox grp1 "" pos:[8,24] width:144 height:64
	
	
	on btnColAll pressed do
	(
		print ("\n\tCollapse All Pressed")
		allStack = true
		adCollapseMod(allStack)
	)
)




fn adCollapseModDefaults =
(

	createdialog adCollapseModRoll()
	

)

)