/*
	 ___ ___   _         _         
	| | | . |_| |___ ___|_|___ ___ 
	|_  | . | . | -_|_ -| | . |   |
	  |_|___|___|___|___|_|_  |_|_|
	                      |___|    
					  
	author: Fabian Groß, 48design.de
	client: www.zwischendrin.com

*/

(
	try (DestroyDialog InstancesToVRayProxyUI) catch ()
	global InstancesToVRayProxyUI
	
	local proxyPath = @"C:\"
	
	function instancesToVrayProxy=
	(
		local objSet = for o in selection where superClassOf o == GeometryClass AND classOf o != VRayProxy collect o
		local objSetFinished = #()
		local i, o
		local obj, obj_copy, obj_proxy, proxy_instance
		
		setWaitCursor()
		disableSceneRedraw()
		with undo off with redraw off
		(
			while objSet.count > 0 do
			(
				obj = objSet[1]
				deleteItem objSet 1
				append objSetFinished obj
				
				InstanceMgr.GetInstances obj &instances
				join objSetFinished instances
				for i in instances where (foundIndex = findItem objSet i) != 0 do deleteItem objSet foundIndex
				
				obj_copy = copy obj
				obj_copy.pos = [0,0,0]
				obj_copy.rotation = (quat 0 0 0 1)
				obj_copy.scale = [1,1,1]
				ResetXForm obj_copy
				
				if (vrayMeshExport meshFile:(proxyPath+obj.name+".vrmesh") autoCreateProxies:false exportMultiple:false animation:off nodes:obj_copy) == OK do
				(
					obj_proxy = VRayProxy fileName:(proxyPath+obj.name+".vrmesh") position:obj_copy.position proxy_scale:1.0 import_weldVertices:true
					for i in instances do
					(
						proxy_instance = instance obj_proxy
						proxy_instance.transform = i.transform
						proxy_instance.name = i.name
						proxy_instance.parent = i.parent
						proxy_instance.wirecolor = i.wirecolor
						proxy_instance.material = i.material
						delete i
					)
					delete obj_proxy
				)
				delete obj_copy
			)
		)
		enableSceneRedraw()
		redrawViews()
		setArrowCursor()
	)
	
	fn checkPath str=
	(
		if str != undefined AND str != "" then
		(
			if str[str.count] != @"\" do str += @"\"
		)
		else str = proxyPath
		str
	)
	
	rollout InstancesToVRayProxyUI "Instances to VRayProxy - www.zwischendrin.com"
	(
		group "Select VRayProxy output"
		(
			edittext txt_proxyPath "" text:proxyPath across:2 align:#left width:310 height:20
			button btn_proxyPathPick "..." align:#right tooltip:"output to system root only possible with admin rights!"
		)
		
		group "Replace selected Instances with VRayProxies"
		(
			button btn_doIt "Replace" width:350 height:30
		)
		
		on txt_proxyPath changed val do
		(
			txt_proxyPath.text = checkPath val
		)
		
		on btn_proxyPathPick pressed do
		(
			new_save_path = getSavePath caption:"select a folder" initialDir:proxyPath
			proxyPath = txt_proxyPath.text = checkPath new_save_path
		)
		
		on btn_doIt pressed do instancesToVrayProxy()
	)

	createDialog InstancesToVRayProxyUI 375 120	
)