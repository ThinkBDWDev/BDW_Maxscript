macroScript CloneXref
	category:"BDW"
	toolTip:"CloneXref"

(



fn CloneXref OpenXref:false =
(


--VARS
new_dummy = undefined
Name_dummy= $
this_xref=undefined
FileName=undefined


	
SEL = $
	
if ClassOf SEL == dummy then
(

disableSceneRedraw() 	

sel_parent = selection[1]
xref_max_index = xrefs.getXRefFileCount()

for i = 1 to xref_max_index do 
(
this_xref = xrefs.getXrefFile i

this_xref_parent = this_xref.parent


if (this_xref_parent != undefined) and (this_xref_parent == sel_parent) then 

	(
		
		if OpenXref == true then
		(
		FileToOpen = this_xref.filename
        shelllaunch 	FileToOpen ""
		)
		
		else
		(
		new_xref = xrefs.addNewXRefFile this_xref.filename
		aXref  = new_xref
		
		CenterXref = aXref.tree.children
		Center_pos = CenterXref.center
		new_dummy = dummy()
		new_dummy.pos = Center_pos

		new_dummy.boxsize=Name_dummy.boxsize
		new_xref.parent = new_dummy
		)
	)

)

if OpenXref != true then
(

FileName = uniquename (getFilenameFile this_xref.filename)
new_dummy.rotation.controller[3].controller.value = Name_dummy.rotation.controller[3].controller.value
new_dummy.pos = Name_dummy.pos
new_dummy.name = FileName
select new_dummy
	
)

enableSceneRedraw()	
)

)

CloneXref OpenXref:false

)
