-------------------------------------------------------------------------

/*
Name				: adDetachBasedOnFaceID
Version			: 1.0.0
Description		: Separates the object based on face IDs
Type				: GUI
Date Created   	: 2015/07/27
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 

*/


-------------------------------------------------------------------------
(

global L = 1

fn adMatIDUniqueFinder obj=
(
      
    local p = obj.numfaces
    local k = 1
    local c = 1 
	local MatID = 1
	local MatIDUniqueArray = #()
    
	while k <= p do
	(
         
		--print ("Value of K is      " + (k as string))
		--print ("Value of P is      " + (p as string))               
         
		MatID = polyop.getFaceMatID obj k
        
		--MatIdUniqueArray = append MatIdUniqueArray (matID as integer)                     -- WORKING !!
		appendIfUnique MatIDUniqueArray (matID as integer)

		c += 1
		k += 1
	)
	
	k = 1
	sort MatIDUniqueArray
	return MatIDUniqueArray
 
)                              -- adMATIDUniqueFinder ENDS


-- Reads the Material Assigned Based on the ID provided
fn adReadOldShaderAssigned mat id=
(
     local subMaterialName
    
     if classof mat == MultiMaterial then
     (
         
          if mat.materialList[id] != undefined then
          (
               subMaterialName = (mat.names[id]) as string
               --print (subMaterialName as string)
          )
          else if mat.materialList[id] == undefined or mat.materialList[id] == " " do
          (
               subMaterialName = "NoName"
          )    
     )
     else if classof mat != MultiMaterial do
     (
          subMaterialName = "Not MultiMaterial"
     )
    

     return subMaterialName
    
)




-- Checks if Material is a MultiMaterial and return the Name of the associated ID
fn adIfMatPresent mat id=
(
    
     local matPresentFlag = true
    
     if classof mat == MultiMaterial then
     (
          if mat.materialList[id] != undefined then
          (
               matPresentFlag = true
          )
          else if mat.materialList[id] == undefined do
          (
               matPresentFlag = false
          )
     )
     else if classof mat != MultiMaterial do
     (
          matPresentFlag = false
     )
    
     return matPresentFlag
)



fn adFacesDetachByID obj Fid=
(
	local k = 1
	local p = obj.numfaces
	local nMatID = 1
	local FaceSelArray = #()
	local matname
	
	
	while k <= p do
	(
		nMatID = polyop.getFaceMatID obj k
		if nMatID == Fid do
		(
			print ("\t\t\tID Match\t" + (Fid as string) +"\t" + (k as string))
			append FaceSelArray k
		)
		k += 1
	)
	
	
	--polyop.detachFaces obj FaceSelArray asNode:true name:"obj1"
	
	-- Get the Name of the Material assiciated with that ID
	if (adIfMatPresent obj.mat Fid ) == True do
	(
		matname = adReadOldShaderAssigned obj.mat Fid
		print ("\t\tThe Name of the Object is:\t" + (matname as string))
		
		polyop.detachFaces obj FaceSelArray asNode:true name:matname
	)
	if (adIfMatPresent obj.mat Fid) == False do
	(
		if obj.mat != undefined do
		(
			matname = obj.mat.name
			polyop.detachFaces obj FaceSelArray asNode:true name:matname
		)
		if obj.mat == undefined do
		(
			matname = ("obj" + (L as string))
			L += 1
			polyop.detachFaces obj FaceSelArray asNode:true name:matname
		)
	)
	
	
)

 

rollout adDetachBasedOnfaceIDRollout "adDetachBasedOnfaceID" width:136 height:144
(
	button btnDth "Detach" pos:[24,56] width:88 height:40
	label lbl01 "adDetachBasedOnfaceID" pos:[8,8] width:120 height:24
	HyperLink cust3 "Web Help" pos:[40,24] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[16,112] width:104 height:24 address:"www.ashishdani.com"
	groupBox grp10 "" pos:[8,40] width:120 height:64
	
	on btnDth pressed do
	(
		for i in $ do
		(
		--print ("Values are\n" + (adMatIDUniqueFinder(i) as string))
		matIDList = adMatIDUniqueFinder(i)
		k = 1
			while k <= matIDList.count do
			(
				-- Pass ID one by one to Detach Function
				adFacesDetachByID $ matIDList[k]
				k += 1	
			)
		)
	)
)



fn adDetachBasedOnfaceIdDefaults =
(

	createdialog adDetachBasedOnfaceIDRollout()
	

)






)


