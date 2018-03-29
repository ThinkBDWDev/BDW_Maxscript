rollout test ""
	
(
	global ITM = #()
	
	
	pickbutton AddObj "Add Object"
	button Remove "Remove"
	button AddSel "Add Selection"
	listbox objlist "Objects"
	
	on AddObj picked o do
		(
			source = o
			appendifunique ITM Source.name
			objlist.items = ITM
			
			)
	
		on Remove pressed do 
	(
		deleteItem ITM objlist.selection
		objlist.items = ITM
	)
	
	
		on AddSel pressed do
	(
		Source = selection as array
		
		for o in Source do (appendifunique ITM o.name)
		
		objlist.items = ITM
	)
	
	
	
	
	)
createdialog test