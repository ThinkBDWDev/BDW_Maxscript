	
macroScript Removelayers
category:"BDW"
toolTip:"Remove Empty layers"
(


	fn RemoveEmptyLayers =
	(
	DeletedLayerCount = 0

	deflayer = LayerManager.getLayer 0

	deflayer.current = true

	for i = Layermanager.count-1 to 1 by-1 do

	(

	layer = layermanager.getLayer i

	local thislayername = layer.name

	layer.nodes &theNodes

	if thenodes.count== 0 then (LayerManager.deleteLayerbyname thislayername;DeletedLayerCount +=1)

	)

	if not DeletedLayerCount == 0 then Messagebox ("Number of layers removed – " + DeletedLayerCount as string) title:"Layer Manager"
	)


	RemoveEmptyLayers()


)
