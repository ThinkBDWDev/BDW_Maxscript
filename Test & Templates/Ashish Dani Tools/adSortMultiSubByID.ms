-------------------------------------------------------------------------

/*
Name				: adSortMultiSubByID
Version			: 1.0.0
Description		: Script to sort the materials within a Multi Sub Object by ID (ascending order)
Type				: GUI
Date Created   	: 2014/12/20
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com


UPDATES			:
					2014/12/22	- Changed the way selection is passed onto the functions.


*/


-------------------------------------------------------------------------



(
 
fn adSortMultiSubByID admat=
(
    
    
    
     -- DECLARE VARIABLES
     local Cntn = 1                    -- Factorial Calculation
     local fact = 1
    
     local Cntk = 1                    -- Top level counter
     local sorted = false               -- Sorting Flag
     local i = 1                              -- Used for ID comparison
     local j = admat.numsubs     -- Condition for ID comparison
    
    
    
     -- Variables to calculate the actual number of materials used.
     local k = 1
     local MatCnt = 0                    -- Counter for number of actual materials
    
    
    
    
     local m = admat
    
 
    
     print(j as string)
    
    
    
     if classof m == MultiMaterial then --Condition to check if it is a multimaterial / multi sub object
     (
         
          print ("This is a multimaterial")
         
         
          -- No of Materials Counter Loop
          --J is numsubs, K is a counter from 1 to numsubs and MatCnt is the count.
          while k <= j do
          (
               --print("Inside Counter loop")
               if m.materialIDList[k] != undefined do
               (
                    MatCnt += 1
               )
               k += 1    
          )
         
          --print ("The Total number of materials used are " + (MatCnt as string))          -- Print Number of Materials Used.
          k = 1          --Reset counter K    
              
        -- Print the materials Used                                      
          while k <= MatCnt do
          (
               --print (m.materialList[k] as string)
               k += 1
          )
         
          MatCnt = MatCnt * MatCnt               -- Square the count to execute loop
         
          k = 1          -- Reset k
 
         
          -- SORTING LOOPS
          while Cntk <= MatCnt do -- PRIMARY COUNTER based on number of Materials USED squared comapred to Cntk
          (
              
               --print("PRIMARY COUNTER                                   " + (Cntk as string))
              
               while sorted == false do
               (
                    sorted = true                              --set the flag to true in the beginning
                    k = 1                                                       -- Reset K to 1 so that it only loops between the no of materials
                   
                   
                    --print ("          Executing Inner Counter")
                    while i < j do                                    --loop though all sub-materials
                    (
                        
                         --print ("               " + (I as string))
                        
                         if m.materialIDList[i] != undefined do
                         (
                              --print("               Inside here     " + (i as string))
                                  
                              if m.materialIDList[i+1] != undefined and m.materialIDList[i] > m.materialIDList[i+1] do
                              (
                                  
                                  
                                   --print("Condition Check")          -- Comparison being executed
                                  
                                   --store the current material in a temp. variable
                                   tmp = m.materialList [k]
                                   --copy the next material into the current one
                                   m.materialList [k] = m.materialList[k+1]
                                   --copy the current material into the next one using the temp var.
                                   m.materialList[k+1] = tmp
                                   --do the same with the material IDs
                                   tmp = m.materialIDList[k]
                                   m.materialIDList[k] = m.materialIDList[k+1]
                                   m.materialIDList[k+1] = tmp
                                   --then copy the states of the enable checkboxes
                                   tmp = m.mapEnabled[k]
                                   m.mapEnabled[k] = m.mapEnabled[k+1]
                                   m.mapEnabled[k+1] = tmp
                                   --and finally switch the places of the user-defined names.
                                   tmp = m.names[k]
                                   m.names[k] = m.names[k+1]
                                   m.names[k+1] = tmp
                                   --set the flag to false as we switched places, ergo sorting goes on
                                  
                                   k += 1
                                   --print ("Value of K is                     " + (k as string))
                                   sorted = false
                              )  
                         )
                         i += 1
                    )
                   
                   
               )
              
               sorted = false
               i = 1
               Cntk += 1
          )
         
     )
    
     print ("DONE")
                messagebox "                  Sorting is DONE " title:"adMultiMaterialIDSorter - www.ashishdani.com"
 
)
 
 
rollout adSortMultiSubByIDRoll "adSortMultiSubByID" width:136 height:160
(
	button adMultiIDSbtn01 "Sort" pos:[16,80] width:104 height:32
	label lbl13 "adSortMultiSubByID" pos:[16,16] width:112 height:16
	
	
	HyperLink cust3 "Web Help" pos:[40,32] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[16,128] width:104 height:24 address:"www.ashishdani.com"
	groupBox grp3 "" pos:[8,64] width:120 height:56
                
	on adMultiIDSbtn01 pressed do
	(
	                print ("Button is Pressed")
	                --sel = selection as array
	                for a in selection do
	                (
	                                adSortMultiSubByID(a.material)
	                )
	)
)
 
 fn adSortMultiSubByIDDefaults =
 (
	createdialog adSortMultiSubByIDRoll ()
 )
 

)