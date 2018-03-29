macroScript BFC category:"BDW" tooltip:"Backface Culling OFF" Icon:#("BFC",1)
(

obj = #()
obj = Geometry


for i=1 to obj.count do(

if (obj[i].backfaceCull==true) then
obj[i].backfaceCull = false
	
)
)