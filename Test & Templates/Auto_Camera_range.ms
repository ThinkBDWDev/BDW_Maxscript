macroScript Set_camera_range

category:"SoddsTools" buttonText:"Camera Range" Tooltip:"Camera Range"

(
actionMan.executeAction 0 "40068"
actionMan.executeAction 0 "40247"

sortKeys $.controller
num_keys = numkeys $.position.controller
StartKey = getkeytime $.position.controller 1
EndKey = StartKey
	
for i = 1 to num_keys do
	
(key_time = getkeytime $.position.controller i
if key_time > EndKey then
EndKey = key_time)

animationRange = interval StartKey EndKey
clearSelection()

messageBox "Range Set")