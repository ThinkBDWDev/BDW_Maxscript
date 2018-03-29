/*
	Wire Colour Tools for the fools with VRay.. 
	Written By David Mackenzie
	
	v1
*/
(

/* Simple Struct for working with Layers. Only 2 fns taken from DandG_LayerLib.ms */	

struct vi_layers (
	version = 1,
	man = LayerManager,
	fn getLayerList = (
		--Returns a list of layers
		layers = #()
		for i = 0 to man.count do(
			l = man.getLayer i
			if l != undefined do(
				append layers l.name
			)
		)--End Loop
		layers
	),
	fn getLayerNodes index = (
		--Returns a list of the nodes currently on the parsed layer index
		if index <= man.count then(
			layer = man.getLayer index
			if layer != undefined then(
				layer.nodes &tempNodes
				return tempNodes
			)
		)else()
	)--End FN
)
	
rollout wire_roll "Wire Colour Tools" (
	group "Change Wire Colour" (
		button btn_layer "Colour By Layer" across:3 width:100
		button btn_mat "Colour By Material" width:100
		button btn_rand "Random Colour"  width:100
	)
	group "Options" (
		checkbox chk_ifSel "Only on Selected" 
	)
	progressbar prg1 
	
	group "Help" (
		label lbl1 "Randomise wirecolour by layer, use 'Colour by Layer'" align:#left
		label lbl2 "Randomise wirecolour by materials, use 'Colour by Material'" align:#left
		label lbl3 "For all object to have random colour, 'Random Colour''" align:#left
	)
	
	/* FN Defs */
	fn calcPer val total = (
		ret = 100.0*val/total
		ret
	)
	fn randColour = (
		col = (color (random 0 255) (random 0 255) (random 0 255))
		col
	)
	fn randomBySceneMats = (
		v = 1
		tot = sceneMaterials.count
		for s in sceneMaterials do(
			wc = randColour()
			for o in (refs.Dependents s) do (
				if SuperClassOf o == GeometryClass then(
					try(
						if chk_ifSel.state == true then(
							if o.isSelected == True then(o.wirecolor = wc)
						)else(
							o.wirecolor = wc
						)
					)catch()
				)
			)
			prg1.value = (calcPer v tot)
			v += 1
		)
	)
	fn randomColours = (
		v = 1 
		tot = objects.count
		for o in objects do(
			try(
				if chk_ifSel.state == true then(
					if o.isSelected == true then(o.wirecolor = randColour())
				)else(
					o.wirecolor = randColour()
				)
			)catch()
			prg1.value = (calcPer v tot)
			v += 1
		)
	)
	fn randomByLayers = (
		lay = vi_layers()
		layers = lay.getLayerList()
		print layers
		v = 1
		tot = layers.count
		for l = 1 to layers.count do(
			col = randColour()
			for n in (lay.getLayerNodes (l - 1)) do(
				try(
					if chk_ifSel.state == True then(
						if n.isSelected == true then(n.wireColor = col)
					)else(
						n.wireColor = col
					)
				)catch()
			)
			prg1.value = (calcPer v tot)
			v += 1
		)
		lay = undefined 
	)
	
	/*Event Handlers*/
	on btn_layer pressed do (
		randomByLayers()
	)
	on btn_mat pressed do(
		randomBySceneMats()
	)
	on btn_rand pressed do(
		randomColours()
	)
)
createDialog wire_roll 350 200
	

)