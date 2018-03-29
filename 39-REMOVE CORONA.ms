/*HeaderStart*******************************************************
:Created By: Simon Odds
:Company:ThinkBDW
:Site:
:Email:
:Client:
:Purpose: Find CoronaMtl, Find 
:History:V1

:Todo: make iti larger tool
:Bugs:
:Tests:
*******************************************************HeaderEnd*/


(
local mats =#()

for o in geometry do 
(
	if classof o.material == CoronaMtl do 
		(
			append mats o
		)
	
	
	if classof o.material == Multimaterial then 
	for m = 1 to o.material.numsubs do
	(
		if classof o.material [m] == CoronaMtl do
		(
			append mats o
		)
	)
)

if mats.count != 0 then
(

	sme.Open()-- open editor
	NodeCount = sme.GetNumViews() as string
	makeview = sme.CreateView ("Found" + NodeCount)
	NewView = sme.GetView makeview
		
	for i = 1 to mats.count do
	(
	  NewView.CreateNode mats[i].material[0,0]
	)

	actionMan.executeAction 369891408 "40060"  -- SME: Lay Out All

	Found = mats.count as string
	messagebox (Found + " Materials Found!")

)
else (messagebox "no Materials Found!")

)
