/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose:
:History:V:1

:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/

macroScript CollapseQuad
	category:"BDW"
	toolTip:"CollapseQuad"
	
(

	fn GetOBJ_ByMod Objs: ModifierType: OutputArr: =
	(
		Mods = (for o in Objs where ((findItem (for m in o.modifiers collect classOf m) ModifierType) > 0 )collect o)
		for i =1 to Mods.count do append OutputArr Mods[i]
	)

	fn collapseToMod ModifierType: Arr: =
	(
		--GET MODIFIER
		iMod = ModifierType
		
		for obj in Arr do
		(
			for i in obj.modifiers.count to 1 by -1 where
				classof obj.modifiers[i] == iMod do
				(
					maxops.CollapseNodeTo obj i true  
					exit
				)
		)
	)



	fn collapseFloorGen_QuadChamf =
	(
		ItemsToCollapseQuad = #()
		GetOBJ_ByMod Objs:objects ModifierType:Quad_Chamfer OutputArr:ItemsToCollapseQuad
		
		if ItemsToCollapseQuad.count !=0 do
		(
			if querybox "Collapse quad chamfer?!" then 
			(
				collapseToMod ModifierType:Quad_Chamfer Arr:ItemsToCollapseQuad
			)
		)
	) 
	
	
	collapseFloorGen_QuadChamf()

)