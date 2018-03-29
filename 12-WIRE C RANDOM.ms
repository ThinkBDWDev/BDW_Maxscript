	
(
	rollout script "Wire Randomizer"
		(
			button b_2  "Randomize"
			on b_2 pressed do
			(select $*
	for i in selection do
	(i.wirecolor = (color (random 0 254)(random 0 254)(random 0 254)))
--clearselction()
			)
		)
	createdialog script
)
