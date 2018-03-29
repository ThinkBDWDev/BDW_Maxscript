/*HeaderStart*******************************************************
:Created By:			Rodri Garcia
:Company:				Rodri Garcia
:Site:					http://rgarcia-digitaldesign.com
:Email:				info@rgarcia-digitaldesign.com
:Client:				
:Purpose:

:History:
	V:0.00.01A 
		Getting started. 
:Todo:
:Bugs:
:Tests:
*******************************************************HeaderEnd*/


try(destroyDialog RenderM)catch()
rollout RenderM "Render Manager"
(

	dotNetControl Button1 "system.windows.forms.button" --Width:150 height:100 Text:"Button\nTest" TextAlign:Alg2 background:ColorBt flatstyle:bt1App
	
	
	
	on Button1 mouseDown senderArg arg do
	(
		if arg.button==arg.button.left then
		(
			senderArg.backColor=senderArg.backColor.red
		)
	)
	on Button1 mouseUp senderArg arg do
	(
		if arg.button==arg.button.left then
		(
			senderArg.backColor=senderArg.backColor.fromArgb 128 128 128
		)
	)
	
	on Button1 mouseEnter senderArg arg do
	(
		senderArg.backColor=senderArg.backColor.green
	)
	on Button1 mouseLeave senderArg arg do
	(
		senderArg.backColor=senderArg.backColor.fromArgb 128 128 128
	)
		
	
	
		on RenderM open do
		(
			--## Button1 Settings##
			Button1.Width = 140
			Button1.height = 50 
			
-- 			Button1.UseWaitCursor = true
			
			Button1.Text = "Button\nTest"
			Button1.flatStyle=(dotNetClass "System.Windows.Forms.FlatStyle").flat
			Button1.TextAlign =  (dotNetClass "System.Drawing.ContentAlignment").middlecenter
			Button1.forecolor = (dotNetClass "System.Drawing.color").fromArgb 255 255 255
			Button1.backcolor = (dotNetClass "System.Drawing.color").fromArgb 128 128 128
		)	
)
createdialog RenderM Width:160 height:250
	
	