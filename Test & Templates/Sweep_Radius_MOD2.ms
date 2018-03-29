for i in geometry where superclassof  i == GeometryClass do
(
	i.modifiers[#Sweep].CurrentBuiltInShape = 2
-- 	
	i.modifiers[#Sweep][#Bar_Section].length = 30.3
	i.modifiers[#Sweep][#Bar_Section].width = 30.3

	
	)
-- 	$.modifiers[#Sweep].CurrentBuiltInShape = 2