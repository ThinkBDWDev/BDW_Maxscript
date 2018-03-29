-------------------------------------------------------------------------

/*
Name				: adXFrogLeafSHDEditor
Version			: 1.0.0
Description		: This script is used to quickly tweak the Leaf Shader. Works only with XFrog Plants with VRay
Type				: GUI
Date Created   	: 2015/03/27
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			:
				2015/03/28 - minor bug fix

*/


-------------------------------------------------------------------------


(





fn LeafShdEditor admat adspnBmp adspnCoat adspnRflF adspnGloF adspnIORF adspnGloB adspnIORB adcpGloFMin adcpGloFMax adcpGloBMin adcpGloBMax adcpTrsMin adcpTrsMax adspnRflB= 
(
     print ("\n          LeafShdEditor          :          Executing Function")

    
     --shdNameString = admat as string
    
     --if ((findString shdNameString "Leaf") != undefined) or ((findString shdNameString "Leaf") != undefined) do
     --(
          --print ("\n" + (shdNameString) + "     is an XFrog Leaf Object")
          --print ("Leaf Shader Connected")
         
         
          adMatL1 = admat
         
         
          ---------------------------------------------------------------------------------------------
          -------------VRAYBUMP Material CHECK ------------------------------------------------
          ---------------------------------------------------------------------------------------------
          if classof adMatL1  == VRayBumpMtl do
          (
               print ("\n                                        VRay Bump Material Detected")
              
               adMatL1.bump_amount = adspnBmp          -- Change Bump Value
              
               -----------------------------------------------------------------------------------------------------------------------------------
               if adMatL1.basemtl != undefined do
               (
                    adMatL2 = adMatL1.basemtl                    -- Add Base material into the variable adMatL2
                    if classof adMatL2 == VRayBlendMtl do     -- Check if it is a VRay Blend Material
                    (
                         print ("\n                                        VRay Blend Material Detected")
                         -- Do Blend Material Changes
                         adMatL2.texmap_blend_multiplier[1] = adspnCoat
                   
                        
                         ---------------------------------------------------------------------------------------------------------------------------
                         if adMatL2.basemtl != undefined do
                         (
                              adMatL3 = admatL2.basemtl
                              if classof adMatL3 == VRay2SidedMtl do
                              (
                                   print ("\n                                        VRay 2 Sided Material Detected")
                                  
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   --------------TRANSLUCENCY Changes--------------------------------------------------------------------------------
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   if adMatL3.texmap_translucency != undefined do
                                   (
                                        adMatL3A = adMatL3.texmap_translucency
                                       
                                        if classof adMatL3A == Falloff do
                                        (
                                             adMatL3A.color1 = adcpTrsMin
                                             --adMatL3A.color
                                             if adMatL3A.map2 != undefined do
                                             (
                                                  adMatL3A1 = adMatL3A.map2
                                                  --print (adMatL3A1)
                                                 
                                                  if classof adMatL3A1 == VRayColor do
                                                  (
                                                       adMatL3A1.color = adcpTrsMax
                                                  )
                                             )
                                        )
                                       
                                   )          -- END Translucency CHanges
                                   ---------------------------------------------------------------------------------------------------------------------------
                                  
                                  
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   -------------FRONT VRay Material-------------------------------------------------------------------------------------
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   if adMatL3.frontMtl != undefined do
                                   (
                                        adMatL4A = adMatL3.frontMtl
                                        if classof adMatL4A == VRayMtl do
                                        (
                                             print ("\n                                        VRay Material FRONT Detected")
                                            
                                             adMatL4A.texmap_reflection_multiplier = adspnRflF          -- FRONT REFLECTION Amount
                                             adMatL4A.reflection_ior                          = adspnIORF          -- FRONT Fresnel IOR
                                            
                                             if adMatL4A.texmap_reflectionGlossiness != undefined do
                                             (
                                                  adMatL4A1 = adMatL4A.texmap_reflectionGlossiness
                                                  if classof adMatL4A1 == Falloff do
                                                  (
                                                       --print ("Front FALLOFF Map")
                                                      
                                                       adMatL4A1.color1 = adcpGloFMin                              -- FRONT Reflection Glossines MIN
                                                       adMatL4A1.color2 = adcpGloFMax                              -- FRONT Reflection Glossines MAX
                                                      
                                                  )     -- END FRONT Falloff Map Adjustments
                                             )         
                                        )          -- END CHECK if VRayMaterial FRONT    
                                   )          -- END CHECK Front Vray Material
                                   ---------------------------------------------------------------------------------------------------------------------------
                                  
                                  
                                  
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   -------------BACK VRay Material---------------------------------------------------------------------------------------
                                   ---------------------------------------------------------------------------------------------------------------------------
                                   if adMatL3.backMtl != undefined do
                                   (
                                        adMatL4B = adMatL3.backMtl
                                        if classof adMatL4B == VRayMtl do
                                        (
                                             print ("\n                                        VRay Material BACK Detected")
                                             --adMatL4B.Reflection           = adcpRflB               -- BACK REFLECTION Color
											adMatL4B.texmap_reflection_multiplier = adspnRflB
                                             adMatL4B.reflection_ior      = adspnIORB          -- BACK Fresnel IOR
                                            
                                             if adMatL4B.texmap_reflectionGlossiness != undefined do
                                             (
                                                  adMatL4B1 = adMatL4B.texmap_reflectionGlossiness
                                                  if classof adMatL4B1 == Falloff do
                                                  (
                                                       --print ("Back FALLOFF MAP")
                                                      
                                                       adMatL4B1.color1 = adcpGloBMin                              -- BACK Reflection Glossines MIN
                                                       adMatL4B1.color2 = adcpGloBMax                              -- BACK Reflection Glossines MAX
                                                  )
                                             )    
                                        )    
                                   )          -- END BACK VRayMaterial CHECK
                                   ---------------------------------------------------------------------------------------------------------------------------
                                  
                                  
                              )
                             
                         )     -- END VRay 2 Sided Material CHECK
                         ---------------------------------------------------------------------------------------------------------------------------
                        
                    )
                   
               )     -- END VRay Blend Material CHECK
               -----------------------------------------------------------------------------------------------------------------------------------
              
              
          )     -- END VRay Bump Material CHECK
         
         
         
     --)          -- END Leaf STRING CHECK
     ---------------------------------------------------------------------------------------------------------------------------
    
     --if ((findString shdNameString "Leaf") == undefined) or ((findString shdNameString "Leaf") == undefined) do
     --(
          --print ("\n" + (shdNameString) + "     Is either not a XFrog Leaf Object or is Incorrectly Named")
     --)
    
)          -- END LeafShdEditor Function









fn adChkForMultiMaterial admat adspnBmp adspnCoat adspnRflF adspnGloF adspnIORF adspnGloB adspnIORB adcpGloFMin adcpGloFMax adcpGloBMin adcpGloBMax adcpTrsMin adcpTrsMax adspnRflB= 
(
     print (adMat)
    
   
    
     --print (n as string)
     --print (adMat)
     --print ("IN FUNCTION")
    
     if classof adMat == multimaterial do
     (
          print ("\n------------------------------------------------------------------------" + "\n" + ("Multimaterial Detected          :          ") + (admat as string) + "\nSearching for sub-materials \n")
          n        = adMat.numsubs               -- Get number of submaterial slots
          m       = 0                                    -- Number of actually used Submaterial Slots
          k         = 1                                    -- Counter
         
         
          while k <= n do
          (
               if adMat.materialList[k] != undefined do
               (
                    m += 1                                  -- Counter to check no of USED materials
                   
                    -- NAME CONDITION CHECK
                    -- IF Condition is MET, then send data to LeafShader
                   
                    shdStr = adMat.names[k]          -- Add name into the string
                   
                   
                    if ((findString shdStr "Leaf") != undefined)  or ((findString shdStr "Leaf0") != undefined) or  ((findString shdStr "Leaf1") != undefined) or ((findString shdStr "Leaf2") != undefined) or ((findString shdStr "Leaf3") != undefined) or
                         ((findString shdStr "Leaf4") != undefined) or ((findString shdStr "Leaf5") != undefined) or ((findString shdStr "Leaf6") != undefined) or ((findString shdStr "Leaf7") != undefined) or ((findString shdStr "Leaf8") != undefined) or ((findString shdStr "Leaf9") != undefined) or          --Leaf
                        
						 
						 -- Branch
						 ((findString shdStr "Branch") != undefined)  or ((findString shdStr "Branch0") != undefined)  or ((findString shdStr "Branch1") != undefined)  or ((findString shdStr "Branch2") != undefined)  or ((findString shdStr "Branch3") != undefined)  or 
						 ((findString shdStr "Branch4") != undefined)  or ((findString shdStr "Branch5") != undefined)  or ((findString shdStr "Branch6") != undefined)  or ((findString shdStr "Branch7") != undefined)  or ((findString shdStr "Branch8") != undefined)  or ((findString shdStr "Branch9") != undefined)  --or
                        ------------------------------------------------------------------------------------------------------
                         
                         
                         then
                         (
                              print ( "\n          " + (adMat.names[k] as string) + "\n")
                             
                              print ("\n          Shader Name match FOUND" + ("\n          Sending shader to Leaf Shader Editor Function\n"))
                              --print (adMat.materialList[k])
                              LeafShdEditor adMat.materialList[k] adspnBmp adspnCoat adspnRflF adspnGloF adspnIORF adspnGloB adspnIORB adcpGloFMin adcpGloFMax adcpGloBMin adcpGloBMax adcpTrsMin adcpTrsMax adspnRflB
                             
                              print ("\n------------------------------------------------------------------------\n\n" )
                             
                         )
                         else
                         (
                              print ( "\n          " + (adMat.names[k] as string) + "\n")

                              print ( "\n          Shader Name match NOT FOUND \n" + "          Proceeding to next\n")

                              print ("\n------------------------------------------------------------------------\n\n" )
                         )
                        
                   
               )          -- END multimaterial undefined
         
               k += 1          -- Increment k
          )
         
     )          --END Check if MultiMaterial
    
    
    
     if classof adMat != multimaterial do
     (
         
          print ("\n------------------------------------------------------------------------" + "\n" + ("     Not a Multimaterial          :          ") + (admat as string))

          --print ("NOT A MULTIMATERIAL")
          shdStr = admat as string
          --print ("Shader IS " + (shdStr))
         
          if ((findString shdStr "Leaf") != undefined)  or ((findString shdStr "Leaf0") != undefined) or  ((findString shdStr "Leaf1") != undefined) or ((findString shdStr "Leaf2") != undefined) or ((findString shdStr "Leaf3") != undefined) or
              ((findString shdStr "Leaf4") != undefined) or ((findString shdStr "Leaf5") != undefined) or ((findString shdStr "Leaf6") != undefined) or ((findString shdStr "Leaf7") != undefined) or ((findString shdStr "Leaf8") != undefined) or ((findString shdStr "Leaf9") != undefined) or          --Leaf         
			  
			  -- Branch
				((findString shdStr "Branch") != undefined)  or ((findString shdStr "Branch0") != undefined)  or ((findString shdStr "Branch1") != undefined)  or ((findString shdStr "Branch2") != undefined)  or ((findString shdStr "Branch3") != undefined)  or 
				((findString shdStr "Branch4") != undefined)  or ((findString shdStr "Branch5") != undefined)  or ((findString shdStr "Branch6") != undefined)  or ((findString shdStr "Branch7") != undefined)  or ((findString shdStr "Branch8") != undefined)  or ((findString shdStr "Branch9") != undefined)  --or
                        
          
          then
          (
               print ( "\n          " + (admat as string))

               print ( "\n          Shader Name match FOUND \n" + "          Sending shader to Leaf Function")

               LeafShdEditor adMat adspnBmp adspnCoat adspnRflF adspnGloF adspnIORF adspnGloB adspnIORB adcpGloFMin adcpGloFMax adcpGloBMin adcpGloBMax adcpTrsMin adcpTrsMax adspnRflB
              
               print ("\n------------------------------------------------------------------------\n\n" )
          )
          else
          (
               print ( "\n          " + (admat as string))

               print ( "\n          Shader Name match NOT FOUND \n" + "          Proceeding to next\n")
              
              
              
               print ("\n------------------------------------------------------------------------\n\n" )
          )
         
         
     )          -- END SINGLE MATERIAL CHECK
    
    
    
    
    
    
)          -- END adChkForMultiMaterial FUNCTION END
























rollout adXFrogLeafSHDEditorRollout "adXFrogLeafSHDEditor" width:496 height:336
(
	GroupBox grp1 "Bump" pos:[8,64] width:136 height:48
	GroupBox grp2 "Coat" pos:[344,64] width:144 height:48
	GroupBox grp3 "Translucency" pos:[160,64] width:168 height:48
	GroupBox grp4 "Front" pos:[8,120] width:232 height:136
	GroupBox grp21 "Glossiness" pos:[16,160] width:216 height:56
	GroupBox grp27 "Back" pos:[256,120] width:232 height:136
	GroupBox grp28 "Glossiness" pos:[264,160] width:216 height:56
    
    
	label lbl1 "Amount" pos:[24,88] width:56 height:16
	label lbl3 "Fresnel IOR" pos:[24,224] width:72 height:16
	label lbl4 "Reflection Map Amount" pos:[24,136] width:128 height:16
	label lbl27 "Min" pos:[24,184] width:16 height:16
	label lbl28 "Max" pos:[96,184] width:24 height:16
	label lbl34 "Fresnel IOR" pos:[272,224] width:72 height:16
	label lbl35 "Reflection Amount" pos:[272,136] width:128 height:16
	label lbl36 "Min" pos:[272,184] width:16 height:16
	label lbl37 "Max" pos:[344,184] width:24 height:16
	label lbl74 "Amount" pos:[360,88] width:56 height:16
	label lbl75 "Min" pos:[176,88] width:16 height:16
	label lbl76 "Max" pos:[248,88] width:24 height:16
    
    
	colorPicker cpGloFMin "" pos:[40,184] width:39 height:16 color:(color 150 150 150) title:""
	colorPicker cpGloFMax "" pos:[120,184] width:39 height:16 color:(color 230 230 230) title:""
	colorPicker cpGloBMin "" pos:[288,184] width:39 height:16 color:(color 115 115 115) title:""
	colorPicker cpGloBMax "" pos:[368,184] width:39 height:16 color:(color 190 190 190) title:""
	--colorPicker cpRflB "" pos:[368,168] width:39 height:16 color:(color 40 40 40) title:""
	colorPicker cpTrsMin "" pos:[192,88] width:39 height:16 color:(color 0 0 0) title:""
	colorPicker cpTrsMax "" pos:[272,88] width:39 height:16 color:(color 255 255 255) title:""
    
    
	spinner spnBmp "" pos:[80,88] width:48 height:16 range:[1,100,30] type:#float scale:1
	spinner spnCoat "" pos:[416,88] width:48 height:16 range:[1,100,50] type:#float scale:1
	spinner spnRflF "" pos:[176,136] width:48 height:16 range:[0,100,100] type:#float scale:1
	spinner spnGloF "" pos:[176,184] width:48 height:16 range:[0,100,100] type:#integer scale:1
	spinner spnIORF "" pos:[176,224] width:48 height:16 range:[1,10,2.25] type:#float scale:1
	spinner spnGloB "" pos:[424,184] width:48 height:16 range:[0,100,100] type:#integer scale:1
	spinner spnIORB "" pos:[424,224] width:48 height:16 range:[1,10,1.75] type:#float scale:1
	spinner spnRflB "" pos:[424,136] width:48 height:16 range:[0,100,100] type:#float scale:1
    
    
    
	button btnApply "Apply" pos:[184,264] width:128 height:32
    
    
    
    
	label lbl150 "adXFrogLeafShdEditor" pos:[192,8] width:112 height:16
	
	HyperLink cust3 "Web Help" pos:[224,32] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[200,304] width:104 height:24 address:"www.ashishdani.com"
	
	on btnApply pressed do
	(
	     print ("APPLY")
	     if $ != undefined do
	     (
	          for a in $ do
	          (
	               if (classof a == PolyMeshObject) or  (classof a == Editable_mesh) or (classof a == Editable_Poly) do
	               (
	                    adChkForMultiMaterial a.mat spnBmp.value spnCoat.value spnRflF.value spnGloF.value spnIORF.value spnGloB.value spnIORB.value cpGloFMin.color cpGloFMax.color cpGloBMin.color cpGloBMax.color cpTrsMin.color cpTrsMax.color spnRflB.value
	                    --LeafShdEditor a.mat spnBmp.value spnCoat.value spnRflF.value spnGloF.value spnIORF.value spnGloB.value spnIORB.value cpGloFMin.color cpGloFMax.color cpRflB.color cpGloBMin.color cpGloBMax.color cpTrsMin.color cpTrsMax.color
	               )
	               --else
	               --(
	                    --messagebox "Please select either Editable Mesh or Editable Poly Objects" title:"adXFRLeafShdEditor :: Warning"
	               --)
	          )
	     )
	    
	)
)


fn adXFrogLeafSHDEditorDefaults=
(
createdialog adXFrogLeafSHDEditorRollout
)




)
