	fn setup_isometric_view objs cam:"none"  =
	(
		--return the center of all the selected objects
		fn CenterPt objs =  (local totalPos=[0,0,0]; for obj in objs do totalPos = totalPos + obj.pos; avgPos = totalPos / selection.count; avgPos )
		
		--return the largest value from an array
		fn maxof vals = (local v=vals[1]; for v1 in vals do (if v1 > v do v=v1);v)
		
		--if there is no camera specified to zoom, then we'll build a quick 'isometric' camera to use.
		if (cam=="none") then
		(
			angleCam = Freecamera fov:45 pos:[0,0,0]
			rotate angleCam (angleaxis 45 [0,0,1])
			in coordsys local
			(
				rotate angleCam (angleaxis 45 [1,0,0])
				angleCam.pos.z = ( angleCam.pos.z + 100 )
			)
			viewport.setcamera angleCam
			cam=angleCam
		)
		
		local max2, fov, asp, v, dist
		vmax=0 -- declare local variables
		totalPos=[0,0,0]
		CenterOfSelection=[0,0,0]
		fov=0 -- initialize the fov value
		asp=1
		in coordsys cam -- work in coordinate system of the camera
		(
			for obj in objs where obj != cam do -- loop across all objects except the camera
			(
				if obj.min.z >=0 do continue -- if object is behind camera, skip it
				-- get max value of the object's bounding box, correcting for the image aspect ratio
				-- in the y values
				v = maxof #((abs obj.max.x),(abs obj.min.x),(abs (obj.max.y*asp)),(abs (obj.min.y*asp)))
				--keep the largest value of the whole selection
				vmax = maxof #(v,vmax)
				in coordsys world totalPos = totalPos + obj.pos;
				CenterOfSelection = totalPos / objs.count
				--fov = maxof #(fov,(2*atan(-v/obj.min.z))) -- increase fov if needed
			)
		)
		
		dist= (vmax/(sin(cam.fov/2)))
		format "dist: %\n" dist
		format "vmax: %\n" vmax
		in coordsys world cam.pos = CenterOfSelection
 		in coordsys cam cam.pos.z = dist*((dist/vmax)/2)
 	
	)
	
	setup_isometric_view $*