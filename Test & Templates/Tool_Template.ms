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

--Destroy the dialog if it is open. This is here for testing purposes. 
try(destroyDialog myTool.instUI;myTool.instUI=undefined)catch()

--Structure containing the tool
struct myTool
(
	testR=undefined,
	
	fn doSomething=
	(
		print "Do Something"
	),
	
	fn menu=
	(
		rcMenu myMenu
		(
			menuItem closeMnu "Close"
			menuItem testMnu "Test"
			
			on closeMnu picked do myTool.run()
			on testMnu picked do myTool.doSomething()
		)
	),
	
	fn ui=
	(
		rollout testR "Test"
		(
			
			on testR close do 
			(
				myTool.testR=undefined
			)
		)
	),
	
	fn run=
	(
		if testR==undefined then
		(
			ui()
			createDialog testR menu:(menu())
		)else
		(
			destroyDialog testR
			testR=undefined
		)
	),
	
	/*CommentStart*******************************************************
	This is here so that other tools can retreive the rollouts from this tool and display
		them in another UI
	*******************************************************CommentEnd*/
	fn getRollouts=(#(ui())),
		
	/*CommentStart*******************************************************
	MacroScript definition
		Will not work if you are encrypting your scripts
	*******************************************************CommentEnd*/
	macro=
	(
		macroScript myToolMacro 
			category:"My Tools"
		(
			on execute do 
			(
				if myTool!=undefined do 
				(
					myTool.run()
				)
			)
		)
	)
)
myTool=myTool()
myTool.run() --Just here for testing. 