/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: Manage scene xrefs
:History:V:1.0

:Todo: Add convert xref to vray proxie
:Bugs:
:Tests:
*******************************************************HeaderEnd*/

--FUNCTIONS

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

FileName = (getFilenameFile this_xref.filename)
new_dummy.rotation.controller[3].controller.value = Name_dummy.rotation.controller[3].controller.value
new_dummy.pos = Name_dummy.pos
new_dummy.name = FileName
select new_dummy
	
)

enableSceneRedraw()	
)

)

fn AddNew_Xref File: =
(

	try (
--add exref
new_xref = xrefs.addNewXRefFile File
aXref  = new_xref

CenterXref = aXref.tree.children
Center_pos = CenterXref.center
new_dummy = dummy()
new_dummy.name = (getFilenameFile new_xref.filename)
new_dummy.pos = Center_pos

--make new dummy
new_dummy.boxsize= [7000,7000,7000]
new_xref.parent = new_dummy
coordSysTM = Inverse(getViewTM())
viewPt = coordSysTM.row4

	new_dummy.pos = viewPt
	
	select new_dummy
-- Sel = $	
-- Sel.pos = viewPt
) catch()
	
)

--#################################################
fn DELXref del: updateX: =
(
	try (
	--to replace with  function lib
	sel_parent = selection[1]
	xref_max_index = xrefs.getXRefFileCount()

	for i = 1 to xref_max_index do 
	(
	this_xref = xrefs.getXrefFile i

	this_xref_parent = this_xref.parent


	if (this_xref_parent != undefined) and (this_xref_parent == sel_parent) then 

	(

	if del == true do (delete this_xref)
	if updateX == true do (updateXRef this_xref)
	)

	)

	)catch()
)

fn Xref Arr: Arr2: =
(
	
--  Maxfiles = #()
 xref_max_index = xrefs.getXRefFileCount()
 

 for x = 1 to xref_max_index do
 (
	 this_xref = xrefs.getXrefFile x
	 append Arr (this_xref.filename)

 )

 for i = 1 to Arr.count do
 (
	 if findItem Arr2 Arr[i] == 0 then append Arr2 Arr[i]
 )
)

fn RelinkAsset NewPath: FileType:"*.max"=
(
  Try(
 	ATSOps.Refresh()  		
	Asset =#() 
	ATSOps.GetFiles &Asset 
	deleteItem Asset 1
 
	
 for i = 1 to Asset.count where matchpattern Asset[i] pattern:FileType do
 (

	ATSOps.SelectFiles Asset[i]
	NewFilePath = NewPath
	
	ATSOps.SetPathOnSelection NewFilePath
 )
 )catch()
 
)


fn SelectXref ItemName: =
(
	
	try (
	SelOBJ = #()
	xref_max_index = xrefs.getXRefFileCount()
	
	for i = 1 to xref_max_index  do
	(
		filenameXref = xrefs.getXrefFile i
		print filenameXref.filename 
		
		if matchpattern filenameXref.filename pattern:ItemName then
		(
		print filenameXref.filename
		append SelOBJ filenameXref.parent
		)
	)
	select SelOBJ)catch()
)

struct var 
(
XrefFiles =#(),
XrefFilesUI =#()
)
var=var()



 try(destroydialog XrefManger) catch() 

 rollout XrefManger "Xref Manager" width:850
 (
	 listbox XrefItems "Scene Xrefs" height:20
	 button AddXrefToDummy "Add xref" width:120 height:30 across: 1
	 button SelInScene "Select In Scene" width:120 height:21 across: 1
-- 	 button ConvertProx "Convert Xref to Proxy"
	 
	 
	 group "RePathing"
	 (
	
	 edittext RelinkPath "New Path" across: 2 width:650
	 button RelinkAll "Relink All" width:120 height:21 across: 2 align:#right
	 )
	 
	group "Scene Dummy Options"
	(	 
	
		
	button DelDummy "Delete Selected Xref" width:120 height:30 across: 3
	button OpenXref "Open Selected Xref" width:120 height:30 across: 3
	button UpdateSEL "Update Selected" width:120 height:30 across: 3
	)
	
	fn reload =
	(
		var.XrefFiles =#()
		var.XrefFilesUI = #()
		Xref Arr:var.XrefFiles Arr2:var.XrefFilesUI
		XrefItems.items = var.XrefFilesUI
	)
	
	on RelinkAll pressed do
	(
		if queryBox "Do you Want to repath all xrefs?" do (
		try (
		RelinkAsset NewPath:RelinkPath.text FileType:"*.max"
		messagebox "xrefs relinked"	)catch()
			)
		
		reload()
	)
	
	on SelInScene pressed do
	(
		try(
		SelectXref ItemName:var.XrefFilesUI[XrefItems.selection] )catch()
	)
	
	on UpdateSEL pressed do
	(
		try(
		if selection.count == 1 then
		(
		DELXref del:false updateX:true
		reload()
		)else (messagebox "Please Select 1 Dummy"))catch()
	)
	
	on DelDummy pressed do
	(   try(
		if selection.count == 1 then
		(
		DELXref del:true updateX:false
		reload()
		)else (messagebox "Please Select 1 Dummy"))catch()
	)
	
	on OpenXref pressed do
	(
		try(
		if selection.count == 1 then
		(
		CloneXref OpenXref:true 
		)else (messagebox "Please Select 1 Dummy"))catch()
		
	)
	
	on AddXrefToDummy pressed do
	(
		try(
		GetFMaxFiles = getOpenFileName()
		AddNew_Xref File:GetFMaxFiles
		reload() )catch()
	)
	
	on XrefManger open do
	(
		try(
		Xref Arr:var.XrefFiles Arr2:var.XrefFilesUI
		XrefItems.items = var.XrefFilesUI
			)catch()
		
	)

 ) 
 CreateDialog XrefManger style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)
 
 
