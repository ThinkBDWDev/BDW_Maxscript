(
 	global TestMapSamples 
 	try(destroyDialog TestMapSamples )catch()
 	local lights_state = #()
 	local lights_array = #()
 
 	fn collectLightsState = 
 	(
 		lights_state = #()
 		lights_array = for l in Lights where classof l != TargetObject collect l
 		for l in lights_array do 
 		(
 			try
 			(
 				append lights_state l.on
 				l.on = false
 			)
 			catch(append lights_state false)	
 		)
 	)
 	
 	fn restoreLightsState = 
 	(
 		for l = 1 to lights_array.count do 
 			try(lights_array[l].on = lights_state[l])catch()	
 	)
 	
 	fn renderMaterial mat size_x size_y=
 	(
 		if superclassof mat == Material then
 		(
 			disablesceneredraw()
 			with undo off
 			(
 				local old_selection = selection as array
 			local visibleObjects = for o in objects where not o.isHidden collect o
 				hide objects
 				collectLightsState()
 			om1 = omniLight pos:[99900.0,99900.0,100300.0] multiplier:1.5
 			om2 = omniLight pos:[100100.0,100000.0,99900.0] multiplier:2.0
 			s = sphere pos:[100000.0,100000.0,100000.0] mapcoords:true segs:24
 				uvw_mod = uvwmap Channel:1
 				uvw_mod.mapType=2
 				addmodifier s uvw_mod 
 				s.material = mat
 				t_o = targetObject pos:[100000.0,100000.0,100000.0]
 				c = TargetCamera target:t_o
 				c.pos = [100000.0,100000.0-65,100030.0] 
 			map_sample = render camera:c outputsize:[size_x,size_y] vfb:false
 				delete #(c,s,om1,om2)
 				unhide visibleObjects
 				select old_selection 
 				restoreLightsState()
 			)
 			enablesceneredraw()
 		)
 		else
 			map_sample = renderMap mat size:[size_x,size_y] scale:200
 		map_sample 
 	)
 
 	rollout TestMapSamples "Test Map Samples"
 	(
 		bitmap bmp_slot1 width:64 height:64 across:6
 		bitmap bmp_slot2 width:64 height:64
 		bitmap bmp_slot3 width:64 height:64
 		bitmap bmp_slot4 width:64 height:64
 		bitmap bmp_slot5 width:64 height:64
 		bitmap bmp_slot6 width:64 height:64
 		
 		button btn_updateSlots "Update Slots"
 		on btn_updateSlots pressed do
 		(
 			suspendEditing()
 			bmp_slot1.bitmap = renderMaterial meditMaterials[1] 64 64
 			bmp_slot2.bitmap = renderMaterial meditMaterials[2] 64 64
 			bmp_slot3.bitmap = renderMaterial meditMaterials[3] 64 64
 			bmp_slot4.bitmap = renderMaterial meditMaterials[4] 64 64
 			bmp_slot5.bitmap = renderMaterial meditMaterials[5] 64 64
 			bmp_slot6.bitmap = renderMaterial meditMaterials[6] 64 64
 			resumeEditing()
 		)	
 	)--end rollout
 	createDialog TestMapSamples 420 100
 )