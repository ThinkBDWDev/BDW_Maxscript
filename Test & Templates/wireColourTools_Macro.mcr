macroScript WireColourTools
category:"Daves Tools"
tooltip:"Wire Colour Tools"
buttontext:"Wire Colour Tools"
silentErrors:False
(
	on execute do ( -- run script
		local scriptfile = "\\wireColourTools.ms"
		filein ((getdir #scripts) + scriptfile)
	)
)
