-------------------------------------------------------------------------

/*
Name				: adGroupUtilities
Version			: 1.0.0
Description		: 3Ds Max Group Operations
Type				: GUI
Date Created   	: 2015/07/27
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 

*/


-------------------------------------------------------------------------

(




rollout adGroupUtilitiesRollout "adGroupUtilities" width:192 height:184
(
	button btnOpn "Open" pos:[16,56] width:72 height:32
	button btnCls "Close" pos:[16,96] width:72 height:32
	button btnGrp "Group" pos:[104,56] width:72 height:16
	button btnUGr "Ungroup" pos:[104,72] width:72 height:16
	button btnAth "Attach" pos:[104,88] width:72 height:16
	button btnDth "Detach" pos:[104,104] width:72 height:16
	button btnExp "Explode" pos:[104,120] width:72 height:16
	GroupBox grp1 "" pos:[8,40] width:88 height:104
	label lbl1 "adGroupUtilities" pos:[56,8] width:80 height:16
	HyperLink cust3 "Web Help" pos:[72,24] width:48 height:24 address:"http://www.ashishdani.com/adtools_max/"
	HyperLink cust2 "www.ashishdani.com" pos:[40,152] width:104 height:24 address:"www.ashishdani.com"
	
	
	
	
	
	
	
	GroupBox grp11 "" pos:[96,40] width:88 height:104
	on btnOpn pressed do
	(
		if $ != undefined then
		(
			max group open
		)	
	)
	on btnCls pressed do
	(
		if $ != undefined then
		(
			max group close
		)	
	)
	on btnGrp pressed do
	(
		if $ != undefined then
		(
			max group group
		)	
	)
	on btnUGr pressed do
	(
		if $ != undefined then
		(
			max group ungroup
		)	
	)
	on btnAth pressed do
	(
		if $ != undefined then
		(
			max group attach
		)	
	)
	on btnDth pressed do
	(
		if $ != undefined then
		(
			max group detach
		)	
	)
	on btnExp pressed do
	(
		if $ != undefined then
		(
			max group explode
		)	
	)
)

fn adGroupUtilitiesDefaults =
(

	createdialog adGroupUtilitiesRollout()
	

)







)