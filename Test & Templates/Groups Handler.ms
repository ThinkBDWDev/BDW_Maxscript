fn openGroups = 
(
	--loop into selected object
	for obj = objects do
	(
		--to find group end open it
		if isGroupHead obj then setGroupopen obj true
	)
)
openGroups() 

fn CloseGroups = 
(
	--loop into selected object
	for obj = objects do
	(
		--to find group end open it
		if isGroupHead obj then setGroupopen obj False
	)
)
CloseGroups()