try destroyDialog DigiClock catch()
rollout DigiClock "DigiClock"
(
	local timeSpan = dotNetClass "TimeSpan"
	local formatStr = "hh' : 'mm' : 'ss"

	timer clock interval:1000
	label l_time "00 : 00 : 00" align:#center

	on clock tick do l_time.text = (timeSpan.FromSeconds clock.ticks).ToString formatStr
)
createDialog DigiClock width:90 height:26