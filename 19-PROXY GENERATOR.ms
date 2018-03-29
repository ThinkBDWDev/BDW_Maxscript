
disableSceneRedraw()
setWaitCursor() 

global proxyPath = @"\\CGISERVER\BDWRenderC\CGIResources\3D\Rodri G_OBJ_Library\Proxy_TempFolder\Trees\"


PathList = getdirectories @"\\CGISERVER\BDWRenderC\CGIResources\3D\Proxys\ProxyGenerator\*"

global PathListUI = #()

for i =1 to PathList.count do
	(
		PathListUI[i] = (filterstring PathList[i] @"\")[7]
		
		)
		



-- global ObjToProxy = (selection as array)

try(destroydialog ProxyGen)catch()
rollout ProxyGen "ProxyGenerator"

	
(

progressbar  conversionprog color:red
listbox Cats "Categories" items:PathListUI height: PathListUI.count
-- 	button TTT "Test" 
-- 	on TTT pressed do
-- 		
-- 	(	ExportPath = PathList[Cats.selection]
-- 		print ExportPath)
	
button ConvertObjs "Convert to Proxy"
	on ConvertObjs pressed do
		(	conversionprog.value = 0
			global ObjToProxy = (selection as array)
			
			with undo off with redraw off
				
			for i =1 to ObjToProxy.count do
			(	
				obj_copy = copy ObjToProxy[i]
				obj_copy.pos = [0,0,0]
				obj_copy.rotation = (quat 0 0 0 1)
				obj_copy.scale = [1,1,1]
				ResetXForm obj_copy
				
				
				ExportPath = PathList[Cats.selection]
				
				
				vrayMeshExport meshFile:(ExportPath+ObjToProxy[i].name+".vrmesh") autoCreateProxies:false exportMultiple:false animation:off nodes:obj_copy
-- 				saveNodes obj_copy MaxPath
				delete obj_copy
				
				
				obj_proxy = VRayProxy fileName:(ExportPath+ObjToProxy[i].name+".vrmesh") maxPreviewFaces:25000 position:ObjToProxy[i].position proxy_scale:1.0 import_weldVertices:true name:("VRProxy_" +ObjToProxy[i].name) 
				
				obj_proxy.material = ObjToProxy[i].material 
				
				delete ObjToProxy[i]
				
				MaxPath = ExportPath + obj_proxy.name + ".max"
				saveNodes obj_proxy MaxPath
				conversionprog.value = 100*i/ObjToProxy.count
			)
ObjToProxy = undefined			
conversionprog.color = green	
-- filein 			
		)
)
createdialog ProxyGen
setarrowCursor() 
enableSceneRedraw()
