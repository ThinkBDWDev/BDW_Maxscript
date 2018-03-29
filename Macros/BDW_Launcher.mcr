macroScript BDW_Launcher category:"BDW" tooltip:"BDW Toolbox" Icon:#("BDW",1)


(
	/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose:
:History:V:1.0

:Todo:
:Bugs: 
:Tests:

*******************************************************HeaderEnd*/

struct varToobox
(
	ItemCount = #(),
	ToolsPath = @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Updated_Toolbox_Catalog\",

	IsExpanded = false,

	hit = undefined,

	MatItems = #(),
	MatItemsUI =#(),


--FUNCTIONS ######################################

	fn getFilesRecursive root: pattern: arr: =
(
	dir_array = GetDirectories (root+"/*")
	for d in dir_array do
	join dir_array (GetDirectories (d+"/*"))
	my_files = #()
	for f in dir_array do
	join my_files (getFiles (f + "*" + pattern + "*"))
	my_files
	for i in my_files do (append arr i)
	),


fn SearchToolbox ArrIn: patternRun: =
(
	varToobox.getFilesRecursive root:varToobox.ToolsPath pattern:(patternRun) arr:ArrIn


	),


fn GetScripts tv: dir: c: =
(
	dirs=getdirectories (dir+"\\*") 
	for d in dirs do
	(
		dirNameAr=(filterstring d "\\")
		tvD= dotnetobject "System.Windows.Forms.TreeNode" dirNameAr[dirNameAr.count]
		tvD.backcolor = c

		tv.nodes.add tvD
		append varToobox.ItemCount dirNameAr.count 

		files=getfiles (d+"\\*.*")
		for F in files do
		(
			tvF = dotnetobject "System.Windows.Forms.TreeNode" (getfileNameFile f)
			tvD.nodes.add tvF
			tvF.tag=f
			append varToobox.ItemCount files.count 
			)

		varToobox.GetScripts tv:tvD dir:d c:undefined
		)

	)

	)

varToobox=varToobox()





--UI#############
try(destroydialog Mtool) catch()
rollout Mtool "BDWTools" width:255 height:700
(

	--logo
	imgTag img_header "Header" width:166 height:58.3 align:#center \ 
	bitmap:(openBitmap @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\Files\ThinkLogo.png") offset:[0,5] 

	label lb1 "ThinkBDW Tools" color:black
	progressBar lineBrake "" color:black value:100 height:1
	edittext SearchBox "Search"
	listbox SearchItems "" height:5


	button expndALL "open close all" align: #center
	DotNetControl tv "System.Windows.Forms.TreeView" width:230
	button RunScript "Run Script" pos:[12,640] width:230 height: 40



	fn reLoad = 
	(

		if SearchBox.text != "" then
		(
			SearchItems.items = varToobox.MatItemsUI
			)
		else
		(

			SearchItems.items = #()


			)
		)

	on SearchBox changed state do
	(
		try
		(
			FoundFiles = #()
			varToobox.SearchToolbox ArrIn:FoundFiles patternRun:SearchBox.text

			varToobox.MatItems = FoundFiles
			varToobox.MatItemsUI = for mat in FoundFiles collect getFilenameFile mat
			reLoad()

			)catch()
		)

	on SearchItems doubleClicked item do
	(

		filein varToobox.MatItems[SearchItems.selection]

		)


	on expndALL pressed do (

		try(
			if varToobox.IsExpanded == false then (

				varToobox.IsExpanded = true
				tv.ExpandAll()
				tv.Refresh()

				)

			else
			(
				varToobox.IsExpanded = false
				tv.CollapseAll()
				tv.Refresh()
				)

			)catch()

		)


	on tv DoubleClick sender arg do
	(  

		try 

		(

			varToobox.hit=tv.hittest arg.location
			runScriptFile = varToobox.hit.node.tag
			filein runScriptFile
			reLoad()

			) catch()
		)


	on tv mousedown sender arg do 
	(
		try
		(

			SearchBox.text = ""
			SearchItems.items = #()
			varToobox.hit= tv.hittest arg.location


			) catch()

		)

	on RunScript pressed do 
	(


		try
		(

			Items = (SearchItems.items)
			if Items.count == 0 then 
			(

				fPath=varToobox.hit.node.tag
				filein fPath

				)

			else 
			(
				filein varToobox.MatItems[SearchItems.selection]
				)

			) catch()
		)


	on Mtool open do 
	(
		-- 			  	showMethods tv.nodes.count	
		tv.nodes.clear()
		tv.fullRowSelect = true
		tv.showrootlines=true
		-- 				tv.ShowLines = true
		tv.ShowPlusMinus=true
		tv.ShowLines =false
		-- 	 		tv.Indent = 0
		tv.indent = 1 



		fn dotnetcolor r g b =

		(

			(dotnetclass "System.Drawing.Color").fromARGB r g b

			)


		tv.BackColor = (dotnetcolor 91 91 91)
		tv.Font = (dotnetobject "System.Drawing.Font" "Arial" 9) 
		tv.ForeColor = Tv.ForeColor.white

		varToobox.GetScripts tv:tv dir:varToobox.ToolsPath c:(dotnetclass "System.Drawing.Color").gray 
		Tv.height = 400
		Tv.width = 230


		)

	)


CreateDialog Mtool style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)

)