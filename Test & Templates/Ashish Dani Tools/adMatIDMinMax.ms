-------------------------------------------------------------------------

/*
Name				: adMatIDMinMax
Version			: 1.0.0
Description		: Script to find the minimum and maximum material IDs assigned to an object. Also find out all the oMaterial IDs assigned to polygon fa
Type				: GUI
Date Created   	: 2015/01/01
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 
					2015/01/02	: Changed the way selection is passed onto the functions.

*/


-------------------------------------------------------------------------

  

 
(
 
-- global sel = selection as array
global MatIDValueArray = #()
global MatIDListString = ""
 
 
 
 
fn adMatIDMinFinder obj=
(
                --print ("Inside adMatIFMinFinder")
                
                local p   = obj.numfaces
                local k = 1
                
                local MatID = 1
                local MinID = 999
                
                while k <= p do
                (
                                --print ("Inside primary WHILE Loop")
                                
                                MatID = polyop.getFaceMatID obj k
                                
                                if MatID <= MinID do
                                (
                                                --print ("MatID is Less than current Min, copying value")
                                                MinID = MatID
                                )
                                
                                k += 1
                )
                
                k = 1
                return MinID
                
)                              -- adMatIDMinFinder ENDS
 
 
 
 
 
 
 
fn adMatIDMaxFinder obj=
(
                --print ("Inside adMatIFMaxFinder")
                
                local p   = obj.numfaces
                local k = 1
                
                local MatID = 1
                local MaxID = 1
                
                while k <= p do
                (
                                --print ("Inside primary WHILE Loop")
                                
                                MatID = polyop.getFaceMatID obj k
                                
                                if MatID >= MaxID do
                                (
                                                --print ("MatID is Less than current Min, copying value")
                                                MaxID = MatID
                                )
                                
                                k += 1
                )
                
                k = 1
                return MaxID
                
)                              -- adMatIDMaxFinder ENDS
 
 
 
 
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
 
 
 
 
 
 
 
 
 
rollout MatIDMinMaxRoll "adMatIDMinMax" width:184 height:312
(
	GroupBox grp1 "" pos:[8,56] width:168 height:208
	button btnFindMinMax "Find Min & Max Material IDs" pos:[16,72] width:152 height:24
	GroupBox grp4 "Result" pos:[16,104] width:152 height:152
	label lblMin "Minimum is" pos:[32,128] width:64 height:16
	label lblMax "Maximum is" pos:[32,144] width:64 height:16
	label lblMinVal "" pos:[96,128] width:56 height:16
	label lblMaxVal "" pos:[96,144] width:56 height:16
	label lbl14 "adMatIDMinMax" pos:[48,8] width:88 height:16
                
	label lblOther "All MatID Values Are" pos:[32,168] width:120 height:16
	label lblOtherMatIDValue "" pos:[32,184] width:120 height:56
	
	HyperLink cust3 "Web Help" pos:[64,32] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[40,272] width:104 height:24 address:"www.ashishdani.com"
                
	on btnFindMinMax pressed do
	(
		--print ("BUTTON is pressed")
	                for a in selection do
	                (
	                                
	                                lblMinVal.caption = ((adMatIDMinFinder a) as string)
	                                lblMaxVal.caption = ((adMatIDMaxFinder a) as string)   
	                                
	                                MatIDValueArray = (adMatIDUniqueFinder a)
	                                
	                                
	                                /*
	                                for i in MatIDValueArray do
	                                (
	                                                if MatIDValueArray[i] != undefined do
	                                                (
	                                                                MatIDListString = (" " + (MatIDListString) + (MatIDValueArray[i] as string))
	                                                                --lblOtherMatIDValue.caption = ( " " + ())
	                                                )
	                                ) */
	                                
	                                local v = 1
	                                while v <= MatIDValueArray.count do
	                                (
	                                               
	                                                print (MatIDValueArray[v] as string)
	                                               
	                                                if v == 1 AND MatIDValueArray[v] != undefined then
	                                                (
	                                                                MatIDListString = ((MatIDValueArray[v] as string))
	                                                )
	                                                else if v > 1 AND MatIDValueArray[v] != undefined do
	                                                (
	                                                                MatIDListString = (" " + (MatIDListString) + " , " +(MatIDValueArray[v] as string))
	                                                )
	
	                                                v += 1
	                                )
	                                
	                                lblOtherMatIDValue.caption = MatIDListString
	                                
	                )
	                
	
	                
	                
	)
)
 
 
fn adMatIDMinMaxDefaults =
(
	createdialog MatIDMinMaxRoll()

)



)