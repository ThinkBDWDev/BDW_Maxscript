groups = for o in helpers where isGroupHead o collect o
while groups.count > 0 do
(
	ungroup groups[groups.count] ; groups.count = groups.count-1
)