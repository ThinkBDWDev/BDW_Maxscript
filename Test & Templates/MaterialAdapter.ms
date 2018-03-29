DotNet.LoadAssembly "System.Xml"

struct XMLNode(
	Tag,
	Parent,
	DotNetNode,
	
	fn init dnNode = (
		DotNetNode = dnNode
		Tag = dnNode.LocalName
		Parent = dnNode.ParentNode
	),
	
	fn GetTag = (
		DotNetNode.Name
	),

	fn GetText = (
		DotNetNode.InnerText
	), 

	fn GetAttribute attribute = (
		DotNetNode.GetAttribute attribute
	),

	fn GetAllAttributes = (
		ret = #()
		attribs = DotNetNode.Attributes
		for i = 0 to (attribs.Count - 1) do(
			t = #()
			item = (attribs.ItemOf i)
			append t item.Name
			append t item.Value
			append ret t
		)
		return ret
	),
	
	fn HasAttribute attribute =(
		DotNetNode.HasAttribute attribute
	),
	
	fn GetChild index = (
		dNode = DotNetObject.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = XMLNode()
			newNode.init dnode
			newNode
		)else(return False)
	),
	fn GetChildren = (
		nodes = #()
		for i = 0 to (DotNetNode.ChildNodes.Count - 1) do(
			dNode = DotNetNode.ChildNodes.ItemOf i
			newNode = XMLNode()
			newNode.init dNode
			append nodes newNode
		)
		nodes
	)
)

struct XMLDocument ( 
	file = undefined,
	rootNode = undefined,
	dom = dotNetObject "System.Xml.XmlDocument",
	loaded = undefined,
	
	fn LoadXML pathToXml = (
		file = pathToXml
		doc = dom.Load file
		loaded = True
		True
	),
	
	fn GetRootNode = (
		rootNode = XMLNode()
		rootNode.init dom.DocumentElement
		rootNode
	)
)

global AXYZ_matfiles=#()
global AXYZ_mainchilds=undefined
global AXYZ_MaterialMeshes=undefined
global AXYZ_MeshesSharingMaterial=undefined
global AXYZ_MaterialXML=undefined
global AXYZ_texture_search_names=#("diffuse","specular","normal","opacity")
global showDiffuseTextureOnViewport
global AXYZ_MaterialProcessMeshes
global roll_AXYZmats
global AXYZ_result_searchbitmap=#()

fn xmlLoad file=(
	xDoc = XMLDocument()										
	try(xDoc.LoadXML file) catch (
		if ((doesFileExist file)==false) then  return MessageBox "XML file doesn't exist" title:"XML File Error" 
		else return MessageBox "Error loading file" title:"XML File Error"	
	)	
	rNode = xDoc.GetRootNode()	
	AXYZ_mainchilds = rNode.GetChildren() 
	AXYZ_mainchilds
)

fn showDiffuseTextureOnViewport &mat =(
	
		nmat=getNumSubMtls mat
		--format "searchMatDest->procesando: % | nmat: % | origmap: %\n" matdest nmat origmap
		if (nmat!=0) then
		(
			for m=1 to nmat do
			(			
				currentmat=getSubMtl mat m
				if (currentmat != undefined) then	
				(
					showDiffuseTextureOnViewport &currentmat
				)
			)
		) 
	
		diffusetexture=undefined
 		mat.showinviewport = true
		possibleDifProperties=#(#diffusemap,#texmapDiffuse,#diffuse_tex,#texmap_diffuse)
		for i=1 to possibleDifProperties.count do
		(
			if(diffusetexture==undefined) then
				try(  diffusetexture = getProperty mat possibleDifProperties[i]) catch()
		)
		if(diffusetexture!=undefined) then (putTextureOnViewport mat diffusetexture false)--false means dont show it!
)

fn matlibLoad matfile=(
	try(mylib=loadTempMaterialLibrary matfile) catch (
		if ((doesFileExist matfile)==false) then  return MessageBox "matlib file doesn't exist" title:"Matlib File Error" 
		else return MessageBox "Error loading file" title:"Matlib File Error"	
	)
	return mylib
)

fn checkName current target =
(
	if target == "diffuse" then
	(
		if (matchpattern current pattern:"diffuse") then return true
		if (matchpattern current pattern:"difuse") then return true
		if (matchpattern current pattern:"diffusse") then return true
		if (matchpattern current pattern:"difuse") then return true
		return false
	)
	if target == "specular" then
	(
		if (matchpattern current pattern:"specular") then return true
		if (matchpattern current pattern:"especular") then return true
		return false
	)
	if target == "normal" then
	(
		if (matchpattern current pattern:"normal") then return true
		return false
	)
	if target == "opacity" then
	(
		if (matchpattern current pattern:"opacity") then return true
		return false
	)
	return false	 
)

fn searchBitmap target testbitmap =(
	--format "entrando en searchbitmap con testbitmap: % | target: %\n" testbitmap target
	if testbitmap != undefined then
	(
		num=getNumSubTexmaps testbitmap
		--format "seachbitmap-> numsubtex: % | testbitmap: %\n" num testbitmap
		if num>0 then 
		(
			for i=1 to num do 
			(
				currentmap=(getSubTexmap testbitmap i)
				if currentmap!=undefined then
				(
					--format "seachbitmap-> reenviamos a searchbitmap el mapa % | testbitmap: %\n" i currentmap
					searchBitmap target currentmap
					----format "seachbitmap-> resultmap: mapa % | %\n" i resultmap
					--if (resultmap!=false) then append AXYZ_result_searchbitmap resultmap
				)
				--else --format "seachbitmap-> undefined map in slot %\n" i
			)
		) 
		tipo=classof testbitmap
		--format "searchbitmap(en el else)->tipo mapa: % | mapa: % | con nombre:%\n" tipo testbitmap testbitmap.name
		if (((tipo==bitmaptexture) or (tipo==Bitmap_Thea)or (tipo==RGB_image) or (tipo==Alpha_image)) and (checkName testbitmap.name target)) then
		(
			append AXYZ_result_searchbitmap testbitmap
			--format "searchbitmap (en el else)-> añadimos testbitmap: % al array: %\n" testbitmap AXYZ_result_searchbitmap
			
		)
		else 
		return false
	)
	--return AXYZ_result_searchbitmap
)

fn searchMatDest target origmap matdest =(
	AXYZ_result_searchbitmap=#()
	local cambiado=false
	--por thea vamos a mirar primero texturas
	num=getNumSubTexmaps matdest
	
	if (num!=0) then
	(
		for i=1 to num do
		(
			currentmap=getSubTexmap matdest i
			--format "i: % | currentmap: %\n" i currentmap
			if (currentmap != undefined) then	
			(
				searchBitmap target currentmap 
				for element in AXYZ_result_searchbitmap do
				(
					if ((element!=false) and (element!=undefined)) then 
					(
						if (origmap==undefined) then 
						(
							(setSubTexmap matdest i undefined) 
						)
						else
						(		
							if classof element == Bitmaptexture then 
							(
								element.bitmap = origmap.bitmap		
								local rendername=renderers.current as string
								if( ((matchPattern rendername pattern:"*vray*") or (matchPattern rendername pattern:"*v?ray*") or (matchPattern rendername pattern:"*scanline*")) and
									   target=="normal" and IDisplayGamma.colorCorrectionMode == #gamma ) then
								(		
									element.output.output_amount = fileingamma							
								)					
								element.output.rgb_level = 1.0
							)
							else
							(
								element.filename = origmap.filename		
							)
							
						)
					)
				)
				AXYZ_result_searchbitmap=#()
				
			)
		)
	)
	
	nmat=getNumSubMtls matdest
	--format "searchMatDest->procesando: % | nmat: % | origmap: %\n" matdest nmat origmap
	if (nmat!=0) then
	(
		for m=1 to nmat do
		(			
			currentmat=getSubMtl matdest m
			--format "currentmat: % | m: %\n" currentmat m
			if (currentmat != undefined) then	
			(
				--format "se va a reenviar submaterial % (%) del material - % - de vuelta a la funcion\n" m currentmat matdest
				cambiado = searchMatDest target origmap currentmat 
				--format "cambiado antes de exit: %\n" cambiado
				if cambiado then return true
			)
		)
	) 
	else
	(
		num=getNumSubTexmaps matdest
		--format "Entramos ya con 1 solo mat (%). Subtexturas: %\n" matdest num
		for i=1 to num do
		(
			currentmap=getSubTexmap matdest i
			--format "i: % | currentmap: %\n" i currentmap
			if (currentmap != undefined) then	
			(
				searchBitmap target currentmap 
				for element in AXYZ_result_searchbitmap do
				(
					if ((element!=false) and (element!=undefined)) then 
					(
						if (origmap==undefined) then 
							(setSubTexmap matdest i undefined) 
						else(
							if classof element == Bitmaptexture then 
								element.bitmap = origmap.bitmap
							else
								element.filename = origmap.filename	
						)
					)
				)
				AXYZ_result_searchbitmap=#()
			)
		)
	)
	false
)

fn copyBitmapMulti target matorig matdest=(
	--format "copyBitmapMulti-> target: % | matorig: % | matdest: %\n" target matorig matdest
	if ((classof matorig)== Standardmaterial) then
	(
		case target of
		(
			"diffuse": (
				if (matorig.diffuseMap!=undefined) then
				(
					numsubs= getNumSubtexMaps matorig.diffuseMap
					origmap=matorig.diffuseMap
					if numsubs>0 then 
					(
						while numsubs>0 do
						(
							origmap=getSubTexmap origmap 1
							numsubs = getNumSubtexMaps origmap
						)
						parent=1
					)
					--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
					matdest=searchMatDest target origmap matdest 
				)
				else
				(
					origmap=matorig.diffuseMap
					searchMatDest target origmap matdest
				)
			)
			"specular": (
				if (matorig.specularLevelMap!=undefined) then
				(
					numsubs= getNumSubtexMaps matorig.specularLevelMap
					origmap=matorig.specularLevelMap
					if numsubs>0 then 
					(
						while numsubs>0 do
						(
							origmap=getSubTexmap origmap 1
							numsubs = getNumSubtexMaps origmap
						)
					)
					--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
					matdest=searchMatDest target origmap matdest
				)
				else
				(
					origmap=matorig.specularLevelMap
					searchMatDest target origmap matdest
				)
			)
			"normal": (
				if (matorig.bumpMap!=undefined) then
				(
					numsubs= getNumSubtexMaps matorig.bumpMap
					origmap=matorig.bumpMap
					if numsubs>0 then 
					(
						while numsubs>0 do
						(
							origmap=getSubTexmap origmap 1
							numsubs = getNumSubtexMaps origmap
						)
					)
					--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
					matdest=searchMatDest target origmap matdest
				)
				else
				(
					origmap=matorig.bumpMap
					searchMatDest target origmap matdest
				)
			)
			"opacity": (
				if (matorig.opacityMap!=undefined) then
				(
					numsubs= getNumSubtexMaps matorig.opacityMap
					origmap=matorig.opacityMap
					if numsubs>0 then 
					(
						while numsubs>0 do
						(
							origmap=getSubTexmap origmap 1
							numsubs = getNumSubtexMaps origmap
						)
					)
					--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
					matdest=searchMatDest target origmap matdest
				)
				else
				(
					origmap=matorig.opacityMap
					searchMatDest target origmap matdest
				)
			)
		)
	)
	else --si es vray
	(
		if ((classof matorig)== vraymtl) then
		(
			case target of
			(
				"diffuse": (
					if (matorig.texmap_diffuse!=undefined) then
					(
						numsubs= getNumSubtexMaps matorig.texmap_diffuse
						origmap=matorig.texmap_diffuse
						if numsubs>0 then 
						(
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
						matdest=searchMatDest target origmap matdest
					)
					else
					(
						origmap=matorig.texmap_diffuse
						searchMatDest target origmap matdest
					)
				)
				"specular": (
					if (matorig.texmap_reflection!=undefined) then
					(
						numsubs= getNumSubtexMaps matorig.texmap_reflection
						origmap=matorig.texmap_reflection
						if numsubs>0 then 
						(
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
						matdest=searchMatDest target origmap matdest
					)
					else
					(
						origmap=matorig.texmap_reflection
						searchMatDest target origmap matdest
					)
				)
				"normal": (
					if (matorig.texmap_bump!=undefined) then
					(
						numsubs= getNumSubtexMaps matorig.texmap_bump
						origmap=matorig.texmap_bump
						if numsubs>0 then 
						(
							while numsubs>0 do
							(
								origmap=getSubTexmap matorig.texmap_bump 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
						matdest=searchMatDest target origmap matdest
					)
					else
					(
						origmap=matorig.texmap_bump
						searchMatDest target origmap matdest
					)
				)
				"opacity": (
					if (matorig.texmap_opacity!=undefined) then
					(
						numsubs= getNumSubtexMaps matorig.texmap_opacity
						origmap=matorig.texmap_opacity
						if numsubs>0 then 
						(
							while numsubs>0 do
							(
								origmap=getSubTexmap matorig.texmap_opacity 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						--format "copyBitmapMulti-> enviamos a searchMatDest mapas orig:% dest:%\n" origmap matdest
						matdest=searchMatDest target origmap matdest
					)
					else
					(
						origmap=matorig.texmap_opacity
						searchMatDest target origmap matdest
					)
				)
			)
		)
	)
	
	if ((classof matorig)!= Standardmaterial and (classof matorig)!= vraymtl) then matdest = matorig
		
	matdest	
)

fn applySimpleMat mymesh meshmat matSimple=(
	--format "entramos en el applySimpleMat\n"
	for target in AXYZ_texture_search_names do 
	(
		if ((classof meshmat)== Standardmaterial) then
		(
			case target of
			(
			
				"diffuse": (
					if (meshmat.diffuseMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.diffuseMap
						origmap=meshmat.diffuseMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.diffuseMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.diffuseMap
						searchMatDest target origmap matSimple
					)
				)
				"specular": (
					if (meshmat.specularLevelMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.specularLevelMap
						origmap=meshmat.specularLevelMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.specularLevelMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.specularLevelMap
						searchMatDest target origmap matSimple
					)
					
				)
				"normal": (
					if (meshmat.bumpMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.bumpMap
						origmap=meshmat.bumpMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.bumpMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.bumpMap
						searchMatDest target origmap matSimple
					)
				)
				"opacity": (
					if (meshmat.opacityMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.opacityMap
						origmap=meshmat.opacityMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.opacityMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					) else
					(
						origmap=meshmat.opacityMap
						searchMatDest target origmap matSimple
					)
				)
			)
		)
		else --si es vray
		(
			case target of
			(	
				
				"diffuse": (
					if (meshmat.texmap_diffuse!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_diffuse
						origmap=meshmat.texmap_diffuse
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.diffuseMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.texmap_diffuse
						searchMatDest target origmap matSimple
					)
				)						
				
				
				"specular": (
					if (meshmat.texmap_reflection!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_reflection
						origmap=meshmat.texmap_reflection
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.specularLevelMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.texmap_reflection
						searchMatDest target origmap matSimple
					)
					
				)
								
				"normal": (
					if (meshmat.texmap_bump!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_bump
						origmap=meshmat.texmap_bump
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.bumpMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					)
					else
					(
						origmap=meshmat.texmap_bump
						searchMatDest target origmap matSimple
					)
				)
				
				"opacity": (
					if (meshmat.texmap_opacity!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_opacity
						origmap=meshmat.texmap_opacity
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.opacityMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.diffuseMap matSimple
					) else
					(
						origmap=meshmat.texmap_opacity
						searchMatDest target origmap matSimple
					)
				)
			)
		)
		
	)
	return matSimple
)

fn applySimpleMat_octane mymesh meshmat matSimple=(
	--format "entramos en el applySimpleMat\n"
	for target in AXYZ_texture_search_names do 
	(
		if ((classof meshmat)== Standardmaterial) then
		(
			case target of
			(
			
				"diffuse": (
					if (meshmat.diffuseMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.diffuseMap
						origmap=meshmat.diffuseMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.diffuseMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						try(matSimple.diffuse_tex.filename = origmap.filename) catch()
					)
				)
				"specular": (
					if (meshmat.specularLevelMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.specularLevelMap
						origmap=meshmat.specularLevelMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.specularLevelMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						try(matSimple.specular_tex.filename = origmap.filename) catch()
					)
				)
				"normal": (
					if (meshmat.bumpMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.bumpMap
						origmap=meshmat.bumpMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.bumpMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						try(
								matSimple.normal_tex.filename = origmap.filename
							) catch()
					)
				)
				"opacity": (
					if (meshmat.opacityMap!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.opacityMap
						origmap=meshmat.opacityMap
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.opacityMap 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						try(matSimple.opacity_tex.filename = origmap.filename) catch()
					)
					else 
					(
						try(matSimple.opacity_input_type=3) catch()
					)
				)
			)
		)
		else --si es vray
		(
			case target of
			(
			
				"diffuse": (
					if (meshmat.texmap_diffuse!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_diffuse
						origmap=meshmat.texmap_diffuse
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.texmap_diffuse 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						) else
						(
							origmap=meshmat.texmap_diffuse
							searchMatDest target origmap matSimple
						)
					)
				)
				"specular": (
					if (meshmat.texmap_reflection!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_reflection
						origmap=meshmat.texmap_reflection
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.texmap_reflection 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						) else
						(
							origmap=meshmat.texmap_reflection
							searchMatDest target origmap matSimple
						)
					)
				)
				"normal": (
					if (meshmat.texmap_bump!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_bump
						origmap=meshmat.texmap_bump
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.texmap_bump 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						) else
						(
							origmap=meshmat.texmap_bump
							searchMatDest target origmap matSimple
						)
					)
				)
				"opacity": (
					if (meshmat.texmap_opacity!=undefined) then
					(
						numsubs= getNumSubtexMaps meshmat.texmap_opacity
						origmap=meshmat.texmap_opacity
						if numsubs>0 then 
						(
							--origmap=getSubTexmap meshmat.texmap_opacity 1
							while numsubs>0 do
							(
								origmap=getSubTexmap origmap 1
								numsubs = getNumSubtexMaps origmap
							)
						)
						cambio=searchMatDest target origmap matSimple
						--if cambio==false then --format "No se cambió en destino el mapa %\nMapa original: %\nMat dest: %\n" target meshmat.texmap_opacity matSimple
					) else
					(
						origmap=meshmat.texmap_opacity
						cambio=searchMatDest target origmap matSimple						
					)
				)
			)
		)
		
	)
	return matSimple
)

fn applyMultiMat mymesh meshmat matMulti=(
	--format "entramos en el applyMultiMat\napplyMultiMat-> procesando multimaterial %\n" matMulti
	--meditmaterials[13]=matMulti
	--vamos a ir emparejando origen y destino
	for mat in meshmat do --para cada material del multimat que viene en la malla...
	(
		if (matchPattern mat.name pattern:"*Cloths*") then --miramos si corresponde con el patrón
		(
			--format "applyMultiMat-> encontrado *cloths* en %\n" mat
			for libmat in matMulti do --para cada material del multimat que viene en la librería del preset...
			(
				if (matchPattern libmat.name pattern:"*Cloths*") then --miramos si corresponde con el patrón
				(
					--format "applyMultiMat-> encontrado *cloths* en origen % y destino %\n" mat libmat
					if ((classof mat) == DirectX_9_Shader) then 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat.renderMaterial libmat
					) else 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat libmat
					)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Skin*") then
		(
			--format "applyMultiMat-> encontrado *skin* en %\n" mat
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Skin*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat.renderMaterial libmat
					) else 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat libmat
					)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Head*") then
		(
			--format "applyMultiMat-> encontrado *head* en %\n" mat
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Head*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat.renderMaterial libmat
					) else 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat libmat
					)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Eyes*") then
		(
			--format "applyMultiMat-> encontrado *eyes*mouth* en %\n" mat
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Eyes*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat.renderMaterial libmat
					) else 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat libmat
					)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Hair*") then
		(
			--format "applyMultiMat-> encontrado *hair* en %\n" mat
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Hair*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat.renderMaterial libmat)
					else 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat libmat)
				)					
			)
		)
		
		else if (matchPattern mat.name pattern:"*Step*") then
		(
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Step*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat.renderMaterial libmat)
					else 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat libmat)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Landing_Metal*") then
		(
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Landing_Metal*") then
				(
					if ((classof mat) == DirectX_9_Shader) then
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat.renderMaterial libmat)
					else 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat libmat)
				)					
			)
		)
		else if (matchPattern mat.name pattern:"*Landing_Plates*") then
		(
			for libmat in matMulti do
			(
				if (matchPattern libmat.name pattern:"*Landing_Plates*") then
				(
					if ((classof mat) == DirectX_9_Shader) then 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat.renderMaterial libmat)
					else 
						for target in AXYZ_texture_search_names do (copyBitmapMulti target mat libmat)
				)					
			)
		)
		else--default!
		(			
			for libmat in matMulti do --para cada material del multimat que viene en la librería del preset...
			(
				if (matchPattern libmat.name pattern:"*Cloths*") then --miramos si corresponde con el patrón
				(
					--format "applyMultiMat-> encontrado *cloths* en origen % y destino %\n" mat libmat
					if ((classof mat) == DirectX_9_Shader) then 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat.renderMaterial libmat
					) else 
					(
						for target in AXYZ_texture_search_names do copyBitmapMulti target mat libmat
					)
				)					
			)
		)
	)		
	
	matMulti
)

fn copysubmat desiredstring sourceMultiSubMtl destMultiSubMtl=
(
	foundinsource=-1
	foundindest=-1
	desiredpattern="*"+desiredstring+"*"
	
	local nmat=getNumSubMtls destMultiSubMtl
	for i=1 to nmat do
	(		
		if (matchPattern destMultiSubMtl.materialList[i].name pattern: desiredpattern) then
		(
			foundindest=i
			local nmatsrc=getNumSubMtls sourceMultiSubMtl
			for i=1 to nmatsrc do
			(		
				if (matchPattern sourceMultiSubMtl.materialList[i].name pattern: desiredpattern) then
				(
					foundinsource=i
					destMultiSubMtl.materialList[foundindest]= copy sourceMultiSubMtl.materialList[foundinsource]
				)
			)
		)
	)		
)

fn AXYZ_MaterialProcessMat matlibpath =(
	
	local matSimpleOrig=undefined
	local matMultiEscalatorOrig=undefined
	local matMultiOrig=undefined
	
	if (doesFileExist matlibpath) then
	(
		mymatlib=matlibLoad matlibpath --cargamos la librería, a partir de ahora "mymatlib"
		if mymatlib==undefined then return messagebox "Can't load selected material library" title:"Error loading preset"
	) 
	else return messagebox "The material library associated to selected preset doesn't exist" title:"Matlib path error"
	
	nummat=mymatlib.count
	if (nummat>3) then 
	(	
		messagebox "Selected material library contains more than 3 materials inside. Only first three materials will be used"
		nummat=3
	)
	for i=1 to nummat do
	(
		cls=(classof mymatlib[i])
		if (cls==multimaterial) then
		(
			if(mymatlib[i].name=="Escalator Material") then
				matMultiEscalatorOrig=mymatlib[i] 
			else
				matMultiOrig=mymatlib[i] 
		)
		else
		(
			matSimpleOrig=mymatlib[i]
		)
		--format "i: % | matsimple: % | matmulti: %\n" i matsimple matmulti
	)
	
	if (matSimpleOrig==undefined) then
		return messagebox "Selected material library has wrong kind of materials.\nIt should contain one simple material (mandatory), one multimaterial (optional) and other multi called 'Escalator Material' (optional)"		
	
	/*if ((matMulti==undefined)) then  
		messagebox "Selected material library has only a single material, it will be applied also to multimaterial characters."*/
	
	num=AXYZ_MaterialMeshes.count
	--format "Número de meshes: %\n" num
	for i=1 to num do
	(		
		local matSimple=copy matSimpleOrig
		local matMultiEscalator=copy matMultiEscalatorOrig
		local matMulti=copy matMultiOrig
		
		
		--format "Procesando malla % | % \n" i AXYZ_MaterialMeshes[i]
		local currmat = AXYZ_MaterialMeshes[i].material
		
		if(((classof currmat)	==Multimaterial) and currmat.name!= "Escalator Material" and  (matMulti==undefined)) then
			currmat=Standardmaterial ()
		
		if(((classof currmat)	==Multimaterial) and currmat.name== "Escalator Material" and  (matMultiEscalator==undefined)) then
			currmat=Standardmaterial ()
		
		cls = classof currmat		
			
		result=undefined		
		case cls of
		(
			(Standardmaterial):(
				if (currentEngine=="Octane Render") then
				(
					result=applySimpleMat_octane AXYZ_MaterialMeshes[i] currmat matSimple
					result.name=AXYZ_MaterialMeshes[i].material.name
				) else
				(
					result=applySimpleMat AXYZ_MaterialMeshes[i] currmat matSimple
					result.name=AXYZ_MaterialMeshes[i].material.name
				)
			)
			(VrayMtl):(
				result=applySimpleMat AXYZ_MaterialMeshes[i] currmat matSimple
				result.name=AXYZ_MaterialMeshes[i].material.name
			)			
			(Multimaterial):(
				if currmat.name!="Escalator Material" then						
					result=applyMultiMat AXYZ_MaterialMeshes[i] currmat matMulti
				else
					result=applyMultiMat AXYZ_MaterialMeshes[i] currmat matMultiEscalator
				
				result.name=AXYZ_MaterialMeshes[i].material.name
			)
			(Shell_Material):(
				if ((classof currmat.originalMaterial)==Multimaterial) then
				(
					result=applyMultiMat AXYZ_MaterialMeshes[i] currmat.originalMaterial matMulti
					result.name=AXYZ_MaterialMeshes[i].material.name
				)
				if ((classof currmat.originalMaterial)==StandardMaterial) then
				(
					if (currentEngine=="Octane Render") then
					(
						result=applySimpleMat_octane AXYZ_MaterialMeshes[i] currmat matSimple
						result.name=AXYZ_MaterialMeshes[i].material.name
					) else
					(
						result=applySimpleMat AXYZ_MaterialMeshes[i] currmat matSimple
						result.name=AXYZ_MaterialMeshes[i].material.name
					)
				)
			)
			(UndefinedClass):(
			)
			default:(MessageBox ("The model "+AXYZ_MaterialMeshes[i].name+" doesn't have a valid material") title:"Mesh material Error")
		) -- end case

		if(result != undefined) then
		(
			if(cls==Multimaterial) then
			(				
				copysubmat "eyes" result AXYZ_MaterialMeshes[i].material
				copysubmat "skin" result AXYZ_MaterialMeshes[i].material
				copysubmat "head" result AXYZ_MaterialMeshes[i].material
				copysubmat "hair" result AXYZ_MaterialMeshes[i].material
				copysubmat "cloths" result AXYZ_MaterialMeshes[i].material
				
				copysubmat "step" result AXYZ_MaterialMeshes[i].material
				copysubmat "landing_metal" result AXYZ_MaterialMeshes[i].material
				copysubmat "landing_plates" result AXYZ_MaterialMeshes[i].material				
			) 
			else
			(
				AXYZ_MaterialMeshes[i].material= copy result
			)
		)
		--showDiffuseTextureOnViewport &currmat
	)--for materials
	
	AXYZ_MaterialMeshes=#()
)

fn AXYZ_MaterialProcessMeshes currentEngine =(

	matlibfile=AXYZ_matfiles[roll_AXYZmats.ddl_preset.selection] --archivo del preset que se ha seleccionado
	--format "matlibfile: %\n" matlibfile
	AXYZ_basepath=getFilenamePath AXYZ_MaterialXML --path base para la libreria de materiales	
	matlibpath=(AXYZ_basepath+matlibfile) --path completo del archivo junto al XML
	AXYZ_MaterialProcessMat matlibpath
)

rollout roll_AXYZmats "aXYZ Material Adapter" width:270 height:100 
(
	label lbl_engine "Render Engine detected: " pos:[15,17] width:120 height:20
	dotNetControl lbl_detected "Windows.Forms.Label" width:150 height:20 pos:[140,17]
	label lbl_preset "Select Material Preset: " pos:[15,40] width:120 height:20
	dropdownlist ddl_preset "" pos:[140,36] items:#() width:120 height:20
	button btn_apply "Apply Materials" pos:[15,70] width:243 height:18
	
	on roll_AXYZmats open do (
		local bkgCol = (colorman.getcolor #background * 255) as color
		lbl_detected.backColor = (dotNetClass "System.Drawing.Color").fromArgb bkgCol.r bkgCol.g bkgCol.b
		lbl_detected.forecolor = (dotNetClass "System.Drawing.Color").fromArgb 117 190 88
	)
	
	on btn_apply pressed do	(
		AXYZ_MaterialProcessMeshes lbl_detected.text
		for i=1 to AXYZ_MeshesSharingMaterial.count do
		(
			for j=2 to AXYZ_MeshesSharingMaterial[i].count do
			(
				AXYZ_MeshesSharingMaterial[i][j].material=AXYZ_MeshesSharingMaterial[i][1].material
			)
		)
		try(destroydialog roll_AXYZmats) catch()
	)
)


fn MainMaterialAdapter MaterialXML MaterialMeshes MeshesSharingMaterial=(
	AXYZ_MaterialXML=MaterialXML
	AXYZ_MaterialMeshes=MaterialMeshes
	AXYZ_MeshesSharingMaterial=MeshesSharingMaterial
	AXYZ_basepath=""
	AXYZ_curr_engine=""
	AXYZ_matnames=#()
	AXYZ_matfiles=#()
	AXYZ_basepath=getFilenamePath AXYZ_MaterialXML --path base para la libreria de materiales	
	r_engine=classof renderers.current as string	
	clearListener()
	xmlLoad AXYZ_MaterialXML
	numengines= AXYZ_mainchilds.count
	for i=1 to numengines do
	(
		attr = AXYZ_mainchilds[i].GetAllAttributes()
		--print attr
		
		search=attr[2][2]
		searcharr=filterString search "@"
		--print searcharr
		if searcharr.count>1 then
		(
			
			for j=1 to searcharr.count do
			(
				if (matchPattern (r_engine) pattern:searcharr[j]) then 
				(
					AXYZ_curr_engine=attr[1][2]
					childs=AXYZ_mainchilds[i].GetChildren()
					for k in childs do 
					(
						append AXYZ_matnames (k.GetAttribute "name")
						append AXYZ_matfiles (k.GetAttribute "file")
					)
					--format "Presets encontrados: %\nAchivos encontrados: %\n" AXYZ_matnames AXYZ_matfiles
				)
			)

		) else if (matchPattern (r_engine) pattern:searcharr[1]) then 
			(
				AXYZ_curr_engine=attr[1][2]
				childs=AXYZ_mainchilds[i].GetChildren()
				for k in childs do 
				(
					append AXYZ_matnames (k.GetAttribute "name")
					append AXYZ_matfiles (k.GetAttribute "file")
				)
			)
	)
	if AXYZ_curr_engine=="" then return messagebox "Your current renderer is not supported in the XML definition file" title:"Unsupported renderer"
	--format "Motor detectado: %\n" AXYZ_curr_engine
	try(destroydialog roll_AXYZmats) catch()
	createdialog roll_AXYZmats style:#(#style_sysmenu,#style_toolwindow)
	roll_AXYZmats.lbl_detected.text=AXYZ_curr_engine
	roll_AXYZmats.ddl_preset.items=AXYZ_matnames
	roll_AXYZmats.ddl_preset.selection=1
)	


fn MainMaterialAdapterLib MaterialLibPath MaterialMeshes=(
	AXYZ_MaterialMeshes=MaterialMeshes
	clearListener()
	AXYZ_MaterialProcessMat MaterialLibPath
)	