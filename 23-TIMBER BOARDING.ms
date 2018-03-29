/*Make timber boarding ***************************

 ToDo
 Fix polyop for edge extrude

 */



 try(destroydialog makeBoarding) catch() 

 rollout makeBoarding "Make Boarding" 
 (
	 group "Board Type"
	 (
	 radiobuttons Type "" labels: #("horizontal","vertical")
	 )
	--checkbox vertical_chk "Vertical Boarding"
	spinner num_boards "Board Width" type:#integer range:[10,5000,10]
	spinner boardin_depth "Board Depth" type:#integer range:[5,5000,10]
	button makeBoards_btn "Make Boarding"
	--button makeEdged "make edges"
	 
	 --quick make edges***********************************
-- 	 on makeEdged pressed do
-- 	 (
-- 		 b = $
-- 		b.pivot = b.center
-- 		 
-- 		 modPanel.addModToSelection (sweep ()) ui:on

-- 		$.modifiers[#Sweep].CurrentBuiltInShape = 2
-- 		$.modifiers[#Sweep][#Bar_Section].length = 70
-- 		$.modifiers[#Sweep][#Bar_Section].width = 30
-- 			 
-- 		$.modifiers[#Sweep][#Bar_Section].cornerRadius = 0
-- 		$.modifiers[#Sweep].SmoothPath = off

-- 		 
-- 	 )
	 
	 --Make Boarding  button***********************************
	 on makeBoards_btn pressed do
	 (


		--make slices***********************************
		
		p = (selection as array)[1]
		p.pivot = p.center

		
		 --Set Matrix fo selection***********************************
		 if p!=undefined then
		 (
			resetxform p;
			RotateBack = quat -1 0 0 1
			p.rotation = RotateBack
			resetxform p;
			ConvertTo $ Editable_Poly
			$.EditablePoly.SetSelection #Edge #{}
			 
			zeroed = quat 0 0 0 1
			p.rotation = zeroed
			sticker = p.rotation
			SliceMin = p.min
			SliceMax = p.max
			 
			 
			 
			if Type.state ==2 then
			(
				--vertialc Boards***********************************
				Xmins = SliceMax.x-SliceMin.x
				XEnteredNo = num_boards.value
				XBoardNo = Xmins/XEnteredNo
				xchops = XBoardNo -- number of lice

				if xchops != undefined then
				(
				slicelen = slicemax-slicemin
				slicelen = slicelen/xchops
				for i = 1 to (xchops-1) do
				(
				slicepoint = [(slicemin.x+(i*slicelen.x)), (slicemin.y+(i*slicelen.y)), (slicemin.z+(i*slicelen.z))]
				p.slice [1,0,0] (slicepoint-p.pos)
				)
				)
			
			)
			
			
			if Type.state ==1 then
			(
				--Hoz Boards***********************************
				Ymins = SliceMax.y-SliceMin.y
				YEnteredNo = num_boards.value
				YBoardNo = Ymins/YEnteredNo
				Ychops = YBoardNo -- number of lice

				if ychops != undefined then
				(
				slicelen = slicemax-slicemin
				slicelen = slicelen/ychops
				for i = 1 to (ychops-1) do
				(
				slicepoint = [(slicemin.x+(i*slicelen.x)), (slicemin.y+(i*slicelen.y)), (slicemin.z+(i*slicelen.z))]
				p.slice [0,1,0] (slicepoint-p.pos)
				)
				)
				
			)
			
			
			
			p.rotation = sticker
			RotateTOStart = quat 1 0 0 1
			p.rotation = RotateTOStart


			--make barding extrude***********************************
			max modify mode
			subobjectLevel = 2

		
			$.edgeExtrudeHeight = boardin_depth.value *-1
			$.edgeExtrudeWidth = 12

			$.EditablePoly.buttonOp #Extrude
			$.EditablePoly.SelectEdgeRing ()
			max create mode
		
			polyop.chamferEdges $ #selection 3
			
			--name and colour***********************************
			$.name = uniquename "boarding"
			$.wirecolor = gray
			--END***********************************
		)
		else (messagebox "Pick Object")

	)

 ) 
 
 CreateDialog makeBoarding


