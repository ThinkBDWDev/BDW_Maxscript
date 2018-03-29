/*
Quick VRay Physical Camera
 Version: 1.0  
Created: first release 2015-08-17
Last Modified: 2015-08-17
Support Version: 3dsmax 2016 and hight 32/64bit
Author: Marcelli Michele
Code by Marcelli Michele
E-mail: Medal71@Hotmail.it

----------------------------------------- 
This Script allows to create a VRay Physical Camera in 3dsmax2016 with Vray 3.2 (hidden default)
----------------------------------------- 
Change Log v.1.0
----------------------------------------- 
Terms of use: 

The use of the script is an "As is". 
The author assumes no liability with regard to any kind of damage (hardware and software) caused by the use of this script. 
Are not responsible for any damage or cancellation or modification of the work, files, crash and or any problem in 3dsMax or 
computer. So if you installed the script,you accept the above conditions and declines any my responsibility. 
-----------------------------------------
--*****************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK ANS SAVE YOUR WORK BEFORE USE THE SCRIPT
-- Please feel free to modify this code, but let me know so that I can benefit from the changes as well
-- Modify added, must be e-mailed to  Medal71@hotmail.it 
--*****************************************************************************************
Please let me know any bug or error!!!! 
*/

try(destroydialog :: vraypc) catch()

rollout vraypc "Quick VRay Physical Camera" width:432 height:96
(
	
	global vr, obj
	
	fn cam_filt obj = classof obj == VRayPhysicalCamera

	groupBox grp_createCam "Create..." pos:[8,8] width:176 height:56 
	button cre_vraypc "Create VRay Physical Camera" pos:[16,32] width:160 height:21
	groupBox grp_align "Align..." pos:[192,8] width:232 height:56
	pickbutton pos_targ "Target Obj" pos:[200,32] width:64 height:21 
	pickbutton pos_move "Move VRay Physical Camera" pos:[272,32] width:144 height:21 filter:cam_filt
	
	label lab_info "Quick VRay Physical Camera (for Vray 3.2 and 3dsMax 2016)" pos:[16,72] width:296 height:16 
	button btn_about "About..." pos:[316,72] width:106 height:16 
	
	---
	on cre_vraypc pressed do (vr = vrayCreateVRayPhysicalCamera())
	

	on pos_targ picked obj do
	(
		try (
		Select obj
		toolMode.coordsys #Local
			)catch()
	)
	on pos_move picked obj do
	(
		try (
		toolMode.coordsys #Local
		obj.position = $.position
		obj.rotation = $.rotation
			)catch()
	)
	
	on btn_about pressed do
	(
			rollout _info "About..." width:272 height:176
		(
			label lbl2 "Quick VRay Physical Camera" pos:[68,32] width:220 height:13 
			label lbl3 "by Michele71" pos:[103,50] width:63 height:13 
			label lbl4 "Medal71@hotmail.it" pos:[88,68] width:93 height:13
			label lbl5 "For 3dsMax 2016 (and up) and Vray 3.2" pos:[32,88] width:216 height:13 
			HyperLink mychannelyoutube "My channel YouTube" pos:[83,112] width:102 height:15 color:(color 0 255 0) visitedcolor:(color 0 255 0) address:"http://www.youtube.com/user/Medal71?feature=mhee"
			GroupBox grp2 "About..." pos:[8,8] width:256 height:160
			button btn_exit "Exit" pos:[16,144] width:240 height:16

			on btn_exit pressed do destroydialog _info
		)
		createdialog _info style:#(#style_titlebar, #style_sysmenu, #style_toolwindow, #style_sunkenedge)
	)

)
createdialog vraypc style:#(#style_titlebar, #style_sysmenu, #style_toolwindow, #style_sunkenedge)