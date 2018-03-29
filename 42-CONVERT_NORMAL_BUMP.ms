/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: ConvertNormals
:History:V1

:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/

fn StNormalToVrayNormal message_box:false =
(
NormalBumpStandard = getClassInstances Normal_bump 

if NormalBumpStandard.count != 0 then
	(
		if message_box==true then
		( 
			
		if querybox "Normal maps found, would you like to convert to Vray Normal ?!" then 
		(
			for o in NormalBumpStandard do 
			(
				--add messagebox##
				vrayNorm = VrayNormalmap()
				vrayNorm.normal_map = o.normal_map
				vrayNorm.bump_map = o.bump_map
				
				vrayNorm.normal_map_multiplier = o.mult_spin
				vrayNorm.bump_map_multiplier = o.bump_spin
				
				vrayNorm.flip_red = o.flipred
				vrayNorm.flip_green = o.flipgreen
				vrayNorm.swap_red_and_green = o.swap_rg
				
				replaceInstances o vrayNorm
				
				
			)
			messagebox "Normal maps converted"
		)
		
	 )else
	 (
		 for o in NormalBumpStandard do 
			(
				--add messagebox##
				vrayNorm = VrayNormalmap()
				vrayNorm.normal_map = o.normal_map
				vrayNorm.bump_map = o.bump_map
				
				vrayNorm.normal_map_multiplier = o.mult_spin
				vrayNorm.bump_map_multiplier = o.bump_spin
				
				vrayNorm.flip_red = o.flipred
				vrayNorm.flip_green = o.flipgreen
				vrayNorm.swap_red_and_green = o.swap_rg
				
				replaceInstances o vrayNorm
				
			)
	 )
		
	)
	
)

StNormalToVrayNormal message_box:true
