macroScript Clone_Xref2

category:"SoddsTools" buttonText:"Clone Xref2" Tooltip:"Clone Xref2"
-----------------------------------------------------------------------------------------------------------------------------------

(
--V4
--fix rotation - done
--add ui
--change dummy size -done

-----------------------------------------------------------------------------------------------------------------------------------    
    
Name_dummy= $.name	
Size_Dummy= $.boxsize
for i in selection do i.name =  "Use"
	
    
sel_parent = selection[1]
xref_max_index = xrefs.getXRefFileCount()

for i = 1 to xref_max_index do (

this_xref = xrefs.getXrefFile i
this_xref_parent = this_xref.parent
if (this_xref_parent != undefined) and (this_xref_parent == sel_parent) then (
new_xref = xrefs.addNewXRefFile this_xref.filename
aXref  = new_xref
CenterXref = aXref.tree.children
Center_pos = CenterXref.center
new_dummy = dummy()
new_dummy.name = Name_dummy
new_dummy.pos = Center_pos
select objects[objects.count]
$.boxsize=Size_Dummy
	new_xref.parent = new_dummy
    
))
$.rotation = $Use.rotation
$.pos = $Use.pos
$.scale = $Use.scale

for i in $Use  do i.name =  Name_dummy
	

)