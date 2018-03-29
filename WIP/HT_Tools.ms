/*HeaderStart*******************************************************
:Created By: Rodri garcia	
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose:
:History:V:0.1

:Todo:
:Bugs: 
:Tests:

*******************************************************HeaderEnd*/


try(destroyDialog HT_Tools)catch()

rollout HT_Tools "HT Tools" (

	Button SaveHT "Save HT" height:50 width:50
    -- Rollout body.
)

createDialog HT_Tools width:100 height:250 style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)
