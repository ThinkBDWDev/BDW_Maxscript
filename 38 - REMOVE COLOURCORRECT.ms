/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: RemoveColourCorrect
:History:V1

:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/
fn RemoveColourCorrect message_box: =
(
--raytrace remove
ColorCor = getClassInstances colorcorrect
if ColorCor.count != 0 then
	(
		if message_box==true then
		(
			if querybox "ColorCorrect Material Found! Do You Want to Remove it?!" then 
				(
					
					for raytinst in ColorCor do (
					MapReplace = raytinst.src_tex
					replaceInstances raytinst MapReplace)
				)
		)
		else
		(
					for raytinst in ColorCor do (
					MapReplace = raytinst.src_tex
					replaceInstances raytinst MapReplace)
		)
)

)

RemoveColourCorrect message_box:true 