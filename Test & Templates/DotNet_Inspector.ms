fn FormatProps sender option:#All=
(
	clearlistener()
	if classOf sender ==dotNetObject or classOf sender==dotnetclass then
	(
		if option==#all or option==#constructor do
		(
			format "\nConstructors************************************:\n"
			dotnet.showConstructors sender
		)
		if option==#ALL or option==#properties do
		(
			format "Properties************************************:\n"
			showProperties sender
		)
		if option==#ALL or option==#methods do
		(
			format "\nMethods************************************:\n"
			showMethods sender
		)
		if option==#ALL or option==#events do
		(
			format "\nEvents************************************:\n"
			showEvents sender
		)
	)else(format "Not a DotNetObject or DotNetClass!: %\n" sender)
)



FormatProps sender