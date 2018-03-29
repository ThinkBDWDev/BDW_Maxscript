
MatLib = #("Brick", "Tiles", "Glass","Frames","Lead","Fascia","Aluminium","Chrome","Wheatherboarding","wood","Mortar","Stone","Plants", "Interiror Wall","Int Furniture","Road","Paving", "Kerb","Grass","Hedge","Water","Railings")
try(destroydialog _matPicker)catch()
rollout _matPicker "Name Selector"
(
	edittext _SUFx "Add Suffix" 
	listbox _matList "Materials" items:matLib  
	button _applyName "Apply Name" height:45 width:140 pos:[10,365]
	button m2o "Material to Object" width:140 height:45 pos:[10,410]
	button o2m "Object to Material" width:140 height:45 pos:[10,455]
	
	
	on _matList rightclick do
	(actionMan.executeAction 0 "40109")
	
	
	
	on _applyName pressed do
		(
		for i in selection do
				(
					NameMat = _matList.selected + "_" + _SUFx.text
					i.name =  uniquename NameMat --MatLib[_matList.selection] 
					$.wirecolor = [random 0 255,random 0 255,random 0 255]
				)
					
-- 		for o in selection do
-- 				(
-- 					o.name = o.name + "_" + _SUFx.text
-- 					)
		)
		
		
		
	
	on m2o pressed do
	(

			for i in objects where i.material != undefined  do 
		(

			i.name = (uniquename i.material.name )
-- 		
			i.name
		)
		
	)
	

on o2m pressed do	
(
			for i in objects where i.material != undefined  do 
		(

			i.material.name = (uniquename i.name )
-- 		
		
		)
	)
on _matPicker open do
( 
-- 	print (_matList.items.count)
	_matList.height = 310
	
)
	
	
	
	)
	
createdialog _matPicker height:525