macroScript Apply_IDs
	category:"BDW"
	toolTip:"ID Editor"
	icon: #("RGTools2",1)
(
	theNames = #()
	for o in Geometry where 
	o.material != undefined and findItem theNames o.material.name == 0 do 
	append theNames o.material.name 
(
rollout _mids "Material IDs"
(
	
	-------------------------------------------------------------------------------------------------------------------------------------
	label LABEL_OIDs "Objects IDs"  
	spinner _IDvalue "OBJ ID Value" range:[0,999,111] type: #integer
	
	-------------------------------------------------------------------------------------------------------------------------------------

	button _ApplyID "Apply ID" width:155
	on _ApplyID pressed do
	(
		
		if  $== undefined then
		(
			messagebox "No object selected"
					--destroydialog _mids
		)	
			
		else
			(
				$.gbufferchannel = _IDValue.value
	)
	)
	
	-------------------------------------------------------------------------------------------------------------------------------------


	-------------------------------------------------------------------------------------------------------------------------------------
	label LABEL_Mats "Material List" 
	Listbox myDropDownList items:theNames --width:155 align:#center
	on myDropDownList selected itm do
	select (for o in Geometry where try(o.material.name == myDropDownList.selected)catch(false) collect o)
	
	label LABEL_MIDs "Material IDs"
	
	spinner _MIDvalue "Mat ID Value" range:[0,15,1] type: #integer


	-------------------------------------------------------------------------------------------------------------------------------------	
	
	
	button _Matids "Apply Mat IDs"  width:155
	on _matids pressed do
			
			(
					objs = getCurrentSelection()

					for obj in objs do
						(
					vrmArr = getClassInstances vrayMtl target:obj

					for vrm in vrmArr do
								(
					vrm.override_effect_id = on
					vrm.effect_id = _MIDvalue.value
								)
						)
						print objs[1].material
						Place = objs[1].material 
						meditmaterials[1] = place
						meditMaterials[1].effectsChannel = _MIDvalue.value 
						print meditMaterials[1].effectsChannel
			)
	-------------------------------------------------------------------------------------------------------------------------------------

-- 	spinner _MIDvalue "Mat ID Value" range:[0,15,1] type: #integer
	
	
	-------------------------------------------------------------------------------------------------------------------------------------	
			
	button _IDREF "ID Refs" align:#Right 
	on _IDREF pressed do
	(REF = "//CGISERVER/BDWRenderC/CGIResources/References/Multimat_ID.txt"
		
			shelllaunch REF ""
	)
	-------------------------------------------------------------------------------------------------------------------------------------
	/*button _Matids2 "Apply Mat IDs VR"
	on _Matids2 pressed do
	(
		objs = getCurrentSelection()
	
	for i in objs where isProperty i #material do
	(	
	if classof i.material == VrayMtl do
	(
	i.material.override_effect_id = on
	i.material.effect_id = _MIDvalue.value
	)

	if classof i.material == MultiMaterial do
	(
	for ID = 1 to i.material.materialList.count do 
	i.material.materialList[ID].effect_id = _MIDvalue.value
	i.material.materialList[ID].override_effect_id = on
	)
	)
	)*/
		

	-------------------------------------------------------------------------------------------------------------------------------------
	
)

	createdialog _mids height:320 width:165 
)
)

-- Random Crap
/*(
objs = getCurrentSelection()

for i in objs where isProperty i #material do
(	
if classof i.material == VrayMtl do
(
i.material.override_effect_id = on
i.material.effect_id = matidd
)

if classof i.material == MultiMaterial do
(
for ID = 1 to i.material.materialList.count do 
i.material.materialList[ID].effect_id = matidd
i.material.materialList[ID].override_effect_id = on
)
)
)
*/
