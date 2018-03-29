-------------------------------------------------------------------------

/*
Name				: adTurboSubDiv
Version			: 1.0.0
Description		: Script to add in a Turbo Smooth modifier (if not present) and change the values.
Type				: GUI
Date Created   	: 2014/12/27
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com


UPDATES			:

Thanks to Neil Blevins (http://www.neilblevins.com/cg_tools/cg_tools.htm) for the base and inpiration

*/


-------------------------------------------------------------------------


 
 
(
 
 
 
 
global RndTimeFlag = true                                            -- Flag to denote if SubDivs will affect RenderTime Only.
 
 
 
fn adSubDiv fnRndTimeFlag fnDispIterations fnRndIterations fnIsolineDisplay=
(
    
    --print ("Inside function adSubDiv")
    if $ == undefined then (MessageBox "Please select at least one object" title:adTSubDiv)
    else
    (
        for i in selection do
        (
            if i.modifiers.count == 0 then                     -- If there are no TS modifiers in stack, add one
            (
                modPanel.addModToSelection (TurboSmooth ()) ui:on
            )
            if i.modifiers.count != 0 then
            (
				for j = 1 to i.modifiers.count do
                (
                    if classof i.modifiers[j] == TurboSmooth then
                    (
      
                        if fnRndTimeFlag == true do
                        (
                            i.modifiers[j].iterations = 0
                            i.modifiers[j].useRenderIterations = true
                            i.modifiers[j].renderIterations = fnRndIterations
                            i.modifiers[j].isolineDisplay = true
                        )
                        if fnRndTimeFlag == false do
                        (
                            i.modifiers[j].iterations = fnDispIterations
                            i.modifiers[j].useRenderIterations = false
                            i.modifiers[j].renderIterations = fnRndIterations
                            i.modifiers[j].isolineDisplay = fnIsolineDisplay
                        )                                                                                                             
               
 
                    )
                )
            )
        )  -- FOR Loop ENDS
    ) -- ELSE ENDS
 
)
 
 
 
rollout  adTurboSubDivRoll "adTurboSubDiv" width:152 height:256
(
	label lblDispIterations "Display" pos:[17,128] width:48 height:16 enabled:false
	edittext edtDispIterations text:"0" pos:[80,128] width:48 height:16 enabled:false
	checkbox chkRenderOnly "Render Time Only" pos:[8,56] width:112 height:16 checked:true
	label lblRenderIterations "Render" pos:[16,152] width:48 height:16
	edittext edtRenderIterations text:"2" pos:[80,152] width:48 height:16
	checkbox chkIsolineDisplay "Isoline Display" pos:[8,80] width:104 height:16 enabled:false
	GroupBox grp19 "Iterations" pos:[8,104] width:136 height:72
	button btnExecute "Run Script" pos:[16,184] width:120 height:32
                
                
                
                local RndChkState = false                             -- Render time ON / OFF Flag based on the checkbox
                local RndIterations = 1
                local DispIterations = 0
                local IsolineDisplay = true
                
                
                
                
	label lbl119 "adTurboSubDiv" pos:[32,8] width:80 height:16
				
				
	HyperLink cust3 "Web Help" pos:[48,24] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[24,224] width:104 height:24 address:"www.ashishdani.com"
                
                
                --edtRenderIterations.text = 2
                
	on chkRenderOnly changed RndChkState do
	(
	    if chkRenderOnly.state == true do                           -- If CHECKED for RenderTime
	    (
	        print ("State is true")
	        RndChkState = true
	        lblDispIterations.enabled = false
	        edtDispIterations.enabled = false
	        RndTimeFlag = true                                                                                         -- Set rendertime flag to TRUE    
	    )
	                
	    if chkRenderOnly.state == false do                          -- If UNCHECKED for RenderTime
	    (
	        print ("State is false")
	        RndChkState = false
	        lblDispIterations.enabled = true
	        edtDispIterations.enabled = true
	        chkIsolineDisplay.enabled = true
	        RndTimeFlag = false
	    )
	                
	)
	on chkIsolineDisplay changed IsolineDisplay do
	(
	    if chkIsolineDisplay.state == true do
	    (
	        IsolineDisplay = true
	        --print ("ISO TRUE")
	    )
	    if chkIsolineDisplay.state == false do
	    (
	        IsolineDisplay = false
	        --print ("ISO False")
	    )
	                
	)
	on btnExecute pressed do
	(
	    print ("button executed")
	    RndIterations = (edtRenderIterations.text as integer)
	    DispIterations = (edtDispIterations.text as integer)
	    adSubDiv RndTimeFlag DispIterations RndIterations IsolineDisplay
	
	)
)
 
fn adTurboSubDivDefaults =
( 
	createdialog  adTurboSubDivRoll ()
)


)
