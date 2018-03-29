/*Header ***************************

DONT RUN STILL WORKING!!!


 */

Global NoteVar = getAppData rootNode -1000250

 fn FindNotes =
 (
	if NoteVar == undefined then
	(
	setAppData rootNode -1000250 ("")
	NoteVar = getAppData rootNode -1000250
	)	 
 )

--Load notes***********************************
-- fn NoteItems txt =
-- (
-- 	if txt != undefined then  
-- 		(
-- 			txt.text
-- 		
-- 		) else ("")
-- 	
-- )


 try(destroydialog NoteMaker) catch() 

 rollout NoteMaker "File Sticky Notes" height: 500 width: 500
 (
	  DotNetControl TxtBox "System.Windows.Forms.TextBox" pos:[0,0] height:460 width: 500
	  DotNetControl Button_del "System.Windows.Forms.button" width: 110 height: 20 pos:[370,470]

--returns	 
on TxtBox KeyUp s e do 
(setAppData rootNode -1000250 (TxtBox.text)
	NoteVar = getAppData rootNode -1000250
	case e.KeyCode of
		(
			(e.KeyCode.Enter): s.SelectedText = "\r\n"
			
		)
)	


on Button_del MouseDown do
(
	
if queryBox "Do you want to delete Notes?" then 
	(
		deleteAppData rootNode -1000250	
		TxtBox.Clear()
		
	) else ("")
	
)




	 
 on NoteMaker open do 
 (
	 FindNotes()
	 
	 
	 
	 fontStyle = dotNetClass "system.drawing.fontStyle"
	 
	 --Button options***********************************
	 Button_del.BackColor = Button_del.BackColor.Gray
	 Button_del.text = "Delete Notes"
	 Button_del.ForeColor = Button_del.ForeColor.white
	 Button_del.FlatStyle = Button_del.FlatStyle.flat
	 Button_del.font = (dotnetobject "System.Drawing.Font" "Aerial" 9)
	 Button_del.FlatAppearance.BorderSize = 0
	 
	 --TxtBox options***********************************
	TxtBox.text = (NoteVar as string)
	TxtBox.BorderStyle = TxtBox.BorderStyle.none
	 
	TxtBox.ScrollBars = TxtBox.ScrollBars.Both
	TxtBox.height = 200 
	TxtBox.MultiLine = true
	TxtBox.ForeColor =TxtBox.ForeColor.black
	TxtBox.BackColor =TxtBox.BackColor.LightYellow
	TxtBox.WordWrap = true
	TxtBox.AcceptsReturn = true
	TxtBox.AcceptsTab = true 
	TxtBox.width = 500
	TxtBox.height = 460
	
	--FontSyle = (dotnetclass "System.Drawing.Fontstyle")
-- 	TxtBox.font = FontSyle.bold

	--font
	TxtBox.font = (dotnetobject "System.Drawing.Font" "Aerial" 11 fontStyle.Regular)
) 


on NoteMaker close do
(

If NoteVar == "" then (deleteAppData rootNode -1000250)	
	
)

 ) 
 CreateDialog NoteMaker
 

 